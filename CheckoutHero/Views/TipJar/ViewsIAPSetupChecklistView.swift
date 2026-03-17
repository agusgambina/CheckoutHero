//
//  ViewsIAPSetupChecklistView.swift
//  CheckoutHero
//
//  Created on 3/13/26.
//

import SwiftUI

struct IAPSetupChecklistView: View {
    @State private var checklist = IAPChecklistItem.allSteps
    
    var body: some View {
        NavigationStack {
            List {
                // Progress Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Setup Progress")
                                .font(.headline)
                            Spacer()
                            Text("\(completedCount)/\(checklist.count)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        ProgressView(value: Double(completedCount), total: Double(checklist.count))
                            .tint(allComplete ? .green : .blue)
                        
                        if allComplete {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("All steps complete! Ready to submit.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Local Testing Section
                Section("1️⃣ Local StoreKit Testing") {
                    ForEach($checklist.filter { $0.wrappedValue.category == .localTesting }) { $item in
                        ChecklistRow(item: $item)
                    }
                }
                
                // App Store Connect - IAP Setup
                Section("2️⃣ App Store Connect - Create IAPs") {
                    ForEach($checklist.filter { $0.wrappedValue.category == .appStoreConnect }) { $item in
                        ChecklistRow(item: $item)
                    }
                }
                
                // IAP Details Section
                Section("3️⃣ Complete Each Product") {
                    ForEach($checklist.filter { $0.wrappedValue.category == .productDetails }) { $item in
                        ChecklistRow(item: $item)
                    }
                }
                
                // Attach to Submission
                Section("4️⃣ Attach to App Submission") {
                    ForEach($checklist.filter { $0.wrappedValue.category == .submission }) { $item in
                        ChecklistRow(item: $item)
                    }
                }
                
                // Documentation Section
                Section {
                    Link(destination: URL(string: "https://developer.apple.com/in-app-purchase/")!) {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("In-App Purchase Documentation")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://appstoreconnect.apple.com")!) {
                        HStack {
                            Image(systemName: "app.badge")
                            Text("Open App Store Connect")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Resources")
                }
            }
            .navigationTitle("IAP Setup Checklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Reset") {
                        checklist = IAPChecklistItem.allSteps
                    }
                    .font(.caption)
                }
            }
        }
    }
    
    private var completedCount: Int {
        checklist.filter { $0.isComplete }.count
    }
    
    private var allComplete: Bool {
        completedCount == checklist.count
    }
}

// MARK: - Checklist Row

struct ChecklistRow: View {
    @Binding var item: IAPChecklistItem
    
    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                item.isComplete.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isComplete ? .green : .secondary)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .foregroundStyle(.primary)
                    
                    if !item.description.isEmpty {
                        Text(item.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Checklist Item Model

struct IAPChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: Category
    var isComplete: Bool = false
    
    enum Category {
        case localTesting
        case appStoreConnect
        case productDetails
        case submission
    }
    
    static var allSteps: [IAPChecklistItem] {
        [
            // Local Testing
            IAPChecklistItem(
                title: "Create StoreKit.storekit file",
                description: "File → New → StoreKit Configuration File",
                category: .localTesting
            ),
            IAPChecklistItem(
                title: "Add 3 products to StoreKit file",
                description: "tip_small ($0.99), tip_medium ($2.99), tip_large ($4.99)",
                category: .localTesting
            ),
            IAPChecklistItem(
                title: "Configure scheme to use StoreKit file",
                description: "Edit Scheme → Run → Options → StoreKit Configuration",
                category: .localTesting
            ),
            IAPChecklistItem(
                title: "Test purchases in simulator",
                description: "Run app and verify products load correctly",
                category: .localTesting
            ),
            IAPChecklistItem(
                title: "Take screenshot of Tip Jar",
                description: "Cmd+S in simulator, save to Desktop",
                category: .localTesting
            ),
            
            // App Store Connect
            IAPChecklistItem(
                title: "Create tip_small in App Store Connect",
                description: "My Apps → CheckoutHero → In-App Purchases → +",
                category: .appStoreConnect
            ),
            IAPChecklistItem(
                title: "Create tip_medium in App Store Connect",
                description: "My Apps → CheckoutHero → In-App Purchases → +",
                category: .appStoreConnect
            ),
            IAPChecklistItem(
                title: "Create tip_large in App Store Connect",
                description: "My Apps → CheckoutHero → In-App Purchases → +",
                category: .appStoreConnect
            ),
            
            // Product Details
            IAPChecklistItem(
                title: "Set pricing for all products",
                description: "Tier 1 ($0.99), Tier 3 ($2.99), Tier 5 ($4.99)",
                category: .productDetails
            ),
            IAPChecklistItem(
                title: "Add Display Names with emojis",
                description: "Small Tip 🙏, Medium Tip 💙, Large Tip 🌟",
                category: .productDetails
            ),
            IAPChecklistItem(
                title: "Add Descriptions for all products",
                description: "Copy from setup guide document",
                category: .productDetails
            ),
            IAPChecklistItem(
                title: "Upload screenshots for all products",
                description: "Use the Tip Jar screenshot you took earlier",
                category: .productDetails
            ),
            IAPChecklistItem(
                title: "Verify all products show 'Ready to Submit'",
                description: "No 'Missing Metadata' warnings",
                category: .productDetails
            ),
            
            // Submission
            IAPChecklistItem(
                title: "Attach tip_small to app version",
                description: "App version → In-App Purchases → + → Select tip_small",
                category: .submission
            ),
            IAPChecklistItem(
                title: "Attach tip_medium to app version",
                description: "App version → In-App Purchases → + → Select tip_medium",
                category: .submission
            ),
            IAPChecklistItem(
                title: "Attach tip_large to app version",
                description: "App version → In-App Purchases → + → Select tip_large",
                category: .submission
            ),
            IAPChecklistItem(
                title: "Verify all 3 IAPs appear in app version",
                description: "Check In-App Purchases section of your app version",
                category: .submission
            ),
        ]
    }
}

// MARK: - Preview

#Preview {
    IAPSetupChecklistView()
}
