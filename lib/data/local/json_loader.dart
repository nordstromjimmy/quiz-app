import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';

class QuestionLoader {
  static Future<void> loadQuestionsFromJson(
    String locale, [
    String category = "General Knowledge",
  ]) async {
    // Decide which JSON file to load based on category
    String assetPath;
    switch (category) {
      case "Science":
        assetPath = 'assets/questions/science-questions.json';
        break;
      case "History":
        assetPath = 'assets/questions/history-questions.json';
        break;
      default:
        assetPath = 'assets/questions/general-questions.json';
    }

    final jsonString = await rootBundle.loadString(assetPath);
    final data = jsonDecode(jsonString) as List;

    final questions = data.map((item) {
      return Question(
        id: item['id'],
        text: item['text'][locale] ?? item['text']['en'],
        options: List<String>.from(
          item['options'][locale] ?? item['options']['en'],
        ),
        correctIndex: item['correctIndex'],
        explanation: item['explanation'][locale] ?? item['explanation']['en'],
        category: item['category'],
      );
    }).toList();

    final box = await Hive.openBox<Question>('questionsBox');

    await box.clear(); // always clean slate on load
    await box.addAll(questions);

    print('✅ Loaded ${questions.length} questions into Hive for $category.');
  }
}
