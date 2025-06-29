import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:quiz/features/quiz/result_screen.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/question.dart';
import '../../data/models/quiz_attempt.dart';
import '../../data/models/user_progress.dart';

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizSessionState>((ref) {
      return QuizController();
    });

class QuizSessionState {
  final List<Question> questions;
  final List<int?> userAnswers; // null means unanswered
  final int currentIndex;

  QuizSessionState({
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
  });

  bool get isCompleted => !userAnswers.contains(null);

  double get progress => currentIndex / questions.length;
}

class QuizController extends StateNotifier<QuizSessionState> {
  QuizController()
    : super(QuizSessionState(questions: [], userAnswers: [], currentIndex: 0));

  void startQuiz(List<Question> originalQuestions) {
    final shuffledQuestions = originalQuestions.map((question) {
      final options = List<String>.from(question.options);
      final correctAnswer = question.options[question.correctIndex];

      options.shuffle();

      return Question(
        id: question.id,
        text: question.text,
        options: options,
        correctIndex: options.indexOf(correctAnswer),
        explanation: question.explanation,
        category: question.category,
      );
    }).toList();

    state = QuizSessionState(
      questions: shuffledQuestions,
      userAnswers: List.filled(shuffledQuestions.length, -1),
      currentIndex: 0,
    );
  }

  void answerCurrent(int selectedIndex, BuildContext context) async {
    final updatedAnswers = [...state.userAnswers];
    updatedAnswers[state.currentIndex] = selectedIndex;

    final isLastQuestion = state.currentIndex + 1 >= state.questions.length;

    if (isLastQuestion) {
      // Update state one last time to include the final answer
      final completedState = QuizSessionState(
        questions: state.questions,
        userAnswers: updatedAnswers,
        currentIndex: state.currentIndex,
      );
      state = completedState;

      await completeQuiz();

      // Now navigate with the correct final state
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(quizState: completedState),
        ),
      );
    } else {
      // Continue to next question
      state = QuizSessionState(
        questions: state.questions,
        userAnswers: updatedAnswers,
        currentIndex: state.currentIndex + 1,
      );
    }
  }

  void goToQuestion(int index) {
    state = QuizSessionState(
      questions: state.questions,
      userAnswers: state.userAnswers,
      currentIndex: index,
    );
  }

  Future<void> completeQuiz() async {
    final attempt = QuizAttempt(
      id: const Uuid().v4(),
      questions: state.questions,
      userAnswers: state.userAnswers.map((e) => e ?? -1).toList(),
      isCompleted: !state.userAnswers.contains(null),
      timestamp: DateTime.now(),
    );

    final box = await Hive.openBox<QuizAttempt>('attemptsBox');
    await box.add(attempt);

    // Update XP / level
    final progressBox = await Hive.openBox<UserProgress>('progressBox');
    var progress = progressBox.get('user');
    if (progress == null) {
      progress = UserProgress();
      await progressBox.put('user', progress);
    }
    progress.quizzesTaken += 1;
    if (attempt.isCompleted) {
      progress.quizzesCompleted += 1;
      progress.addXp(50); // simple XP reward
    } else {
      progress.addXp(20); // smaller reward for partial
    }
    await progress.save();
  }
}
