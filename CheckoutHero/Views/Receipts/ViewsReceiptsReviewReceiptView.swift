//
//  ViewsReceiptsReviewReceiptView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import SwiftUI

/// Review sheet shown after scanning a receipt. User can correct OCR extraction
/// before saving to the history.
struct ReviewReceiptView: View {
    @Environment(\.dismiss) private var dismiss

    let initial: ReceiptOCRService.ParsedReceipt
    let onSave: (_ storeName: String, _ total: Decimal, _ currencySymbol: String, _ date: Date, _ rawText: String) -> Void

    @State private var storeName: String
    @State private var totalString: String
    @State private var currencySymbol: String
    @State private var date: Date
    @State private var showingCurrencyPicker = false
    @FocusState private var focused: Field?

    enum Field { case store, total }

    init(initial: ReceiptOCRService.ParsedReceipt,
         onSave: @escaping (_ storeName: String, _ total: Decimal, _ currencySymbol: String, _ date: Date, _ rawText: String) -> Void) {
        self.initial = initial
        self.onSave = onSave
        _storeName = State(initialValue: initial.storeName ?? "")
        _totalString = State(initialValue: initial.total.map { "\($0)" } ?? "")
        _currencySymbol = State(initialValue: initial.currencySymbol ?? Locale.current.currencySymbol ?? "$")
        _date = State(initialValue: initial.date ?? Date())
    }

    private var parsedTotal: Decimal? {
        NumberInput.decimal(totalString)
    }

    private var canSave: Bool {
        let totalIsBlank = totalString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return (totalIsBlank || parsedTotal != nil)
            && !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("receipt_store_placeholder", text: $storeName)
                        .textInputAutocapitalization(.words)
                        .focused($focused, equals: .store)
                } header: {
                    Text("receipt_store_header")
                }

                Section {
                    DatePicker("receipt_date_label", selection: $date, displayedComponents: [.date])
                } header: {
                    Text("receipt_date_header")
                }

                Section {
                    TextField("receipt_total_placeholder", text: $totalString)
                        .keyboardType(.decimalPad)
                        .focused($focused, equals: .total)
                } header: {
                    Text("receipt_total_header")
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
                }

                if !initial.rawText.isEmpty {
                    Section {
                        Text(initial.rawText)
                            .font(.footnote.monospaced())
                            .foregroundStyle(.secondary)
                    } header: {
                        Text("receipt_raw_header")
                    }
                }
            }
            .navigationTitle("receipt_review_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        onSave(
                            storeName.trimmingCharacters(in: .whitespacesAndNewlines),
                            parsedTotal ?? 0,
                            currencySymbol,
                            date,
                            initial.rawText
                        )
                        dismiss()
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done") { focused = nil }
                }
            }
            .sheet(isPresented: $showingCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $currencySymbol)
            }
        }
    }
}
