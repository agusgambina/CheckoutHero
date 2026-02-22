//
//  TotalDisplayView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import SwiftUI

struct TotalDisplayView: View {
    let shoppingList: ShoppingList
    @Environment(LanguageService.self) private var languageService

    private var progress: Double {
        guard shoppingList.itemCount > 0 else { return 0 }
        return Double(shoppingList.checkedItemCount) / Double(shoppingList.itemCount)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Total + breakdown
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("total")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.75))

                    Text(shoppingList.formattedTotal())
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                if shoppingList.checkedItemCount > 0 {
                    VStack(alignment: .trailing, spacing: 8) {
                        Label {
                            Text(shoppingList.formattedCheckedAmount())
                                .font(.callout)
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundStyle(.white)

                        Label {
                            Text(shoppingList.formattedRemainingAmount())
                                .font(.callout)
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "circle")
                        }
                        .foregroundStyle(.white.opacity(0.65))
                    }
                }
            }

            // Progress bar
            if shoppingList.itemCount > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.25))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white)
                                .frame(width: geo.size.width * progress, height: 6)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                        }
                    }
                    .frame(height: 6)

                    Text(String(format: languageService.string(forKey: "items_checked_format"), shoppingList.checkedItemCount, shoppingList.itemCount))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .background(
            LinearGradient(
                colors: [Color.teal, Color.mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        TotalDisplayView(shoppingList: .mock(itemCount: 5))
        TotalDisplayView(shoppingList: .mock(itemCount: 0))
    }
}
