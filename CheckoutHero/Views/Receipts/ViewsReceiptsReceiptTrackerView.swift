//
//  ViewsReceiptsReceiptTrackerView.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 7/3/26.
//

import SwiftUI
import SwiftData
import UIKit

struct ReceiptTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Receipt.date, order: .reverse) private var receipts: [Receipt]

    @State private var showingScanner = false
    @State private var pendingReview: ReceiptOCRService.ParsedReceipt?
    @State private var isProcessing = false
    @State private var syncingIDs: Set<UUID> = []
    @State private var errorMessage: String?
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Group {
                if receipts.isEmpty {
                    emptyState
                } else {
                    receiptList
                }
            }
            .navigationTitle("receipt_tracker_title")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingScanner = true
                    } label: {
                        Label("receipt_scan_button", systemImage: "doc.text.viewfinder")
                    }
                    .tint(.teal)
                    .disabled(isProcessing)
                }
            }
            .overlay {
                if isProcessing {
                    ProgressView("receipt_processing")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .fullScreenCover(isPresented: $showingScanner) {
                DocumentScannerView(
                    onFinish: { images in
                        showingScanner = false
                        processScannedImages(images)
                    },
                    onCancel: {
                        showingScanner = false
                    }
                )
                .ignoresSafeArea()
            }
            .sheet(item: Binding(
                get: { pendingReview.map { IdentifiableReceipt(value: $0) } },
                set: { pendingReview = $0?.value }
            )) { wrapper in
                ReviewReceiptView(initial: wrapper.value) { store, total, date, raw in
                    saveReceipt(store: store, total: total, date: date, raw: raw)
                }
            }
            .alert("error", isPresented: $showingError) {
                Button("ok", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - UI

    private var emptyState: some View {
        ContentUnavailableView {
            Label("receipt_empty_title", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("receipt_empty_description")
        } actions: {
            Button("receipt_scan_first") {
                showingScanner = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
    }

    private var receiptList: some View {
        List {
            ForEach(receipts) { receipt in
                receiptRow(receipt)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            delete(receipt)
                        } label: {
                            Label("delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }

    private func receiptRow(_ receipt: Receipt) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.storeName.isEmpty ? NSLocalizedString("receipt_unknown_store", value: "Unknown store", comment: "") : receipt.storeName)
                    .font(.headline)
                Text(receipt.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if GoogleSheetsSyncService.isConfigured {
                    statusChip(for: receipt)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(receipt.formattedTotal())
                    .font(.title3.weight(.semibold))

                if GoogleSheetsSyncService.isConfigured {
                    syncButton(for: receipt)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func statusChip(for receipt: Receipt) -> some View {
        let synced = receipt.syncStatus == .synced
        return Label(
            receipt.syncStatus.localizedTitle,
            systemImage: synced ? "checkmark.circle.fill" : "clock"
        )
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(synced ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
        .foregroundStyle(synced ? Color.green : Color.orange)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func syncButton(for receipt: Receipt) -> some View {
        if receipt.syncStatus == .synced {
            EmptyView()
        } else if syncingIDs.contains(receipt.id) {
            ProgressView().controlSize(.small)
        } else {
            Button {
                Task { await syncToSheets(receipt) }
            } label: {
                Label("receipt_sync_button", systemImage: "arrow.up.doc")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .tint(.teal)
        }
    }

    // MARK: - Actions

    private struct IdentifiableReceipt: Identifiable {
        let id = UUID()
        let value: ReceiptOCRService.ParsedReceipt
    }

    private func processScannedImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        isProcessing = true
        Task {
            let parsed = await ReceiptOCRService.scan(images: images)
            await MainActor.run {
                isProcessing = false
                pendingReview = parsed
            }
        }
    }

    private func saveReceipt(store: String, total: Decimal, date: Date, raw: String) {
        let receipt = Receipt(
            date: date,
            storeName: store,
            total: total,
            currencySymbol: "$",
            rawText: raw,
            syncStatus: .pending
        )
        modelContext.insert(receipt)
        saveContext()
    }

    private func delete(_ receipt: Receipt) {
        withAnimation {
            modelContext.delete(receipt)
            saveContext()
        }
    }

    private func syncToSheets(_ receipt: Receipt) async {
        await MainActor.run { syncingIDs.insert(receipt.id) }

        let payload = GoogleSheetsSyncService.Payload(
            date: ISO8601DateFormatter().string(from: receipt.date),
            store: receipt.storeName,
            total: "\(receipt.total)",
            currencySymbol: receipt.currencySymbol
        )

        do {
            try await GoogleSheetsSyncService.send(payload: payload)
            await MainActor.run {
                receipt.syncStatus = .synced
                saveContext()
                syncingIDs.remove(receipt.id)
            }
        } catch {
            await MainActor.run {
                syncingIDs.remove(receipt.id)
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }

    private func saveContext() {
        do { try modelContext.save() }
        catch { print("SwiftData save error: \(error)") }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Receipt.self, configurations: config)
    return ReceiptTrackerView()
        .modelContainer(container)
}
