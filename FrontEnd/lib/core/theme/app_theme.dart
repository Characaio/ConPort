import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color pageBackground;
  final Color cardBackground;
  final Color mutedBackground;
  final Color inputBackground;
  final Color accentGreen;
  final Color accentBrown;
  final Color accentSalmon;
  final Color statusPending;
  final Color statusInProgress;
  final Color statusTreated;
  final Color statusDenied;
  final Color onAccent;

  const AppColors({
    required this.pageBackground,
    required this.cardBackground,
    required this.mutedBackground,
    required this.inputBackground,
    required this.accentGreen,
    required this.accentBrown,
    required this.accentSalmon,
    required this.statusPending,
    required this.statusInProgress,
    required this.statusTreated,
    required this.statusDenied,
    required this.onAccent,
  });

  static const light = AppColors(
    pageBackground: Color(0xFFF5F5F5),
    cardBackground: Colors.white,
    mutedBackground: Color(0xFFE5E7E7),
    inputBackground: Color(0xFFE6E6E6),
    accentGreen: Color(0xFF5E7654),
    accentBrown: Color(0xFF766057),
    accentSalmon: Color(0xFFC3917C),
    statusPending: Color(0xFFCFCFCF),
    statusInProgress: Color(0xFFC7C900),
    statusTreated: Color(0xFF6B9B65),
    statusDenied: Color(0xFFC25B5B),
    onAccent: Colors.white,
  );

  static const dark = AppColors(
    pageBackground: Color(0xFF121212),
    cardBackground: Color(0xFF1E1E1E),
    mutedBackground: Color(0xFF292929),
    inputBackground: Color(0xFF262626),
    accentGreen: Color(0xFF557A5E),
    accentBrown: Color(0xFF765F56),
    accentSalmon: Color(0xFF9B6E5C),
    statusPending: Color(0xFF666A6A),
    statusInProgress: Color(0xFFB59A32),
    statusTreated: Color(0xFF568B62),
    statusDenied: Color(0xFFB45C63),
    onAccent: Colors.white,
  );

  static AppColors forBrightness(
    Brightness brightness, {
    bool highContrast = false,
  }) {
    final base = brightness == Brightness.dark ? dark : light;
    if (!highContrast) return base;

    return base.copyWith(
      pageBackground: brightness == Brightness.dark
          ? const Color(0xFF0A0A0A)
          : Colors.white,
      cardBackground: brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : Colors.white,
      mutedBackground: brightness == Brightness.dark
          ? const Color(0xFF333333)
          : const Color(0xFFE0E0E0),
    );
  }

  @override
  AppColors copyWith({
    Color? pageBackground,
    Color? cardBackground,
    Color? mutedBackground,
    Color? inputBackground,
    Color? accentGreen,
    Color? accentBrown,
    Color? accentSalmon,
    Color? statusPending,
    Color? statusInProgress,
    Color? statusTreated,
    Color? statusDenied,
    Color? onAccent,
  }) {
    return AppColors(
      pageBackground: pageBackground ?? this.pageBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      mutedBackground: mutedBackground ?? this.mutedBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      accentGreen: accentGreen ?? this.accentGreen,
      accentBrown: accentBrown ?? this.accentBrown,
      accentSalmon: accentSalmon ?? this.accentSalmon,
      statusPending: statusPending ?? this.statusPending,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusTreated: statusTreated ?? this.statusTreated,
      statusDenied: statusDenied ?? this.statusDenied,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      mutedBackground: Color.lerp(mutedBackground, other.mutedBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentBrown: Color.lerp(accentBrown, other.accentBrown, t)!,
      accentSalmon: Color.lerp(accentSalmon, other.accentSalmon, t)!,
      statusPending: Color.lerp(statusPending, other.statusPending, t)!,
      statusInProgress: Color.lerp(statusInProgress, other.statusInProgress, t)!,
      statusTreated: Color.lerp(statusTreated, other.statusTreated, t)!,
      statusDenied: Color.lerp(statusDenied, other.statusDenied, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme => lightThemeFor();

  static ThemeData get darkTheme => darkThemeFor();

  static ThemeData lightThemeFor({
    bool useMaterial3 = true,
    bool highContrast = false,
    bool semAnimacao = false,
  }) {
    final colors = AppColors.forBrightness(
      Brightness.light,
      highContrast: highContrast,
    );
    final scheme = ColorScheme.light(
      primary: highContrast ? const Color(0xFF173B23) : const Color(0xFF2B5137),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFCDE8C3),
      onPrimaryContainer: const Color(0xFF102516),
      secondary: highContrast ? const Color(0xFF2C160C) : const Color(0xFF402216),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD8C7B8),
      onSecondaryContainer: const Color(0xFF261710),
      tertiary: highContrast ? const Color(0xFF18300F) : const Color(0xFF254016),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE8D0C2),
      onTertiaryContainer: const Color(0xFF29150D),
      surface: colors.pageBackground,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFAFAFA),
      surfaceContainer: const Color(0xFFF2F2F2),
      surfaceContainerHigh: const Color(0xFFECECEC),
      surfaceContainerHighest: const Color(0xFFE5E5E5),
      onSurface: const Color(0xFF1C1B1F),
      onSurfaceVariant: const Color(0xFF48464A),
      outline: const Color(0xFF767477),
      outlineVariant: const Color(0xFFC8C6C9),
      error: const Color(0xFFB00020),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
    );
    return _themeData(scheme, colors, useMaterial3, semAnimacao: semAnimacao);
  }

  static ThemeData darkThemeFor({
    bool useMaterial3 = true,
    bool highContrast = false,
    bool semAnimacao = false,
  }) {
    final colors = AppColors.forBrightness(
      Brightness.dark,
      highContrast: highContrast,
    );
    final scheme = ColorScheme.dark(
      primary: highContrast ? const Color(0xFF8AFFA0) : const Color(0xFF76B889),
      onPrimary: Colors.black,
      primaryContainer: const Color(0xFF31543A),
      onPrimaryContainer: const Color(0xFFD1F2D1),
      secondary: highContrast ? const Color(0xFFFFB47A) : const Color(0xFFB98261),
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF513C31),
      onSecondaryContainer: const Color(0xFFFFDBCA),
      tertiary: highContrast ? const Color(0xFFB4FF82) : const Color(0xFF86A96B),
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0xFF3B4D2E),
      onTertiaryContainer: const Color(0xFFD6EDBD),
      surface: colors.pageBackground,
      surfaceContainerLowest: const Color(0xFF0D0D0D),
      surfaceContainerLow: const Color(0xFF171717),
      surfaceContainer: const Color(0xFF1E1E1E),
      surfaceContainerHigh: const Color(0xFF242424),
      surfaceContainerHighest: const Color(0xFF2B2B2B),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFCAC4D0),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF454545),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
    );
    return _themeData(scheme, colors, useMaterial3, semAnimacao: semAnimacao);
  }

  static ThemeData _themeData(
    ColorScheme scheme,
    AppColors colors,
    bool useMaterial3, {
    bool semAnimacao = false,
  }) {
    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: scheme.brightness,
      fontFamily: 'Montserrat',
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      scaffoldBackgroundColor: colors.pageBackground,
      canvasColor: colors.pageBackground,
      cardColor: colors.cardBackground,
      dividerColor: scheme.outlineVariant,
      shadowColor: Colors.black,
      // Trocar de página sem deslizar é o movimento mais irritante para quem
      // pediu menos animação: ele acontece em toda navegação e é o que mais
      // incomoda. Sem transição, a troca continua sendo uma troca.
      pageTransitionsTheme: semAnimacao
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _SemTransicao(),
                TargetPlatform.iOS: _SemTransicao(),
                TargetPlatform.linux: _SemTransicao(),
                TargetPlatform.macOS: _SemTransicao(),
                TargetPlatform.windows: _SemTransicao(),
                TargetPlatform.fuchsia: _SemTransicao(),
              },
            )
          : null,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputBackground,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Troca de página sem animação nenhuma.
///
/// Transição zerada não é o mesmo que transição curta: a curva continua
/// existindo, só que instantânea. Aqui a rota nova aparece pronta, que é o que
/// quem pediu "Reduzir animações" quer — nenhuma mudança de tela visível.
class _SemTransicao extends PageTransitionsBuilder {
  const _SemTransicao();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
