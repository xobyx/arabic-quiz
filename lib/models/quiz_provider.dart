import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizProvider extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  List<Question> _questions = [];

  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get quizCompleted => _quizCompleted;
  List<Question> get questions => _questions;
  Question get currentQuestion => _questions[_currentQuestionIndex];

  void __setQuestions(List<Question> questions) {
    _questions = questions;
    notifyListeners();
  }
  void setQuestions(List<Question> questions) {
    // If there are more than 20 questions, randomly select only 20
    if (questions.length > 20) {
      questions.shuffle();
      _questions = questions.sublist(0, 20);
    } else {
      _questions = questions;
    }
    notifyListeners();
  }
  void answerQuestion(int selectedIndex) {
    if (_currentQuestionIndex < _questions.length) {
      if (selectedIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
        
      }
      else{
        _quizCompleted = true;
        return notifyListeners();
      }

      if (_currentQuestionIndex == _questions.length - 1) {
        _quizCompleted = true;
      } else {
        _currentQuestionIndex++;
      }

      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _quizCompleted = false;
    notifyListeners();
  }
}
