//
//  PersistenceTests.swift
//  CheckoutHeroTests
//

import Foundation
import SwiftData
import Testing
@testable import CheckoutHero

@MainActor
@Suite("SwiftData persistence")
struct PersistenceTests {

    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: ShoppingList.self, ShoppingItem.self, configurations: config)
    }

    private func insertList(itemCount: Int) throws -> ShoppingList {
        let list = ShoppingList(name: "Groceries", currencySymbol: "€")
        context.insert(list)
        for index in 0..<itemCount {
            let item = ShoppingItem(name: "Item \(index)", quantity: 1, unit: "units", pricePerUnit: Decimal(index + 1))
            context.insert(item)
            list.items.append(item)
        }
        try context.save()
        return list
    }

    @Test func savesAndFetchesListWithItems() throws {
        _ = try insertList(itemCount: 3)

        let lists = try context.fetch(FetchDescriptor<ShoppingList>())
        #expect(lists.count == 1)
        #expect(lists.first?.name == "Groceries")
        #expect(lists.first?.currencySymbol == "€")
        #expect(lists.first?.items.count == 3)
        #expect(lists.first?.totalAmount == 6) // 1 + 2 + 3
    }

    @Test func itemsKnowTheirList() throws {
        let list = try insertList(itemCount: 2)
        let items = try context.fetch(FetchDescriptor<ShoppingItem>())
        #expect(items.allSatisfy { $0.shoppingList?.id == list.id })
    }

    @Test func deletingListCascadesToItems() throws {
        let list = try insertList(itemCount: 3)

        context.delete(list)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<ShoppingList>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<ShoppingItem>()) == 0)
    }

    @Test func deletingItemKeepsList() throws {
        let list = try insertList(itemCount: 2)
        let item = list.items[0]

        list.items.removeAll { $0.id == item.id }
        context.delete(item)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<ShoppingList>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<ShoppingItem>()) == 1)
    }

    @Test func checkedStatePersists() throws {
        let list = try insertList(itemCount: 1)
        list.items[0].isChecked = true
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ShoppingItem>())
        #expect(fetched.first?.isChecked == true)
    }
}
