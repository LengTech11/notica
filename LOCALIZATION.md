# Multi-Language Implementation - Testing Guide

## Overview
Multi-language support has been added to Notica with English (en) and Khmer (km) languages.

## Implementation Details

### Files Added/Modified:
1. **pubspec.yaml** - Added flutter_localizations dependency and enabled code generation
2. **l10n.yaml** - Configuration for localization code generation
3. **lib/l10n/app_en.arb** - English translations (all UI strings)
4. **lib/l10n/app_km.arb** - Khmer translations (all UI strings)
5. **lib/providers/locale_provider.dart** - Manages language preference with persistence
6. **lib/main.dart** - Added localization delegates and locale support
7. **lib/views/reminder_list_view.dart** - Updated to use localized strings
8. **lib/views/add_reminder_view.dart** - Updated to use localized strings

### Key Features:
- ✅ Full UI translation for English and Khmer
- ✅ Language selector in app menu
- ✅ Persistent language preference (saved using SharedPreferences)
- ✅ Immediate language switching without app restart
- ✅ Support for both LTR (English) and RTL-capable layouts

## Build Instructions

### Prerequisites:
- Flutter SDK (3.9.0 or higher)
- Dart SDK

### Steps to Build and Test:

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```
   This will automatically generate the localization code in `.dart_tool/flutter_gen/`

2. **Verify generated files:**
   The following file should be generated automatically:
   - `.dart_tool/flutter_gen/gen_l10n/app_localizations.dart`
   - `.dart_tool/flutter_gen/gen_l10n/app_localizations_en.dart`
   - `.dart_tool/flutter_gen/gen_l10n/app_localizations_km.dart`

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Test language switching:**
   - Open the app
   - Tap the menu button (⋮) in the top-right corner
   - Select "Language" / "ភាសា"
   - Choose between English and Khmer
   - Verify all UI elements update immediately

## Testing Checklist

### English (en) Testing:
- [ ] App title displays "Notica"
- [ ] All menu items in English
- [ ] Empty state message in English
- [ ] Form labels and hints in English
- [ ] Dialog messages in English
- [ ] Success/error messages in English
- [ ] Date/time formatting in English

### Khmer (km) Testing:
- [ ] App title displays "ណូធីកា"
- [ ] All menu items in Khmer
- [ ] Empty state message in Khmer
- [ ] Form labels and hints in Khmer
- [ ] Dialog messages in Khmer
- [ ] Success/error messages in Khmer
- [ ] Date/time formatting in Khmer

### Persistence Testing:
- [ ] Select English, close app, reopen - English is still selected
- [ ] Select Khmer, close app, reopen - Khmer is still selected
- [ ] Language preference survives app restart

### UI/UX Testing:
- [ ] All text is readable and properly aligned
- [ ] No text overflow or clipping
- [ ] Buttons and controls are accessible
- [ ] Language dialog is easy to use

## Known Limitations

1. **Frequency descriptions** in add_reminder_view are not yet translated (only the frequency names are translated)
2. **Priority descriptions** in add_reminder_view are not yet translated (only the priority names are translated)
3. Numbers in date formatting use standard numerals (could be localized further for Khmer numerals if desired)

## Future Enhancements

Potential improvements for the localization system:
- Add more languages (Thai, Vietnamese, etc.)
- Localize number formatting
- Localize date/time patterns more extensively
- Add right-to-left (RTL) support for Arabic languages
- Add screen-specific context for translations

## Troubleshooting

### If generated files are missing:
```bash
flutter clean
flutter pub get
```

### If imports show errors:
The import `package:flutter_gen/gen_l10n/app_localizations.dart` will only work after `flutter pub get` generates the files.

### If language doesn't switch:
Check that SharedPreferences is working correctly. Clear app data and try again.

## Translation Updates

To add or modify translations:

1. Edit `lib/l10n/app_en.arb` for English
2. Edit `lib/l10n/app_km.arb` for Khmer
3. Run `flutter pub get` to regenerate localization code
4. Use the new translation keys in your code: `l10n.yourNewKey`

## Code Examples

### Using translations in widgets:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.appTitle); // "Notica" or "ណូធីកា"
}
```

### Switching language:
```dart
final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
localeProvider.setLocale(const Locale('km')); // Switch to Khmer
```
