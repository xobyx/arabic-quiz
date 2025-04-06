import 'package:flutter/material.dart';
class GameStage {
  final int id;
  final String name;
  final String description;
  final String imagePath;
  final Difficulty difficulty;
  final int requiredPointsToUnlock;
  final int questionsPerQuiz;
  final bool isUnlocked;
  final int? highScore;
  final int? starsEarned;
///
  final int completedQuestions;
  final int totalQuestions;
  final int earnedPoints;
  final int totalPoints;
  final bool isCompleted;
  
  const GameStage({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.difficulty,
    required this.requiredPointsToUnlock,
    required this.questionsPerQuiz,
    this.isUnlocked = false,
    this.highScore,
    this.starsEarned,
//
    this.completedQuestions = 0,
    this.totalQuestions = 10,
    this.earnedPoints = 0,
    this.totalPoints = 100,
    this.isCompleted = false,
  });

  // Create a copy with some properties changed
  GameStage copyWith({
    int? id,
    String? name,
    String? description,
    String? imagePath,
    Difficulty? difficulty,
    int? requiredPointsToUnlock,
    int? questionsPerQuiz,
    bool? isUnlocked,
    int? highScore,
    int? starsEarned,
//
    int? completedQuestions,
    int? totalQuestions,
    int? earnedPoints,
    int? totalPoints,
    bool? isCompleted,
  }) {
    return GameStage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      difficulty: difficulty ?? this.difficulty,
      requiredPointsToUnlock: requiredPointsToUnlock ?? this.requiredPointsToUnlock,
      questionsPerQuiz: questionsPerQuiz ?? this.questionsPerQuiz,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      highScore: highScore ?? this.highScore,
      starsEarned: starsEarned ?? this.starsEarned,
//
      completedQuestions: completedQuestions ?? this.completedQuestions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      totalPoints: totalPoints ?? this.totalPoints,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum Difficulty {
  beginner,
  easy,
  medium,
  hard,
  expert,
}

extension DifficultyExtension on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'مبتدئ';
      case Difficulty.easy:
        return 'سهل';
      case Difficulty.medium:
        return 'متوسط';
      case Difficulty.hard:
        return 'صعب';
      case Difficulty.expert:
        return 'خبير';
    }
  }
  
  Color get color {
    switch (this) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.easy:
        return Colors.lightGreen;
      case Difficulty.medium:
        return Colors.amber;
      case Difficulty.hard:
        return Colors.orange;
      case Difficulty.expert:
        return Colors.red;
    }
  }
  
  // Time limit in seconds per question based on difficulty
  int get timePerQuestion {
    switch (this) {
      case Difficulty.beginner:
        return 30;
      case Difficulty.easy:
        return 25;
      case Difficulty.medium:
        return 20;
      case Difficulty.hard:
        return 15;
      case Difficulty.expert:
        return 10;
    }
  }
  
  // Points multiplier based on difficulty
  double get pointsMultiplier {
    switch (this) {
      case Difficulty.beginner:
        return 1.0;
      case Difficulty.easy:
        return 1.2;
      case Difficulty.medium:
        return 1.5;
      case Difficulty.hard:
        return 2.0;
      case Difficulty.expert:
        return 3.0;
    }
  }
}