//
//  CurrencyPickerView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: String
    
    @State private var customCurrency: String = ""
    @State private var showingCustomInput = false
    
    private let commonCurrencies = LocalizationService.commonCurrencies
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(commonCurrencies, id: \.symbol) { currency in
                        Button {
                            selectedCurrency = currency.symbol
                            dismiss()
                        } label: {
                            HStack {
                                Text(currency.symbol)
                                    .font(.title2)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(currency.name)
                                        .foregroundStyle(.primary)
                                    Text(currency.code)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedCurrency == currency.symbol {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("common_currencies")
                }
                
                Section {
                    if showingCustomInput {
                        HStack {
                            TextField("custom_currency_placeholder", text: $customCurrency)
                                .textInputAutocapitalization(.never)
                            
                            Button("done") {
                                if !customCurrency.isEmpty {
                                    selectedCurrency = customCurrency
                                    dismiss()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Button {
                            showingCustomInput = true
                        } label: {
                            Label("enter_custom_currency", systemImage: "pencil")
                        }
                    }
                } header: {
                    Text("custom_currency")
                } footer: {
                    Text("custom_currency_footer")
                }
            }
            .navigationTitle("select_currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var currency = "$"
    
    return CurrencyPickerView(selectedCurrency: $currency)
}
