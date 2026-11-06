//
//  ViewsScannerReviewScanView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import SwiftUI

/// Review sheet shown after a label scan. Lets the user correct OCR mistakes
/// and choose a quantity before adding the item to the list.
struct ReviewScanView: View {
    @Environment(\.dismiss) private var dismiss

    let currencySymbol: String
    let initial: LabelScannerService.ParsedLabel
    let onConfirm: (_ name: String, _ price: Decimal, _ quantity: Double) -> Void

    @State private var name: String
    @State private var priceString: String
    @State private var quantity: Double
    @FocusState private var focused: Field?

    enum Field { case name, price }

    init(currencySymbol: String,
         initial: LabelScannerService.ParsedLabel,
         onConfirm: @escaping (_ name: String, _ price: Decimal, _ quantity: Double) -> Void) {
        self.currencySymbol = currencySymbol
        self.initial = initial
        self.onConfirm = onConfirm
        _name = State(initialValue: initial.productName ?? "")
        _priceString = State(initialValue: initial.price.map { "\($0)" } ?? "")
        _quantity = State(initialValue: 1)
    }

    private var parsedPrice: Decimal? {
        NumberInput.decimal(priceString)
    }

    private var canConfirm: Bool {
        let priceIsBlank = priceString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return (priceIsBlank || parsedPrice != nil)
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("item_name_placeholder", text: $name)
                        .textInputAutocapitalization(.words)
                        .focused($focused, equals: .name)
                } header: {
                    Text("review_scan_name_header")
                }

                Section {
                    HStack {
                        Text(currencySymbol).foregroundStyle(.secondary)
                        TextField("price_placeholder", text: $priceString)
                            .keyboardType(.decimalPad)
                            .focused($focused, equals: .price)
                    }
                } header: {
                    Text("review_scan_price_header")
                }

                Section {
                    Stepper(value: $quantity, in: 1...999, step: 1) {
                        HStack {
                            Text("review_scan_quantity_label")
                            Spacer()
                            Text("\(Int(quantity))")
                                .font(.title3.weight(.semibold))
                        }
                    }
                } header: {
                    Text("review_scan_quantity_header")
                }

                if !initial.rawText.isEmpty {
                    Section {
                        Text(initial.rawText)
                            .font(.footnote.monospaced())
                            .foregroundStyle(.secondary)
                    } header: {
                        Text("review_scan_raw_header")
                    }
                }
            }
            .navigationTitle("review_scan_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("review_scan_confirm") {
                        let price = parsedPrice ?? 0
                        onConfirm(name.trimmingCharacters(in: .whitespacesAndNewlines), price, quantity)
                        dismiss()
                    }
                    .disabled(!canConfirm)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done") { focused = nil }
                }
            }
        }
    }
}
