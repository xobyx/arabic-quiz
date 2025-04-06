import 'package:flutter/material.dart';
import '../models/quiz_provider.dart';
import '../utils/web_responsive_helper.dart';
import 'question_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade800,
              Colors.purple.shade500,
              Colors.purple.shade300,
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
                    // Title with Arabic styling
                    Text(
                      'اختبار المعلومات',
                      style: TextStyle(
                        fontSize: WebResponsiveHelper.isWebPlatform() ? 50 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 20),
                    // Subtitle
                    Text(
                      'أجب على الأسئلة واختبر معلوماتك',
                      style: TextStyle(
                        fontSize: WebResponsiveHelper.isWebPlatform() ? 22 : 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 80),
                    // Start button with decoration
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuestionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'ابدأ الاختبار',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
