import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color brand = Color(0xFFFACC15);
  static const Color brandHover = Color(0xFFFDE047);
  static const Color brandPressed = Color(0xFFEAB308);
  static const Color brandSoft = Color(0xFFFEF08A);
  static const Color onBrand = Color(0xFF0A0A0A);
  static const Color brandTint5 = Color(0x0DFACC15);
  static const Color brandTint10 = Color(0x1AFACC15);
  static const Color brandTint15 = Color(0x26FACC15);
  static const Color brandTint20 = Color(0x33FACC15);
  static const Color brandBorder = Color(0x4DFACC15);

  static const Color bgApp = Color(0xFF0A0A0A);
  static const Color bgSurface = Color(0xFF171717);
  static const Color bgSurfaceRaised = Color(0xFF262626);
  static const Color bgSurfaceHigh = Color(0xFF404040);
  static const Color bgSurfaceTop = Color(0xFF525252);
  static const Color borderSubtle = Color(0xFF262626);
  static const Color borderStrong = Color(0xFF404040);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textBody = Color(0xFFE5E5E5);
  static const Color textTertiary = Color(0xFFD4D4D4);
  static const Color textMuted = Color(0xFFA3A3A3);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textLink = brand;

  static const Color success = Color(0xFF10B981);
  static const Color successSolid = Color(0xFF059669);
  static const Color successText = Color(0xFF34D399);
  static const Color successTextStrong = Color(0xFF6EE7B7);
  static const Color successBg = Color(0x2610B981);
  static const Color successBorder = Color(0x4D10B981);

  static const Color dangerSolid = Color(0xFFDC2626);
  static const Color dangerSolidHover = Color(0xFFB91C1C);
  static const Color dangerText = Color(0xFFF87171);
  static const Color dangerTextStrong = Color(0xFFFCA5A5);
  static const Color dangerBg = Color(0x1AEF4444);
  static const Color dangerBorder = Color(0x4DEF4444);

  static const Color warningSolid = Color(0xFFF97316);
  static const Color warningText = Color(0xFFFB923C);
  static const Color warningTextStrong = Color(0xFFFDBA74);
  static const Color warningBg = Color(0x1AF97316);
  static const Color warningBorder = Color(0x4DF97316);

  static const Color role = Color(0xFF9333EA);
  static const Color roleText = Color(0xFFC084FC);
  static const Color roleTextStrong = Color(0xFFD8B4FE);
  static const Color roleBg = Color(0x26A855F7);
  static const Color roleBorder = Color(0x4DA855F7);

  // Aliases semânticos mantêm as telas existentes compatíveis.
  static const Color darkBg = bgApp;
  static const Color darkCard = bgSurface;
  static const Color primary = brand;
  static const Color primaryLight = brandHover;
  static const Color textSecondary = textMuted;
  static const Color border = borderSubtle;
  static const Color statusScraped = success;
  static const Color statusPending = warningSolid;
  static const Color statusFailed = dangerText;

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: brand,
      scaffoldBackgroundColor: bgApp,
      cardColor: bgSurface,
      dividerColor: borderSubtle,
      splashColor: brandTint20,
      highlightColor: brandTint10,
      colorScheme: const ColorScheme.dark(
        primary: brand,
        onPrimary: onBrand,
        secondary: brandHover,
        onSecondary: onBrand,
        surface: bgSurface,
        onSurface: textPrimary,
        error: dangerSolid,
        onError: textInverse,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        baseTextTheme.copyWith(
          titleLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: const TextStyle(color: textPrimary),
          bodyLarge: const TextStyle(color: textBody),
          bodyMedium: const TextStyle(color: textMuted),
          labelLarge: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurfaceRaised.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerText),
        ),
        labelStyle: const TextStyle(color: textBody),
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return brandPressed;
            if (states.contains(WidgetState.hovered)) return brandHover;
            return brand;
          }),
          foregroundColor: const WidgetStatePropertyAll(onBrand),
          overlayColor: const WidgetStatePropertyAll(brandTint20),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: textLink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: onBrand,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: brand,
        linearTrackColor: bgSurfaceHigh,
        circularTrackColor: bgSurfaceHigh,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? onBrand : textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? brand : bgSurfaceHigh,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgApp,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bgApp,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: bgApp,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: bgSurface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgSurface,
        selectedItemColor: brand,
        unselectedItemColor: textMuted,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: bgSurface,
        selectedIconTheme: IconThemeData(color: onBrand),
        selectedLabelTextStyle: TextStyle(color: brand),
        unselectedIconTheme: IconThemeData(color: textMuted),
        unselectedLabelTextStyle: TextStyle(color: textMuted),
        indicatorColor: brand,
      ),
    );
  }
}
