//
//  AddItemView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let shoppingList: ShoppingList
    
    @State private var name: String = ""
    @State private var quantity: String = "1"
    @State private var unit: String = "units"
    @State private var pricePerUnit: String = "0"
    @State private var showingError = false
    @State private var errorMessage = ""

    @State private var showingLabelCamera = false
    @State private var reviewScan: LabelScannerService.ParsedLabel?
    @State private var isProcessingScan = false

    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, quantity, price
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showingLabelCamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("scan_label_button")
                                .fontWeight(.semibold)
                            Spacer()
                            if isProcessingScan {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(isProcessingScan)
                    .tint(.teal)
                } footer: {
                    Text("scan_label_footer")
                }

                Section {
                    TextField("item_name_placeholder", text: $name)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .name)
                        .accessibilityIdentifier("itemNameField")
                } header: {
                    Text("item_name_header")
                }
                
                Section {
                    HStack {
                        TextField("quantity_placeholder", text: $quantity)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .quantity)
                            .accessibilityIdentifier("itemQuantityField")
                        
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
                } footer: {
                    Text("quantity_footer")
                }
                
                Section {
                    HStack {
                        Text(shoppingList.currencySymbol)
                            .foregroundStyle(.secondary)
                        
                        TextField("price_placeholder", text: $pricePerUnit)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                            .accessibilityIdentifier("itemPriceField")
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
            .navigationTitle("add_item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("add") {
                        addItem()
                    }
                    .disabled(!canSave)
                    .accessibilityIdentifier("confirmAddItemButton")
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
            .fullScreenCover(isPresented: $showingLabelCamera) {
                LabelCameraView(
                    onCapture: { image in
                        showingLabelCamera = false
                        handleScannedImage(image)
                    },
                    onCancel: {
                        showingLabelCamera = false
                    }
                )
                .ignoresSafeArea()
            }
            .sheet(item: Binding(
                get: { reviewScan.map { IdentifiableLabel(value: $0) } },
                set: { reviewScan = $0?.value }
            )) { wrapper in
                ReviewScanView(
                    currencySymbol: shoppingList.currencySymbol,
                    initial: wrapper.value
                ) { scannedName, scannedPrice, scannedQuantity in
                    name = scannedName
                    pricePerUnit = "\(scannedPrice)"
                    quantity = "\(Int(scannedQuantity))"
                }
            }
        }
        .onAppear {
            focusedField = .name
        }
    }

    private struct IdentifiableLabel: Identifiable {
        let id = UUID()
        let value: LabelScannerService.ParsedLabel
    }

    private func handleScannedImage(_ image: UIImage) {
        isProcessingScan = true
        Task {
            let parsed = await LabelScannerService.scan(image: image)
            await MainActor.run {
                isProcessingScan = false
                reviewScan = parsed
            }
        }
    }
    
    private func calculateTotalPreview() -> String? {
        guard let qty = NumberInput.double(quantity),
              let price = NumberInput.decimal(pricePerUnit),
              qty > 0, price >= 0 else {
            return nil
        }
        
        let total = Decimal(qty) * price
        return CurrencyFormatterService.format(
            amount: total,
            currencySymbol: shoppingList.currencySymbol
        )
    }
    
    private func addItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let qty = NumberInput.double(quantity) ?? 1.0
        let price = NumberInput.decimal(pricePerUnit) ?? 0

        if price < 0 {
            errorMessage = NSLocalizedString("item_validation_negative_price", value: "Price cannot be negative", comment: "")
            showingError = true
            return
        }

        let newItem = ShoppingItem(
            name: trimmedName,
            quantity: qty,
            unit: unit,
            pricePerUnit: price
        )

        shoppingList.items.append(newItem)
        shoppingList.modifiedDate = Date()
        saveContext()
        dismiss()
    }

    private func saveContext() {
        do { try modelContext.save() }
        catch { print("SwiftData save error: \(error)") }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    
    let mockList = ShoppingList.mock()
    container.mainContext.insert(mockList)
    
    return AddItemView(shoppingList: mockList)
        .modelContainer(container)
}
