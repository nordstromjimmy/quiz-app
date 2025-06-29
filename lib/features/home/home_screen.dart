import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:quiz/data/local/json_loader.dart';
import 'package:quiz/data/models/user_profile.dart';
import '../../data/models/user_progress.dart';
import '../../data/models/question.dart';
import '../quiz/quiz_controller.dart';
import '../quiz/quiz_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String countryFlag(String country) {
    switch (country) {
      case "USA":
        return "🇺🇸";
      case "England":
        return "🇬🇧";
      case "Sweden":
        return "🇸🇪";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box<UserProgress>('progressBox');
    final progress = box.get('user') ?? UserProgress();

    final profileBox = Hive.box<UserProfile>('profileBox');
    final userProfile = profileBox.get('user');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            if (userProfile != null)
              Row(
                children: [
                  Text(
                    tr("welcome", namedArgs: {"name": userProfile.username}),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    countryFlag(userProfile.country),
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),

            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      tr("level", namedArgs: {"level": "${progress.level}"}),
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.xp / progress.nextLevelXp,
                    ),
                    SizedBox(height: 8),
                    Text("${progress.xp} XP / ${progress.nextLevelXp} XP"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              tr(
                "quizzes_taken",
                namedArgs: {"count": "${progress.quizzesTaken}"},
              ),
            ),
            Text(
              tr(
                "quizzes_completed",
                namedArgs: {"count": "${progress.quizzesCompleted}"},
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black, width: 1),
                ),
                onPressed: () async {
                  final qBox = Hive.box<Question>('questionsBox');

                  await qBox
                      .clear(); // clear for now, remove later if you want to keep history

                  final locale = context.locale.languageCode;
                  await QuestionLoader.loadQuestionsFromJson(locale);

                  final questions = qBox.values.toList()..shuffle();
                  ref
                      .read(quizControllerProvider.notifier)
                      .startQuiz(questions.take(5).toList());

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizScreen()),
                  );
                },
                child: Text(
                  tr("start_quiz"),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
