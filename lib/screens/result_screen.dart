import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_progress.dart';
import '../models/quiz_provider.dart';
import '../widgets/star_rating_animation.dart';

class ResultScreen extends StatelessWidget {
  final int stageId;
  final String stageName;

  const ResultScreen({
    Key? key,
    required this.stageId,
    required this.stageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final gameProgress = Provider.of<GameProgress>(context);
    
    // Calculate stars based on correct answers
    final correctAnswers = quizProvider.score;
    final totalQuestions = quizProvider.totalQuestions;
    final stage = gameProgress.stages.firstWhere((s) => s.id == stageId);
    final stars = stage.calculateStars(correctAnswers);
    
    // Update game progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameProgress.updateStageProgress(stageId, correctAnswers);
    });
    
    // Check if next stage is unlocked
    final nextStageUnlocked = stars >= 1 && stageId < gameProgress.stages.length;
    final hasNextStage = stageId < gameProgress.stages.length;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade100, Colors.purple.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'النتيجة',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'المرحلة: $stageName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'الإجابات الصحيحة: $correctAnswers من $totalQuestions',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'النسبة المئوية: ${(correctAnswers / totalQuestions * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'النجوم المكتسبة:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StarRatingAnimation(stars: stars),
                      const SizedBox(height: 20),
                      if (nextStageUnlocked && stars >= 1)
                        const Text(
                          'تم فتح المرحلة التالية! 🎉',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('الرئيسية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        quizProvider.resetQuiz();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                if (hasNextStage && stars >= 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to next stage
                        final nextStage = gameProgress.stages.firstWhere((s) => s.id == stageId + 1);
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
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('المرحلة التالية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
