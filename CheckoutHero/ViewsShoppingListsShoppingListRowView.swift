//
//  ShoppingListRowView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI

struct ShoppingListRowView: View {
    let shoppingList: ShoppingList
    @Environment(LanguageService.self) private var languageService

    private var progress: Double {
        guard shoppingList.itemCount > 0 else { return 0 }
        return Double(shoppingList.checkedItemCount) / Double(shoppingList.itemCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name + total
            HStack(alignment: .top) {
                Text(shoppingList.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text(shoppingList.formattedTotal())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.teal)
            }

            // Item count + date
            HStack(spacing: 6) {
                Image(systemName: "cart")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("^[\(shoppingList.itemCount) item](inflect: true)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("·")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Text(shoppingList.modifiedDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Progress bar (only when list has items)
            if shoppingList.itemCount > 0 {
                VStack(alignment: .leading, spacing: 5) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 5)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.teal)
                                .frame(width: geo.size.width * progress, height: 5)
                                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: progress)
                        }
                    }
                    .frame(height: 5)

                    HStack {
                        if shoppingList.checkedItemCount > 0 {
                            Text(String(format: languageService.string(forKey: "checked_progress_format"), shoppingList.checkedItemCount, shoppingList.itemCount))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.teal)
                        } else {
                            Text(String(format: languageService.string(forKey: "checked_progress_format"), 0, shoppingList.itemCount))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        VStack(spacing: 12) {
            ShoppingListRowView(shoppingList: .mock(name: "Weekly Groceries", currencySymbol: "$", itemCount: 9))
            ShoppingListRowView(shoppingList: .mock(name: "Party Shopping", currencySymbol: "€", itemCount: 12))
            ShoppingListRowView(shoppingList: .mock(name: "Quick Shop", currencySymbol: "£", itemCount: 3))
        }
        .padding()
    }
}
