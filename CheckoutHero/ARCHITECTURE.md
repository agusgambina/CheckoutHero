# CheckoutHero - Architecture Documentation

## Overview
This document describes the architecture, design patterns, and technical implementation details of CheckoutHero.

## Architecture Pattern: MVVM with Swift Data

### Components

#### Models (Swift Data)
- **Purpose**: Define data structure and relationships
- **Technology**: Swift Data with @Model macro
- **Responsibilities**:
  - Data persistence
  - Relationships between entities
  - Computed properties for derived data

#### Views (SwiftUI)
- **Purpose**: User interface and presentation
- **Technology**: SwiftUI
- **Responsibilities**:
  - Display data
  - User interaction
  - Navigation
  - Minimal business logic

#### ViewModels (ObservableObject)
- **Purpose**: Business logic and state management
- **Technology**: Combine framework via @Observable or ObservableObject
- **Responsibilities**:
  - CRUD operations on models
  - Data transformation
  - Validation
  - Coordination between views and models

#### Services
- **Purpose**: Cross-cutting concerns and utilities
- **Technology**: Swift classes/structs
- **Responsibilities**:
  - Formatting (currency, numbers)
  - Localization helpers
  - Shared utilities

## Data Flow

```
User Interaction → View → ViewModel → Swift Data Model → Persistence
                    ↑                      ↓
                    └──────────────────────┘
                      (Observable updates)
```

1. User interacts with View
2. View calls ViewModel method
3. ViewModel updates Model via ModelContext
4. Swift Data persists changes
5. SwiftUI observes changes and updates View automatically

## Data Model Details

### ShoppingList Model

```swift
@Model
final class ShoppingList {
    var id: UUID
    var name: String
    var createdDate: Date
    var modifiedDate: Date
    var currencySymbol: String
    
    @Relationship(deleteRule: .cascade, inverse: \ShoppingItem.shoppingList)
    var items: [ShoppingItem]
    
    // Computed properties
    var totalAmount: Decimal { ... }
    var checkedAmount: Decimal { ... }
    var itemCount: Int { items.count }
}
```

**Key Design Decisions**:
- `deleteRule: .cascade` ensures items are deleted when list is deleted
- `inverse` relationship maintains data integrity
- Computed properties for UI display (not stored)
- `currencySymbol` as String for maximum flexibility

### ShoppingItem Model

```swift
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
    
    // Computed properties
    var totalPrice: Decimal { ... }
}
```

**Key Design Decisions**:
- `quantity` as Double allows fractional quantities (e.g., 1.5 kg)
- `pricePerUnit` and calculations use Decimal for accuracy
- `unit` as String provides flexibility (not enum)
- `isChecked` tracks shopping progress

## Service Layer

### CurrencyFormatterService

**Purpose**: Format monetary values consistently

```swift
struct CurrencyFormatterService {
    static func format(
        amount: Decimal,
        currencySymbol: String,
        locale: Locale = .current
    ) -> String
}
```

**Features**:
- Respects locale for decimal separator
- Positions currency symbol correctly
- Handles different decimal places per currency
- Thread-safe (stateless)

### LocalizationService

**Purpose**: Provide localization utilities

```swift
struct LocalizationService {
    static var currentLanguage: String { ... }
    static var supportedLanguages: [String] { ... }
    static func localizedString(key: String) -> String { ... }
}
```

**Features**:
- Wraps NSLocalizedString
- Provides language switching capabilities
- Lists available translations

## View Architecture

### Navigation Structure

```
ShoppingListsView (Root)
    ├── CreateListView (Sheet)
    └── ShoppingItemsView (NavigationLink)
            ├── AddItemView (Sheet)
            └── EditItemView (Sheet)
```

### View Responsibilities

#### ShoppingListsView
- Display all shopping lists
- Show total and item count for each
- Navigate to list details
- Delete lists
- Create new lists

#### ShoppingItemsView
- Display items in a list
- Show running total
- Check/uncheck items
- Edit items
- Delete items
- Add new items

#### TotalDisplayView
- Reusable component
- Display formatted total
- Show breakdown (checked/unchecked)
- Prominent display for shopping

## State Management

### Swift Data + SwiftUI Integration

```swift
@main
struct CheckoutHeroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ShoppingList.self, ShoppingItem.self])
    }
}
```

**Environment Propagation**:
- ModelContainer injected at app level
- Available throughout view hierarchy
- Views query data directly using @Query

### Query Pattern

```swift
struct ShoppingListsView: View {
    @Query(sort: \ShoppingList.modifiedDate, order: .reverse)
    private var shoppingLists: [ShoppingList]
    
    @Environment(\.modelContext) private var modelContext
}
```

**Benefits**:
- Automatic updates when data changes
- No manual refresh needed
- Type-safe queries
- Efficient performance

## Localization Strategy

### String Catalogs

**File**: `Localizable.xcstrings`

**Structure**:
```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "shopping_lists_title" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : { "stringUnit" : { "value" : "Shopping Lists" } },
        "es" : { "stringUnit" : { "value" : "Listas de Compras" } }
      }
    }
  }
}
```

