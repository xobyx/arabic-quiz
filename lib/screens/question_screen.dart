import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_provider.dart';
import '../utils/web_responsive_helper.dart';
import '../widgets/answer_feedback.dart';
import 'result_screen.dart';
import '../models/question.dart';
import '../models/quiz_questions.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with SingleTickerProviderStateMixin {
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _selectedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadQuestionsFromJson();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Future<void> _loadQuestionsFromJson() async {
    try {
      final questions = await QuizQuestions.loadQuestions();
      if (mounted) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        quizProvider.setQuestions(questions);
      }
    } catch (e) {
      debugPrint('Error loading questions: $e');
    }
  }
  void _checkAnswer(QuizProvider quizProvider, int index) {
    if (_showFeedback) return; // Prevent multiple selections
    
    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) return;
    
    final isCorrect = index == currentQuestion.correctAnswerIndex;
    
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
      _selectedIndex = index;
    });
    
    // Could add sound effect here using an audio package
  }

  void _nextQuestion(QuizProvider quizProvider) {
    // Animate out current question
    _animationController.reverse().then((_) {
      // Store the selected index before resetting state
      final selectedIndex = _selectedIndex;
      
      setState(() {
        _showFeedback = false;
        _selectedIndex = -1;
      });
      
      // Process the answer in the provider
      quizProvider.answerQuestion(selectedIndex);
      
      // Animate in next question
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        // Handle quiz completion
        if (quizProvider.quizCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ResultScreen(),
              ),
            );
          });
        }

        // Show loading indicator while questions are being loaded
        if (quizProvider.questions.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentQuestion = quizProvider.currentQuestion;
        if (currentQuestion == null) {
          // Handle unexpected null case
          return Scaffold(
            body: Center(
              child: Text(
                'خطأ في تحميل السؤال',
                style: TextStyle(fontSize: 20),
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }

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
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App bar with back button
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () {quizProvider.resetQuiz(); Navigator.of(context).pop();},
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.help, color: Colors.white),
                                  onPressed: () {quizProvider.resetQuiz(); Navigator.of(context).pop();},
                                ),
                                // Optional: Add settings or help button here
                              ],
                            ),
                          ),
                          
                          // Progress indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: quizProvider.progressPercentage,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                  minHeight: WebResponsiveHelper.isWebPlatform() ? 12 : 8,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                const SizedBox(height: 8),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    'سؤال ${quizProvider.currentQuestionIndex + 1} من ${quizProvider.questions.length}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Score display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.black87, size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        'النقاط: ${quizProvider.score}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Question text
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
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
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  currentQuestion.questionText,
                                  style: TextStyle(
                                    fontSize: WebResponsiveHelper.isWebPlatform() ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Feedback or answer options
                          Expanded(
                            child: _showFeedback
                                ? AnswerFeedback(
                                    isCorrect: _isCorrect,
                                    question: currentQuestion,
                                    selectedAnswerIndex: _selectedIndex,
                                    onNextQuestion: () => _nextQuestion(quizProvider),
                                    isLastQuestion: quizProvider.isLastQuestion(),
                                  )
                                : _buildAnswerOptions(currentQuestion, quizProvider),
                          ),
                        ],
                      ),
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

  Widget _buildAnswerOptions(Question question, QuizProvider quizProvider) {
    return ListView.builder(
      itemCount: question.options.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildAnswerButton(question.options[index], index, quizProvider),
        );
      },
    );
  }

  Widget _buildAnswerButton(String optionText, int index, QuizProvider quizProvider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _checkAnswer(quizProvider, index),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: WebResponsiveHelper.isWebPlatform() ? 18 : 14,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    optionText,
                    style: TextStyle(
                      fontSize: WebResponsiveHelper.isWebPlatform() ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.circle_outlined,
                color: Colors.blue.shade300,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}