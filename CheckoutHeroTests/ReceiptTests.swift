//
//  ReceiptTests.swift
//  CheckoutHeroTests
//

import Foundation
import SwiftData
import Testing
@testable import CheckoutHero

@MainActor
@Suite("Receipt model")
struct ReceiptTests {

    @Test func formatsTotalWithItsOwnCurrency() {
        let receipt = Receipt(total: Decimal(string: "1234.5")!, currencySymbol: "€")
        #expect(receipt.formattedTotal(locale: Locale(identifier: "de_DE")) == "1.234,50 €")
    }

    @Test func syncStatusRoundTrips() {
        let receipt = Receipt()
        #expect(receipt.syncStatus == .pending)
        receipt.syncStatus = .synced
        #expect(receipt.syncStatusRaw == "synced")
    }

    @Test func unknownSyncStatusFallsBackToPending() {
        let receipt = Receipt()
        receipt.syncStatusRaw = "something-else"
        #expect(receipt.syncStatus == .pending)
    }

    @Test func persistsCurrencyAndTotal() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Receipt.self, configurations: config)
        container.mainContext.insert(Receipt(storeName: "Market", total: Decimal(string: "12.10")!, currencySymbol: "£"))
        try container.mainContext.save()

        let saved = try container.mainContext.fetch(FetchDescriptor<Receipt>())
        #expect(saved.count == 1)
        #expect(saved.first?.currencySymbol == "£")
        #expect(saved.first?.total == Decimal(string: "12.10"))
    }

    /// Mirrors the 1.0.4 -> 1.0.5 upgrade: a store written without `Receipt` must open with it.
    @Test func storeFromBeforeReceiptsKeepsItsLists() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("store.sqlite")

        do {
            let config = ModelConfiguration(url: url)
            let old = try ModelContainer(for: ShoppingList.self, ShoppingItem.self, configurations: config)
            let list = ShoppingList(name: "Groceries", currencySymbol: "€")
            old.mainContext.insert(list)
            let item = ShoppingItem(name: "Milk", quantity: 1, unit: "L", pricePerUnit: 2)
            old.mainContext.insert(item)
            list.items.append(item)
            try old.mainContext.save()
        }

        let config = ModelConfiguration(url: url)
        let new = try ModelContainer(for: ShoppingList.self, ShoppingItem.self, Receipt.self, configurations: config)
        let lists = try new.mainContext.fetch(FetchDescriptor<ShoppingList>())
        #expect(lists.count == 1)
        #expect(lists.first?.items.count == 1)
        #expect(try new.mainContext.fetch(FetchDescriptor<Receipt>()).isEmpty)
    }
}

@Suite("Release safeguards")
struct ReleaseSafeguardTests {

    /// The privacy policy says the app sends nothing anywhere. Update it before changing this.
    @Test func googleSheetsSyncStaysOffInShippedBuilds() {
        #expect(GoogleSheetsSyncService.isConfigured == false)
    }
}
