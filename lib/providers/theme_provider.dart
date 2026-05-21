import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provider pour gérer le thème de l'application (clair/sombre)
/// Amélioration #24: Google Fonts (Poppins + Inter)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Activer/désactiver les notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _savePreferences();
    notifyListeners();
  }

  // #24 — Typographie premium
  static TextTheme _buildTextTheme(TextTheme base, Brightness brightness) {
    final color = brightness == Brightness.light ? Colors.black87 : Colors.white;
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: color),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: color),
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: color),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: color),
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: color),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: color),
      bodyLarge: GoogleFonts.inter(color: color),
      bodyMedium: GoogleFonts.inter(color: color),
      bodySmall: GoogleFonts.inter(color: color.withValues(alpha: 0.7)),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: color),
      labelSmall: GoogleFonts.inter(color: color.withValues(alpha: 0.6)),
    );
  }

  // #30 — Transitions de pages personnalisées
  static PageTransitionsTheme get _pageTransitions => PageTransitionsTheme(
    builders: {
      TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
    },
  );
  
  /// Thème clair
  ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.brown,
      scaffoldBackgroundColor: Colors.white,
      textTheme: _buildTextTheme(base.textTheme, Brightness.light),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown,
        primary: Colors.brown[700]!,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.inter(),
        hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.brown[700],
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
      ),
      pageTransitionsTheme: _pageTransitions,
    );
  }
  
  /// Thème sombre
  ThemeData get darkTheme {
    final base = ThemeData.dark();
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.brown,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: _buildTextTheme(base.textTheme, Brightness.dark),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown,
        primary: Colors.brown[300]!,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown[300]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.inter(),
        hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.brown[300],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
      ),
      pageTransitionsTheme: _pageTransitions,
    );
  }
  
  /// Basculer le mode sombre
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme();
    notifyListeners();
  }
  
  /// Définir un mode spécifique
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveTheme();
    notifyListeners();
  }
  
  Future<void> _saveTheme() async {
    await _savePreferences();
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }
}
