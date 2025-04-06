import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_provider.dart';
import '../utils/web_responsive_helper.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final score = quizProvider.score;
        final totalQuestions = quizProvider.questions.length;
        final percentage = (score / totalQuestions) * 100;
        
        // Determine result message based on score percentage
        String resultMessage;
        Color resultColor;
        IconData resultIcon;
        
        if (percentage >= 80) {
          resultMessage = 'ممتاز! أداء رائع';
          resultColor = Colors.green;
          resultIcon = Icons.emoji_events;
        } else if (percentage >= 60) {
          resultMessage = 'جيد جدًا! استمر';
          resultColor = Colors.lightGreen;
          resultIcon = Icons.thumb_up;
        } else if (percentage >= 40) {
          resultMessage = 'حسنًا، يمكنك التحسن';
          resultColor = Colors.orange;
          resultIcon = Icons.trending_up;
        } else {
          resultMessage = 'حاول مرة أخرى للتحسن';
          resultColor = Colors.red;
          resultIcon = Icons.refresh;
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.teal.shade800,
                  Colors.teal.shade500,
                  Colors.teal.shade300,
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
                        // Result title
                        Text(
                          'النتيجة النهائية',
                          style: TextStyle(
                            fontSize: WebResponsiveHelper.isWebPlatform() ? 48 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Score display with circular progress
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: WebResponsiveHelper.isWebPlatform() ? 250 : 200,
                              height: WebResponsiveHelper.isWebPlatform() ? 250 : 200,
                              child: CircularProgressIndicator(
                                value: score / totalQuestions,
                                strokeWidth: WebResponsiveHelper.isWebPlatform() ? 20 : 15,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '$score/$totalQuestions',
                                  style: TextStyle(
                                    fontSize: WebResponsiveHelper.isWebPlatform() ? 50 : 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${percentage.toInt()}%',
                                  style: TextStyle(
                                    fontSize: WebResponsiveHelper.isWebPlatform() ? 30 : 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Result message
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                resultIcon,
                                size: WebResponsiveHelper.isWebPlatform() ? 80 : 60,
                                color: resultColor,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                resultMessage,
                                style: TextStyle(
                                  fontSize: WebResponsiveHelper.isWebPlatform() ? 30 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: resultColor,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Try again button
                        ElevatedButton(
                          onPressed: () {
                            quizProvider.resetQuiz();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal.shade800,
                            padding: EdgeInsets.symmetric(
                              horizontal: WebResponsiveHelper.isWebPlatform() ? 50 : 40, 
                              vertical: WebResponsiveHelper.isWebPlatform() ? 20 : 15
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'حاول مرة أخرى',
                            style: TextStyle(
                              fontSize: WebResponsiveHelper.isWebPlatform() ? 24 : 20,
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
      },
    );
  }
}
