//
//  EditItemView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var item: ShoppingItem
    let shoppingList: ShoppingList
    
    @State private var name: String
    @State private var quantity: String
    @State private var unit: String
    @State private var pricePerUnit: String
    @State private var showingError = false
    @State private var errorMessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, quantity, price
    }
    
    init(item: ShoppingItem, shoppingList: ShoppingList) {
        self.item = item
        self.shoppingList = shoppingList
        _name = State(initialValue: item.name)
        _quantity = State(initialValue: "\(item.quantity)")
        _unit = State(initialValue: item.unit)
        _pricePerUnit = State(initialValue: "\(item.pricePerUnit)")
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("item_name_placeholder", text: $name)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .name)
                } header: {
                    Text("item_name_header")
                }
                
                Section {
                    HStack {
                        TextField("quantity_placeholder", text: $quantity)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .quantity)
                        
                        Divider()
                        
                        Picker("unit", selection: $unit) {
                            ForEach(ShoppingItem.commonUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                } header: {
                    Text("quantity_header")
                }
                
                Section {
                    HStack {
                        Text(shoppingList.currencySymbol)
                            .foregroundStyle(.secondary)
                        
                        TextField("price_placeholder", text: $pricePerUnit)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                    }
                } header: {
                    Text("price_per_unit_header")
                } footer: {
                    Text("price_per_unit_footer \(unit)")
                }
                
                if let totalPreview = calculateTotalPreview() {
                    Section {
                        HStack {
                            Text("total_preview")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(totalPreview)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("edit_item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done") {
                        focusedField = nil
                    }
                }
            }
            .alert("error", isPresented: $showingError) {
                Button("ok", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func calculateTotalPreview() -> String? {
        guard let qty = Double(quantity),
              let price = Decimal(string: pricePerUnit),
              qty > 0, price >= 0 else {
            return nil
        }
        
        let total = Decimal(qty) * price
        return CurrencyFormatterService.format(
            amount: total,
            currencySymbol: shoppingList.currencySymbol
        )
    }
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let qty = Double(quantity) ?? 1.0
        let price = Decimal(string: pricePerUnit) ?? 0

        if price < 0 {
            errorMessage = NSLocalizedString("item_validation_negative_price", value: "Price cannot be negative", comment: "")
            showingError = true
            return
        }

        item.name = trimmedName
        item.quantity = qty
        item.unit = unit
        item.pricePerUnit = price

        shoppingList.modifiedDate = Date()
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    let mockList = ShoppingList.mock()
    container.mainContext.insert(mockList)
    
    return EditItemView(item: mockList.items[0], shoppingList: mockList)
        .modelContainer(container)
}
