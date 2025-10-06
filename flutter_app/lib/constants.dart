import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


String apiUrl = "https://rain-fire-detection.onrender.com";

String? user_id;  // will be populated when user signs for first time
String? id_token;
String? camera_id;  // will be populated when user inputs on input page
String? key;  // will be populated on first pairing
// ? means unless assigned, the value of the variable is null

// Modern Fire-Themed Color Palette
Color primaryColor = Color(0xFFFF6B35);      // Vibrant fire orange
Color secondaryColor = Color(0xFFF7931E);    // Warm amber
Color accentColor = Color(0xFFC1272D);       // Alert red
Color backgroundColor = Color(0xFFFAFAFA);   // Clean light background
Color surfaceColor = Color(0xFFFFFFFF);      // Pure white surface
Color darkColor = Color(0xFF2D3436);         // Modern dark
Color successColor = Color(0xFF00B894);      // Safety green
Color warningColor = Color(0xFFFDCB6E);      // Caution yellow
Color textPrimaryColor = Color(0xFF2D3436);  // Primary text
Color textSecondaryColor = Color(0xFF636E72); // Secondary text
Color dividerColor = Color(0xFFDDD6FE);      // Subtle dividers

// Legacy color mapping for backward compatibility
Color highlightColor = Color(0xFF2D3436);    // Maps to darkColor

// Typography System
class AppTypography {
  static const String fontFamily = 'Roboto';
  
  // Heading styles
  static TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    letterSpacing: -0.5,
  );
  
  static TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    letterSpacing: -0.5,
  );
  
  static TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    letterSpacing: -0.25,
  );
  
  static TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    letterSpacing: -0.25,
  );
  
  // Body text styles
  static TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    height: 1.3,
  );
  
  // Button styles
  static TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.25,
  );
  
  // Caption and label styles
  static TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    letterSpacing: 0.4,
  );
  
  static TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
    letterSpacing: 0.1,
  );
}

// Common UI Constants
class AppConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 50.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
  
  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}

// Theme Configuration
ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: accentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onBackground: textPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: AppConstants.elevationS,
      centerTitle: true,
      titleTextStyle: AppTypography.h3.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkColor,
        foregroundColor: Colors.white,
        textStyle: AppTypography.buttonMedium,
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        elevation: AppConstants.elevationS,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: AppTypography.label,
      hintStyle: AppTypography.bodyMedium.copyWith(color: textSecondaryColor),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: AppConstants.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      margin: EdgeInsets.all(AppConstants.spacingS),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: AppConstants.elevationM,
    ),
  );
}

// Enhanced popup alert with modern styling
void PopupAlert(String title, String content, BuildContext context, {
  String buttonText = "OK",
  VoidCallback? onPressed,
  bool isError = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Row(
          children: [
            Icon(
              isError ? Icons.warning_rounded : Icons.info_rounded,
              color: isError ? accentColor : primaryColor,
              size: AppConstants.iconM,
            ),
            SizedBox(width: AppConstants.spacingS),
            Expanded(
              child: Text(
                title,
                style: AppTypography.h4.copyWith(
                  color: isError ? accentColor : textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingS,
              ),
            ),
            child: Text(
              buttonText,
              style: AppTypography.buttonMedium.copyWith(
                color: primaryColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// helper function to save a String into local storage
Future<void> storeString(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

// helper function to get a String from local storage
Future<String?> getString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString(key);
  return value;
}

// helper function to clear saved data
Future<void> clearPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

// UI Helper Functions
class UIHelpers {
  // Create a loading indicator with consistent styling
  static Widget loadingIndicator({Color? color, double size = 24.0}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? primaryColor),
      ),
    );
  }
  
  // Create a status chip with consistent styling
  static Widget statusChip({
    required String label,
    required bool isActive,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: isActive ? successColor : textSecondaryColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppConstants.iconS,
              color: Colors.white,
            ),
            SizedBox(width: AppConstants.spacingXS),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  // Create a modern card with consistent styling
  static Widget modernCard({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? elevation,
  }) {
    return Card(
      elevation: elevation ?? AppConstants.elevationS,
      color: backgroundColor ?? surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppConstants.spacingM),
        child: child,
      ),
    );
  }
  
  // Create a gradient background
  static BoxDecoration gradientBackground({
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors ?? [
          primaryColor.withOpacity(0.1),
          secondaryColor.withOpacity(0.05),
        ],
      ),
    );
  }
}
