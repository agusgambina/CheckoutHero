//
//  ReceiptOCRServiceTests.swift
//  CheckoutHeroTests
//

import Foundation
import Testing
@testable import CheckoutHero

@MainActor
@Suite("ReceiptOCRService parsing")
struct ReceiptOCRServiceTests {

    private func dateParts(_ date: Date?) -> DateComponents? {
        date.map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
    }

    // MARK: - Total

    @Test func prefersTheLastTotalLineOverSubtotal() {
        let parsed = ReceiptOCRService.parse(lines: ["SUBTOTAL 10.00", "TAX 2.10", "TOTAL 12.10"])
        #expect(parsed.total == Decimal(string: "12.10"))
    }

    @Test func readsCommaDecimalTotals() {
        let parsed = ReceiptOCRService.parse(lines: ["Mercado", "TOTAL 45,90"])
        #expect(parsed.total == Decimal(string: "45.90"))
    }

    @Test func readsTotalsWithThousandsSeparators() {
        #expect(ReceiptOCRService.parse(lines: ["TOTAL 1,234.56"]).total == Decimal(string: "1234.56"))
        #expect(ReceiptOCRService.parse(lines: ["TOTAL 1.234,56"]).total == Decimal(string: "1234.56"))
    }

    @Test func fallsBackToLargestAmountInLowerHalfWithoutKeyword() {
        let parsed = ReceiptOCRService.parse(lines: ["Store", "Street 1", "Milk 3.50", "Bread 8.25"])
        #expect(parsed.total == Decimal(string: "8.25"))
    }

    @Test func totalIsNilWhenNoAmountIsPresent() {
        #expect(ReceiptOCRService.parse(lines: ["Thank you", "Come again"]).total == nil)
    }

    // MARK: - Date

    @Test func readsISODates() {
        let parts = dateParts(ReceiptOCRService.parse(lines: ["2026-10-31"]).date)
        #expect(parts?.year == 2026 && parts?.month == 10 && parts?.day == 31)
    }

    @Test func readsDayFirstDatesWhenMonthFirstIsImpossible() {
        let parts = dateParts(ReceiptOCRService.parse(lines: ["25/10/2026"]).date)
        #expect(parts?.year == 2026 && parts?.month == 10 && parts?.day == 25)
    }

    @Test func readsTwoDigitYearsAsThisCentury() {
        let parts = dateParts(ReceiptOCRService.parse(lines: ["25/10/26"]).date)
        #expect(parts?.year == 2026 && parts?.month == 10 && parts?.day == 25)
    }

    @Test func dateIsNilWhenNotPresent() {
        #expect(ReceiptOCRService.parse(lines: ["TOTAL 5.00"]).date == nil)
    }

    // MARK: - Store

    @Test func storeNameSkipsReceiptHeadersAndNumbers() {
        let parsed = ReceiptOCRService.parse(lines: ["RECEIPT", "12345", "Green Market"])
        #expect(parsed.storeName == "Green Market")
    }

    @Test func storeNameIsNilForEmptyInput() {
        let parsed = ReceiptOCRService.parse(lines: [])
        #expect(parsed.storeName == nil)
        #expect(parsed.rawText.isEmpty)
    }

    // MARK: - Currency

    @Test func detectsCurrencyOnTheTotalLine() {
        #expect(ReceiptOCRService.parse(lines: ["TOTAL €12.10"]).currencySymbol == "€")
        #expect(ReceiptOCRService.parse(lines: ["TOTAL 12,10 £"]).currencySymbol == "£")
    }

    @Test func totalLineCurrencyWinsOverOtherLines() {
        let parsed = ReceiptOCRService.parse(lines: ["Tip $1.00", "TOTAL €12.10"])
        #expect(parsed.currencySymbol == "€")
    }

    @Test func detectsCurrencyOnOtherLines() {
        #expect(ReceiptOCRService.parse(lines: ["Milk £3.50", "Thanks"]).currencySymbol == "£")
    }

    @Test func doesNotReadBrazilianRealAsDollars() {
        #expect(ReceiptOCRService.parse(lines: ["TOTAL R$ 12,10"]).currencySymbol == "R$")
    }

    @Test func currencyIsNilWhenNoSymbolIsPrinted() {
        #expect(ReceiptOCRService.parse(lines: ["TOTAL 12.10"]).currencySymbol == nil)
    }
}
