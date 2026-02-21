//
//  ShoppingListsView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

struct ShoppingListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingList.modifiedDate, order: .reverse)
    private var shoppingLists: [ShoppingList]

    @State private var showingCreateSheet = false
    @State private var listToEdit: ShoppingList?

    var body: some View {
        NavigationStack {
            Group {
                if shoppingLists.isEmpty {
                    emptyStateView
                } else {
                    listContent
                }
            }
            .navigationTitle("shopping_lists_title")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Label("add_list", systemImage: "plus")
                    }
                    .tint(.teal)
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateListView()
            }
            .sheet(item: $listToEdit) { list in
                CreateListView(listToEdit: list)
            }
        }
    }

    private var listContent: some View {
        List {
            ForEach(shoppingLists) { list in
                NavigationLink(destination: ShoppingItemsView(shoppingList: list)) {
                    ShoppingListRowView(shoppingList: list)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        deleteList(list)
                    } label: {
                        Label("delete", systemImage: "trash")
                    }

                    Button {
                        listToEdit = list
                    } label: {
                        Label("edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        duplicateList(list)
                    } label: {
                        Label("duplicate", systemImage: "doc.on.doc")
                    }
                    .tint(.teal)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("no_lists_title", systemImage: "cart")
        } description: {
            Text("no_lists_description")
        } actions: {
            Button("create_first_list") {
                showingCreateSheet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
    }

    private func deleteList(_ list: ShoppingList) {
        withAnimation {
            modelContext.delete(list)
            try? modelContext.save()
        }
    }

    private func duplicateList(_ list: ShoppingList) {
        let newList = ShoppingList(
            name: "\(list.name) (Copy)",
            currencySymbol: list.currencySymbol
        )

        // Copy items
        for item in list.items {
            let newItem = ShoppingItem(
                name: item.name,
                quantity: item.quantity,
                unit: item.unit,
                pricePerUnit: item.pricePerUnit,
                isChecked: false
            )
            newList.items.append(newItem)
        }

        modelContext.insert(newList)
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)

    let mockLists = ShoppingList.mockMultiple(count: 3)
    mockLists.forEach { container.mainContext.insert($0) }

    return ShoppingListsView()
        .modelContainer(container)
}

#Preview("Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)

    return ShoppingListsView()
        .modelContainer(container)
}
