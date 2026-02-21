//
//  ShoppingItemRowView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI
import SwiftData

// MARK: - Row

struct ShoppingItemRowView: View {
    @Bindable var item: ShoppingItem
    let currencySymbol: String
    let onToggle: () -> Void

    @Environment(\.modelContext) private var modelContext

    private enum ActiveSheet: Identifiable {
        case quantity, price, total
        var id: Self { self }
    }

    @State private var activeSheet: ActiveSheet?

    var body: some View {
        HStack(spacing: 14) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isChecked ? .teal : Color(.systemGray3))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: item.isChecked)
            }
            .buttonStyle(.plain)

            // Item details
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .secondary : .primary)

                HStack(spacing: 6) {
                    // Quantity chip — tap to edit
                    Button { activeSheet = .quantity } label: {
                        Text(item.formattedQuantity)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.teal.opacity(0.1), in: RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)

                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    // Price-per-unit chip — tap to edit
                    Button { activeSheet = .price } label: {
                        Text(item.formattedPricePerUnit(currencySymbol: currencySymbol) + (!item.unit.isEmpty ? "/\(item.unit)" : ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.teal.opacity(0.1), in: RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            // Total — tap to edit
            Button { activeSheet = .total } label: {
                Text(item.formattedTotalPrice(currencySymbol: currencySymbol))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(item.isChecked ? Color(.systemGray3) : .teal)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .quantity:
                QuantityEditSheet(item: item, onSave: saveItem)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            case .price:
                PriceEditSheet(item: item, currencySymbol: currencySymbol, editTotal: false, onSave: saveItem)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            case .total:
                PriceEditSheet(item: item, currencySymbol: currencySymbol, editTotal: true, onSave: saveItem)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func saveItem() {
        item.shoppingList?.modifiedDate = Date()
        try? modelContext.save()
    }
}

// MARK: - Quantity edit sheet

private struct QuantityEditSheet: View {
    @Bindable var item: ShoppingItem
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var quantityText: String = ""
    @State private var selectedUnit: String = "units"
    @FocusState private var focused: Bool

    private var canCommit: Bool {
        quantityText.isEmpty || (Double(quantityText) != nil && Double(quantityText)! >= 0)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Quantity")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 8)

            TextField("1", text: $quantityText)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.teal)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($focused)

            Picker("Unit", selection: $selectedUnit) {
                ForEach(ShoppingItem.commonUnits, id: \.self) {
                    Text($0).tag($0)
                }
            }
            .pickerStyle(.menu)
            .tint(.teal)

            Button("Save") {
                commit()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .disabled(!canCommit)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onAppear {
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 0
            fmt.maximumFractionDigits = 4
            quantityText = fmt.string(from: NSNumber(value: item.quantity)) ?? "1"
            selectedUnit = item.unit.isEmpty ? "units" : item.unit
            focused = true
        }
    }

    private func commit() {
        if let qty = Double(quantityText), qty >= 0 {
            item.quantity = qty
        }
        item.unit = selectedUnit
        onSave()
    }
}

// MARK: - Price / Total edit sheet

private struct PriceEditSheet: View {
    @Bindable var item: ShoppingItem
    let currencySymbol: String
    /// When true we're editing the total and back-calculate price per unit.
    let editTotal: Bool
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var valueText: String = ""
    @FocusState private var focused: Bool

    private var title: String {
        editTotal ? "Total" : "Price per \(item.unit.isEmpty ? "unit" : item.unit)"
    }

    private var hint: String? {
        guard editTotal else { return nil }
        if item.quantity > 0 {
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 0
            fmt.maximumFractionDigits = 2
            let qtyStr = fmt.string(from: NSNumber(value: item.quantity)) ?? "\(item.quantity)"
            return "Adjusts price per unit (total ÷ \(qtyStr))"
        } else {
            return "Quantity will be set to 1"
        }
    }

    private var canCommit: Bool {
        guard !valueText.isEmpty else { return true }
        guard let d = Decimal(string: valueText) else { return false }
        return d >= 0
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 8)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(currencySymbol)
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.secondary)

                TextField("0", text: $valueText)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.teal)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if let hint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Save") {
                commit()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .disabled(!canCommit)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onAppear {
            let source = editTotal ? item.totalPrice : item.pricePerUnit
            valueText = formatDecimal(source)
            focused = true
        }
    }

    private func formatDecimal(_ d: Decimal) -> String {
        let fmt = NumberFormatter()
        fmt.minimumFractionDigits = 0
        fmt.maximumFractionDigits = 4
        fmt.numberStyle = .decimal
        return fmt.string(from: NSDecimalNumber(decimal: d)) ?? "0"
    }

    private func commit() {
        let parsed = valueText.isEmpty ? (editTotal ? item.totalPrice : item.pricePerUnit)
                                       : (Decimal(string: valueText) ?? (editTotal ? item.totalPrice : item.pricePerUnit))
        guard parsed >= 0 else { return }

        if editTotal {
            if item.quantity > 0 {
                item.pricePerUnit = parsed / Decimal(item.quantity)
            } else {
                item.quantity = 1
                item.pricePerUnit = parsed
            }
        } else {
            item.pricePerUnit = parsed
        }
        onSave()
    }
}

// MARK: - Preview

#Preview {
    List {
        ShoppingItemRowView(
            item: .mock(name: "Apples", quantity: 2, unit: "kg", pricePerUnit: 3.50, isChecked: false),
            currencySymbol: "$",
            onToggle: {}
        )
        ShoppingItemRowView(
            item: .mock(name: "Milk", quantity: 1, unit: "L", pricePerUnit: 2.99, isChecked: true),
            currencySymbol: "$",
            onToggle: {}
        )
        ShoppingItemRowView(
            item: .mock(name: "Bread", quantity: 2, unit: "units", pricePerUnit: 2.50, isChecked: false),
            currencySymbol: "€",
            onToggle: {}
        )
    }
}
