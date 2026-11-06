//
//  ServicesGoogleSheetsSyncService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import Foundation

struct GoogleSheetsSyncService {

    /// Paste the deployed Google Apps Script Web App URL here. See
    /// Views/Receipts/DocumentationApps-Script-Setup.md for the script and
    /// step-by-step deployment instructions.
    static let webAppURL: String = ""

    /// Sync UI is hidden until a URL is set, so unconfigured builds stay fully on-device.
    static var isConfigured: Bool { !webAppURL.isEmpty }

    enum SyncError: Error, LocalizedError {
        case notConfigured
        case invalidURL
        case network(Error)
        case badStatus(Int)

        var errorDescription: String? {
            switch self {
            case .notConfigured:
                return NSLocalizedString(
                    "sheets_error_not_configured",
                    value: "Google Sheets sync is not configured. Add your Apps Script Web App URL in ServicesGoogleSheetsSyncService.swift.",
                    comment: ""
                )
            case .invalidURL:
                return NSLocalizedString("sheets_error_invalid_url", value: "The configured URL is invalid.", comment: "")
            case .network(let error):
                return error.localizedDescription
            case .badStatus(let code):
                return NSLocalizedString("sheets_error_bad_status", value: "Server returned status \(code).", comment: "")
            }
        }
    }

    struct Payload: Encodable {
        let date: String
        let store: String
        let total: String
        let currencySymbol: String
    }

    static func send(payload: Payload) async throws {
        guard isConfigured else { throw SyncError.notConfigured }
        guard let url = URL(string: webAppURL) else { throw SyncError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw SyncError.badStatus(http.statusCode)
            }
        } catch let syncError as SyncError {
            throw syncError
        } catch {
            throw SyncError.network(error)
        }
    }
}
