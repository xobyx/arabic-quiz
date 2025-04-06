import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebResponsiveHelper {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Max content widths for different screen sizes
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 800;
  static const double desktopMaxWidth = 1000;
  
  // Check if running on web platform
  static bool isWebPlatform() {
    return kIsWeb;
  }
  
  // Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenSize.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenSize.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenSize.desktop;
    } else {
      return ScreenSize.largeDesktop;
    }
  }
  
  // Get appropriate padding based on screen size
  static EdgeInsets getWebPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16);
      case ScreenSize.tablet:
        return const EdgeInsets.all(24);
      case ScreenSize.desktop:
        return const EdgeInsets.all(32);
      case ScreenSize.largeDesktop:
        return const EdgeInsets.all(40);
    }
  }
  
  // Get maximum content width for current screen
  static double getMaxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileMaxWidth;
      case ScreenSize.tablet:
        return tabletMaxWidth;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return desktopMaxWidth;
    }
  }
  
  // Get font size scaling factor based on screen size
  static double getFontScaleFactor(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return 1.0;
      case ScreenSize.tablet:
        return 1.1;
      case ScreenSize.desktop:
        return 1.2;
      case ScreenSize.largeDesktop:
        return 1.3;
    }
  }
  
  // Helper to adjust widget spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, {
    double small = 8.0,
    double medium = 16.0,
    double large = 24.0,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return small;
      case ScreenSize.tablet:
        return medium;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return large;
    }
  }
}

// Screen size categories
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}