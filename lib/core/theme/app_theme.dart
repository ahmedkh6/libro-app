import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Figma Design Tokens ───
  // Backgrounds & Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGray = Color(0xFFF5F5F4); // stone-100

  // Text Colors (Stone palette)
  static const Color textPrimary = Color(0xFF1C1917);   // stone-900
  static const Color textSecondary = Color(0xFF57534D);  // stone-600
  static const Color textTertiary = Color(0xFF44403B);   // stone-700
  static const Color textMuted = Color(0xFF79716B);      // stone-500

  // Accent / Orange
  static const Color accent = Color(0xFFE17100);         // Active orange
  static const Color gradientStart = Color(0xFFFE9A00);  // Gradient: warm
  static const Color gradientEnd = Color(0xFFF54900);    // Gradient: hot

  // Borders & Dividers
  static const Color border = Color(0xFFE7E5E4);         // stone-300
  static const Color borderLight = Color(0xFFEEEEEE);

  // Status Colors
  static const Color deleteRed = Color(0xFFC10007);
  static const Color deleteBg = Color(0xFFFFE2E2);
  static const Color signOutBg = Color(0xFFFEF2F2);
  static const Color signOutBorder = Color(0xFFFFC9C9);
  static const Color newBadgeBg = Color(0xFFDBEAFE);
  static const Color newBadgeText = Color(0xFF1447E6);

  // Progress Bar
  static const Color progressTrack = Color(0x33030213); // 20% opacity
  static const Color progressFill = Color(0xFF030213);

  // Dark Theme
  static const Color _darkBackground = Color(0xFF1C1917);
  static const Color _darkSurface = Color(0xFF292524);
  static const Color _darkTextPrimary = Color(0xFFFAFAF9);
  static const Color _darkTextSecondary = Color(0xFFA8A29E);

  // ─── Orange Gradient ───
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient orangeGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientEnd],
  );

  // ─── Shadows ───
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get ctaShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get heroShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 50,
      offset: const Offset(0, 25),
    ),
  ];

  // ─── Text Theme Builder ───
  static TextTheme _buildTextTheme(TextTheme base, Color primary, Color secondary) {
    return base.copyWith(
      displayLarge: GoogleFonts.inter(textStyle: base.displayLarge?.copyWith(color: primary, fontWeight: FontWeight.w500)),
      displayMedium: GoogleFonts.inter(textStyle: base.displayMedium?.copyWith(color: primary, fontWeight: FontWeight.w500)),
      displaySmall: GoogleFonts.inter(textStyle: base.displaySmall?.copyWith(color: primary, fontWeight: FontWeight.w500)),
      headlineLarge: GoogleFonts.inter(textStyle: base.headlineLarge?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 30)),
      headlineMedium: GoogleFonts.inter(textStyle: base.headlineMedium?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 24)),
      headlineSmall: GoogleFonts.inter(textStyle: base.headlineSmall?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 20)),
      titleLarge: GoogleFonts.inter(textStyle: base.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 18)),
      titleMedium: GoogleFonts.inter(textStyle: base.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 16)),
      titleSmall: GoogleFonts.inter(textStyle: base.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 14)),
      bodyLarge: GoogleFonts.inter(textStyle: base.bodyLarge?.copyWith(color: secondary, fontSize: 16, height: 1.6)),
      bodyMedium: GoogleFonts.inter(textStyle: base.bodyMedium?.copyWith(color: secondary, fontSize: 14, height: 1.5)),
      bodySmall: GoogleFonts.inter(textStyle: base.bodySmall?.copyWith(color: secondary, fontSize: 12, height: 1.4)),
      labelLarge: GoogleFonts.inter(textStyle: base.labelLarge?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 16)),
      labelMedium: GoogleFonts.inter(textStyle: base.labelMedium?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 14)),
      labelSmall: GoogleFonts.inter(textStyle: base.labelSmall?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 12)),
    );
  }

  // ─── Light Theme ───
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE17100),
      brightness: Brightness.light,
      surface: surface,
      primary: accent,
      secondary: const Color(0xFFF54900),
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    textTheme: _buildTextTheme(ThemeData.light().textTheme, textPrimary, textSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 0.81,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 0.81),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: textPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 16),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return progressFill;
        return const Color(0xFFCBCED4);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: progressFill,
      linearTrackColor: progressTrack,
    ),
  );

  // ─── Dark Theme ───
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE17100),
      brightness: Brightness.dark,
      surface: _darkSurface,
      primary: accent,
      secondary: const Color(0xFFF54900),
      onSurface: _darkTextPrimary,
    ),
    scaffoldBackgroundColor: _darkBackground,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme, _darkTextPrimary, _darkTextSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: _darkTextPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: _darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.81),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkTextPrimary,
        foregroundColor: _darkBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return const Color(0xFF44403B);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
