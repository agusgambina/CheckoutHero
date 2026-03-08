//
//  SettingsView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(LanguageService.self) private var languageService
    @Environment(AuthenticationService.self) private var authService
    @Environment(StoreKitService.self) private var storeKitService
    @Environment(\.dismiss) private var dismiss

    @State private var showingTipJar = false
    @State private var showingAuth = false
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
                // Section 1: Support
                Section {
                    Button {
                        showingTipJar = true
                    } label: {
                        Label(LocalizedStringKey("support_checkout_hero_row"), systemImage: "heart")
                            .foregroundStyle(.primary)
                    }
                } header: {
                    Text(LocalizedStringKey("support_section_header"))
                }

                // Section 2: Account
                Section {
                    Button {
                        showingAuth = true
                    } label: {
                        HStack {
                            Label(LocalizedStringKey("sign_in_apple"), systemImage: "person.circle")
                                .foregroundStyle(.primary)
                            Spacer()
                            authStateLabel
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }
                } header: {
                    Text(LocalizedStringKey("account"))
                } footer: {
                    Text(LocalizedStringKey("sign_in_footer"))
                }

                // Section 3: Import
                Section {
                    Button {
                        showingReminders = true
                    } label: {
                        Label(LocalizedStringKey("import_from_reminders"), systemImage: "list.bullet")
                            .foregroundStyle(.primary)
                    }
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
        .sheet(isPresented: $showingTipJar) {
            TipJarView()
                .environment(storeKitService)
        }
        .sheet(isPresented: $showingAuth) {
            AuthSignInView()
                .environment(authService)
        }
        .sheet(isPresented: $showingReminders) {
            RemindersListPickerView()
        }
    }

    @ViewBuilder
    private var authStateLabel: some View {
        switch authService.authState {
        case .guest:
            Text(LocalizedStringKey("sign_in"))
        case .signedIn(_, let displayName):
            if let name = displayName {
                Text(name)
            } else {
                Text(LocalizedStringKey("account"))
            }
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
        .environment(AuthenticationService())
        .environment(StoreKitService())
}
