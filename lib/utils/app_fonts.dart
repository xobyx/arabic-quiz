import 'package:flutter/material.dart';

class AppFonts {
  static const String fontFamily = 'Cairo';
  
  static void loadFonts(BuildContext context) {
    // This is a placeholder for actual font loading
    // In a production app, you would include the font files in the pubspec.yaml
    // and they would be loaded automatically
    precacheImage(
      const AssetImage('assets/fonts/cairo_regular.ttf'),
      context,
    );
  }
}
