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
        Form {
            Section {
                ForEach(storeKit.products, id: \.id) { product in
                    Button {
                        Task { await buyTip(product) }
                    } label: {
                        HStack {
                            Image(systemName: iconName(for: product.id))
                                .foregroundStyle(iconColor(for: product.id))
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey(labelKey(for: product.id)))
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Text(product.displayPrice)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text(LocalizedStringKey("tip_jar_header"))
            } footer: {
                Text(LocalizedStringKey("tip_jar_footer"))
            }
        }
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
}

#Preview {
    TipJarView()
        .environment(StoreKitService())
}
