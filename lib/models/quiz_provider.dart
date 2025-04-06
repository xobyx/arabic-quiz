import 'package:flutter/material.dart';
import '../models/question.dart';
import 'quiz_config.dart';
class QuizProvider extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  List<Question> _questions = [];
  List<int> _userAnswers = [];
  QuizConfig _config = const QuizConfig();
  
  // Getters
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get quizCompleted => _quizCompleted;
  List<Question> get questions => _questions;
  Question? get currentQuestion => 
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length ? 
      _questions[_currentQuestionIndex] : null;
  List<int> get userAnswers => _userAnswers;
  double get progressPercentage => _questions.isEmpty ? 
      0.0 : (_currentQuestionIndex + 1) / _questions.length;
  
  // Initialize with config
  void initialize(List<Question> questions, {QuizConfig? config}) {
    _config = config ?? const QuizConfig();
    setQuestions(questions);
    resetQuiz();
  }
  
  void setQuestions(List<Question> questions) {
    if (questions.isEmpty) {
      _questions = [];
      return;
    }
    
    // Apply randomization if configured
    final workingList = List<Question>.from(questions);
    if (_config.randomizeQuestions) {
      workingList.shuffle();
    }
    
    // Apply max questions limit if configured
    if (_config.maxQuestions > 0 && workingList.length > _config.maxQuestions) {
      _questions = workingList.sublist(0, _config.maxQuestions);
    } else {
      _questions = workingList;
    }
    
    // Randomize answer options if configured
    if (_config.randomizeAnswers) {
      for (final question in _questions) {
        question.randomizeOptions();
      }
    }
    
    _userAnswers = List<int>.filled(_questions.length, -1);
    notifyListeners();
  }
  
  void answerQuestion(int selectedIndex) {
    if (_currentQuestionIndex >= _questions.length || _quizCompleted) {
      return;
    }
    
    // Record the user's answer
    _userAnswers[_currentQuestionIndex] = selectedIndex;
    
    // Check if correct
    final isCorrect = selectedIndex == _questions[_currentQuestionIndex].correctAnswerIndex;
    if (isCorrect) {
      _score++;
    } else if (_config.endOnFirstWrongAnswer) {
      _quizCompleted = true;
      notifyListeners();
      return;
    }
    
    // Check if we've reached the end
    if (_currentQuestionIndex == _questions.length - 1) {
      _quizCompleted = true;
    } else {
      _currentQuestionIndex++;
    }
    
    notifyListeners();
  }
  
  bool isLastQuestion() {
    return _currentQuestionIndex == _questions.length - 1;
  }
  
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _quizCompleted = false;
    if (_questions.isNotEmpty) {
      _userAnswers = List<int>.filled(_questions.length, -1);
    }
    notifyListeners();
  }
}