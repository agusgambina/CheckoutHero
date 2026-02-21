//
//  ShoppingItem.swift
//  CheckoutHero
//
//  Created by Agustin Gambina Pirillo on 2/20/26.
//

import Foundation
import SwiftData

@Model
final class ShoppingItem {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var pricePerUnit: Decimal
    var isChecked: Bool
    var createdDate: Date
    
    var shoppingList: ShoppingList?
    
    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String,
        pricePerUnit: Decimal,
        isChecked: Bool = false,
        createdDate: Date = Date(),
        shoppingList: ShoppingList? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.pricePerUnit = pricePerUnit
        self.isChecked = isChecked
        self.createdDate = createdDate
        self.shoppingList = shoppingList
    }
    
    /// Total price for this item (quantity × price per unit)
    var totalPrice: Decimal {
        Decimal(quantity) * pricePerUnit
    }
    
    /// Formatted quantity with unit
    var formattedQuantity: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        let quantityString = formatter.string(from: NSNumber(value: quantity)) ?? "\(quantity)"
        return "\(quantityString) \(unit)"
    }
    
    /// Formatted price per unit
    func formattedPricePerUnit(currencySymbol: String, locale: Locale = .current) -> String {
        CurrencyFormatterService.format(
            amount: pricePerUnit,
            currencySymbol: currencySymbol,
            locale: locale
        )
    }
    
    /// Formatted total price
    func formattedTotalPrice(currencySymbol: String, locale: Locale = .current) -> String {
        CurrencyFormatterService.format(
            amount: totalPrice,
            currencySymbol: currencySymbol,
            locale: locale
        )
    }
}

// MARK: - Common Units
extension ShoppingItem {
    /// Common units for products
    static let commonUnits = [
        "units",
        "kg",
        "g",
        "lb",
        "oz",
        "L",
        "mL",
        "gal",
        "pcs",
        "box",
        "bag",
        "bottle",
        "can"
    ]
}

// MARK: - Validation
extension ShoppingItem {
    /// Validates if the item has valid data (only name is required)
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        pricePerUnit >= 0
    }

    /// Validation errors
    enum ValidationError: Error, LocalizedError {
        case emptyName
        case negativePricePerUnit

        var errorDescription: String? {
            switch self {
            case .emptyName:
                return NSLocalizedString("item_validation_empty_name",
                                       value: "Item name cannot be empty",
                                       comment: "Validation error for empty item name")
            case .negativePricePerUnit:
                return NSLocalizedString("item_validation_negative_price",
                                       value: "Price cannot be negative",
                                       comment: "Validation error for negative price")
            }
        }
    }

    /// Validates and throws specific validation errors
    func validate() throws {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.emptyName
        }
        if pricePerUnit < 0 {
            throw ValidationError.negativePricePerUnit
        }
    }
}

// MARK: - Mock Data for Testing and Previews
extension ShoppingItem {
    /// Create a mock shopping item for testing
    static func mock(
        name: String = "Mock Item",
        quantity: Double = 1,
        unit: String = "units",
        pricePerUnit: Decimal = 5.99,
        isChecked: Bool = false
    ) -> ShoppingItem {
        ShoppingItem(
            name: name,
            quantity: quantity,
            unit: unit,
            pricePerUnit: pricePerUnit,
            isChecked: isChecked
        )
    }
    
    /// Create multiple mock items
    static func mockMultiple(count: Int = 5) -> [ShoppingItem] {
        let items = [
            ("Apples", 2.0, "kg", Decimal(3.50)),
            ("Milk", 1.0, "L", Decimal(2.99)),
            ("Bread", 2.0, "units", Decimal(2.50)),
            ("Chicken", 1.5, "kg", Decimal(8.99)),
            ("Tomatoes", 0.5, "kg", Decimal(4.50)),
            ("Cheese", 0.3, "kg", Decimal(12.99)),
            ("Orange Juice", 2.0, "L", Decimal(4.99)),
            ("Eggs", 1.0, "dozen", Decimal(3.49)),
            ("Butter", 0.25, "kg", Decimal(6.99)),
            ("Coffee", 0.5, "kg", Decimal(15.99))
        ]
        
        return (0..<count).map { index in
            let item = items[index % items.count]
            return mock(
                name: item.0,
                quantity: item.1,
                unit: item.2,
                pricePerUnit: item.3,
                isChecked: Bool.random()
            )
        }
    }
}
