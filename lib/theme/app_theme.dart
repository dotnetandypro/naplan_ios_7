import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color scheme
  static const Color primaryColor = Color(0xFF3949AB); // Deep blue
  static const Color secondaryColor = Color(0xFF00BCD4); // Teal
  static const Color accentColor = Color(0xFFFF5722); // Orange
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFE53935); // Red
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Button styles
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 3,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static ButtonStyle secondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static ButtonStyle successButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: successColor,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static ButtonStyle outlineButtonStyle({Color color = primaryColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static ButtonStyle flagButtonStyle({required bool isFlagged}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isFlagged ? warningColor.withOpacity(0.1) : Colors.white,
      foregroundColor: isFlagged ? warningColor : textSecondaryColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isFlagged ? warningColor : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
    );
  }

  // Container styles
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration dropTargetDecoration({bool isActive = false}) {
    return BoxDecoration(
      color: isActive ? primaryColor.withOpacity(0.1) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isActive ? primaryColor : Colors.grey.shade300,
        width: 2,
      ),
    );
  }

  static BoxDecoration draggableItemDecoration() {
    return BoxDecoration(
      color: primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: primaryColor,
        width: 1.5,
      ),
    );
  }

  // Input decoration
  static InputDecoration textFieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  // Get complete Material theme
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displaySmall: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 18,
          color: textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 16,
          color: textPrimaryColor,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 14,
          color: textSecondaryColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: outlineButtonStyle(),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(Colors.white),
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: primaryColor),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade600;
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}
