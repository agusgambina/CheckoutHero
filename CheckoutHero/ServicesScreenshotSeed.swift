//
//  ServicesScreenshotSeed.swift
//  CheckoutHero
//
//  Sample data for App Store screenshots. Only used when the app is launched
//  with `-ScreenshotData` (by CheckoutHeroUITests/ScreenshotTests); never in normal use.
//

import Foundation
import SwiftData

enum ScreenshotSeed {

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-ScreenshotData")
    }

    private struct SeedItem {
        let name: String
        let quantity: Double
        let unit: String
        let price: String
        let checked: Bool
    }

    private struct SeedList {
        let name: String
        let currency: String
        let hoursAgo: Double
        let items: [SeedItem]
    }

    static func populate(_ context: ModelContext) {
        let spanish = (Locale.preferredLanguages.first ?? "en").hasPrefix("es")
        let lists = spanish ? spanishLists : englishLists

        for seed in lists {
            let date = Date().addingTimeInterval(-seed.hoursAgo * 3600)
            let list = ShoppingList(name: seed.name, createdDate: date, modifiedDate: date, currencySymbol: seed.currency)
            context.insert(list)
            for item in seed.items {
                let shoppingItem = ShoppingItem(
                    name: item.name,
                    quantity: item.quantity,
                    unit: item.unit,
                    pricePerUnit: Decimal(string: item.price) ?? 0,
                    isChecked: item.checked
                )
                context.insert(shoppingItem)
                list.items.append(shoppingItem)
            }
        }
        try? context.save()
    }

    // The first list is the most recent, so it appears at the top and is the one opened in screenshots.
    private static let englishLists: [SeedList] = [
        SeedList(name: "Weekly Groceries", currency: "$", hoursAgo: 1, items: [
            SeedItem(name: "Bananas", quantity: 1.5, unit: "kg", price: "1.20", checked: true),
            SeedItem(name: "Whole Milk", quantity: 2, unit: "L", price: "1.49", checked: true),
            SeedItem(name: "Sourdough Bread", quantity: 1, unit: "units", price: "4.50", checked: true),
            SeedItem(name: "Chicken Breast", quantity: 1, unit: "kg", price: "9.99", checked: false),
            SeedItem(name: "Free-Range Eggs", quantity: 12, unit: "pcs", price: "0.35", checked: false),
            SeedItem(name: "Cheddar Cheese", quantity: 0.4, unit: "kg", price: "12.50", checked: false),
            SeedItem(name: "Tomatoes", quantity: 1, unit: "kg", price: "3.20", checked: false),
            SeedItem(name: "Olive Oil", quantity: 1, unit: "bottle", price: "8.99", checked: false),
        ]),
        SeedList(name: "Weekend BBQ", currency: "$", hoursAgo: 26, items: [
            SeedItem(name: "Burger Patties", quantity: 8, unit: "pcs", price: "1.75", checked: false),
            SeedItem(name: "Buns", quantity: 2, unit: "bag", price: "3.49", checked: false),
            SeedItem(name: "Corn on the Cob", quantity: 6, unit: "units", price: "0.80", checked: false),
            SeedItem(name: "Lemonade", quantity: 2, unit: "bottle", price: "2.99", checked: false),
        ]),
        SeedList(name: "Pharmacy", currency: "$", hoursAgo: 72, items: [
            SeedItem(name: "Toothpaste", quantity: 2, unit: "units", price: "3.25", checked: true),
            SeedItem(name: "Sunscreen", quantity: 1, unit: "bottle", price: "11.99", checked: false),
        ]),
    ]

    private static let spanishLists: [SeedList] = [
        SeedList(name: "Compras de la Semana", currency: "€", hoursAgo: 1, items: [
            SeedItem(name: "Plátanos", quantity: 1.5, unit: "kg", price: "1.20", checked: true),
            SeedItem(name: "Leche Entera", quantity: 2, unit: "L", price: "0.99", checked: true),
            SeedItem(name: "Pan de Masa Madre", quantity: 1, unit: "units", price: "3.50", checked: true),
            SeedItem(name: "Pechuga de Pollo", quantity: 1, unit: "kg", price: "7.90", checked: false),
            SeedItem(name: "Huevos Camperos", quantity: 12, unit: "pcs", price: "0.30", checked: false),
            SeedItem(name: "Queso Manchego", quantity: 0.4, unit: "kg", price: "14.50", checked: false),
            SeedItem(name: "Tomates", quantity: 1, unit: "kg", price: "2.40", checked: false),
            SeedItem(name: "Aceite de Oliva", quantity: 1, unit: "bottle", price: "7.95", checked: false),
        ]),
        SeedList(name: "Asado del Finde", currency: "€", hoursAgo: 26, items: [
            SeedItem(name: "Chorizos", quantity: 8, unit: "pcs", price: "1.10", checked: false),
            SeedItem(name: "Pan", quantity: 2, unit: "bag", price: "1.80", checked: false),
            SeedItem(name: "Mazorcas de Maíz", quantity: 6, unit: "units", price: "0.70", checked: false),
            SeedItem(name: "Limonada", quantity: 2, unit: "bottle", price: "1.99", checked: false),
        ]),
        SeedList(name: "Farmacia", currency: "€", hoursAgo: 72, items: [
            SeedItem(name: "Pasta de Dientes", quantity: 2, unit: "units", price: "2.75", checked: true),
            SeedItem(name: "Protector Solar", quantity: 1, unit: "bottle", price: "12.90", checked: false),
        ]),
    ]
}
