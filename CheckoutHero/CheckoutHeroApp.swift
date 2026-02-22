//
//  CheckoutHeroApp.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

@main
struct CheckoutHeroApp: App {
    @State private var languageService = LanguageService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageService)
                .environment(\.locale, languageService.locale)
                .id(languageService.selectedLanguage)
        }
        .modelContainer(for: [ShoppingList.self, ShoppingItem.self])
    }
}
