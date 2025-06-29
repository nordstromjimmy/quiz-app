import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 2)
class UserProgress extends HiveObject {
  @HiveField(0)
  int xp;

  @HiveField(1)
  int level;

  @HiveField(2)
  int quizzesTaken;

  @HiveField(3)
  int quizzesCompleted;

  @HiveField(4)
  int totalCorrectAnswers;

  @HiveField(5)
  int totalQuestionsAnswered;

  @HiveField(6)
  int perfectQuizzes;

  UserProgress({
    this.xp = 0,
    this.level = 1,
    this.quizzesTaken = 0,
    this.quizzesCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.totalQuestionsAnswered = 0,
    this.perfectQuizzes = 0,
  });

  /// XP needed for next level
  int get nextLevelXp => level * 100;

  /// Add XP and level up if needed
  void addXp(int amount) {
    xp += amount;
    while (xp >= nextLevelXp) {
      xp -= nextLevelXp;
      level++;
    }
  }
}
