//
//  ServicesStoreKitService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import Foundation
import StoreKit
import Observation

@Observable final class StoreKitService {
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var purchaseError: String?
    private(set) var lastPurchasedProductID: String?

    private var transactionListenerTask: Task<Void, Error>?

    static let productIDs = ["tip_small", "tip_medium", "tip_large"]

    init() {
        transactionListenerTask = listenForTransactions()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await Product.products(for: Self.productIDs)
            products = fetched.sorted { $0.price < $1.price }
        } catch {
            print("StoreKit load products error: \(error)")
            purchaseError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            lastPurchasedProductID = transaction.productID
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func isPurchased(_ id: String) async -> Bool {
        // Consumables are never "owned" persistently
        return false
    }

    // MARK: - Private

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    self.lastPurchasedProductID = transaction.productID
                    await transaction.finish()
                }
            }
        }
    }
}
