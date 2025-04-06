import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stage.dart';

class GameProgress extends ChangeNotifier{
  List<Stage> stages;
  
  // Constructor
  GameProgress({required this.stages}) {
    // Initialize first stage as unlocked
    if (stages.isNotEmpty) {
      stages[0].isUnlocked = true;
    }
  }
  
  // Save progress to SharedPreferences
  Future<bool> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert stages progress to JSON
      List<Map<String, dynamic>> stagesJson = stages.map((stage) => stage.toJson()).toList();
      String jsonString = jsonEncode(stagesJson);
      
      // Save to SharedPreferences
      await prefs.setString('game_progress', jsonString);
      return true;
    } catch (e) {
      debugPrint('Error saving game progress: $e');
      return false;
    }
  }
  
  // Load progress from SharedPreferences
  Future<bool> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get saved progress
      String? jsonString = prefs.getString('game_progress');
      if (jsonString == null) {
        return false; // No saved progress
      }
      
      // Parse JSON
      List<dynamic> stagesJson = jsonDecode(jsonString);
      
      // Update stages with saved progress
      for (var stageJson in stagesJson) {
        int stageId = stageJson['id'];
        // Find matching stage and update its progress
        for (var stage in stages) {
          if (stage.id == stageId) {
            stage.updateFromJson(stageJson);
            break;
          }
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error loading game progress: $e');
      return false;
    }
  }
  
  // Update stage progress after completion
  void updateStageProgress(int stageId, int correctAnswers) {
    // Find the stage
    Stage? completedStage;
    int completedStageIndex = -1;
    
    for (int i = 0; i < stages.length; i++) {
      if (stages[i].id == stageId) {
        completedStage = stages[i];
        completedStageIndex = i;
        break;
      }
    }
    
    if (completedStage != null) {
      // Update stars for the completed stage
      completedStage.updateStars(correctAnswers);
      
      // Unlock next stage if this one has at least 1 star
      if (completedStage.stars >= 1 && completedStageIndex < stages.length - 1) {
        stages[completedStageIndex + 1].isUnlocked = true;
      }
      
      // Save the updated progress
      saveProgress();
    }
  }
  
  // Reset all progress (for testing)
  Future<bool> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('game_progress');
      
      // Reset stages to initial state
      for (int i = 0; i < stages.length; i++) {
        stages[i].isUnlocked = (i == 0); // Only first stage unlocked
        stages[i].stars = 0;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error resetting game progress: $e');
      return false;
    }
  }
}
