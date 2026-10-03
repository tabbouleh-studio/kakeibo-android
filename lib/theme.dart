import 'package:flutter/material.dart';

import 'models/enums.dart';

/// Calm paper-ledger palette: warm paper, soft ink, an ink-green accent.
class _Palette {
  const _Palette({
    required this.paper,
    required this.card,
    required this.raised,
    required this.track,
    required this.line,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.error,
    required this.hero,
  });

  final Color paper, card, raised, track, line, ink, muted;
  final Color accent, onAccent, accentSoft, onAccentSoft, error, hero;

  static const light = _Palette(
    paper: Color(0xFFF4EFE6),
    card: Color(0xFFFFFCF6),
    raised: Color(0xFFEDE6DA),
    track: Color(0xFFE6DED0),
    line: Color(0xFFE3DACB),
    ink: Color(0xFF2A251F),
    muted: Color(0xFF7A7063),
    accent: Color(0xFF2F5D50),
    onAccent: Color(0xFFF6F1E7),
    accentSoft: Color(0xFFD9E7DF),
    onAccentSoft: Color(0xFF16302A),
    error: Color(0xFFB0442F),
    hero: Color(0xFF2F5D50),
  );

  static const dark = _Palette(
    paper: Color(0xFF14120F),
    card: Color(0xFF1E1B17),
    raised: Color(0xFF29251F),
    track: Color(0xFF332E27),
    line: Color(0xFF2E2A24),
    ink: Color(0xFFEFE8DC),
    muted: Color(0xFFA69D8F),
    accent: Color(0xFF94C4AF),
    onAccent: Color(0xFF0F261F),
    accentSoft: Color(0xFF26443A),
    onAccentSoft: Color(0xFFD8EADF),
    error: Color(0xFFEE8C76),
    hero: Color(0xFF25433A),
  );
}

/// Colours outside the Material scheme.
@immutable
class KakeiboColors extends ThemeExtension<KakeiboColors> {
  const KakeiboColors({required this.hero, required this.onHero});

  /// Background of the home screen's main card.
  final Color hero;
  final Color onHero;

  static KakeiboColors of(BuildContext context) => Theme.of(context).extension<KakeiboColors>()!;

  @override
  KakeiboColors copyWith({Color? hero, Color? onHero}) =>
      KakeiboColors(hero: hero ?? this.hero, onHero: onHero ?? this.onHero);

  @override
  KakeiboColors lerp(KakeiboColors? other, double t) => other == null
      ? this
      : KakeiboColors(
          hero: Color.lerp(hero, other.hero, t)!,
          onHero: Color.lerp(onHero, other.onHero, t)!,
        );
}

ThemeData buildTheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  final p = light ? _Palette.light : _Palette.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.accent,
    onPrimary: p.onAccent,
    primaryContainer: p.accentSoft,
    onPrimaryContainer: p.onAccentSoft,
    secondary: p.accent,
    onSecondary: p.onAccent,
    secondaryContainer: p.accentSoft,
    onSecondaryContainer: p.onAccentSoft,
    error: p.error,
    onError: p.onAccent,
    surface: p.paper,
    onSurface: p.ink,
    onSurfaceVariant: p.muted,
    surfaceContainerLowest: p.card,
    surfaceContainerLow: p.card,
    surfaceContainer: p.card,
    surfaceContainerHigh: p.raised,
    surfaceContainerHighest: p.track,
    outline: p.muted,
    outlineVariant: p.line,
  );

  final base = ThemeData(colorScheme: scheme, brightness: brightness);
  final text = base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink);
  final roundedField = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );

  return base.copyWith(
    scaffoldBackgroundColor: p.paper,
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.paper,
      foregroundColor: p.ink,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: light ? BorderSide(color: p.line) : BorderSide.none,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.raised,
      border: roundedField,
      enabledBorder: roundedField,
      focusedBorder: roundedField.copyWith(borderSide: BorderSide(color: p.accent, width: 1.5)),
      errorBorder: roundedField.copyWith(borderSide: BorderSide(color: p.error)),
      focusedErrorBorder: roundedField.copyWith(borderSide: BorderSide(color: p.error, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.accent,
      foregroundColor: p.onAccent,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      extendedTextStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.accentSoft,
      elevation: 0,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) =>
            IconThemeData(color: states.contains(WidgetState.selected) ? p.onAccentSoft : p.muted),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected) ? p.ink : p.muted,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dividerTheme: DividerThemeData(color: p.line, space: 1),
    extensions: [KakeiboColors(hero: p.hero, onHero: const Color(0xFFF5F0E6))],
  );
}

/// Tabular figures so amounts line up like a ledger.
TextStyle moneyStyle(TextStyle? base) =>
    (base ?? const TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

extension SpendCategoryStyle on SpendCategory {
  IconData get icon => switch (this) {
    SpendCategory.needs => Icons.shopping_basket_outlined,
    SpendCategory.wants => Icons.favorite_border_rounded,
    SpendCategory.culture => Icons.auto_stories_outlined,
    SpendCategory.extra => Icons.bolt_rounded,
  };

  String get hint => switch (this) {
    SpendCategory.needs => 'Food, transport, bills',
    SpendCategory.wants => 'Eating out, shopping',
    SpendCategory.culture => 'Books, learning, hobbies',
    SpendCategory.extra => 'Unexpected costs',
  };

  /// Strong colour for light backgrounds.
  Color get deep => switch (this) {
    SpendCategory.needs => const Color(0xFF3F7A6B),
    SpendCategory.wants => const Color(0xFFBF6A3A),
    SpendCategory.culture => const Color(0xFF5866A8),
    SpendCategory.extra => const Color(0xFFA9822A),
  };

  /// Soft colour for dark backgrounds (also used on the hero card).
  Color get pastel => switch (this) {
    SpendCategory.needs => const Color(0xFF94CBBB),
    SpendCategory.wants => const Color(0xFFF1AC82),
    SpendCategory.culture => const Color(0xFFAAB4EA),
    SpendCategory.extra => const Color(0xFFE9C875),
  };

  Color color(Brightness brightness) => brightness == Brightness.light ? deep : pastel;
}
