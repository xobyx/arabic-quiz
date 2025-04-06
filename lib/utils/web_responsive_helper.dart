import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebResponsiveHelper {
  static bool isWebPlatform() {
    return kIsWeb;
  }
  
  static double getMaxContentWidth(BuildContext context) {
    // For web, limit the maximum width to create a better experience
    if (kIsWeb) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth > 800 ? 800 : screenWidth;
    }
    return MediaQuery.of(context).size.width;
  }
  
  static EdgeInsets getWebPadding(BuildContext context) {
    if (kIsWeb) {
      double screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth > 800) {
        // Center the content with equal padding on both sides
        double sidePadding = (screenWidth - 800) / 2;
        return EdgeInsets.symmetric(horizontal: sidePadding);
      }
    }
    return const EdgeInsets.symmetric(horizontal: 20);
  }
  
  static TextDirection getTextDirection() {
    // For Arabic content, we want to use RTL direction
    return TextDirection.rtl;
  }
  
  static TextAlign getTextAlign() {
    // For Arabic content, we want to align text to the right
    return TextAlign.right;
  }
}
