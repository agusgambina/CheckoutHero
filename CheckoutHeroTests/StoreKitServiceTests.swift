//
//  StoreKitServiceTests.swift
//  CheckoutHeroTests
//
//  Exercises the Tip Jar against the local StoreKit.storekit configuration.
//

import Foundation
import StoreKit
import StoreKitTest
import Testing
@testable import CheckoutHero

@MainActor
@Suite("StoreKitService (Tip Jar)", .serialized)
struct StoreKitServiceTests {

    private let session: SKTestSession

    init() throws {
        session = try SKTestSession(configurationFileNamed: "StoreKit")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.askToBuyEnabled = false
        session.clearTransactions()
    }

    // MARK: - Loading

    @Test func loadsAllThreeTipsSortedByPrice() async {
        let service = StoreKitService()
        await service.loadProducts()

        #expect(service.loadState == .loaded)
        #expect(service.products.map(\.id) == ["tip_small", "tip_medium", "tip_large"])
    }

    @Test func tipsAreConsumables() async {
        let service = StoreKitService()
        await service.loadProducts()

        #expect(!service.products.isEmpty)
        #expect(service.products.allSatisfy { $0.type == .consumable })
    }

    @Test func everyProductIDIsInTheStoreKitConfiguration() async throws {
        let products = try await Product.products(for: StoreKitService.productIDs)
        #expect(Set(products.map(\.id)) == Set(StoreKitService.productIDs))
    }

    @Test func loadFailureIsReportedAndRetryRecovers() async throws {
        let service = StoreKitService()
        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .loadProducts)

        await service.loadProducts()
        guard case .failed = service.loadState else {
            Issue.record("Expected .failed, got \(service.loadState)")
            return
        }
        #expect(service.products.isEmpty)

        try await session.setSimulatedError(nil, forAPI: .loadProducts)
        await service.loadProducts()
        #expect(service.loadState == .loaded)
        #expect(service.products.count == 3)
    }

    // MARK: - Purchasing

    @Test func purchaseSucceedsAndFinishesTransaction() async throws {
        let service = StoreKitService()
        await service.loadProducts()
        let small = try #require(service.products.first { $0.id == "tip_small" })

        let outcome = try await service.purchase(small)

        #expect(outcome == .success(productID: "tip_small"))
        #expect(service.lastPurchasedProductID == "tip_small")

        var unfinished = 0
        for await _ in Transaction.unfinished { unfinished += 1 }
        #expect(unfinished == 0, "Consumable tips must be finished so they can be bought again")
    }

    @Test func sameTipCanBePurchasedTwice() async throws {
        let service = StoreKitService()
        await service.loadProducts()
        let medium = try #require(service.products.first { $0.id == "tip_medium" })

        #expect(try await service.purchase(medium) == .success(productID: "tip_medium"))
        #expect(try await service.purchase(medium) == .success(productID: "tip_medium"))
    }

    @Test func purchaseErrorIsThrownToTheCaller() async throws {
        let service = StoreKitService()
        await service.loadProducts()
        let large = try #require(service.products.first { $0.id == "tip_large" })
        try await session.setSimulatedError(.purchase(.purchaseNotAllowed), forAPI: .purchase)
        defer { Task { try? await session.setSimulatedError(nil, forAPI: .purchase) } }

        await #expect(throws: (any Error).self) {
            _ = try await service.purchase(large)
        }
    }

    @Test func askToBuyReturnsPending() async throws {
        let service = StoreKitService()
        await service.loadProducts()
        let small = try #require(service.products.first { $0.id == "tip_small" })
        session.askToBuyEnabled = true
        defer { session.askToBuyEnabled = false }

        #expect(try await service.purchase(small) == .pending)
    }
}
