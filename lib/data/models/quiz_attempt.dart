import 'package:hive/hive.dart';
import 'question.dart';

part 'quiz_attempt.g.dart';

@HiveType(typeId: 1)
class QuizAttempt extends HiveObject {
  @HiveField(0)
  final String id; // e.g. uuid for this attempt

  @HiveField(1)
  final List<Question> questions;

  @HiveField(2)
  final List<int> userAnswers; // index of selected options

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime timestamp;

  QuizAttempt({
    required this.id,
    required this.questions,
    required this.userAnswers,
    required this.isCompleted,
    required this.timestamp,
  });

  int get correctCount {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].correctIndex == userAnswers[i]) {
        count++;
      }
    }
    return count;
  }

  double get scorePercent => (correctCount / questions.length) * 100;
}
