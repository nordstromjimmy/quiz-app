import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz/data/models/question.dart';
import 'package:quiz/data/models/quiz_attempt.dart';
import 'package:quiz/data/models/user_profile.dart';
import 'package:quiz/data/models/user_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/features/home/home_screen.dart';
import 'package:quiz/features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initHive();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('sv')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: ProviderScope(child: MyApp()),
    ),
  );
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(QuizAttemptAdapter());
  Hive.registerAdapter(UserProgressAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  await Hive.openBox<Question>('questionsBox');
  await Hive.openBox<QuizAttempt>('attemptsBox');
  await Hive.openBox<UserProgress>('progressBox');
  await Hive.openBox<UserProfile>('profileBox');

  // Ensure there's at least a progress record
  var progressBox = Hive.box<UserProgress>('progressBox');
  if (progressBox.get('user') == null) {
    await progressBox.put('user', UserProgress());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileBox = Hive.box<UserProfile>('profileBox');
    final hasProfile = profileBox.get('user') != null;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(primarySwatch: Colors.blue),
      //home: hasProfile ? HomeScreen() : OnboardingScreen(),
      home: OnboardingScreen(),
    );
  }
}
