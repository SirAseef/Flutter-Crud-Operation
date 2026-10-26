
import 'package:flutter/material.dart';

// AppTheme class app ke Light aur Dark mode ki styling manage karti hai.
class AppTheme {

  // Yeh app ka main blue color hai.
  // Isi color ko base bana kar Light aur Dark theme ke colors generate honge.
  static const _blue = Color(0xFF465FFF);

  // Light mode ke liye theme return karta hai.
  static ThemeData get light => _buildTheme(Brightness.light);

  // Dark mode ke liye theme return karta hai.
  static ThemeData get dark => _buildTheme(Brightness.dark);

  // Yeh method selected brightness ke mutabiq complete theme banata hai.
  // Brightness.light ka matlab Light mode aur Brightness.dark ka matlab Dark mode hai.
  static ThemeData _buildTheme(Brightness brightness) {

    // Seed color ki madad se app ke matching colors generate hote hain.
    // Brightness decide karti hai ke colors Light mode ke honge ya Dark mode ke.
    final scheme = ColorScheme.fromSeed(
      seedColor: _blue,
      brightness: brightness,
    );

    // Input fields ke borders ki common styling define kar rahe hain.
    // Border ke corners 14 pixels round honge.
    // Border ka color theme ke outlineVariant color se liya jayega.
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    // ThemeData app ke different UI components ki default styling control karta hai.
    return ThemeData(
      // Material Design 3 ke components aur styling enable karta hai.
      useMaterial3: true,

      // App ke buttons, text aur doosre components ke liye color palette set karta hai.
      colorScheme: scheme,

      // App ki screens ka background color set karta hai.
      // Light mode mein halka grey aur Dark mode mein dark grey background hoga.
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF6F7FB)
          : const Color(0xFF111827),

      // AppBar ki common styling set karta hai.
      // centerTitle: false ka matlab title left side par rahega.
      // elevation: 0 ka matlab AppBar ke neeche shadow nahi hogi.
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      // App ke tamam Cards ki default styling define karta hai.
      cardTheme: CardThemeData(
        // Card ke neeche shadow nahi hogi.
        elevation: 0,

        // Card ke bahar extra margin nahi hogi.
        margin: EdgeInsets.zero,

        // Card ke corners round aur border visible hoga.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // TextField aur doosre input fields ki common styling set karta hai.
      inputDecorationTheme: InputDecorationTheme(
        // Input field ke andar background color enable karta hai.
        filled: true,

        // Input field ka background theme ke surface color se set hota hai.
        fillColor: scheme.surface,

        // Input field ka default border set karta hai.
        border: border,

        // Jab input field enabled ho aur focus mein na ho,
        // tab bhi yahi border styling use hogi.
        enabledBorder: border,

        // Jab user input field par click kare,
        // tab border primary color ka aur thora mota ho jayega.
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: scheme.primary,
            width: 1.5,
          ),
        ),

        // Input field ke andar text aur border ke darmiyan spacing set karta hai.
        // Horizontal 16 aur vertical 15 pixels ki padding hogi.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),

      // App ke FilledButton widgets ki default styling set karta hai.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Button ke text aur button ke edges ke darmiyan spacing set karta hai.
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          // Button ke corners ko 14 pixels round karta hai.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
