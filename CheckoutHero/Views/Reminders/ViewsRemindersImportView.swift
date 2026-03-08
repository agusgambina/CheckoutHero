//
//  ViewsRemindersImportView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import SwiftUI
import SwiftData
import EventKit

struct RemindersImportView: View {
    let targetList: ShoppingList

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    enum FlowState {
        case checkingPermission
        case denied
        case calendarPicker
        case reminderPicker(calendar: EKCalendar)
        case importing
        case done(count: Int)
    }

    @State private var flowState: FlowState = .checkingPermission
    @State private var calendars: [EKCalendar] = []
    @State private var reminders: [EKReminder] = []
    @State private var selectedReminderIDs: Set<String> = []

    var body: some View {
        Group {
            switch flowState {
            case .checkingPermission:
                checkingView
            case .denied:
                deniedView
            case .calendarPicker:
                calendarPickerView
            case .reminderPicker(let calendar):
                reminderPickerView(calendar: calendar)
            case .importing:
                importingView
            case .done(let count):
                doneView(count: count)
            }
        }
        .navigationTitle(LocalizedStringKey("import_from_reminders"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let granted = await RemindersImportService.requestPermission()
            if granted {
                calendars = RemindersImportService.fetchReminderCalendars()
                flowState = .calendarPicker
            } else {
                flowState = .denied
            }
        }
    }

    private var checkingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(LocalizedStringKey("checking_permission"))
                .foregroundStyle(.secondary)
        }
    }

    private var deniedView: some View {
        ContentUnavailableView {
            Label(LocalizedStringKey("reminders_access_denied_title"), systemImage: "bell.slash")
        } description: {
            Text(LocalizedStringKey("reminders_access_denied_description"))
        } actions: {
            Button(LocalizedStringKey("open_settings")) {
                if let url = URL(string: "app-settings:") {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var calendarPickerView: some View {
        List {
            Section(LocalizedStringKey("select_calendar")) {
                ForEach(calendars, id: \.calendarIdentifier) { calendar in
                    Button {
                        Task {
                            reminders = await RemindersImportService.fetchReminders(from: calendar)
                            selectedReminderIDs = []
                            flowState = .reminderPicker(calendar: calendar)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(Color(cgColor: calendar.cgColor))
                                .font(.caption)
                            Text(calendar.title)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }

    private func reminderPickerView(calendar: EKCalendar) -> some View {
        Group {
            if reminders.isEmpty {
                ContentUnavailableView(
                    LocalizedStringKey("no_reminders_found"),
                    systemImage: "checklist"
                )
            } else {
                List {
                    Section(LocalizedStringKey("select_reminders")) {
                        ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                            let id = reminder.calendarItemIdentifier
                            Button {
                                if selectedReminderIDs.contains(id) {
                                    selectedReminderIDs.remove(id)
                                } else {
                                    selectedReminderIDs.insert(id)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: selectedReminderIDs.contains(id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedReminderIDs.contains(id) ? .teal : Color(.systemGray3))
                                    Text(reminder.title ?? "")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                            }
                        }
                    }

                    Section {
                        Button(LocalizedStringKey("import_button")) {
                            let selected = reminders.filter { selectedReminderIDs.contains($0.calendarItemIdentifier) }
                            flowState = .importing
                            Task {
                                RemindersImportService.importReminders(selected, into: targetList, context: modelContext)
                                flowState = .done(count: selected.count)
                            }
                        }
                        .disabled(selectedReminderIDs.isEmpty)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private var importingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(LocalizedStringKey("importing"))
                .foregroundStyle(.secondary)
        }
    }

    private func doneView(count: Int) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.teal)
            Text(String(format: NSLocalizedString("imported_count", comment: ""), count))
                .font(.title3)
            Button(LocalizedStringKey("done")) {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
        .padding()
    }
}
