//
//  ViewsTipJarView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/27/26.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(StoreKitService.self) private var storeKit
    @State private var showingThankYou = false

    var body: some View {
        NavigationStack {
            Group {
                if storeKit.isLoading {
                    loadingView
                } else if storeKit.products.isEmpty {
                    unavailableView
                } else {
                    tipListView
                }
            }
            .navigationTitle(LocalizedStringKey("support_checkout_hero"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await storeKit.loadProducts()
        }
        .sheet(isPresented: $showingThankYou) {
            thankYouView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(LocalizedStringKey("loading_products"))
                .foregroundStyle(.secondary)
        }
    }

    private var unavailableView: some View {
        ContentUnavailableView {
            Label(LocalizedStringKey("tips_unavailable"), systemImage: "exclamationmark.triangle")
        } description: {
            Text(LocalizedStringKey("tips_unavailable_description"))
        }
    }

    private var tipListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.pink.gradient)
                        .symbolEffect(.pulse)
                    
                    Text(LocalizedStringKey("tip_jar_header"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(LocalizedStringKey("tip_jar_description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Tip Options
                VStack(spacing: 12) {
                    ForEach(storeKit.products, id: \.id) { product in
                        TipOptionCard(
                            product: product,
                            icon: iconName(for: product.id),
                            color: iconColor(for: product.id),
                            label: labelKey(for: product.id),
                            description: descriptionKey(for: product.id)
                        ) {
                            Task { await buyTip(product) }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Footer Note
                Text(LocalizedStringKey("tip_jar_footer"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var thankYouView: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            Text(LocalizedStringKey("thank_you_title"))
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(LocalizedStringKey("thank_you_message"))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(LocalizedStringKey("done")) {
                showingThankYou = false
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
        .padding()
    }

    private func buyTip(_ product: Product) async {
        do {
            let purchased = try await storeKit.purchase(product)
            if purchased { showingThankYou = true }
        } catch {
            print("Purchase error: \(error)")
        }
    }

    private func iconName(for productID: String) -> String {
        switch productID {
        case "tip_small": return "heart"
        case "tip_medium": return "heart.fill"
        case "tip_large": return "heart.circle.fill"
        default: return "heart"
        }
    }

    private func iconColor(for productID: String) -> Color {
        switch productID {
        case "tip_small": return .pink
        case "tip_medium": return .red
        case "tip_large": return .purple
        default: return .pink
        }
    }

    private func labelKey(for productID: String) -> String {
        switch productID {
        case "tip_small": return "tip_small_label"
        case "tip_medium": return "tip_medium_label"
        case "tip_large": return "tip_large_label"
        default: return productID
        }
    }
    
    private func descriptionKey(for productID: String) -> String {
        switch productID {
        case "tip_small": return "tip_small_description"
        case "tip_medium": return "tip_medium_description"
        case "tip_large": return "tip_large_description"
        default: return ""
        }
    }
}

// MARK: - Tip Option Card

struct TipOptionCard: View {
    let product: Product
    let icon: String
    let color: Color
    let label: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(color)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(label))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(LocalizedStringKey(description))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Price
                VStack(spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TipJarView()
        .environment(StoreKitService())
}
