import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_provider.dart';
import '../utils/web_responsive_helper.dart';
import '../widgets/answer_feedback.dart';
import 'result_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _selectedIndex = -1;

  void _checkAnswer(QuizProvider quizProvider, int index) {
    final isCorrect = index == quizProvider.currentQuestion.correctAnswerIndex;
    
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
      _selectedIndex = index;
    });
    
    // Play sound effect based on answer correctness
    // This would be implemented with audio packages in a full implementation
  }

  void _nextQuestion(QuizProvider quizProvider) {
    // Store the selected index before resetting it
    final selectedIndex = _selectedIndex;
    
    setState(() {
      _showFeedback = false;
      _selectedIndex = -1;
    });
    
    // Use the stored index for scoring
    quizProvider.answerQuestion(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.quizCompleted) {
          // Navigate to results screen when quiz is completed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ResultScreen(),
              ),
            );
          });
        }

        if (quizProvider.questions.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentQuestion = quizProvider.currentQuestion;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade500,
                  Colors.blue.shade300,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: LinearProgressIndicator(
                            value: (quizProvider.currentQuestionIndex + 1) / quizProvider.questions.length,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                            minHeight: WebResponsiveHelper.isWebPlatform() ? 15 : 10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        
                        // Question counter and score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'النقاط: ${quizProvider.score}',
                                style: TextStyle(
                                  fontSize: WebResponsiveHelper.isWebPlatform() ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            Text(
                              'سؤال ${quizProvider.currentQuestionIndex + 1} من ${quizProvider.questions.length}',
                              style: TextStyle(
                                fontSize: WebResponsiveHelper.isWebPlatform() ? 18 : 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Question text
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
                          child: Text(
                            currentQuestion.questionText,
                            style: TextStyle(
                              fontSize: WebResponsiveHelper.isWebPlatform() ? 26 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Show feedback or answer options
                        if (_showFeedback)
                          AnswerFeedback(
                            isCorrect: _isCorrect,
                            question: currentQuestion,
                            onNextQuestion: () => _nextQuestion(quizProvider),
                          )
                        else
                          // Answer options
                          ...List.generate(
                            currentQuestion.options.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: ElevatedButton(
                                onPressed: () => _checkAnswer(quizProvider, index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue.shade800,
                                  padding: EdgeInsets.symmetric(
                                    vertical: WebResponsiveHelper.isWebPlatform() ? 20 : 15
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  currentQuestion.options[index],
                                  style: TextStyle(
                                    fontSize: WebResponsiveHelper.isWebPlatform() ? 22 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
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
