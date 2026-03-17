# 💙 Tip Jar - Visual Design Spec

## Layout Overview

```
┌─────────────────────────────────────┐
│         Navigation Title            │
│      "Support CheckoutHero"         │
├─────────────────────────────────────┤
│                                     │
│              ❤️                     │
│           (Pulsing)                 │
│                                     │
│       Buy Me a Coffee ☕            │
│                                     │
│  CheckoutHero is free and ad-free. │
│  If you find it helpful, consider  │
│         leaving a tip!              │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  ◯    Small Tip 🙏            │ │
│  │ 🩷    Buy me a coffee    $0.99 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  ⬤    Medium Tip 💙           │ │
│  │ ❤️    Buy me lunch       $2.99 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  ⦿    Large Tip 🌟            │ │
│  │ 💜    You're amazing!    $4.99 │ │
│  └───────────────────────────────┘ │
│                                     │
│  Tips help fund ongoing development │
│  and keep the app free for everyone.│
│    Thank you for your support! 💙   │
│                                     │
└─────────────────────────────────────┘
```

## Color Palette

### Icons
- **Small Tip:** Pink heart outline (`heart`)
- **Medium Tip:** Red filled heart (`heart.fill`)
- **Large Tip:** Purple heart in circle (`heart.circle.fill`)

### Background Colors
- **Icon Circles:** 15% opacity of icon color
- **Cards:** Secondary system grouped background
- **Card Borders:** 20% opacity of icon color
- **Overall Background:** System grouped background

## Typography

### Header Section
- **Icon:** System size 64pt, pink gradient
- **Title:** Title 2, bold, center aligned
- **Description:** Subheadline, secondary color, center aligned

### Tip Cards
- **Display Name:** Headline weight, primary color
- **Description:** Caption size, secondary color
- **Price:** Title 3, semibold, primary color

### Footer
- **Text:** Caption size, secondary color, center aligned

## Spacing

### Vertical Spacing
- Top padding: 20pt
- Section spacing: 20pt
- Card spacing: 12pt
- Footer top padding: 8pt
- Bottom padding: 20pt

### Horizontal Spacing
- Icon to text: 16pt
- Card padding: 16pt all around
- Edge margins: System default (via .padding(.horizontal))

## Card Design

### Structure
```
┌─────────────────────────────────────────┐
│  [Circle]  [Title]           [Price]    │
│   [Icon]   [Description]                │
└─────────────────────────────────────────┘
```

### Properties
- **Corner Radius:** 12pt
- **Border:** 1pt stroke with 20% opacity color
- **Icon Circle:** 56x56pt
- **Tap Effect:** System button style (plain)

## Thank You Screen

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│               ❤️                    │
│           (Red, Large)              │
│                                     │
│           Thank You!                │
│                                     │
│  Your support means the world and   │
│  helps keep CheckoutHero free and   │
│   improving. You're awesome! 💙     │
│                                     │
│         ┌──────────┐                │
│         │   Done   │                │
│         └──────────┘                │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### Properties
- **Heart Icon:** System size 60pt, red color
- **Title:** Large title, bold
- **Message:** Body text, secondary color, center aligned
- **Button:** Bordered prominent style, teal tint

## Animations

### Header Heart
- **Effect:** `.symbolEffect(.pulse)`
- **Behavior:** Continuous gentle pulsing animation

### Card Interactions
- **Tap:** Instant feedback (plain button style)
- **Purchase:** Sheet transition for thank you screen

## States

### Loading
```
┌─────────────────────────────────────┐
│                                     │
│           ⟳ Spinner                 │
│                                     │
│       Loading products...           │
│                                     │
└─────────────────────────────────────┘
```

### Error / Unavailable
```
┌─────────────────────────────────────┐
│                                     │
│      ⚠️ Tips Unavailable            │
│                                     │
│  Unable to load tip options.        │
│  Please check your internet         │
│  connection and try again.          │
│                                     │
└─────────────────────────────────────┘
```

### Success (Products Loaded)
- Shows full tip card layout
- All three products visible
- Interactive and ready for purchase

## Accessibility

### VoiceOver Labels
- Icon images: Decorative (no label needed)
- Card buttons: "{Display Name}, {Price}, button"
- Header: "Buy me a coffee. CheckoutHero is free..."
- Footer: Reads as continuous text

### Dynamic Type
- All text scales with user's preferred text size
- Layout adjusts automatically
- Card spacing maintains readability

### Color Contrast
- Primary text on background: WCAG AA compliant
- Secondary text: Appropriately muted but readable
- Icon colors: Strong contrast against backgrounds

## Screenshot Considerations

### Best Appearance
- **Device:** iPhone 15 Pro or larger
- **Orientation:** Portrait
- **Mode:** Light mode recommended (cleaner for screenshots)
- **Timing:** After products fully load
- **Status Bar:** Standard iOS simulator status

### What to Capture
- ✅ Full Tip Jar view
- ✅ All three tip options visible
- ✅ Prices clearly shown
- ✅ Navigation title visible
- ✅ Clean, professional appearance

## Implementation Notes

### SwiftUI Components Used
- `ScrollView` - Main container
- `VStack` - Vertical layout
- `HStack` - Card layout
- `ZStack` - Icon circles
- `Button` - Tap interaction
- `Image(systemName:)` - SF Symbols
- `LocalizedStringKey` - Localization
- `.symbolEffect()` - Animation
- `.sheet()` - Thank you screen

### Custom Components
- `TipOptionCard` - Reusable card view
- Takes: product, icon, color, label, description, action
- Returns: Styled interactive card

## Responsive Behavior

### iPhone SE (Small)
- Cards stack vertically (same as larger devices)
- Text wraps appropriately
- Maintains readability

### iPhone Pro Max (Large)
- More breathing room
- Same proportions, better spacing
- Easier to read

### iPad
- Centers content
- Maximum width constraint recommended
- Otherwise same design

## Dark Mode Support

All colors are semantic and automatically adapt:
- Background colors invert appropriately
- Text remains readable
- Icon colors maintain vibrancy
- Card borders stay subtle

---

**Design Philosophy:** Clean, friendly, non-intrusive. The Tip Jar should feel like a gentle "thanks for considering" rather than a pushy monetization attempt.

**User Experience:** Users should immediately understand what they're looking at, feel good about supporting, and have a delightful experience whether they tip or not.
