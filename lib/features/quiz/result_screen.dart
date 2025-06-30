import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quiz/data/models/user_progress.dart';
import 'package:quiz/features/home/home_screen.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'quiz_controller.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizSessionState quizState;

  const QuizResultScreen({super.key, required this.quizState});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  double animatedValue = 0.0;
  bool showLevelUp = false;
  late ConfettiController _confettiController;

  late final int totalCorrect;
  late final bool allCorrect;
  late final int earnedXp;
  late final int showEarnedXp;
  late final double beforeFraction;
  late double afterFraction;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _prepareAnimation();
  }

  void _prepareAnimation() async {
    final progressBox = Hive.box<UserProgress>('progressBox');
    var progress = progressBox.get('user') ?? UserProgress();

    totalCorrect = widget.quizState.questions
        .asMap()
        .entries
        .where(
          (entry) =>
              widget.quizState.userAnswers[entry.key] ==
              entry.value.correctIndex,
        )
        .length;

    allCorrect = totalCorrect == widget.quizState.questions.length;
    earnedXp = (totalCorrect * 5) + 10 + (allCorrect ? 25 : 0);
    showEarnedXp = (totalCorrect * 5) + 10;

    final xpBefore = progress.xp;
    final levelBefore = progress.level;
    final nextLevelXpBefore = progress.nextLevelXp;

    progress.addXp(earnedXp);
    progress.quizzesTaken += 1;
    progress.quizzesCompleted += 1;
    progress.totalCorrectAnswers += totalCorrect;
    progress.totalQuestionsAnswered += widget.quizState.questions.length;
    if (allCorrect) {
      progress.perfectQuizzes += 1;
    }
    progress.save();

    final xpNow = progress.xp;
    final levelNow = progress.level;
    final nextLevelXpNow = progress.nextLevelXp;

    beforeFraction = xpBefore / nextLevelXpBefore;
    afterFraction = xpNow / nextLevelXpNow;

    // Start two-stage animation
    if (levelNow > levelBefore) {
      await _animateXp(beforeFraction, 1.0);
      setState(() => showLevelUp = true);
      _confettiController.play();
      await Future.delayed(Duration(seconds: 1));
      await _animateXp(0.0, afterFraction);
    } else {
      await _animateXp(beforeFraction, afterFraction);
    }
  }

  Future<void> _animateXp(double start, double end) async {
    final steps = 30;
    final diff = (end - start) / steps;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      setState(() => animatedValue = (start + diff * i).clamp(0.0, 1.0));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Center(
                  child: Text(
                    tr(
                      "you_got_correct",
                      namedArgs: {
                        "correct": "$totalCorrect",
                        "total": "${widget.quizState.questions.length}",
                      },
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  color: Colors.white12,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          tr("xp_earned", namedArgs: {"xp": "$showEarnedXp"}),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                        if (allCorrect)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              tr("perfect_bonus"),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (showLevelUp)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              "🎉 LEVEL UP!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: animatedValue,
                            color: Colors.greenAccent,
                            backgroundColor: Colors.white24,
                            minHeight: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          tr(
                            "xp_progress",
                            namedArgs: {
                              "percent": (animatedValue * 100).toStringAsFixed(
                                0,
                              ),
                            },
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ...widget.quizState.questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  final selected = widget.quizState.userAnswers[index];
                  final isCorrect = selected == question.correctIndex;

                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.white12,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isCorrect ? Colors.green : Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (isCorrect)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "✅ ${tr("correct")}: ${question.options[question.correctIndex]}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "+5 XP",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "❌ ${tr("your_answer")}: "
                                    "${selected != null && selected >= 0 ? question.options[selected] : tr("no_answer")}\n"
                                    "✅ ${tr("correct_answer")}: ${question.options[question.correctIndex]}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      "ℹ️ ${question.explanation}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  },
                  child: Text(
                    tr("back_home"),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 10,
              minBlastForce: 5,
              shouldLoop: false,
              colors: [Colors.green, Colors.amber, Colors.blue, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
