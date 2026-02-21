//
//  SimpleShoppingListsView.swift
//  CheckoutHero
//
//  Simplified version without localization for debugging
//

import SwiftUI
import SwiftData

struct SimpleShoppingListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingList.modifiedDate, order: .reverse)
    private var shoppingLists: [ShoppingList]
    
    @State private var showingCreateSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Lists: \(shoppingLists.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if shoppingLists.isEmpty {
                    ContentUnavailableView {
                        Label("No Lists Yet", systemImage: "cart")
                    } description: {
                        Text("Create your first shopping list")
                    } actions: {
                        Button("Create List") {
                            showingCreateSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(shoppingLists) { list in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(list.name)
                                    .font(.headline)
                                Text("\(list.itemCount) items • \(list.currencySymbol)\(String(describing: list.totalAmount))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteLists)
                    }
                }
            }
            .navigationTitle("Shopping Lists")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                SimpleCreateListView()
            }
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(shoppingLists[index])
            }
            try? modelContext.save()
        }
    }
}

struct SimpleCreateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var currencySymbol: String = "$"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("List Name") {
                    TextField("e.g., Weekly Groceries", text: $name)
                }
                
                Section("Currency") {
                    Picker("Symbol", selection: $currencySymbol) {
                        Text("$ Dollar").tag("$")
                        Text("€ Euro").tag("€")
                        Text("£ Pound").tag("£")
                        Text("¥ Yen").tag("¥")
                        Text("₹ Rupee").tag("₹")
                    }
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        saveList()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveList() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        print("🔵 Creating list: '\(trimmedName)' with currency: '\(currencySymbol)'")
        
        let newList = ShoppingList(
            name: trimmedName,
            currencySymbol: currencySymbol
        )
        
        modelContext.insert(newList)
        
        do {
            try modelContext.save()
            print("✅ List saved successfully! ID: \(newList.id)")
            print("✅ List name: \(newList.name)")
            dismiss()
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    return SimpleShoppingListsView()
        .modelContainer(container)
}
