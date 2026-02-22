//
//  SettingsView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(LanguageService.self) private var languageService
    @Environment(\.dismiss) private var dismiss

    private let languageOptions: [(code: String, labelKey: String)] = [
        ("system", "system_default"),
        ("en", "english"),
        ("es", "spanish"),
    ]

    var body: some View {
        @Bindable var bindableService = languageService
        NavigationStack {
            Form {
                Section {
                    Picker("language", selection: $bindableService.selectedLanguage) {
                        ForEach(languageOptions, id: \.code) { option in
                            Text(LocalizedStringKey(option.labelKey)).tag(option.code)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("language")
                } footer: {
                    Text("language_footer")
                }
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(LanguageService())
}
