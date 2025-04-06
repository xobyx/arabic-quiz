import 'package:flutter/material.dart';
import 'question.dart';

class Stage {
  final int id;
  final String name;
  final String description;
  final int difficultyLevel;
  final List<Question> questions;
  final int? timeLimit; // Time limit in seconds (null means no time limit)
  bool isUnlocked;
  int stars; // 0-3 stars based on performance

  Stage({
    required this.id,
    required this.name,
    required this.description,
    required this.difficultyLevel,
    required this.questions,
    this.timeLimit,
    this.isUnlocked = false,
    this.stars = 0,
  });

  // Convert Stage to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'stars': stars,
    };
  }

  // Update Stage from JSON (only progress data)
  void updateFromJson(Map<String, dynamic> json) {
    if (json.containsKey('isUnlocked')) {
      isUnlocked = json['isUnlocked'];
    }
    if (json.containsKey('stars')) {
      stars = json['stars'];
    }
  }

  // Calculate stars based on correct answers
  int calculateStars(int correctAnswers) {
    if (correctAnswers >= 13) {
      return 3;
    } else if (correctAnswers >= 10) {
      return 2;
    } else if (correctAnswers >= 5) {
      return 1;
    } else {
      return 0;
    }
  }

  // Update stars if new score is better
  void updateStars(int correctAnswers) {
    int newStars = calculateStars(correctAnswers);
    if (newStars > stars) {
      stars = newStars;
    }
  }
}
