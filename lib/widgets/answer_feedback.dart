import 'package:flutter/material.dart';
import '../models/question.dart';

class AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final Question question;
  final int selectedAnswerIndex;
  final VoidCallback onNextQuestion;
  final bool isLastQuestion;

  const AnswerFeedback({
    Key? key,
    required this.isCorrect,
    required this.question,
    required this.selectedAnswerIndex,
    required this.onNextQuestion,
    this.isLastQuestion = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          // Feedback card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Icon and text
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isCorrect ? 'إجابة صحيحة!' : 'إجابة خاطئة!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                
                // Explanation if available
                if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.explanation!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Continue button
          ElevatedButton(
            onPressed: onNextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? Colors.green : Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              isLastQuestion ? 'عرض النتائج' : 'السؤال التالي',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}