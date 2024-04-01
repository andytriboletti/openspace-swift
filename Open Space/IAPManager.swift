//
//  IAPManager.swift
//  Open Space
//
//  Created by Andrew Triboletti on 4/1/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()

    var products: [SKProduct] = []
    private var productsRequest: SKProductsRequest?

    func requestProducts() {
        let productIdentifiers: Set<String> = [ProductIdentifiers.newSphere]
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
        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            print("Product not found")
        }
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

    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        // Perform any actions necessary upon successful purchase
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
