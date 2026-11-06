//
//  ServicesReceiptOCRService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import Foundation
import Vision
import UIKit

struct ReceiptOCRService {

    struct ParsedReceipt {
        var storeName: String?
        var total: Decimal?
        var date: Date?
        var currencySymbol: String?
        var rawText: String
    }

    static func scan(images: [UIImage]) async -> ParsedReceipt {
        var allLines: [String] = []
        for image in images {
            let lines = await LabelScannerService.recognizeText(in: image)
            allLines.append(contentsOf: lines)
        }
        return parse(lines: allLines)
    }

    static func parse(lines: [String]) -> ParsedReceipt {
        let joined = lines.joined(separator: "\n")

        let total = extractTotal(from: lines)
        let date = extractDate(from: lines)
        let storeName = extractStoreName(from: lines)
        let currencySymbol = extractCurrencySymbol(from: lines)

        return ParsedReceipt(
            storeName: storeName,
            total: total,
            date: date,
            currencySymbol: currencySymbol,
            rawText: joined
        )
    }

    // MARK: - Total extraction

    private static let totalKeywords = ["TOTAL", "NET", "BALANCE", "AMOUNT DUE", "AMOUNT", "GRAND TOTAL"]

    private static let amountRegex: NSRegularExpression = {
        // Grouped amounts come first, so "1,234.56" is not split into "1,23" and "4.56".
        let pattern = #"(?<num>\d{1,3}(?:[.,]\d{3})+[.,]\d{2}|\d{1,5}[.,]\d{2})"#
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    private static func extractTotal(from lines: [String]) -> Decimal? {
        // Prefer amounts on lines containing TOTAL/NET/BALANCE keywords.
        for line in lines.reversed() {
            let upper = line.uppercased()
            if totalKeywords.contains(where: { upper.contains($0) }) {
                if let amount = firstAmount(in: line) {
                    return amount
                }
            }
        }

        // Fallback: pick the largest amount that appears in the lower half of the receipt.
        let lowerHalf = Array(lines.suffix(max(1, lines.count / 2)))
        let amounts = lowerHalf.compactMap { firstAmount(in: $0) }
        return amounts.max()
    }

    private static func firstAmount(in line: String) -> Decimal? {
        let range = NSRange(line.startIndex..<line.endIndex, in: line)
        // Grab all amount matches on the line, pick the largest (skips small subtotals).
        let matches = amountRegex.matches(in: line, options: [], range: range)
        let values: [Decimal] = matches.compactMap { match in
            let r = match.range(withName: "num")
            guard r.location != NSNotFound, let swiftRange = Range(r, in: line) else { return nil }
            // The last separator is always the decimal one; any others group thousands.
            let digits = line[swiftRange].filter(\.isNumber)
            return Decimal(string: "\(digits.dropLast(2)).\(digits.suffix(2))")
        }
        return values.max()
    }

    // MARK: - Currency extraction

    /// "R$" comes before "$" so Brazilian receipts are not read as dollars.
    private static let currencySymbols = ["R$", "€", "£", "¥", "₹", "₪", "₽", "$"]

    /// Prefers the symbol on a total line, then any symbol printed on the receipt.
    private static func extractCurrencySymbol(from lines: [String]) -> String? {
        let totalLines = lines.filter { line in
            let upper = line.uppercased()
            return totalKeywords.contains(where: { upper.contains($0) })
        }
        for line in totalLines.reversed() + lines {
            if let symbol = currencySymbols.first(where: { line.contains($0) }) {
                return symbol
            }
        }
        return nil
    }

    // MARK: - Date extraction

    private static let dateFormatters: [DateFormatter] = {
        let formats = [
            "MM/dd/yyyy", "M/d/yyyy", "MM-dd-yyyy",
            "dd/MM/yyyy", "d/M/yyyy", "dd-MM-yyyy",
            "MM/dd/yy", "dd/MM/yy",
            "yyyy-MM-dd", "yyyy/MM/dd"
        ]
        return formats.map { format in
            let f = DateFormatter()
            f.dateFormat = format
            f.locale = Locale(identifier: "en_US_POSIX")
            return f
        }
    }()

    private static let dateRegex: NSRegularExpression = {
        let pattern = #"\b(\d{1,4}[/\-]\d{1,2}[/\-]\d{1,4})\b"#
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    private static func extractDate(from lines: [String]) -> Date? {
        for line in lines {
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            let matches = dateRegex.matches(in: line, options: [], range: range)
            for match in matches {
                guard let swiftRange = Range(match.range(at: 1), in: line) else { continue }
                let candidate = String(line[swiftRange])
                for formatter in dateFormatters {
                    // "yyyy" also accepts "26" as the year 26, so leave those to the "yy" formats.
                    if let date = formatter.date(from: candidate),
                       Calendar.current.component(.year, from: date) >= 2000 {
                        return date
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Store name extraction

    /// Heuristic: first non-empty line that is mostly letters and not a header like "RECEIPT".
    private static func extractStoreName(from lines: [String]) -> String? {
        for line in lines.prefix(5) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= 3 else { continue }
            let letters = trimmed.filter { $0.isLetter }
            guard letters.count >= 3 else { continue }
            let upper = trimmed.uppercased()
            if upper == "RECEIPT" || upper == "INVOICE" { continue }
            return trimmed
        }
        return nil
    }
}
