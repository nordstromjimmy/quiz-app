import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quiz/data/models/user_progress.dart';
import 'package:quiz/features/home/home_screen.dart';
import 'quiz_controller.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizSessionState quizState;

  const QuizResultScreen({super.key, required this.quizState});

  @override
  Widget build(BuildContext context) {
    final totalCorrect = quizState.questions
        .asMap()
        .entries
        .where(
          (entry) =>
              quizState.userAnswers[entry.key] == entry.value.correctIndex,
        )
        .length;

    final allCorrect = totalCorrect == quizState.questions.length;

    final earnedXp = (totalCorrect * 5) + 10 + (allCorrect ? 25 : 0);

    // Update user progress
    final progressBox = Hive.box<UserProgress>('progressBox');
    var progress = progressBox.get('user') ?? UserProgress();
    final xpBefore = progress.xp;
    progress.addXp(earnedXp);
    progress.quizzesTaken += 1;
    progress.quizzesCompleted += 1;
    progress.save();
    final xpNow = progress.xp;

    final nextLevelXp = progress.nextLevelXp;
    final beforeFraction = xpBefore / nextLevelXp;
    final afterFraction = xpNow / nextLevelXp;
    final earnedFraction = (afterFraction - beforeFraction).clamp(0.0, 1.0);

    return Scaffold(
      body: SingleChildScrollView(
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
                    "total": "${quizState.questions.length}",
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

            ...quizState.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final selected = quizState.userAnswers[index];
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
            }).toList(),

            SizedBox(height: 30),
            Card(
              color: Colors.white12,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "+$earnedXp XP earned this quiz",
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
                          "+25 XP PERFECT BONUS!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          flex: (beforeFraction * 1000).round(),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: (earnedFraction * 1000).round(),
                          child: Container(
                            height: 12,
                            color: Colors.greenAccent,
                          ),
                        ),
                        Flexible(
                          flex: ((1 - beforeFraction - earnedFraction) * 1000)
                              .round(),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${progress.xp}/${progress.nextLevelXp} XP to next level",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
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
    );
  }
}
