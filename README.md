<p align="center">
  <img src="CheckoutHero/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" width="120" alt="CheckoutHero App Icon">
</p>

<h1 align="center">CheckoutHero</h1>

<p align="center">
  A modern iOS shopping list app — track expenses in real-time, manage multiple lists, and never lose track of your spending.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-007AFF.svg?style=flat-square" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/Swift-5.9+-FA7343.svg?style=flat-square" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/SwiftUI-5-00C389.svg?style=flat-square" alt="SwiftUI">
  <img src="https://img.shields.io/badge/SwiftData-1.0-A550D7.svg?style=flat-square" alt="SwiftData">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat-square" alt="MIT License">
</p>

---

## Features

| Feature | Description |
|---|---|
| Multiple Lists | Create and manage unlimited shopping lists |
| Real-time Totals | Running total, checked amount, and remaining — all live |
| Smart Item Editing | Tap quantity or price chips directly on the row to edit |
| Back-calculation | Enter a total price and the app calculates price-per-unit |
| Duplicate Lists | Recreate recurring shopping trips in one tap |
| Multi-currency | 20+ currencies pre-loaded; any custom symbol supported |
| Offline-first | 100% local storage — no account, no cloud, no tracking |
| Localized | English and Spanish, switchable in-app |
| Dark Mode | Full system appearance support |

---

## Screenshots

> _Coming soon_

---

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

---

## Installation

```bash
git clone https://github.com/agusgambina/CheckoutHero.git
cd CheckoutHero
open CheckoutHero.xcodeproj
```

No external dependencies. Press `Cmd + R` to build and run.

---

## Project Structure

```
CheckoutHero/
├── CheckoutHeroApp.swift         # App entry point, ModelContainer, LanguageService
├── ContentView.swift
│
├── Models/
│   ├── ModelsShoppingList.swift  # @Model — list with cascade delete
│   └── ModelsShoppingItem.swift  # @Model — item with validation
│
├── Services/
│   ├── ServicesCurrencyFormatterService.swift  # Locale-aware Decimal formatting
│   ├── ServicesLocalizationService.swift       # Currency catalog, locale utilities
│   └── ServicesLanguageService.swift           # @Observable language switcher
│
├── Views/
│   ├── ShoppingLists/            # List management screens
│   ├── ShoppingItems/            # Item management screens
│   └── Components/               # TotalDisplayView, CurrencyPickerView
│
├── Settings/
│   └── ViewsSettingsView.swift
│
└── Resources/
    └── Localizable.xcstrings     # String catalog (EN + ES)
```

---

## Architecture

**Pattern**: MVVM + SwiftData

```
User Action → SwiftUI View
           → Direct @Model mutation via @Bindable / ModelContext
           → SwiftData persists automatically
           → @Query observes change → View re-renders
```

**Key decisions**:
- Services are stateless `struct`s with `static` methods — no singleton overhead
- `LanguageService` is `@Observable` and injected via `.environment()` — drives locale-aware re-renders
- `Decimal` for all price arithmetic — no floating-point rounding errors
- Zero external dependencies — native Swift/Apple frameworks only

---

## Privacy

- No network requests
- No analytics, crash reporters, or trackers
- All data stored locally on-device
- Included in standard iOS encrypted backups
- No account required

---

## Localization

Currently supported: **English** and **Spanish**.

To add a new language:
1. Open `Localizable.xcstrings` in Xcode
2. Click **+** → select language
3. Translate all string entries
4. Build and test

---

## Roadmap

- [ ] iCloud sync
- [ ] Share lists with family
- [ ] Budget limits and warnings
- [ ] Home Screen widgets
- [ ] Spending history and charts
- [ ] Barcode scanning
- [ ] Apple Watch companion

---

## Support the Project

CheckoutHero is free and will always remain free.

If it saves you time and money at the supermarket, consider leaving a tip inside the app (**Settings → Support CheckoutHero**) — or buying me a coffee:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-support-%23FFDD00?style=flat-square&logo=buy-me-a-coffee&logoColor=black)](https://cafecito.app/agusgambina)

---

## License

Distributed under the [MIT License](LICENSE).

---

<p align="center">Made with Swift · iOS 17+ · SwiftUI · SwiftData</p>
