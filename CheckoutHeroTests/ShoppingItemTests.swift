//
//  ShoppingItemTests.swift
//  CheckoutHeroTests
//

import Foundation
import Testing
@testable import CheckoutHero

@MainActor
@Suite("ShoppingItem")
struct ShoppingItemTests {

    private func item(
        name: String = "Milk",
        quantity: Double = 1,
        unit: String = "units",
        price: String = "1.00"
    ) -> ShoppingItem {
        ShoppingItem(name: name, quantity: quantity, unit: unit, pricePerUnit: Decimal(string: price)!)
    }

    // MARK: - Totals

    @Test func totalPriceMultipliesQuantityByUnitPrice() {
        #expect(item(quantity: 2, price: "3.50").totalPrice == Decimal(string: "7.00"))
    }

    @Test func totalPriceSupportsFractionalQuantities() {
        #expect(item(quantity: 0.5, unit: "kg", price: "4.50").totalPrice == Decimal(string: "2.25"))
    }

    @Test func totalPriceIsZeroWhenFree() {
        #expect(item(quantity: 3, price: "0").totalPrice == 0)
    }

    // MARK: - Formatting

    @Test func formattedQuantityIncludesUnit() {
        #expect(item(quantity: 2, unit: "kg").formattedQuantity == "2 kg")
    }

    @Test func formattedTotalPriceUsesCurrencySymbol() {
        let result = item(quantity: 2, price: "1.50")
            .formattedTotalPrice(currencySymbol: "$", locale: Locale(identifier: "en_US"))
        #expect(result == "$3.00")
    }

    // MARK: - Validation

    @Test func itemWithNameAndZeroPriceIsValid() throws {
        let sut = item(price: "0")
        #expect(sut.isValid)
        try sut.validate()
    }

    @Test(arguments: ["", "   ", "\n\t"])
    func blankNameIsInvalid(name: String) {
        let sut = item(name: name)
        #expect(!sut.isValid)
        #expect(throws: ShoppingItem.ValidationError.emptyName) { try sut.validate() }
    }

    @Test func negativePriceIsInvalid() {
        let sut = item(price: "-1")
        #expect(!sut.isValid)
        #expect(throws: ShoppingItem.ValidationError.negativePricePerUnit) { try sut.validate() }
    }

    @Test func validationErrorsHaveDescriptions() {
        #expect(ShoppingItem.ValidationError.emptyName.errorDescription?.isEmpty == false)
        #expect(ShoppingItem.ValidationError.negativePricePerUnit.errorDescription?.isEmpty == false)
    }

    // MARK: - Defaults

    @Test func newItemStartsUnchecked() {
        #expect(item().isChecked == false)
    }

    @Test func commonUnitsAreUniqueAndIncludeDefault() {
        #expect(ShoppingItem.commonUnits.contains("units"))
        #expect(Set(ShoppingItem.commonUnits).count == ShoppingItem.commonUnits.count)
    }
}
