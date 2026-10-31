//
//  LocalizationServiceTests.swift
//  CheckoutHeroTests
//

import Foundation
import Testing
@testable import CheckoutHero

@MainActor
@Suite("LocalizationService")
struct LocalizationServiceTests {

    @Test(arguments: [("USD", "$"), ("EUR", "€"), ("GBP", "£"), ("BRL", "R$")])
    func currencySymbolForKnownCode(code: String, symbol: String) {
        #expect(LocalizationService.currencySymbol(for: code) == symbol)
    }

    @Test func currencySymbolForUnknownCodeIsNil() {
        #expect(LocalizationService.currencySymbol(for: "XYZ") == nil)
    }

    @Test func currencyNameForSymbol() {
        #expect(LocalizationService.currencyName(for: "R$") == "Brazilian Real")
        #expect(LocalizationService.currencyName(for: "€") == "Euro")
    }

    @Test func currencyCodesAreUnique() {
        let codes = LocalizationService.commonCurrencies.map(\.code)
        #expect(Set(codes).count == codes.count)
    }

    @Test func localizedStringFallsBackToDefaultForMissingKey() {
        let value = LocalizationService.localizedString(key: "definitely_missing_key_123", defaultValue: "Fallback")
        #expect(value == "Fallback")
    }

    @Test func preferredUnitsMatchMeasurementSystem() {
        if LocalizationService.usesMetricSystem {
            #expect(LocalizationService.preferredWeightUnit == "kg")
            #expect(LocalizationService.preferredVolumeUnit == "L")
        } else {
            #expect(LocalizationService.preferredWeightUnit == "lb")
            #expect(LocalizationService.preferredVolumeUnit == "gal")
        }
    }
}
