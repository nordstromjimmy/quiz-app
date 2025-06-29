/* import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class TriviaService {
  static Future<List<Question>> fetchGeneralKnowledgeQuestions(
    int amount,
  ) async {
    final url = Uri.parse(
      'https://the-trivia-api.com/api/questions?categories=general_knowledge&limit=$amount',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception("Failed to load questions");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((item) {
      final allOptions = List<String>.from(item['incorrectAnswers'])
        ..add(item['correctAnswer']);
      allOptions.shuffle();

      return Question(
        id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        text: item['question'],
        options: allOptions,
        correctIndex: allOptions.indexOf(item['correctAnswer']),
        explanation: "", // API doesn't give explanations
        category: item['category'] ?? "General Knowledge",
      );
    }).toList();
  }
}
 */
