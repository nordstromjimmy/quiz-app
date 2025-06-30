import 'dart:async';
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
  final List<int?> userAnswers;
  final int currentIndex;
  final int timeRemaining;

  QuizSessionState({
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
    this.timeRemaining = 10,
  });

  bool get isCompleted => !userAnswers.contains(null);
  double get progress => currentIndex / questions.length;

  QuizSessionState copyWith({
    List<Question>? questions,
    List<int?>? userAnswers,
    int? currentIndex,
    int? timeRemaining,
  }) {
    return QuizSessionState(
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }
}

class QuizController extends StateNotifier<QuizSessionState> {
  QuizController()
    : super(QuizSessionState(questions: [], userAnswers: [], currentIndex: 0));

  Timer? questionTimer;

  void startTimer(BuildContext context) {
    questionTimer?.cancel();
    state = state.copyWith(timeRemaining: 10);

    questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final newTime = state.timeRemaining - 1;
      state = state.copyWith(timeRemaining: newTime);

      if (newTime <= 0) {
        timer.cancel();
        _handleTimeout(context);
      }
    });
  }

  void _handleTimeout(BuildContext context) {
    answerCurrent(-1, context);
  }

  void startQuiz(List<Question> originalQuestions, BuildContext context) {
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

    startTimer(context);
  }

  void answerCurrent(int selected, BuildContext context) {
    questionTimer?.cancel();

    final updatedAnswers = List<int>.from(state.userAnswers);
    updatedAnswers[state.currentIndex] = selected;

    final newIndex = state.currentIndex + 1;

    if (newIndex >= state.questions.length) {
      state = state.copyWith(userAnswers: updatedAnswers); // ensure saved
      completeQuiz();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QuizResultScreen(quizState: state)),
      );
    } else {
      state = state.copyWith(
        currentIndex: newIndex,
        userAnswers: updatedAnswers,
      );
      startTimer(context); // start for next question
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

    final progressBox = await Hive.openBox<UserProgress>('progressBox');
    var progress = progressBox.get('user');
    if (progress == null) {
      progress = UserProgress();
      await progressBox.put('user', progress);
    }

    progress.quizzesTaken += 1;
    if (attempt.isCompleted) {
      progress.quizzesCompleted += 1;
    }

    await progress.save();
  }
}
