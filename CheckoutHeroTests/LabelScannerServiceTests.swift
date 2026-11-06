//
//  LabelScannerServiceTests.swift
//  CheckoutHeroTests
//

import Foundation
import Testing
@testable import CheckoutHero

@MainActor
@Suite("LabelScannerService parsing")
struct LabelScannerServiceTests {

    @Test func readsNameAndPriceFromLabel() {
        let parsed = LabelScannerService.parse(lines: ["Whole Milk 1L", "$3.49"])
        #expect(parsed.productName == "Whole Milk 1L")
        #expect(parsed.price == Decimal(string: "3.49"))
        #expect(parsed.currencySymbol == "$")
    }

    @Test func readsCommaPriceWithTrailingSymbol() {
        let parsed = LabelScannerService.parse(lines: ["Queso Manchego", "12,50 €"])
        #expect(parsed.price == Decimal(string: "12.50"))
        #expect(parsed.currencySymbol == "€")
    }

    @Test func picksTheLargestPrice() {
        let parsed = LabelScannerService.parse(lines: ["Olive Oil", "per 100ml 0.89", "8.99"])
        #expect(parsed.price == Decimal(string: "8.99"))
    }

    @Test func priceLineIsNotUsedAsProductName() {
        let parsed = LabelScannerService.parse(lines: ["Eggs", "Special offer price 2.99"])
        #expect(parsed.productName == "Eggs")
    }

    @Test func handlesUnreadableLabels() {
        let parsed = LabelScannerService.parse(lines: [])
        #expect(parsed.productName == nil)
        #expect(parsed.price == nil)
        #expect(parsed.rawText.isEmpty)
    }
}
