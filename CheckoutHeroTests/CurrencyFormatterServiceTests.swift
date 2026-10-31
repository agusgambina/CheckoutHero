//
//  CurrencyFormatterServiceTests.swift
//  CheckoutHeroTests
//

import Foundation
import Testing
@testable import CheckoutHero

@MainActor
@Suite("CurrencyFormatterService")
struct CurrencyFormatterServiceTests {

    private let enUS = Locale(identifier: "en_US")
    private let deDE = Locale(identifier: "de_DE")

    // MARK: - format

    @Test func formatsUSDollarsWithPrefixAndGrouping() {
        #expect(CurrencyFormatterService.format(amount: Decimal(string: "1234.5")!, currencySymbol: "$", locale: enUS) == "$1,234.50")
    }

    @Test func formatsEurosWithSuffixInGermanLocale() {
        #expect(CurrencyFormatterService.format(amount: Decimal(string: "1234.5")!, currencySymbol: "€", locale: deDE) == "1.234,50 €")
    }

    @Test func formatsZeroWithTwoDecimals() {
        #expect(CurrencyFormatterService.format(amount: 0, currencySymbol: "$", locale: enUS) == "$0.00")
    }

    @Test func roundsToTwoDecimals() {
        #expect(CurrencyFormatterService.format(amount: Decimal(string: "2.999")!, currencySymbol: "$", locale: enUS) == "$3.00")
    }

    // MARK: - formatWhole

    @Test func formatWholeDropsDecimals() {
        #expect(CurrencyFormatterService.formatWhole(amount: Decimal(string: "1234")!, currencySymbol: "$", locale: enUS) == "$1,234")
    }

    // MARK: - formatCompact

    @Test(arguments: [
        ("999", "$999"),
        ("1500", "$1.5K"),
        ("2000000", "$2M"),
    ])
    func formatCompactAbbreviatesLargeNumbers(input: String, expected: String) {
        #expect(CurrencyFormatterService.formatCompact(amount: Decimal(string: input)!, currencySymbol: "$", locale: enUS) == expected)
    }

    // MARK: - parseAmount

    @Test func parsesDotDecimalInUSLocale() {
        #expect(CurrencyFormatterService.parseAmount("12.50", locale: enUS) == Decimal(string: "12.5"))
    }

    @Test func parsesCommaDecimalInGermanLocale() {
        #expect(CurrencyFormatterService.parseAmount("12,50", locale: deDE) == Decimal(string: "12.5"))
    }

    @Test func parseIgnoresCurrencySymbolAndWhitespace() {
        #expect(CurrencyFormatterService.parseAmount("  $7.25 ", locale: enUS) == Decimal(string: "7.25"))
    }

    @Test(arguments: ["", "abc"])
    func parseReturnsNilForNonNumbers(input: String) {
        #expect(CurrencyFormatterService.parseAmount(input, locale: enUS) == nil)
    }
}

@MainActor
@Suite("NumberInput (typed quantities and prices)")
struct NumberInputTests {

    @Test(arguments: [
        ("1.25", "1.25"), ("1,25", "1.25"), ("3", "3"), ("0", "0"),
        ("0,5", "0.5"), (".5", "0.5"), (",5", "0.5"), ("12.", "12"), (" 7,25 ", "7.25"), ("1234,5", "1234.5"),
    ])
    func parsesDotOrCommaDecimals(input: String, expected: String) {
        #expect(NumberInput.decimal(input) == Decimal(string: expected))
    }

    @Test(arguments: ["", " ", ".", ",", "abc", "1,2,3", "1.234,5", "-1", "1e3", "1.2.3", "$5"])
    func rejectsNonNumbers(input: String) {
        #expect(NumberInput.decimal(input) == nil)
    }

    @Test func commaPriceNoLongerTruncates() {
        // Regression: Decimal(string: "1,25") silently returned 1
        let price = NumberInput.decimal("1,25")!
        let quantity = NumberInput.double("3")!
        #expect(Decimal(quantity) * price == Decimal(string: "3.75"))
    }

    @Test func doubleParsesCommaQuantities() {
        #expect(NumberInput.double("1,5") == 1.5)
        #expect(NumberInput.double("2") == 2)
        #expect(NumberInput.double("x") == nil)
    }
}
