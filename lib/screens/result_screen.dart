import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_progress.dart';
import '../models/quiz_provider.dart';
import '../widgets/star_rating_animation.dart';
import '../widgets/gradient_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
class ResultScreen extends StatefulWidget {
  final int stageId;
  final String stageName;

  const ResultScreen({
    Key? key,
    required this.stageId,
    required this.stageName,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;
  bool _showNextStageButton = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Start confetti for good scores
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final totalQuestions = quizProvider.totalQuestions;
      final correctAnswers = quizProvider.score;
      
      if (correctAnswers / totalQuestions >= 0.7) {
        _confettiController.play();
      }
      
      // Delayed appearance of next stage button
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showNextStageButton = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final gameProgress = Provider.of<GameProgress>(context);
    
    // Calculate stars based on correct answers
    final correctAnswers = quizProvider.score;
    final totalQuestions = quizProvider.totalQuestions;
    final stage = gameProgress.stages.firstWhere((s) => s.id == widget.stageId);
    final stars = stage.calculateStars(correctAnswers);
    
    // Calculate percentage
    final percentage = (correctAnswers / totalQuestions * 100);
    
    // Update game progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameProgress.updateStageProgress(widget.stageId, correctAnswers);
    });
    
    // Check if next stage is unlocked
    final nextStageUnlocked = stars >= 1 && widget.stageId < gameProgress.stages.length;
    final hasNextStage = widget.stageId < gameProgress.stages.length;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
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
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Results Title with Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Text(
                                'النتيجة',
                                style: GoogleFonts.cairo(
                                  fontSize: 40,
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
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        
                        // Stage name
                        Text(
                          'المرحلة: ${widget.stageName}',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        // Result card with detailed information
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Score Animation
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: percentage),
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              height: 150,
                                              width: 150,
                                              child: CircularProgressIndicator(
                                                value: value / 100,
                                                strokeWidth: 12,
                                                backgroundColor: Colors.grey.shade200,
                                                color: _getScoreColor(percentage),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  '${value.toInt()}%',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getScoreColor(percentage),
                                                  ),
                                                ),
                                                Text(
                                                  '$correctAnswers من $totalQuestions',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 18,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                                
                                // Feedback text based on score
                                Text(
                                  _getFeedbackText(percentage),
                                  style: GoogleFonts.cairo(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(percentage),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                
                                // Stars section
                                Text(
                                  'النجوم المكتسبة:',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                StarRatingAnimation(stars: stars),
                                const SizedBox(height: 30),
                                
                                // Unlocked next stage message
                                if (nextStageUnlocked && stars >= 1)
                                  AnimatedOpacity(
                                    opacity: _showNextStageButton ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 500),
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.lock_open,
                                            color: Colors.green.shade700,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'تم فتح المرحلة التالية! 🎉',
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Buttons row
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutQuad,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 50),
                                child: child,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GradientButton(
                                onPressed: () {
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                },
                                gradient: LinearGradient(
                                  colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade900],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.home, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'الرئيسية',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              GradientButton(
                                onPressed: () {
                                  quizProvider.resetQuiz();
                                  Navigator.pop(context);
                                },
                                gradient: LinearGradient(
                                  colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.replay, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'إعادة المحاولة',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Next stage button
                        if (hasNextStage && stars >= 1)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: _showNextStageButton ? 1 : 0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 30),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: GradientButton(
                                onPressed: () {
                                  // Navigate to next stage
                                  final nextStage = gameProgress.stages.firstWhere((s) => s.id == widget.stageId + 1);
                                  quizProvider.setQuestions(nextStage.questions);
                                  quizProvider.resetQuiz();
                                  
                                  // Pop current result screen and question screen
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                  
                                  // Navigate to next stage's question screen
                                  Navigator.pushNamed(
                                    context, 
                                    '/question',
                                    arguments: {
                                      'stageId': nextStage.id,
                                      'stageName': nextStage.name,
                                      'timeLimit': nextStage.timeLimit,
                                    },
                                  );
                                },
                                gradient: LinearGradient(
                                  colors: [Colors.green.shade400, Colors.green.shade700],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'المرحلة التالية',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, color: Colors.white),
                                  ],
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
          
          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 1,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color based on score percentage
  Color _getScoreColor(double percentage) {
    if (percentage < 50) {
      return Colors.red.shade600;
    } else if (percentage < 70) {
      return Colors.orange.shade600;
    } else if (percentage < 90) {
      return Colors.green.shade600;
    } else {
      return Colors.purple.shade500;
    }
  }

  // Helper method to get feedback text based on score percentage
  String _getFeedbackText(double percentage) {
    if (percentage < 50) {
      return 'حاول مرة أخرى! 💪';
    } else if (percentage < 70) {
      return 'جيد! يمكنك التحسن أكثر 👍';
    } else if (percentage < 90) {
      return 'ممتاز! تقدم رائع 🌟';
    } else {
      return 'مذهل! أداء مثالي! 🏆';
    }
  }
}