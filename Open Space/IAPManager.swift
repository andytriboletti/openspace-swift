import Foundation
import StoreKit
import UIKit
import FirebaseAuth

/// StoreKit purchases. The game server decides what a purchase is worth: it checks the
/// App Store receipt with Apple and credits each transaction once (see /verifyReceipt in
/// openspace-php). A transaction is only finished after the server has credited it, so a
/// purchase is never lost to a network error: StoreKit keeps unfinished transactions and
/// hands them back on the next launch, and `retryPendingTransactions()` runs after sign-in.
class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()

    var products: [SKProduct] = []
    private var productsRequest: SKProductsRequest?
    /// Transactions currently being sent to the server, so a retry never double-sends.
    private var inFlight = Set<String>()

    func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }

    func requestProducts() {
        let productIdentifiers: Set<String> = [
            ProductIdentifiers.newSphere,
            ProductIdentifiers.refillEnergy,
            ProductIdentifiers.upgradeCargoLimit,
            ProductIdentifiers.upgradeMaxEnergy,
            ProductIdentifiers.upgradePassengerLimit,
            ProductIdentifiers.premiumSubscription,
            ProductIdentifiers.smallMineralPack,
            ProductIdentifiers.largeMineralPack
        ]

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    // Delegate method to receive product information
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }

    // Method to get the price of a product
    func getPrice(for productIdentifier: String) -> String? {
        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
            let priceFormatter = NumberFormatter()
            priceFormatter.numberStyle = .currency
            priceFormatter.locale = product.priceLocale
            return priceFormatter.string(from: product.price)
        }
        return nil
    }

    // Method to initiate the purchase
    func purchaseProduct(with productIdentifier: String) {
        if askGuestToSaveAccount() { return }
        guard let product = products.first(where: { $0.productIdentifier == productIdentifier }) else {
            return
        }

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    /// "Restore Purchases" (required by App Review for the subscription and upgrades).
    func restorePurchases() {
        if askGuestToSaveAccount() { return }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /// Guests save their account (Google or Apple) before buying or restoring, so a purchase
    /// is never tied to a guest game that could be lost. Returns true if it asked.
    private func askGuestToSaveAccount() -> Bool {
        guard Auth.auth().currentUser?.isAnonymous == true else { return false }
        DispatchQueue.main.async {
            guard let top = AccountSaver.topViewController() else { return }
            let alert = UIAlertController(title: "Save your account first",
                                          message: "Purchases belong to your account. Save your guest game with Google or Apple so you never lose what you buy.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
            alert.addAction(UIAlertAction(title: "Save Account", style: .default) { _ in
                AccountSaver.shared.save(from: top) { _ in }
            })
            top.present(alert, animated: true)
        }
        return true
    }

    /// Sends any purchases the server hasn't confirmed yet. Called after sign-in, because
    /// StoreKit may hand over unfinished transactions at launch before the player is signed in.
    func retryPendingTransactions() {
        for transaction in SKPaymentQueue.default().transactions
        where transaction.transactionState == .purchased || transaction.transactionState == .restored {
            process(transaction, restored: transaction.transactionState == .restored, quiet: true)
        }
    }

    // SKPaymentTransactionObserver methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                process(transaction, restored: false, quiet: false)
            case .restored:
                process(transaction, restored: true, quiet: true)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        showMessage(title: "Purchases Restored",
                    message: "Purchases made with this Apple ID have been restored to your account.")
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if (error as? SKError)?.code == .paymentCancelled { return }
        showMessage(title: "Restore Failed", message: error.localizedDescription)
    }

    private func fetchReceipt() -> String? {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            return nil
        }
        return receiptData.base64EncodedString(options: [])
    }

    private func process(_ transaction: SKPaymentTransaction, restored: Bool, quiet: Bool) {
        let productIdentifier = transaction.payment.productIdentifier
        let key = transaction.transactionIdentifier ?? "\(productIdentifier)-\(transaction.hash)"
        guard !inFlight.contains(key) else { return }

        guard let receipt = fetchReceipt() else {
            // No receipt on the device yet; StoreKit will hand the transaction back later.
            return
        }
        inFlight.insert(key)

        OpenspaceAPI.shared.sendReceiptToServer(receipt: receipt, productIdentifier: productIdentifier) { result in
            DispatchQueue.main.async {
                self.inFlight.remove(key)
                switch result {
                case .credited:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    NotificationCenter.default.post(name: .purchaseCompleted, object: nil, userInfo: ["productIdentifier": productIdentifier])
                case .alreadyCredited:
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .rejected(let message):
                    // A restored item the server won't credit (for example an expired
                    // subscription) is done. A new purchase stays queued and is retried.
                    if restored {
                        SKPaymentQueue.default().finishTransaction(transaction)
                    } else if !quiet {
                        self.showMessage(title: "Purchase Not Confirmed", message: message)
                    }
                case .retryLater:
                    if !quiet {
                        self.showMessage(title: "Purchase Pending",
                                         message: "Your purchase went through, but the game server couldn't confirm it yet. It will be added automatically the next time you open the game.")
                    }
                }
            }
        }
    }

    private func showMessage(title: String, message: String) {
        DispatchQueue.main.async {
            let window = UIApplication.shared.delegate?.window ?? nil
            guard var top = window?.rootViewController else { return }
            while let presented = top.presentedViewController { top = presented }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            top.present(alert, animated: true)
        }
    }
}
