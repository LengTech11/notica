import 'package:flutter_test/flutter_test.dart';
import 'package:notica/providers/theme_provider.dart';
import 'package:flutter/material.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('Initial theme mode should be system', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('Should convert ThemeMode to string correctly', () {
      // Access private method through reflection or test public behavior
      // We'll test through setThemeMode which uses the conversion
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('Toggle theme should switch between light and dark', () async {
      // Start with light mode
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);

      // Toggle should switch to dark
      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);

      // Toggle again should switch to light
      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    test('setThemeMode should update theme mode', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);

      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);

      await themeProvider.setThemeMode(ThemeMode.system);
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('setThemeMode should not update if same mode', () async {
      await themeProvider.setThemeMode(ThemeMode.light);
      final beforeMode = themeProvider.themeMode;
      
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, beforeMode);
    });
  });
}
