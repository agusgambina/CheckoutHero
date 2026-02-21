//
//  ShoppingItemsView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

struct ShoppingItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var shoppingList: ShoppingList
    
    @State private var showingAddItem = false
    @State private var itemToEdit: ShoppingItem?
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: ShoppingItem?
    
    private var sortedItems: [ShoppingItem] {
        shoppingList.items.sorted { !$0.isChecked && $1.isChecked }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Total display at the top
            TotalDisplayView(shoppingList: shoppingList)

            // Items list
            Group {
                if shoppingList.items.isEmpty {
                    emptyStateView
                } else {
                    itemsList
                }
            }
        }
        .navigationTitle(shoppingList.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddItem = true
                } label: {
                    Label("add_item", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Button {
                        uncheckAllItems()
                    } label: {
                        Label("uncheck_all", systemImage: "circle")
                    }
                    .disabled(shoppingList.checkedItemCount == 0)
                    
                    Button(role: .destructive) {
                        deleteCheckedItems()
                    } label: {
                        Label("delete_checked", systemImage: "trash")
                    }
                    .disabled(shoppingList.checkedItemCount == 0)
                } label: {
                    Label("more_options", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(shoppingList: shoppingList)
        }
        .sheet(item: $itemToEdit) { item in
            EditItemView(item: item, shoppingList: shoppingList)
        }
        .alert("delete_item_title", isPresented: $showingDeleteAlert) {
            Button("cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button("delete", role: .destructive) {
                if let item = itemToDelete {
                    deleteItem(item)
                }
            }
        } message: {
            Text("delete_item_message")
        }
    }
    
    private var itemsList: some View {
        List {
            ForEach(sortedItems) { item in
                ShoppingItemRowView(
                    item: item,
                    currencySymbol: shoppingList.currencySymbol,
                    onToggle: {
                        toggleItem(item)
                    }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        itemToDelete = item
                        showingDeleteAlert = true
                    } label: {
                        Label("delete", systemImage: "trash")
                    }
                    
                    Button {
                        itemToEdit = item
                    } label: {
                        Label("edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        toggleItem(item)
                    } label: {
                        Label(
                            item.isChecked ? "uncheck" : "check",
                            systemImage: item.isChecked ? "circle" : "checkmark.circle.fill"
                        )
                    }
                    .tint(item.isChecked ? .orange : .green)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("no_items_title", systemImage: "basket")
        } description: {
            Text("no_items_description")
        } actions: {
            Button("add_first_item") {
                showingAddItem = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func toggleItem(_ item: ShoppingItem) {
        withAnimation {
            item.isChecked.toggle()
            shoppingList.modifiedDate = Date()
            try? modelContext.save()
        }
    }
    
    private func deleteItem(_ item: ShoppingItem) {
        withAnimation {
            if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
                shoppingList.items.remove(at: index)
            }
            modelContext.delete(item)
            shoppingList.modifiedDate = Date()
            try? modelContext.save()
        }
        itemToDelete = nil
    }
    
    private func uncheckAllItems() {
        withAnimation {
            for item in shoppingList.items {
                item.isChecked = false
            }
            shoppingList.modifiedDate = Date()
            try? modelContext.save()
        }
    }
    
    private func deleteCheckedItems() {
        withAnimation {
            let checkedItems = shoppingList.items.filter { $0.isChecked }
            for item in checkedItems {
                if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
                    shoppingList.items.remove(at: index)
                }
                modelContext.delete(item)
            }
            shoppingList.modifiedDate = Date()
            try? modelContext.save()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    let mockList = ShoppingList.mock(itemCount: 5)
    container.mainContext.insert(mockList)
    
    return NavigationStack {
        ShoppingItemsView(shoppingList: mockList)
    }
    .modelContainer(container)
}

#Preview("Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    let mockList = ShoppingList.mock(itemCount: 0)
    container.mainContext.insert(mockList)
    
    return NavigationStack {
        ShoppingItemsView(shoppingList: mockList)
    }
    .modelContainer(container)
}
