# Font Setup Instructions

## Download Required Fonts

To support Hindi (Devanagari script) properly, you need to download the Noto Sans Devanagari font files:

### Download Links:
- **NotoSansDevanagari-Regular.ttf**: https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari
- **NotoSansDevanagari-Bold.ttf**: https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari

### Steps:
1. Visit the Google Fonts link above
2. Click "Download family" button
3. Extract the zip file
4. Copy the following files to `assets/fonts/`:
   - `NotoSansDevanagari-Regular.ttf`
   - `NotoSansDevanagari-Bold.ttf`

### Alternative: Use Google Fonts Package
If you prefer not to download fonts manually, you can use the `google_fonts` package which is already included in pubspec.yaml. In that case, remove the fonts section from pubspec.yaml and use:

```dart
GoogleFonts.notoSansDevanagari(
  fontSize: 16,
  fontWeight: FontWeight.w400,
)
```

### Font Usage in Code:
```dart
Text(
  'हिन्दी',
  style: TextStyle(
    fontFamily: 'NotoSansDevanagari',
    fontWeight: FontWeight.w400,
  ),
)
```

### Testing:
After adding the fonts, run:
```bash
flutter clean
flutter pub get
flutter run
```

The Hindi text should now render correctly with proper Devanagari script support.
