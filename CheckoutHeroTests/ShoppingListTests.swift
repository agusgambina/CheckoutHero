//
//  ShoppingListTests.swift
//  CheckoutHeroTests
//

import Foundation
import Testing
@testable import CheckoutHero

@MainActor
@Suite("ShoppingList")
struct ShoppingListTests {

    /// Milk 2 × 1.50 = 3.00 (checked), Bread 1 × 2.25 = 2.25, Apples 0.5 × 4.00 = 2.00 (checked)
    private func makeList() -> ShoppingList {
        let list = ShoppingList(name: "Groceries", currencySymbol: "$")
        list.items = [
            ShoppingItem(name: "Milk", quantity: 2, unit: "L", pricePerUnit: Decimal(string: "1.50")!, isChecked: true),
            ShoppingItem(name: "Bread", quantity: 1, unit: "units", pricePerUnit: Decimal(string: "2.25")!),
            ShoppingItem(name: "Apples", quantity: 0.5, unit: "kg", pricePerUnit: Decimal(string: "4.00")!, isChecked: true),
        ]
        return list
    }

    @Test func emptyListHasZeroTotals() {
        let list = ShoppingList(name: "Empty")
        #expect(list.totalAmount == 0)
        #expect(list.checkedAmount == 0)
        #expect(list.remainingAmount == 0)
        #expect(list.itemCount == 0)
        #expect(list.checkedItemCount == 0)
    }

    @Test func totalAmountSumsAllItems() {
        #expect(makeList().totalAmount == Decimal(string: "7.25"))
    }

    @Test func checkedAmountSumsOnlyCheckedItems() {
        #expect(makeList().checkedAmount == Decimal(string: "5.00"))
    }

    @Test func remainingAmountIsTotalMinusChecked() {
        #expect(makeList().remainingAmount == Decimal(string: "2.25"))
    }

    @Test func countsItems() {
        let list = makeList()
        #expect(list.itemCount == 3)
        #expect(list.checkedItemCount == 2)
    }

    @Test func togglingAnItemUpdatesTotals() {
        let list = makeList()
        list.items[1].isChecked = true
        #expect(list.checkedAmount == list.totalAmount)
        #expect(list.remainingAmount == 0)
    }

    @Test func formattedAmountsUseListCurrency() {
        let list = makeList()
        let en = Locale(identifier: "en_US")
        #expect(list.formattedTotal(locale: en) == "$7.25")
        #expect(list.formattedCheckedAmount(locale: en) == "$5.00")
        #expect(list.formattedRemainingAmount(locale: en) == "$2.25")
    }

    @Test func defaultCurrencyIsDollar() {
        #expect(ShoppingList(name: "x").currencySymbol == "$")
    }
}
