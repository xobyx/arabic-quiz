import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stage.dart';
import '../models/game_progress.dart';
import '../models/quiz_provider.dart';
import 'question_screen.dart';

class StageSelectionScreen extends StatelessWidget {
  const StageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراحل اللعبة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade100, Colors.purple.shade300],
          ),
        ),
        child: Consumer<GameProgress>(
          builder: (context, gameProgress, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'اختر المرحلة',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: gameProgress.stages.length,
                      itemBuilder: (context, index) {
                        final stage = gameProgress.stages[index];
                        return _buildStageCard(context, stage);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStageCard(BuildContext context, Stage stage) {
    return GestureDetector(
      onTap: stage.isUnlocked
          ? () {
              // Start the selected stage
              final quizProvider = Provider.of<QuizProvider>(context, listen: false);
              quizProvider.setQuestions(stage.questions);
              quizProvider.resetQuiz();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionScreen(
                    stageId: stage.id,
                    stageName: stage.name,
                    timeLimit: stage.timeLimit,
                  ),
                ),
              );
            }
          : null,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: stage.isUnlocked
                  ? [
                      _getDifficultyColor(stage.difficultyLevel).withOpacity(0.7),
                      _getDifficultyColor(stage.difficultyLevel),
                    ]
                  : [Colors.grey.shade400, Colors.grey.shade600],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock icon for locked stages
                if (!stage.isUnlocked)
                  const Icon(
                    Icons.lock,
                    size: 40,
                    color: Colors.white,
                  ),
                
                // Stage number and name
                Text(
                  'المرحلة ${stage.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stage.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Difficulty indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 16,
                      color: index < stage.difficultyLevel
                          ? Colors.amber
                          : Colors.white.withOpacity(0.3),
                    );
                  }),
                ),
                
                const SizedBox(height: 12),
                
                // Stars earned
                if (stage.isUnlocked)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Icon(
                        Icons.star,
                        size: 24,
                        color: index < stage.stars
                            ? Colors.amber
                            : Colors.white.withOpacity(0.3),
                      );
                    }),
                  ),
                
                // Time limit indicator if applicable
                if (stage.isUnlocked && stage.timeLimit != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${stage.timeLimit} ثانية',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficultyLevel) {
    switch (difficultyLevel) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
}
