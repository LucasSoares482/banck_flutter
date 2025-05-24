// lib/utils/responsive_helper.dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getResponsiveWidth(BuildContext context, double factor) {
    return MediaQuery.of(context).size.width * factor;
  }
  
  static double getResponsiveHeight(BuildContext context, double factor) {
    return MediaQuery.of(context).size.height * factor;
  }
  
  static double getResponsiveFontSize(BuildContext context, double factor) {
    final width = MediaQuery.of(context).size.width;
    return width * factor;
  }
  
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }
  
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 400 && width <= 600;
  }
  
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 400;
  }
  
  // Specific for Xiaomi devices (tend to have larger screens)
  static EdgeInsets getXiaomiPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 400) {
      return EdgeInsets.all(width * 0.05); // Larger padding for big screens
    }
    return EdgeInsets.all(width * 0.04);
  }
  
  static double getXiaomiFontSize(BuildContext context, double baseFactor) {
    final width = MediaQuery.of(context).size.width;
    // Adjust font size for Xiaomi's typically larger, high-DPI screens
    if (width > 400) {
      return width * (baseFactor * 0.9); // Slightly smaller on large screens
    }
    return width * baseFactor;
  }
  
  static double getCardHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.12; // 12% of screen height
  }
  
  static double getButtonHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.07; // 7% of screen height, minimum 50
  }
}

// Extension methods for easier use
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  double responsiveWidth(double factor) => screenWidth * factor;
  double responsiveHeight(double factor) => screenHeight * factor;
  double responsiveFontSize(double factor) => ResponsiveHelper.getXiaomiFontSize(this, factor);
  
  bool get isLargeScreen => screenWidth > 600;
  bool get isMediumScreen => screenWidth > 400 && screenWidth <= 600;
  bool get isSmallScreen => screenWidth <= 400;
  
  EdgeInsets get xiaomiPadding => ResponsiveHelper.getXiaomiPadding(this);
}