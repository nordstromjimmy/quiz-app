import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:quiz/data/local/json_loader.dart';
import 'package:quiz/data/models/user_profile.dart';
import 'package:quiz/features/onboarding/onboarding_screen.dart';
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            if (userProfile != null)
              Card(
                color: Colors.lime,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        countryFlag(userProfile.country),
                        style: TextStyle(fontSize: 26),
                      ),
                      Spacer(),
                      Text(
                        tr(
                          "welcome",
                          namedArgs: {"name": userProfile.username},
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OnboardingScreen(
                                initialUsername: userProfile.username,
                                initialCountry: userProfile.country,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 30),
            Card(
              color: Color(0xFFFFC107),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      tr("level", namedArgs: {"level": "${progress.level}"}),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress.xp / progress.nextLevelXp,
                      color: Colors.green,
                      backgroundColor: Colors.white,
                      minHeight: 8,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "${progress.xp} XP / ${progress.nextLevelXp} XP",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              tr(
                "quizzes_taken",
                namedArgs: {"count": "${progress.quizzesTaken}"},
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            /*             Text(
              tr(
                "quizzes_completed",
                namedArgs: {"count": "${progress.quizzesCompleted}"},
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ), */
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final qBox = Hive.box<Question>('questionsBox');

                  await qBox.clear(); // clear for now for fresh load
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
