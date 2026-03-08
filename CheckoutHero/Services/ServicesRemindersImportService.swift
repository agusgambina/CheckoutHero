//
//  ServicesRemindersImportService.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import Foundation
import EventKit
import SwiftData

struct RemindersImportService {
    private static let store = EKEventStore()

    static func requestPermission() async -> Bool {
        do {
            return try await store.requestFullAccessToReminders()
        } catch {
            print("Reminders permission error: \(error)")
            return false
        }
    }

    static func fetchReminderCalendars() -> [EKCalendar] {
        store.calendars(for: .reminder)
    }

    static func fetchReminders(from calendar: EKCalendar) async -> [EKReminder] {
        await withCheckedContinuation { continuation in
            let predicate = store.predicateForReminders(in: [calendar])
            store.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }

    static func importReminders(_ reminders: [EKReminder], into list: ShoppingList, context: ModelContext) {
        for reminder in reminders {
            let title = reminder.title ?? ""
            guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            let item = ShoppingItem(
                name: title,
                quantity: 1,
                unit: "units",
                pricePerUnit: 0
            )
            list.items.append(item)
        }
        list.modifiedDate = Date()
        do {
            try context.save()
        } catch {
            print("SwiftData save error: \(error)")
        }
    }
}