**Usage in Code**:
```swift
Text("shopping_lists_title", bundle: .main)
// or
Text(LocalizedStringKey("shopping_lists_title"))
```

## Currency Design

### Currency Agnostic Approach

**Philosophy**: The app doesn't know about currencies, only symbols

**Implementation**:
1. User selects or enters currency symbol when creating list
2. Symbol stored as plain string with list
3. Formatter adds symbol to numbers
4. No conversion or validation

**Benefits**:
- Works offline
- Simple implementation
- Supports any currency
- No API dependencies
- No exchange rate issues

**Trade-offs**:
- Can't validate if symbol is real currency
- Can't convert between currencies
- User responsibility to use correct symbol

### Common Currency Symbols

Pre-populated for user convenience:
- $ (USD, CAD, AUD, etc.)
- € (EUR)
- £ (GBP)
- ¥ (JPY, CNY)
- ₹ (INR)
- R$ (BRL)
- ₽ (RUB)
- ₪ (ILS)
- CHF
- Custom input option

## Testing Strategy

### Unit Testing with Swift Testing

**Framework**: Swift Testing (modern alternative to XCTest)

**Test Structure**:
```swift
import Testing
@testable import CheckoutHero

@Suite("ShoppingList Tests")
struct ShoppingListTests {
    
    @Test("Calculate total amount correctly")
    func calculateTotalAmount() async throws {
        // Arrange
        let list = ShoppingList(...)
        
        // Act
        let total = list.totalAmount
        
        // Assert
        #expect(total == expectedTotal)
    }
}
```

### Test Categories

#### 1. Model Tests
- **ShoppingListTests**: Total calculation, item management
- **ShoppingItemTests**: Price calculation, validation

#### 2. ViewModel Tests
- CRUD operations
- State management
- Error handling
- Edge cases (empty lists, zero prices)

#### 3. Service Tests
- Currency formatting
- Localization
- Edge cases (negative numbers, very large numbers)

### Mock Data

Create mock data helpers for testing:
```swift
extension ShoppingList {
    static func mock(itemCount: Int = 3) -> ShoppingList { ... }
}
```

### Test Coverage Goals

- **Models**: 100%
- **ViewModels**: 95%+
- **Services**: 100%
- **Views**: Not unit tested (use Preview for visual testing)

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Use `@Query` with filters
2. **Efficient Calculations**: Cache computed totals when needed
3. **List Virtualization**: SwiftUI's List handles this automatically
4. **Decimal Performance**: Acceptable for shopping cart use case
5. **Memory**: Cascade deletes prevent orphaned data

### Scalability

**Expected Limits**:
- ~100 lists per user (generous)
- ~200 items per list (very large shopping trip)
- No performance issues expected with these numbers

**If Scaling Needed**:
- Add pagination for lists
- Lazy load items
- Archive old lists
- Add search/filter

## Security & Privacy

### Data Privacy
- All data stored locally
- No network requests
- No analytics or tracking
- User owns their data

### Data Backup
- Stored in app's container (backed up by iOS)
- Can be excluded from backup if needed
- Future: iCloud sync option

## Error Handling

### Strategy

1. **Graceful Degradation**: App continues working even with errors
2. **User Feedback**: Show alerts for critical errors
3. **Logging**: Print errors in debug mode
4. **Recovery**: Allow user to retry operations

### Common Error Scenarios

- **Save Failure**: Show alert, keep data in memory
- **Delete Failure**: Show alert, don't remove from UI
- **Invalid Input**: Validate before saving
- **Data Corruption**: Validate on load, skip corrupted items

## Accessibility

### Compliance
- VoiceOver support (automatic with SwiftUI)
- Dynamic Type support
- High contrast colors
- Semantic labels for all interactive elements

### Implementation
```swift
Text("Total")
    .accessibilityLabel("Shopping cart total")
    .accessibilityValue(formattedTotal)
```

## Future Architecture Considerations

### iCloud Sync
- Add CloudKit integration
- Handle merge conflicts
- Maintain offline capability

### Sharing Lists
- Add UserDefaults for sharing preferences
- Implement CloudKit sharing
- Handle permissions

### Watch App
- Lightweight read-only view
- Show active list total
- Quick check-off items

## Development Workflow

### Git Workflow
1. Feature branches from main
2. PR with tests before merge
3. Tag releases (v1.0.0, etc.)

### Code Review Checklist
- [ ] Unit tests included
- [ ] Strings localized
- [ ] Accessibility labels added
- [ ] Documentation updated
- [ ] No force unwrapping
- [ ] Error handling in place

## Dependencies

### Native Frameworks Only
- SwiftUI
- Swift Data
- Foundation
- Combine (minimal, mostly @Observable)

**No Third-Party Dependencies** = 
- Smaller app size
- Better security
- Easier maintenance
- Full control

## Conclusion

This architecture provides:
- ✅ Clean separation of concerns
- ✅ Testable components
- ✅ Scalable structure
- ✅ Modern Swift practices
- ✅ Maintainable codebase
- ✅ Type safety
- ✅ Declarative UI

The architecture supports the current requirements and allows for future enhancements without major refactoring.

