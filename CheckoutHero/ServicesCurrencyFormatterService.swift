//
//  CurrencyFormatterService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import Foundation

/// Service for formatting currency values
struct CurrencyFormatterService {
    
    /// Format a decimal amount with a currency symbol
    /// - Parameters:
    ///   - amount: The monetary amount to format
    ///   - currencySymbol: The currency symbol (e.g., "$", "€", "£")
    ///   - locale: The locale for number formatting (defaults to current)
    /// - Returns: Formatted string with currency symbol
    static func format(
        amount: Decimal,
        currencySymbol: String,
        locale: Locale = .current
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = locale
        
        guard let formattedNumber = formatter.string(from: amount as NSDecimalNumber) else {
            return "\(currencySymbol)0.00"
        }
        
        // Determine currency position based on locale
        // For most locales, check the currency formatting pattern
        let shouldPrefixSymbol = shouldPrefixCurrencySymbol(for: locale, symbol: currencySymbol)
        
        if shouldPrefixSymbol {
            return "\(currencySymbol)\(formattedNumber)"
        } else {
            return "\(formattedNumber) \(currencySymbol)"
        }
    }
    
    /// Determine if currency symbol should be prefixed or suffixed
    /// - Parameters:
    ///   - locale: The locale to check
    ///   - symbol: The currency symbol
    /// - Returns: True if symbol should be prefixed
    private static func shouldPrefixCurrencySymbol(for locale: Locale, symbol: String) -> Bool {
        // Create a currency formatter to check the pattern
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
        
        // Format a sample number to see where the symbol appears
        let sampleFormatted = currencyFormatter.string(from: 1.0) ?? ""
        
        // Check if numbers come before currency symbols (suffix) or after (prefix)
        // Most English locales: $1.00 (prefix)
        // Some European locales: 1.00 € (suffix)
        let numberCharacters = CharacterSet.decimalDigits
        
        // Find first digit position
        if let firstDigitIndex = sampleFormatted.firstIndex(where: { $0.unicodeScalars.first.map(numberCharacters.contains) ?? false }) {
            // Find first non-whitespace, non-digit character before the digit
            let beforeDigit = sampleFormatted[..<firstDigitIndex]
            let hasSymbolBefore = beforeDigit.contains { !$0.isWhitespace && !$0.isNumber }
            return hasSymbolBefore
        }
        
        // Default to prefix for common symbols
        return ["$", "£", "¥", "₹", "₽", "₪"].contains(symbol)
    }
    
    /// Parse a string amount to Decimal
    /// - Parameters:
    ///   - string: String to parse
    ///   - locale: Locale for parsing
    /// - Returns: Decimal value or nil if parsing fails
    static func parseAmount(_ string: String, locale: Locale = .current) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        
        // Remove any currency symbols and extra whitespace
        let cleanString = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .filter { $0.isNumber || $0 == formatter.decimalSeparator.first || $0 == formatter.groupingSeparator.first }
        
        guard let number = formatter.number(from: cleanString) else {
            return nil
        }
        
        return Decimal(string: number.stringValue)
    }
}

// MARK: - Formatting Options
extension CurrencyFormatterService {
    /// Format with no decimal places (for whole numbers)
    static func formatWhole(
        amount: Decimal,
        currencySymbol: String,
        locale: Locale = .current
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.locale = locale
        
        guard let formattedNumber = formatter.string(from: amount as NSDecimalNumber) else {
            return "\(currencySymbol)0"
        }
        
        let shouldPrefixSymbol = shouldPrefixCurrencySymbol(for: locale, symbol: currencySymbol)
        
        if shouldPrefixSymbol {
            return "\(currencySymbol)\(formattedNumber)"
        } else {
            return "\(formattedNumber) \(currencySymbol)"
        }
    }
    
    /// Format with compact notation for large numbers (e.g., $1.2K)
    static func formatCompact(
        amount: Decimal,
        currencySymbol: String,
        locale: Locale = .current
    ) -> String {
        let nsAmount = amount as NSDecimalNumber
        let doubleAmount = nsAmount.doubleValue
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        
        let compactValue: String
        if doubleAmount >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            let millions = doubleAmount / 1_000_000
            compactValue = (formatter.string(from: NSNumber(value: millions)) ?? "0") + "M"
        } else if doubleAmount >= 1_000 {
            formatter.maximumFractionDigits = 1
            let thousands = doubleAmount / 1_000
            compactValue = (formatter.string(from: NSNumber(value: thousands)) ?? "0") + "K"
        } else {
            formatter.maximumFractionDigits = 2
            compactValue = formatter.string(from: NSNumber(value: doubleAmount)) ?? "0"
        }
        
        let shouldPrefixSymbol = shouldPrefixCurrencySymbol(for: locale, symbol: currencySymbol)
        
        if shouldPrefixSymbol {
            return "\(currencySymbol)\(compactValue)"
        } else {
            return "\(compactValue) \(currencySymbol)"
        }
    }
}
