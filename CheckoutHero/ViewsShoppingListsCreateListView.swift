//
//  CreateListView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

struct CreateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let listToEdit: ShoppingList?
    
    @State private var name: String = ""
    @State private var currencySymbol: String = "$"
    @State private var showingCurrencyPicker = false
    
    private var isEditing: Bool {
        listToEdit != nil
    }
    
    private var title: String {
        isEditing ? NSLocalizedString("edit_list", value: "Edit List", comment: "") 
                  : NSLocalizedString("create_list", value: "Create List", comment: "")
    }
    
    private var saveButtonTitle: String {
        isEditing ? NSLocalizedString("save", value: "Save", comment: "")
                  : NSLocalizedString("create", value: "Create", comment: "")
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(listToEdit: ShoppingList? = nil) {
        self.listToEdit = listToEdit
        if let list = listToEdit {
            _name = State(initialValue: list.name)
            _currencySymbol = State(initialValue: list.currencySymbol)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("list_name_placeholder", text: $name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("list_name_header")
                }
                
                Section {
                    Button {
                        showingCurrencyPicker = true
                    } label: {
                        HStack {
                            Text("currency_symbol")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(currencySymbol)
                                .foregroundStyle(.secondary)
                                .font(.title3)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("currency_header")
                } footer: {
                    Text("currency_footer")
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveButtonTitle) {
                        saveList()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $currencySymbol)
            }
        }
    }
    
    private func saveList() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let list = listToEdit {
            // Edit existing list
            list.name = trimmedName
            list.currencySymbol = currencySymbol
            list.modifiedDate = Date()
        } else {
            // Create new list
            let newList = ShoppingList(
                name: trimmedName,
                currencySymbol: currencySymbol
            )
            modelContext.insert(newList)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Create") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    return CreateListView()
        .modelContainer(container)
}

#Preview("Edit") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    let mockList = ShoppingList.mock()
    container.mainContext.insert(mockList)
    
    return CreateListView(listToEdit: mockList)
        .modelContainer(container)
}
