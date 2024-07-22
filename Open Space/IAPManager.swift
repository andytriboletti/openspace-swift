import Foundation
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()

    var products: [SKProduct] = []
    private var productsRequest: SKProductsRequest?

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
            ProductIdentifiers.premiumSubscription
        ]

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    // Delegate method to receive product information
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        print(products.description)
    }

    // Method to get the price of a product
    func getPrice(for productIdentifier: String) -> String? {
        print(products.description)
        print(productIdentifier)
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
        guard let product = products.first(where: { $0.productIdentifier == productIdentifier }) else {
            print("Product not found")
            return
        }

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    // SKPaymentTransactionObserver methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completeTransaction(transaction)
            case .failed:
                failedTransaction(transaction)
            case .restored:
                restoreTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }

    private func fetchReceipt() -> String? {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            return nil
        }
        return receiptData.base64EncodedString(options: [])
    }

    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        // Perform any actions necessary upon successful purchase
        if let receipt = fetchReceipt() {
            OpenspaceAPI.shared.sendReceiptToServer(receipt: receipt, productIdentifier: transaction.payment.productIdentifier) { result in
                switch result {
                case .success:
                    print("Receipt successfully sent to server")
                case .failure(let error):
                    print("Failed to send receipt to server: \(error)")
                }
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            if error.code != .paymentCancelled {
                print("Transaction failed with error: \(error.localizedDescription)")
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        // Perform any actions necessary upon successful restoration
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
