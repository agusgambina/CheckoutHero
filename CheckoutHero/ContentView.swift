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
        ShoppingListsView()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, ShoppingItem.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
