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
  final progressBox = await Hive.openBox<UserProgress>('progressBox');
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
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF0B1E3D), // dark blue
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFC107), // gold
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 6,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.white54),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: hasProfile ? HomeScreen() : OnboardingScreen(),
    );
  }
}
