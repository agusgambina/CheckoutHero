//
//  ModelsReceipt.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import Foundation
import SwiftData

@Model
final class Receipt {
    var id: UUID
    var date: Date
    var storeName: String
    var total: Decimal
    var currencySymbol: String
    var rawText: String
    var syncStatusRaw: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        storeName: String = "",
        total: Decimal = 0,
        currencySymbol: String = "$",
        rawText: String = "",
        syncStatus: SyncStatus = .pending,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.storeName = storeName
        self.total = total
        self.currencySymbol = currencySymbol
        self.rawText = rawText
        self.syncStatusRaw = syncStatus.rawValue
        self.createdDate = createdDate
    }

    enum SyncStatus: String, CaseIterable {
        case pending
        case synced

        var localizedTitle: String {
            switch self {
            case .pending:
                return NSLocalizedString("receipt_status_pending", value: "Pending", comment: "")
            case .synced:
                return NSLocalizedString("receipt_status_synced", value: "Synced", comment: "")
            }
        }
    }

    var syncStatus: SyncStatus {
        get { SyncStatus(rawValue: syncStatusRaw) ?? .pending }
        set { syncStatusRaw = newValue.rawValue }
    }

    func formattedTotal(locale: Locale = .current) -> String {
        CurrencyFormatterService.format(amount: total, currencySymbol: currencySymbol, locale: locale)
    }
}
