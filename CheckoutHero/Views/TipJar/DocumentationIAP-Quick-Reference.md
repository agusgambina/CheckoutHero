# 📋 Quick Reference: Copy & Paste for App Store Connect

Use this as your cheat sheet while filling out App Store Connect forms.

---

## 🎯 Product 1: tip_small

### Basic Info
```
Reference Name: Small Tip
Product ID: tip_small
Type: Consumable
Price Tier: 1 ($0.99 USD)
```

### Localization (English - U.S.)
```
Display Name:
Small Tip 🙏

Description:
Support CheckoutHero with a small tip! Your generosity helps keep this app free and improving. Every contribution makes a difference!
```

### Review Notes
```
This is a voluntary tip to support the app. No additional features are unlocked.
```

---

## 💙 Product 2: tip_medium

### Basic Info
```
Reference Name: Medium Tip
Product ID: tip_medium
Type: Consumable
Price Tier: 3 ($2.99 USD)
```

### Localization (English - U.S.)
```
Display Name:
Medium Tip 💙

Description:
Show your appreciation with a medium tip! Help fund new features and ongoing development. Your support means everything!
```

### Review Notes
```
This is a voluntary tip to support the app. No additional features are unlocked.
```

---

## 🌟 Product 3: tip_large

### Basic Info
```
Reference Name: Large Tip
Product ID: tip_large
Type: Consumable
Price Tier: 5 ($4.99 USD)
```

### Localization (English - U.S.)
```
Display Name:
Large Tip 🌟

Description:
Make a big impact with a large tip! You're making a real difference in keeping CheckoutHero awesome. Thank you for being amazing!
```

### Review Notes
```
This is a voluntary tip to support the app. No additional features are unlocked.
```

---

## 📝 Review Information (Same for all products)

### Why are these consumable?
```
Tips are consumable products because users may want to tip multiple times to show ongoing support. Unlike non-consumables, this allows users to purchase the same tip tier multiple times if they wish.
```

### Purpose of IAPs
```
These are voluntary tips that allow users to support the development of CheckoutHero. They are clearly labeled as tips and do not unlock any additional features, content, or functionality. Users can fully use the app without making any purchases.
```

---

## ⚡ Quick Actions Checklist

### For Each Product:
1. ✅ Set Product ID (must match code exactly!)
2. ✅ Set Reference Name
3. ✅ Select "Consumable" type
4. ✅ Choose Price Tier
5. ✅ Check "Cleared for Sale"
6. ✅ Add English localization
7. ✅ Copy/paste Display Name (with emoji!)
8. ✅ Copy/paste Description
9. ✅ Upload screenshot
10. ✅ Add review notes
11. ✅ Click "Save"
12. ✅ Verify status is "Ready to Submit"

### Attach to App Version:
1. ✅ Go to your app version (1.0)
2. ✅ Scroll to "In-App Purchases and Subscriptions"
3. ✅ Click "+"
4. ✅ Select all three products
5. ✅ Click "Done"
6. ✅ Verify all three appear in the list

---

## 🎨 Emojis to Copy

In case they don't paste correctly:

```
🙏 (for Small Tip)
💙 (for Medium Tip)
🌟 (for Large Tip)
☕ (coffee - optional for descriptions)
```

---

## 💰 Price Tiers Quick Reference

```
Tier 1 = $0.99 USD
Tier 3 = $2.99 USD
Tier 5 = $4.99 USD
```

---

## 🔗 Important Product IDs (Must Match Code!)

```
tip_small
tip_medium
tip_large
```

⚠️ **CRITICAL:** These must match your code EXACTLY (case-sensitive, no spaces)

---

## 📱 Testing in Simulator

After setting up in App Store Connect, test locally:

```
1. Xcode: File → New → StoreKit Configuration File → StoreKit.storekit
2. Add same 3 products with matching IDs
3. Edit Scheme → Run → Options → StoreKit Configuration
4. Run app and test purchases
```

---

## 🚨 Common Mistakes to Avoid

❌ **Wrong Product ID** (tip-small instead of tip_small)
✅ Use: tip_small, tip_medium, tip_large

❌ **Forgot to attach to app version**
✅ Always attach IAPs to your specific app version

❌ **Missing screenshot**
✅ Upload at least one screenshot per product

❌ **Forgot localization**
✅ At least English (U.S.) is required

❌ **Left "Cleared for Sale" unchecked**
✅ Must be checked for products to be available

---

## 📞 If Apple Asks Questions During Review

### "What do users get with these purchases?"

```
These are voluntary tips that support the ongoing development of CheckoutHero. 
Users do not receive any additional features, content, or functionality. 
The app is fully functional without making any purchases. Tips are clearly 
labeled as such in the app's interface.
```

### "Why are these consumable?"

```
Tips are implemented as consumable in-app purchases to allow users to tip 
multiple times if they wish to show ongoing support for the app. This is 
similar to how tipping works in real-world scenarios - users can tip as 
often as they like.
```

### "Where are these shown in the app?"

```
The tip options are accessible through the Settings screen under 
"Support CheckoutHero". Users must actively navigate to this section 
and explicitly choose to support the app. There are no prompts, 
popups, or forced requests for tips.
```

---

**Last Updated:** March 13, 2026  
**App:** CheckoutHero v1.0  
**Product IDs:** tip_small, tip_medium, tip_large
