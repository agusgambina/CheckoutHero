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
    @State private var authService = AuthenticationService()

    /// UI tests launch with `-UITesting` so they start from an empty, in-memory store
    /// and never touch the user's real data.
    private static let isUITesting = ProcessInfo.processInfo.arguments.contains("-UITesting")

    private let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: CheckoutHeroApp.isUITesting)
        do {
            return try ModelContainer(for: ShoppingList.self, ShoppingItem.self, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageService)
                .environment(authService)
                .environment(\.locale, languageService.locale)
                .id(languageService.selectedLanguage)
        }
        .modelContainer(container)
    }
}
