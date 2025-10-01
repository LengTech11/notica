# Localization Guide for Notica

This document explains how the localization system works in the Notica app.

## Overview

Notica uses the `easy_localization` package to support multiple languages. Currently supported languages:
- **English (en)** - Default language
- **Khmer (km)** - Cambodian language

## How to Use

### Switching Languages

Users can switch between languages through the app:
1. Tap the menu icon (three dots) in the top right corner
2. Select "Language" / "ភាសា"
3. Choose your preferred language from the dialog

The app will immediately update all text to the selected language.

## For Developers

### Adding a New Language

1. Create a new JSON file in `assets/translations/` with the language code (e.g., `fr.json` for French)
2. Copy the structure from `en.json` and translate all values
3. Update `main.dart` to include the new locale:
   ```dart
   supportedLocales: const [
     Locale('en'),
     Locale('km'),
     Locale('fr'), // Add new language here
   ],
   ```

### Using Translations in Code

To use a translated string in your widget:

```dart
import 'package:easy_localization/easy_localization.dart';

// Simple translation
Text('app_name'.tr())

// Nested translation
Text('menu.settings'.tr())

// With parameters (if needed)
Text('welcome_message'.tr(args: ['John']))
```

### Translation File Structure

The translation files use a nested JSON structure:

```json
{
  "app_name": "Notica",
  "menu": {
    "settings": "Settings",
    "about": "About"
  }
}
```

Access nested values with dot notation: `'menu.settings'.tr()`

### Current Translation Keys

All available translation keys can be found in:
- `assets/translations/en.json` - English translations
- `assets/translations/km.json` - Khmer translations

Main sections include:
- `app_name` - App name
- `menu.*` - Menu items
- `theme.*` - Theme-related strings
- `settings.*` - Settings screen
- `reminder_list.*` - Reminder list view
- `reminder_form.*` - Add/edit reminder form
- `habit_list.*` - Habit list view
- `habit_form.*` - Add/edit habit form
- `onboarding.*` - Onboarding pages
- `frequency.*` - Reminder frequency options
- `priority.*` - Priority levels
- `common.*` - Common buttons and actions

### Best Practices

1. **Always use translation keys**: Never hardcode user-facing strings
2. **Use descriptive keys**: Keys should clearly indicate what they're for
3. **Keep translations short**: Mobile screens have limited space
4. **Test both languages**: Ensure UI looks good in all supported languages
5. **Update both files**: When adding new keys, update both `en.json` and `km.json`

## Technical Details

- **Package**: easy_localization ^3.0.7
- **Default locale**: en (English)
- **Fallback locale**: en (English)
- **Translation files location**: `assets/translations/`
- **Initialization**: In `main.dart` before `runApp()`

## Troubleshooting

### Translation not showing
- Check that the key exists in the JSON file
- Ensure the JSON file is valid (no syntax errors)
- Verify the asset is included in `pubspec.yaml`

### Language not persisting
- The selected language is automatically saved by easy_localization
- If issues persist, check SharedPreferences permissions

### Missing translations
- If a key is missing in the current language, it will fall back to English
- Always ensure all keys exist in all translation files
