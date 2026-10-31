//
//  ServicesStoreKitService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import Foundation
import StoreKit
import Observation

/// Loads and purchases the Tip Jar consumables.
///
/// Tips are consumables: they unlock nothing and are never "owned", so there is
/// nothing to restore. Every verified transaction is finished immediately.
@MainActor
@Observable final class StoreKitService {

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        /// Products could not be fetched, or none of the IDs exist in App Store Connect.
        case failed(String)
    }

    enum PurchaseOutcome: Equatable {
        case success(productID: String)
        case cancelled
        /// Waiting on Ask to Buy / Strong Customer Authentication. Will arrive via `Transaction.updates`.
        case pending
    }

    static let productIDs = ["tip_small", "tip_medium", "tip_large"]

    private(set) var products: [Product] = []
    private(set) var loadState: LoadState = .idle
    private(set) var lastPurchasedProductID: String?

    var isLoading: Bool { loadState == .loading }

    /// Only written in `init` and read in `deinit`, so it is safe to touch from the nonisolated deinit.
    @ObservationIgnored nonisolated(unsafe) private var transactionListenerTask: Task<Void, Never>?

    init() {
        transactionListenerTask = listenForTransactions()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Products

    func loadProducts() async {
        guard loadState != .loading else { return }
        loadState = .loading
        do {
            let fetched = try await Product.products(for: Self.productIDs)
            products = fetched.sorted { $0.price < $1.price }
            if products.isEmpty {
                // StoreKit returns an empty array (not an error) when the IDs are unknown
                // to App Store Connect or the products are not available yet.
                print("StoreKit: no products returned for \(Self.productIDs)")
                loadState = .failed(String(localized: "tips_unavailable_description"))
            } else {
                loadState = .loaded
            }
        } catch {
            print("StoreKit load products error: \(error)")
            products = []
            loadState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Purchasing

    /// Purchases using StoreKit directly. Prefer `handle(_:)` with SwiftUI's
    /// `@Environment(\.purchase)` from views so the payment sheet attaches to the right scene.
    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        try await handle(product.purchase())
    }

    /// Verifies and finishes a purchase result, returning what the UI should show.
    func handle(_ result: Product.PurchaseResult) async throws -> PurchaseOutcome {
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            lastPurchasedProductID = transaction.productID
            await transaction.finish()
            return .success(productID: transaction.productID)
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .cancelled
        }
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

    /// Finishes transactions that complete outside a direct purchase call
    /// (e.g. approved Ask to Buy, or interrupted purchases on relaunch).
    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let transaction = try? self.checkVerified(result) {
                    self.lastPurchasedProductID = transaction.productID
                    await transaction.finish()
                }
            }
        }
    }
}
