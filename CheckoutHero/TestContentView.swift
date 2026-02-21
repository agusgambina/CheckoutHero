//
//  TestContentView.swift
//  CheckoutHero
//
//  Quick test view to verify models work
//

import SwiftUI
import SwiftData

struct TestContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [ShoppingList]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CheckoutHero Debug View")
                .font(.title)
            
            Text("Lists in database: \(lists.count)")
                .font(.headline)
            
            Button("Create Test List") {
                createTestList()
            }
            .buttonStyle(.borderedProminent)
            
            if !lists.isEmpty {
                List {
                    ForEach(lists) { list in
                        VStack(alignment: .leading) {
                            Text(list.name)
                                .font(.headline)
                            Text("Currency: \(list.currencySymbol)")
                                .font(.caption)
                            Text("Items: \(list.itemCount)")
                                .font(.caption)
                        }
                    }
                    .onDelete(perform: deleteLists)
                }
            }
            
            Button("Delete All Lists") {
                deleteAllLists()
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
    }
    
    private func createTestList() {
        let list = ShoppingList(
            name: "Test List \(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 1000))",
            currencySymbol: "$"
        )
        
        modelContext.insert(list)
        
        do {
            try modelContext.save()
            print("✅ List created successfully: \(list.name)")
        } catch {
            print("❌ Failed to save list: \(error)")
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(lists[index])
        }
        try? modelContext.save()
    }
    
    private func deleteAllLists() {
        for list in lists {
            modelContext.delete(list)
        }
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, ShoppingItem.self, configurations: config)
    
    return TestContentView()
        .modelContainer(container)
}
