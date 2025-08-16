# Language Feature Implementation Guide

This guide explains the language selection and localization feature implemented in the Logistix app.

## 🌍 Overview

The app now supports multiple languages with a dedicated language selection screen that appears after the splash screen. Users can choose between English and Hindi, and the selection is persisted throughout the app.

## 🎨 Design Implementation

### Language Selection Screen
- **Location**: `lib/features/language/presentation/screens/language_selection_screen.dart`
- **Design**: Matches the exact design from the provided image
- **Features**:
  - Two language cards (English and Hindi) with large alphabet characters
  - Radio button selection indicators
  - Continue button with primary orange color
  - Country selection with India flag
  - Responsive layout with proper spacing

### Color Scheme
- **Primary Orange**: `#FF8300` - Used for continue button and selection indicators
- **Light Orange**: `#FFC486` - Used for language card backgrounds
- **Pure Black**: `#000000` - Used for primary text
- **Neutral Grey**: `#B8B8B8` - Used for secondary text
- **Pure White**: `#FFFFFF` - Used for backgrounds

## 🔧 Technical Implementation

### 1. Language Service
**Location**: `lib/core/services/language_service.dart`

```dart
// Set language
await LanguageService.setLanguage('English');

// Get current language
String language = await LanguageService.getLanguage();

// Check if language is set
bool isSet = await LanguageService.isLanguageSet();
```

### 2. Localization System
**Location**: `lib/core/localization/app_localizations.dart`

```dart
// Get localized string
String text = AppLocalizations.of(context).get('chooseLanguage');

// Supported languages
static const Locale englishLocale = Locale('en', 'IN');
static const Locale hindiLocale = Locale('hi', 'IN');
```

### 3. Navigation Flow
1. **Splash Screen** → Checks if language is set
2. **Language Selection** → If language not set
3. **Welcome/Login** → After language selection

## 📱 Usage Examples

### Using Localized Strings

```dart
// In any widget
Text(
  AppLocalizations.of(context).get('continue'),
  style: TextStyle(color: AppColors.pureBlack),
)
```

### Language Selection

```dart
// Navigate to language selection
Navigator.pushNamed(context, '/language-selection');

// Set language programmatically
await LanguageService.setLanguage('Hindi');
```

### Country Selection

```dart
// Show country selection dialog
showDialog(
  context: context,
  builder: (context) => CountrySelectionDialog(
    currentCountry: 'India',
    onCountrySelected: (country) {
      // Handle country selection
    },
  ),
);
```

## 🌐 Supported Languages

### English (en-IN)
- **Display Name**: English
- **Alphabet Character**: a
- **Locale**: `Locale('en', 'IN')`

### Hindi (hi-IN)
- **Display Name**: हिन्दी
- **Alphabet Character**: अ
- **Locale**: `Locale('hi', 'IN')`

## 📋 Available Translations

The app includes translations for:

- **Language Selection**: Choose Language, Continue, etc.
- **Common UI**: Login, Sign Up, Home, Settings, etc.
- **Authentication**: Email, Password, OTP, etc.
- **Booking**: Book Now, Pickup Location, etc.
- **Tracking**: Track Package, Status, etc.
- **Payment**: Payment Methods, Card Number, etc.
- **Wallet**: Balance, Transactions, etc.
- **Support**: Help, Contact Us, FAQ, etc.

## 🔄 App Flow

### First Launch
1. **Splash Screen** (3 seconds with animation)
2. **Language Selection Screen** (if language not set)
3. **Welcome Screen** (after language selection)
4. **Login/Home** (based on authentication)

### Subsequent Launches
1. **Splash Screen** (3 seconds with animation)
2. **Login/Home** (direct navigation based on saved language)

## 🎯 Key Features

### Language Cards
- **Visual Design**: Large alphabet characters (a, अ)
- **Selection State**: Orange border and checkmark for selected language
- **Interaction**: Tap to select language
- **Background**: Light orange (`#FFC486`)

### Continue Button
- **Color**: Primary orange (`#FF8300`)
- **Text**: White, bold, centered
- **Action**: Saves language selection and navigates forward

### Country Selection
- **Flag Display**: Simplified India flag with tricolor
- **Dropdown**: Tap to open country selection dialog
- **Persistence**: Country selection is saved with language

## 🔧 Configuration

### Adding New Languages

1. **Update Language Service**:
   ```dart
   static const String newLanguage = 'Spanish';
   static const Locale spanishLocale = Locale('es', 'ES');
   ```

2. **Add Translations**:
   ```dart
   'es': {
     'chooseLanguage': 'Elegir Idioma',
     'continue': 'Continuar',
     // ... more translations
   }
   ```

3. **Update Localizations Delegate**:
   ```dart
   supportedLocales: const [
     Locale('en', 'IN'),
     Locale('hi', 'IN'),
     Locale('es', 'ES'), // Add new locale
   ]
   ```

### Customizing Colors

Update the color constants in `lib/core/config/app_colors.dart`:

```dart
static const Color primaryOrange = Color(0xFFFF8300);
static const Color lightOrange = Color(0xFFFFC486);
```

## 📱 Testing

### Test Scenarios

1. **First Launch**: Verify language selection appears
2. **Language Switching**: Test both English and Hindi
3. **Persistence**: Verify selection is saved
4. **Country Selection**: Test country dialog
5. **Navigation**: Verify proper flow after selection

### Test Commands

```bash
# Run the app
flutter run

# Test specific language
# Set language to Hindi in app and verify UI changes
```

## 🐛 Troubleshooting

### Common Issues

1. **Language not persisting**:
   - Check SharedPreferences implementation
   - Verify LanguageService.setLanguage() is called

2. **Translations not showing**:
   - Check AppLocalizationsDelegate is registered
   - Verify locale is supported

3. **Navigation issues**:
   - Check route registration in main.dart
   - Verify splash screen navigation logic

## 📚 Additional Resources

- **Brand Colors Guide**: `BRAND_COLORS_GUIDE.md`
- **App Flow Chart**: `APP_FLOW_CHART.md`
- **API Documentation**: `Logistix API (2).yaml`

---

For questions or issues with the language feature, please refer to the development team or create an issue in the project repository. 