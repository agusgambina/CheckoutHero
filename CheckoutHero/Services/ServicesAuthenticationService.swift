//
//  ServicesAuthenticationService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import Foundation
import AuthenticationServices
import Security
import Observation

enum AuthState {
    case guest
    case signedIn(userID: String, displayName: String?)
}

@Observable final class AuthenticationService {
    private(set) var authState: AuthState = .guest

    private let keychainService = "littlebit.CheckoutHero"
    private let userIDKey = "checkout_hero_apple_user_id"
    private let nameKey = "checkout_hero_apple_full_name"

    init() {
        restoreFromKeychain()
    }

    func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            let userID = credential.user
            var displayName: String?
            if let fullName = credential.fullName {
                let parts = [fullName.givenName, fullName.familyName].compactMap { $0 }
                let joined = parts.joined(separator: " ")
                if !joined.isEmpty { displayName = joined }
            }
            keychainWrite(key: userIDKey, value: userID)
            if let name = displayName {
                keychainWrite(key: nameKey, value: name)
            }
            authState = .signedIn(userID: userID, displayName: displayName)

        case .failure(let error):
            print("Sign In with Apple failed: \(error)")
        }
    }

    func signOut() {
        keychainDelete(key: userIDKey)
        keychainDelete(key: nameKey)
        authState = .guest
    }

    func deleteAccount() {
        keychainDelete(key: userIDKey)
        keychainDelete(key: nameKey)
        authState = .guest
    }

    // MARK: - Keychain helpers

    private func restoreFromKeychain() {
        guard let userID = keychainRead(key: userIDKey) else { return }
        let displayName = keychainRead(key: nameKey)
        authState = .signedIn(userID: userID, displayName: displayName)
    }

    private func keychainWrite(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func keychainRead(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }

    private func keychainDelete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
