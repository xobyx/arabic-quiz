import 'package:flutter/material.dart';
import '../utils/web_responsive_helper.dart';
import '../widgets/gradient_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stage_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.purple.shade700,
              Colors.deepPurple.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: WebResponsiveHelper.getWebPadding(context),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: WebResponsiveHelper.getMaxContentWidth(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or Illustration
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lightbulb,
                          size: 80,
                          color: Colors.amber.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Title with Arabic styling
                    Text(
                      'اختبار المعلومات',
                      style: GoogleFonts.cairo(
                        fontSize: WebResponsiveHelper.isWebPlatform() ? 50 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      'أجب على الأسئلة واختبر معلوماتك',
                      style: GoogleFonts.cairo(
                        fontSize: WebResponsiveHelper.isWebPlatform() ? 22 : 18,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 80),
                    
                    // Start button with decoration
                    GradientButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) {
                              return FadeTransition(
                                opacity: animation,
                                child: const StageSelectionScreen(),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade300, Colors.orange.shade400],
                      ),
                      width: 220,
                      height: 60,
                      borderRadius: BorderRadius.circular(30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ابدأ الاختبار',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Additional buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          icon: Icons.info_outline,
                          label: 'حول',
                          onPressed: () {
                            // Show info dialog
                            _showInfoDialog(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildIconButton(
                          icon: Icons.settings,
                          label: 'الإعدادات',
                          onPressed: () {
                            // Navigate to settings
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'حول التطبيق',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'تطبيق اختبار المعلومات هو وسيلة ممتعة لاختبار معلوماتك في مختلف المجالات.',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}