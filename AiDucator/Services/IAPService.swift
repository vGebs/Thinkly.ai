//
//  IAPService.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-08-25.
//

import Foundation
import StoreKit

@available(iOS 13.0, *)
class InAppPurchasesService: ObservableObject {
    private var inAppPurchases: InAppPurchaseWrapper?
    
    @Published var products: [SKProduct] = []
    private var updates: Task<Void, Never>? = nil
    @Published private(set) var purchasedProductIDs = Set<String>()
    let entitlementManager: EntitlementManager
    
    init(productIdentifiers: Set<String>, entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        
        let callbacks = InAppPurchasesCallbacks(onFetchCompleted: { [weak self] products in
            // handle fetching completed
            for product in products {
                print("product: \(product.localizedTitle) - \(product.price)")
                DispatchQueue.main.async {
                    self?.products.append(product)
                }
            }
        }, onProductsNotFound: { skus in
            // handle product not found
            if let skus = skus {
                for sku in skus {
                    print("Could not find product with sku: \(sku)")
                }
            } else {
                print("product not found")
            }
        }, onPurchaseSucceeded: { product in
            // handle purchase succeeded
            print("purchase succeeded for product: \(product.localizedTitle)")
            
            Task {
                await self.updatePurchasedProducts()
            }
            
        }, onPurchaseFailed: { product, error in
            // handle purchase failed
            print("purchase failed for product: \(product.localizedTitle) - \(error?.localizedDescription ?? "")")
        }, onRestoreCompleted: { transactions in
            // handle restore completed
            for transaction in transactions {
                print("product: \(transaction.payment.productIdentifier)")
            }
            
            Task {
                await self.updatePurchasedProducts()
            }
        }, onRestoreFailed: { error in
            // handle restore failed
            print("restore failed: \(error?.localizedDescription ?? "")")
        })
        
        inAppPurchases = InAppPurchaseWrapper(productIdentifiers: productIdentifiers, callbacks: callbacks)
        self.updates = observeTransactionUpdates()
    }
    
    func purchase(product: SKProduct) {
        inAppPurchases!.purchaseProduct(product)
    }
    
    func restore() {
        inAppPurchases!.restorePurchases()
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                DispatchQueue.main.async {
                    self.purchasedProductIDs.insert(transaction.productID)
                }
            } else {
                DispatchQueue.main.async {
                    self.purchasedProductIDs.remove(transaction.productID)
                }
            }
        }
        DispatchQueue.main.async {
            self.entitlementManager.hasPro = !self.purchasedProductIDs.isEmpty
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "com.bricksquad.thinklyai")!

    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
