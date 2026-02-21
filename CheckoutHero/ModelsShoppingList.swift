//
//  ShoppingList.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import Foundation
import SwiftData

@Model
final class ShoppingList {
    var id: UUID
    var name: String
    var createdDate: Date
    var modifiedDate: Date
    var currencySymbol: String
    
    @Relationship(deleteRule: .cascade, inverse: \ShoppingItem.shoppingList)
    var items: [ShoppingItem]
    
    init(
        id: UUID = UUID(),
        name: String,
        createdDate: Date = Date(),
        modifiedDate: Date = Date(),
        currencySymbol: String = "$",
        items: [ShoppingItem] = []
    ) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.currencySymbol = currencySymbol
        self.items = items
    }
    
    /// Total amount for all items in the list
    var totalAmount: Decimal {
        items.reduce(Decimal(0)) { $0 + $1.totalPrice }
    }
    
    /// Total amount for checked items only
    var checkedAmount: Decimal {
        items.filter { $0.isChecked }
            .reduce(Decimal(0)) { $0 + $1.totalPrice }
    }
    
    /// Total amount for unchecked items
    var remainingAmount: Decimal {
        totalAmount - checkedAmount
    }
    
    /// Number of items in the list
    var itemCount: Int {
        items.count
    }
    
    /// Number of checked items
    var checkedItemCount: Int {
        items.filter { $0.isChecked }.count
    }
    
    /// Formatted total amount with currency symbol
    func formattedTotal(locale: Locale = .current) -> String {
        CurrencyFormatterService.format(
            amount: totalAmount,
            currencySymbol: currencySymbol,
            locale: locale
        )
    }
    
    /// Formatted checked amount with currency symbol
    func formattedCheckedAmount(locale: Locale = .current) -> String {
        CurrencyFormatterService.format(
            amount: checkedAmount,
            currencySymbol: currencySymbol,
            locale: locale
        )
    }
    
    /// Formatted remaining amount with currency symbol
    func formattedRemainingAmount(locale: Locale = .current) -> String {
        CurrencyFormatterService.format(
            amount: remainingAmount,
            currencySymbol: currencySymbol,
            locale: locale
        )
    }
}

// MARK: - Mock Data for Testing and Previews
extension ShoppingList {
    /// Create a mock shopping list for testing
    static func mock(
        name: String = "Grocery Shopping",
        currencySymbol: String = "$",
        itemCount: Int = 3
    ) -> ShoppingList {
        let list = ShoppingList(
            name: name,
            currencySymbol: currencySymbol
        )
        
        let mockItems = [
            ShoppingItem(name: "Apples", quantity: 2, unit: "kg", pricePerUnit: 3.50),
            ShoppingItem(name: "Milk", quantity: 1, unit: "L", pricePerUnit: 2.99),
            ShoppingItem(name: "Bread", quantity: 2, unit: "units", pricePerUnit: 2.50),
            ShoppingItem(name: "Chicken", quantity: 1.5, unit: "kg", pricePerUnit: 8.99),
            ShoppingItem(name: "Tomatoes", quantity: 0.5, unit: "kg", pricePerUnit: 4.50),
        ]
        
        list.items = Array(mockItems.prefix(itemCount))
        
        // Mark some items as checked
        if list.items.count > 0 {
            list.items[0].isChecked = true
        }
        
        return list
    }
    
    /// Create multiple mock shopping lists
    static func mockMultiple(count: Int = 3) -> [ShoppingList] {
        let names = [
            "Weekly Groceries",
            "Party Shopping",
            "Weekend BBQ",
            "Health Foods",
            "Bulk Purchase"
        ]
        
        let currencies = ["$", "€", "£", "¥", "R$"]
        
        return (0..<count).map { index in
            mock(
                name: names[index % names.count],
                currencySymbol: currencies[index % currencies.count],
                itemCount: (2...5).randomElement() ?? 3
            )
        }
    }
}
