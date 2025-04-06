import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/stage.dart';

class GameData {
  // Load all stages from JSON file
  static Future<List<Stage>> loadStages() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/stages.json');
      
      // Parse the JSON
      final List<dynamic> stagesJson = json.decode(jsonString);
      
      // Convert JSON to Stage objects
      List<Stage> stages = stagesJson.map((stageJson) {
        // Convert questions JSON to Question objects
        List<Question> questions = (stageJson['questions'] as List).map((questionJson) {
          return Question(
            questionText: questionJson['questionText'],
            options: List<String>.from(questionJson['options']),
            correctAnswerIndex: questionJson['correctAnswerIndex'],
          );
        }).toList();
        
        return Stage(
          id: stageJson['stageId'],
          name: stageJson['stageName'],
          description: stageJson['stageDescription'],
          difficultyLevel: stageJson['difficultyLevel'],
          questions: questions,
          timeLimit: stageJson.containsKey('timeLimit') ? stageJson['timeLimit'] : null,
        );
      }).toList();
      
      return stages;
    } catch (e) {
      debugPrint('Error loading stages: $e');
      // Return empty list in case of error
      return [];
    }
  }
}
