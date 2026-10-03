import 'package:flutter/material.dart';

import 'models/enums.dart';

const _seed = Color(0xFF8A6A47);
const _paperLight = Color(0xFFF8F4EC);
const _paperDark = Color(0xFF1C1A17);

ThemeData buildTheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.neutral,
  ).copyWith(surface: light ? _paperLight : _paperDark);

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, scrolledUnderElevation: 0),
    cardTheme: CardThemeData(
      elevation: 0,
      color: light ? Colors.white.withValues(alpha: 0.7) : scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}

/// Tabular figures so amounts line up like a ledger.
TextStyle moneyStyle(TextStyle? base) =>
    (base ?? const TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

extension SpendCategoryStyle on SpendCategory {
  IconData get icon => switch (this) {
    SpendCategory.needs => Icons.shopping_basket_outlined,
    SpendCategory.wants => Icons.favorite_border,
    SpendCategory.culture => Icons.menu_book_outlined,
    SpendCategory.extra => Icons.bolt_outlined,
  };

  Color color(Brightness brightness) {
    final light = brightness == Brightness.light;
    return switch (this) {
      SpendCategory.needs => light ? const Color(0xFF5B7F6B) : const Color(0xFF8DB59E),
      SpendCategory.wants => light ? const Color(0xFFB87A35) : const Color(0xFFE0A866),
      SpendCategory.culture => light ? const Color(0xFF5E7193) : const Color(0xFF94A6C8),
      SpendCategory.extra => light ? const Color(0xFFA85C57) : const Color(0xFFD9918B),
    };
  }
}
