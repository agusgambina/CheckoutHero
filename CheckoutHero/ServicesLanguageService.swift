//
//  LanguageService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import Foundation
import Observation

/// Manages in-app language selection, persisted across launches.
@Observable
final class LanguageService {

    /// The stored language code. `"system"` means follow the device locale.
    var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selected_language")
            // AppleLanguages drives xcstrings and NSLocalizedString bundle lookup.
            if selectedLanguage == "system" {
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            } else {
                UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
            }
        }
    }

    /// A `Locale` using the effective language code (short code, e.g. "en" or "es").
    /// Passing this to `.environment(\.locale, ...)` drives `Text(LocalizedStringKey)` lookups.
    var locale: Locale {
        Locale(identifier: effectiveLanguageCode)
    }

    /// The resolved language code (never "system").
    var effectiveLanguageCode: String {
        guard selectedLanguage != "system" else {
            return Locale.current.language.languageCode?.identifier ?? "en"
        }
        return selectedLanguage
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "selected_language") ?? "system"
        self.selectedLanguage = saved
        // Re-apply on startup so the bundle is already configured before any view renders.
        if saved != "system" {
            UserDefaults.standard.set([saved], forKey: "AppleLanguages")
        }
    }

    /// Returns a localized string for `key` using the currently selected language.
    /// Used for computed `String` properties that cannot benefit from SwiftUI's
    /// `Text(LocalizedStringKey)` rendering.
    func string(forKey key: String) -> String {
        let code = effectiveLanguageCode
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: key, table: nil)
        }
        return NSLocalizedString(key, comment: "")
    }
}
