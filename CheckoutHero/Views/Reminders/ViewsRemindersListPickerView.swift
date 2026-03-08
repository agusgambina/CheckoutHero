//
//  ViewsRemindersListPickerView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import SwiftUI
import SwiftData

struct RemindersListPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ShoppingList.modifiedDate, order: .reverse)
    private var shoppingLists: [ShoppingList]

    var body: some View {
        NavigationStack {
            List {
                ForEach(shoppingLists) { list in
                    NavigationLink(destination: RemindersImportView(targetList: list)) {
                        VStack(alignment: .leading) {
                            Text(list.name)
                                .font(.body)
                            Text("\(list.items.count) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("import_from_reminders"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("cancel")) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, configurations: config)
    return RemindersListPickerView()
        .modelContainer(container)
}
