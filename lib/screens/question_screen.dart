import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_provider.dart';
import '../models/game_progress.dart';
import 'dart:async';
class QuestionScreen extends StatefulWidget {
  final int stageId;
  final String stageName;
  final int? timeLimit;

  const QuestionScreen({
    Key? key,
    required this.stageId,
    required this.stageName,
    this.timeLimit,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with TickerProviderStateMixin {
  int _selectedIndex = -1;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _remainingTime = 0;
  late AnimationController _timerController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // Initialize timer if time limit is set
    if (widget.timeLimit != null) {
      _remainingTime = widget.timeLimit!;
      _timerController = AnimationController(
        vsync: this,
        duration: Duration(seconds: widget.timeLimit!),
      );
      _timerController.reverse(from: 1.0);
      
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _timerController.value = _remainingTime / widget.timeLimit!;
        } else {
          _timer?.cancel();
          // Time's up - move to next question
          final quizProvider = Provider.of<QuizProvider>(context, listen: false);
          _nextQuestion(quizProvider);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.timeLimit != null) {
      _timerController.dispose();
    }
    super.dispose();
  }

  void _checkAnswer(int index, QuizProvider quizProvider) {
    if (_showFeedback) return; // Prevent multiple selections
    
    final isCorrect = quizProvider.isCorrectAnswer(index);
    
    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
      _isCorrect = isCorrect;
    });
    
    // Automatically move to next question after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion(quizProvider);
      }
    });
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
    
    // Reset timer for next question if applicable
    if (widget.timeLimit != null && quizProvider.currentQuestionIndex < quizProvider.totalQuestions - 1) {
      _remainingTime = widget.timeLimit!;
      _timerController.value = 1.0;
      _timerController.reverse(from: 1.0);
    } else if (_timer != null) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        // Check if quiz is complete
        if (quizProvider.isQuizComplete) {
          // Navigate to results screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              '/result',
              arguments: {
                'stageId': widget.stageId,
                'stageName': widget.stageName,
              },
            );
          });
          return const Center(child: CircularProgressIndicator());
        }

        final currentQuestion = quizProvider.getCurrentQuestion();
        final questionNumber = quizProvider.currentQuestionIndex + 1;
        final totalQuestions = quizProvider.totalQuestions;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'المرحلة: ${widget.stageName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'النقاط: ${quizProvider.score}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade100, Colors.purple.shade300],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    Row(
                      children: [
                        Text(
                          'السؤال $questionNumber من $totalQuestions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: questionNumber / totalQuestions,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.purple.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Timer if applicable
                    if (widget.timeLimit != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '$_remainingTime ثانية',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _remainingTime <= 5 ? Colors.red : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _remainingTime / (widget.timeLimit ?? 1),
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _remainingTime <= 5 ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Question card
                    Expanded(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Text(
                                currentQuestion.questionText,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Answer options
                    ...List.generate(currentQuestion.options.length, (index) {
                      final option = currentQuestion.options[index];
                      final isSelected = _selectedIndex == index;
                      final isCorrectAnswer = currentQuestion.correctAnswerIndex == index;
                      
                      // Determine button color based on selection and feedback state
                      Color buttonColor;
                      if (_showFeedback) {
                        if (isCorrectAnswer) {
                          buttonColor = Colors.green;
                        } else if (isSelected) {
                          buttonColor = Colors.red;
                        } else {
                          buttonColor = Colors.white;
                        }
                      } else {
                        buttonColor = isSelected ? Colors.purple.shade700 : Colors.white;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ElevatedButton(
                          onPressed: _showFeedback
                              ? null
                              : () => _checkAnswer(index, quizProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: isSelected || (_showFeedback && isCorrectAnswer)
                                ? Colors.white
                                : Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 24.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                    
                    // Feedback message
                    if (_showFeedback)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isCorrect ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _isCorrect ? 'إجابة صحيحة! 👏' : 'إجابة خاطئة! 😔',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
