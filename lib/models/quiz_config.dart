class QuizConfig {
  final bool endOnFirstWrongAnswer;
  final int maxQuestions;
  final int timePerQuestionInSeconds;
  final bool randomizeQuestions;
  final bool randomizeAnswers;
  
  const QuizConfig({
    this.endOnFirstWrongAnswer = false,
    this.maxQuestions = 20,
    this.timePerQuestionInSeconds = 30,
    this.randomizeQuestions = true,
    this.randomizeAnswers = false,
  });
}