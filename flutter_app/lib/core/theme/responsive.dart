import 'package:flutter/material.dart';

enum ScreenSize { small, medium, large, xl }

class Responsive {
  // Breakpoints
  static const double smallBreakpoint = 360;
  static const double mediumBreakpoint = 768;
  static const double largeBreakpoint = 1024;

  // Get screen size category
  static ScreenSize getSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < smallBreakpoint) {
      return ScreenSize.small;
    } else if (width < mediumBreakpoint) {
      return ScreenSize.medium;
    } else if (width < largeBreakpoint) {
      return ScreenSize.large;
    } else {
      return ScreenSize.xl;
    }
  }

  // Check if mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mediumBreakpoint;
  }

  // Check if tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mediumBreakpoint && width < largeBreakpoint;
  }

  // Check if desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeBreakpoint;
  }

  // Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  // Responsive padding
  static double padding(BuildContext context) {
    return value(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  // Responsive font sizes
  static double fontSize(BuildContext context, double baseSize) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust font size based on screen width
    double scaleFactor = 1.0;
    if (screenWidth < smallBreakpoint) {
      scaleFactor = 0.9;
    } else if (screenWidth >= largeBreakpoint) {
      scaleFactor = 1.1;
    }
    
    return baseSize * scaleFactor * textScaleFactor;
  }

  // Screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Safe area padding
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Responsive spacing
  static double spacing(BuildContext context, {double multiplier = 1.0}) {
    return value(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    ) * multiplier;
  }
}
