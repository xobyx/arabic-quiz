import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuizQuestions {
  // Load questions from JSON file and randomize them
  static Future<List<Question>> loadQuestions() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/quiz_questions.json');
      
      // Parse the JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> questionsJson = jsonData['questions'];
      
      // Convert JSON to Question objects
      List<Question> questions = questionsJson.map((questionJson) {
        return Question(
          questionText: questionJson['questionText'],
          options: List<String>.from(questionJson['options']),
          correctAnswerIndex: questionJson['correctAnswerIndex'],
        );
      }).toList();
      
      // Randomize the questions order
      questions = _randomizeQuestions(questions);
      
      return questions;
    } catch (e) {
      debugPrint('Error loading questions: $e');
      // Return empty list in case of error
      return [];
    }
  }
  
  // Helper method to randomize the order of questions
  static List<Question> _randomizeQuestions(List<Question> questions) {
    final random = Random();
    
    // Create a copy of the list to avoid modifying the original
    final List<Question> randomizedQuestions = List.from(questions);
    
    // Fisher-Yates shuffle algorithm
    for (int i = randomizedQuestions.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      // Swap elements
      Question temp = randomizedQuestions[i];
      randomizedQuestions[i] = randomizedQuestions[j];
      randomizedQuestions[j] = temp;
    }
    
    return randomizedQuestions;
  }
}
