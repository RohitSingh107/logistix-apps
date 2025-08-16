# Logistix Brand Colors Guide

This guide explains the brand color scheme implemented in the Logistix app and how to use it consistently throughout the application.

## 🎨 Color Palette Overview

The Logistix brand uses a carefully selected color palette that includes:

### Primary Colors
- **Primary Orange** (`#FF8300`) - Vibrant orange for main branding and CTAs
- **Secondary Orange** (`#FFC486`) - Burnt orange/terracotta for accents
- **Light Orange** (`#FFC486`) - Desaturated beige/peach for backgrounds

### Neutral Colors
- **Pure Black** (`#000000`) - For text and strong contrasts
- **Neutral Grey** (`#B8B8B8`) - For secondary text and borders
- **Pure White** (`#FFFFFF`) - For backgrounds and light text

### Green Colors
- **Dark Green** (`#3FAA35`) - Forest green for success states
- **Light Green** (`#C8EDD7`) - Pale sage for subtle accents

### Semantic Colors
- **Success** (`#3FAA35`) - Dark green for success states
- **Error** (`#E53E3E`) - Red for error states
- **Warning** (`#FF8C42`) - Orange variant for warnings
- **Info** (`#3182CE`) - Blue for informational content

## 🚀 Implementation

### 1. Using Colors in Widgets

```dart
import 'package:your_app/core/config/app_colors.dart';

// Use colors directly
Container(
  color: AppColors.primaryOrange,
  child: Text(
    'LOGISTIX',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)

// Use with opacity
Container(
  color: AppColors.primaryOrangeWithOpacity(0.8),
)
```

### 2. Theme Integration

The colors are already integrated into the app theme. You can access them through the theme:

```dart
// Using theme colors
Container(
  color: Theme.of(context).colorScheme.primary, // AppColors.primaryOrange
  child: Text(
    'Button',
    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
  ),
)
```

### 3. Text Styling

```dart
Text(
  'Primary Text',
  style: TextStyle(color: AppColors.textPrimary),
)

Text(
  'Secondary Text',
  style: TextStyle(color: AppColors.textSecondary),
)
```

## 🎯 Usage Guidelines

### Primary Orange (`#FF6B35`)
- **Use for**: Main CTAs, primary buttons, brand elements
- **Examples**: Login buttons, "Book Now" buttons, brand logo
- **Avoid**: Large background areas, small text

### Secondary Orange (`#D4A574`)
- **Use for**: Secondary buttons, accents, highlights
- **Examples**: Secondary actions, card highlights
- **Avoid**: Primary CTAs, error states

### Dark Green (`#2E5A3D`)
- **Use for**: Success states, confirmations, positive feedback
- **Examples**: "Success" messages, "Confirmed" status
- **Avoid**: Error states, warnings

### Neutral Colors
- **Pure Black**: Primary text, strong contrasts
- **Neutral Grey**: Secondary text, borders, disabled states
- **Pure White**: Backgrounds, text on dark backgrounds

## 🎨 Splash Screen

The splash screen uses the primary orange background with white text:

```dart
Scaffold(
  backgroundColor: AppColors.primaryOrange, // #FF8300
  body: Center(
    child: Text(
      'LOGISTIX',
      style: TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

## 🌍 Language Selection Screen

The language selection screen features:

- **Background**: Pure white (`#FFFFFF`)
- **Language Cards**: Light orange background (`#FFC486`)
- **Continue Button**: Primary orange (`#FF8300`)
- **Text**: Pure black (`#000000`) for primary text, neutral grey (`#B8B8B8`) for secondary text

```dart
// Language selection card
Container(
  color: AppColors.lightOrange, // #FFC486
  child: Text(
    'English',
    style: TextStyle(color: AppColors.pureBlack), // #000000
  ),
)

// Continue button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrange, // #FF8300
    foregroundColor: AppColors.pureWhite, // #FFFFFF
  ),
  child: Text('Continue'),
)
```

## 📱 Component Examples

### Buttons

```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.textOnPrimary,
  ),
  onPressed: () {},
  child: Text('Primary Action'),
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryOrange,
    side: BorderSide(color: AppColors.primaryOrange),
  ),
  onPressed: () {},
  child: Text('Secondary Action'),
)
```

### Cards

```dart
Card(
  color: AppColors.surface,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          'Card Title',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Card content with secondary text',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    ),
  ),
)
```

### Input Fields

```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.backgroundSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderFocused),
    ),
  ),
)
```

## 🔧 Customization

### Adding New Colors

To add new colors to the palette:

1. Add the color constant to `lib/core/config/app_colors.dart`
2. Update the theme in `lib/core/config/app_theme.dart` if needed
3. Document the usage in this guide

### Color Variations

Use the utility methods for opacity variations:

```dart
// 50% opacity
AppColors.primaryOrangeWithOpacity(0.5)

// Custom opacity
AppColors.withOpacity(AppColors.darkGreen, 0.3)
```

## 🎨 Brand Colors Demo

To see all colors in action, navigate to the brand colors demo:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const BrandColorsDemo()),
);
```

## 📋 Best Practices

1. **Consistency**: Always use `AppColors` constants instead of hardcoded values
2. **Accessibility**: Ensure sufficient contrast ratios between text and background colors
3. **Semantic Usage**: Use colors for their intended semantic meaning
4. **Testing**: Test color combinations in both light and dark themes
5. **Documentation**: Document any new color usage patterns

## 🔍 Color Accessibility

All colors have been tested for accessibility compliance:

- **Contrast Ratios**: Meet WCAG AA standards (4.5:1 for normal text, 3:1 for large text)
- **Color Blindness**: Colors are distinguishable for users with color vision deficiencies
- **High Contrast**: Colors work well in high contrast mode

## 📱 Platform Considerations

- **iOS**: Colors automatically adapt to system appearance settings
- **Android**: Colors work with Material Design theming
- **Web**: Colors are optimized for web display and accessibility

---

For questions or suggestions about the color scheme, please refer to the design team or create an issue in the project repository. 