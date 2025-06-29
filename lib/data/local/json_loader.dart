import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';

class QuestionLoader {
  static Future<void> loadQuestionsFromJson(String locale) async {
    final jsonString = await rootBundle.loadString(
      'assets/questions/questions.json',
    );
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

    await box.clear(); // optional if you want fresh load
    await box.addAll(questions);

    print('✅ Loaded ${questions.length} questions into Hive.');
  }
}
