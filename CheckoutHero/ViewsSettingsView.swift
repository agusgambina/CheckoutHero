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

    @State private var showingReminders = false

    private let languageOptions: [(code: String, labelKey: String)] = [
        ("system", "system_default"),
        ("en", "english"),
        ("es", "spanish"),
    ]

    var body: some View {
        @Bindable var bindableService = languageService
        NavigationStack {
            Form {
                // Section 3: Import
                Section {
                    Button {
                        showingReminders = true
                    } label: {
                        Label(LocalizedStringKey("import_from_reminders"), systemImage: "list.bullet")
                            .foregroundStyle(.primary)
                    }
                    .accessibilityIdentifier("remindersImportRow")
                } header: {
                    Text(LocalizedStringKey("import_section_header"))
                }

                // Section 4: Language
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

                // Section 5: About
                Section {
                    LabeledContent(LocalizedStringKey("version"), value: appVersion)
                    Link(LocalizedStringKey("privacy_policy"), destination: URL(string: "https://agusgambina.github.io/CheckoutHero/privacy-policy.html")!)
                } header: {
                    Text(LocalizedStringKey("about_section_header"))
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
        .sheet(isPresented: $showingReminders) {
            RemindersListPickerView()
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

#Preview {
    SettingsView()
        .environment(LanguageService())
}
