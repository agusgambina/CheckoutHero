//
//  ViewsAuthSignInView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import SwiftUI
import AuthenticationServices

struct AuthSignInView: View {
    @Environment(AuthenticationService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                switch authService.authState {
                case .guest:
                    guestSection
                case .signedIn(let userID, let displayName):
                    signedInSection(userID: userID, displayName: displayName)
                }
            }
            .navigationTitle(LocalizedStringKey("sign_in_apple"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("done")) { dismiss() }
                }
            }
        }
    }

    private var guestSection: some View {
        Section {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName]
            } onCompletion: { result in
                authService.handleAuthorization(result)
                dismiss()
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
        } footer: {
            Text(LocalizedStringKey("sign_in_footer"))
        }
    }

    private func signedInSection(userID: String, displayName: String?) -> some View {
        Group {
            Section(LocalizedStringKey("account")) {
                if let name = displayName {
                    LabeledContent(LocalizedStringKey("name"), value: name)
                }
                LabeledContent(LocalizedStringKey("apple_user_id")) {
                    Text(String(userID.prefix(20)) + (userID.count > 20 ? "…" : ""))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            Section {
                Button(LocalizedStringKey("sign_out"), role: .destructive) {
                    authService.signOut()
                    dismiss()
                }
            }
        }
    }
}

#Preview("Guest") {
    AuthSignInView()
        .environment(AuthenticationService())
}

#Preview("Signed In") {
    let service = AuthenticationService()
    return AuthSignInView()
        .environment(service)
}
