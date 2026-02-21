//
//  LocalizationService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import Foundation

/// Service for localization utilities
struct LocalizationService {
    
    /// Get the current language code
    static var currentLanguage: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    /// Get all supported languages
    static var supportedLanguages: [String] {
        Bundle.main.localizations.filter { $0 != "Base" }
    }
    
    /// Check if a language is supported
    /// - Parameter languageCode: The language code to check
    /// - Returns: True if supported
    static func isLanguageSupported(_ languageCode: String) -> Bool {
        supportedLanguages.contains(languageCode)
    }
    
    /// Get localized string for a key
    /// - Parameters:
    ///   - key: The localization key
    ///   - defaultValue: Default value if key not found
    ///   - comment: Comment for translators
    /// - Returns: Localized string
    static func localizedString(
        key: String,
        defaultValue: String? = nil,
        comment: String = ""
    ) -> String {
        let localized = NSLocalizedString(key, comment: comment)
        
        // If localization is the same as key, it wasn't found
        if localized == key, let defaultValue = defaultValue {
            return defaultValue
        }
        
        return localized
    }
    
    /// Get the display name for a language code
    /// - Parameter languageCode: The language code
    /// - Returns: Display name in the current locale
    static func displayName(for languageCode: String) -> String? {
        Locale.current.localizedString(forLanguageCode: languageCode)
    }
}

// MARK: - Common Currency Symbols
extension LocalizationService {
    /// Common currency symbols with their display names
    static let commonCurrencies: [(symbol: String, name: String, code: String)] = [
        ("$", "US Dollar", "USD"),
        ("€", "Euro", "EUR"),
        ("£", "British Pound", "GBP"),
        ("¥", "Japanese Yen", "JPY"),
        ("¥", "Chinese Yuan", "CNY"),
        ("₹", "Indian Rupee", "INR"),
        ("R$", "Brazilian Real", "BRL"),
        ("₽", "Russian Ruble", "RUB"),
        ("₪", "Israeli Shekel", "ILS"),
        ("CHF", "Swiss Franc", "CHF"),
        ("A$", "Australian Dollar", "AUD"),
        ("C$", "Canadian Dollar", "CAD"),
        ("₩", "South Korean Won", "KRW"),
        ("MX$", "Mexican Peso", "MXN"),
        ("₱", "Philippine Peso", "PHP"),
        ("฿", "Thai Baht", "THB"),
        ("₫", "Vietnamese Dong", "VND"),
        ("zł", "Polish Zloty", "PLN"),
        ("kr", "Swedish Krona", "SEK"),
        ("kr", "Norwegian Krone", "NOK"),
    ]
    
    /// Get currency symbol for a currency code
    /// - Parameter currencyCode: ISO currency code (e.g., "USD")
    /// - Returns: Currency symbol if found
    static func currencySymbol(for currencyCode: String) -> String? {
        commonCurrencies.first { $0.code == currencyCode }?.symbol
    }
    
    /// Get currency name for a symbol
    /// - Parameter symbol: Currency symbol
    /// - Returns: Currency name if found
    static func currencyName(for symbol: String) -> String? {
        commonCurrencies.first { $0.symbol == symbol }?.name
    }
}

// MARK: - Locale Utilities
extension LocalizationService {
    /// Check if the current locale uses metric system
    static var usesMetricSystem: Bool {
        Locale.current.measurementSystem == .metric
    }
    
    /// Get preferred weight unit based on locale
    static var preferredWeightUnit: String {
        usesMetricSystem ? "kg" : "lb"
    }
    
    /// Get preferred volume unit based on locale
    static var preferredVolumeUnit: String {
        usesMetricSystem ? "L" : "gal"
    }
    
    /// Get decimal separator for current locale
    static var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    /// Get grouping separator for current locale
    static var groupingSeparator: String {
        Locale.current.groupingSeparator ?? ","
    }
}
