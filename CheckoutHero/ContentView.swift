//
//  ContentView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            ShoppingListsView()
                .tabItem {
                    Label("tab_lists", systemImage: "cart")
                }

            ReceiptTrackerView()
                .tabItem {
                    Label("tab_receipts", systemImage: "doc.text.magnifyingglass")
                }
        }
        .tint(.teal)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, ShoppingItem.self, Receipt.self, configurations: config)

    return ContentView()
        .modelContainer(container)
}
