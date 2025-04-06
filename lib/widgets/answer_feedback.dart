import 'package:flutter/material.dart';
import '../models/question.dart';

class AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final Question question;
  final VoidCallback onNextQuestion;

  const AnswerFeedback({
    Key? key,
    required this.isCorrect,
    required this.question,
    required this.onNextQuestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 60,
          ),
          const SizedBox(height: 15),
          Text(
            isCorrect ? 'إجابة صحيحة!' : 'إجابة خاطئة!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 15),
          if (!isCorrect)
            Text(
              'الإجابة الصحيحة هي: ${question.options[question.correctAnswerIndex]}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onNextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'متابعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
