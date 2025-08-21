/// Application wide constants
class AppConstants {
  // App Information
  static const String appName = 'CV Maker';
  static const String appVersion = '1.0.0';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Spacing
  static const double spacingXs = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // Border Radius
  static const double radiusS = 4;
  static const double radiusM = 8;
  static const double radiusL = 12;
  static const double radiusXl = 16;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // PDF Settings
  static const String defaultFontFamily = 'Helvetica';
  static const double defaultFontSize = 12;
  static const double titleFontSize = 16;
  static const double subtitleFontSize = 14;

  // File Settings
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
}
