import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quiz/data/models/user_profile.dart';
import 'package:quiz/features/home/edit_screen.dart';
import 'package:quiz/features/quiz/start_quiz_screen.dart';
import '../../data/models/user_progress.dart';
import '../../data/models/question.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String countryFlag(String country) {
    switch (country) {
      case "USA":
        return "🇺🇸";
      case "United Kingdom":
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
                color: Colors.white12,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
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
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(LucideIcons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditScreen(
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
              color: Colors.white12,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          tr(
                            "level",
                            namedArgs: {"level": "${progress.level}"},
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Spacer(),
                        Icon(LucideIcons.gem, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress.xp / progress.nextLevelXp,
                      color: Color(0xFFFFC107),
                      backgroundColor: Colors.white24,
                      minHeight: 8,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "${progress.xp} XP / ${progress.nextLevelXp} XP",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white12,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tr("stats"),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Spacer(),
                          Icon(
                            LucideIcons.chartNoAxesColumn,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        tr(
                          "quizzes_taken",
                          namedArgs: {"count": "${progress.quizzesTaken}"},
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        tr(
                          "quizzes_completed",
                          namedArgs: {"count": "${progress.quizzesCompleted}"},
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        tr(
                          "correct_answers",
                          namedArgs: {
                            "answers": "${progress.totalCorrectAnswers}",
                          },
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        tr(
                          "accuracy",
                          namedArgs: {
                            "percent": progress.totalQuestionsAnswered > 0
                                ? ((progress.totalCorrectAnswers /
                                              progress.totalQuestionsAnswered) *
                                          100)
                                      .toStringAsFixed(0)
                                : "0",
                          },
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        tr(
                          "perfect_quizzes",
                          namedArgs: {"count": "${progress.perfectQuizzes}"},
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final qBox = Hive.box<Question>('questionsBox');

                  await qBox.clear(); // clear for now for fresh load

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StartQuizScreen()),
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
