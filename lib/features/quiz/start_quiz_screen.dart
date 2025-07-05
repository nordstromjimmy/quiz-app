import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quiz/data/local/json_loader.dart';
import 'package:quiz/data/models/question.dart';
import '../quiz/quiz_controller.dart';
import '../quiz/quiz_screen.dart';

class StartQuizScreen extends ConsumerStatefulWidget {
  const StartQuizScreen({super.key});

  @override
  ConsumerState<StartQuizScreen> createState() => _StartQuizScreenState();
}

class _StartQuizScreenState extends ConsumerState<StartQuizScreen> {
  int questionCount = 5;

  final categoryKeys = ["general", "science", "history"];
  String selectedCategory = "general";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1E3D),
      appBar: AppBar(
        title: Text(tr("choose_quiz")),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr("select_category"),
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFF1A2A52),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Color(0xFF1A2A52),
                  value: selectedCategory,
                  items: categoryKeys
                      .map(
                        (key) => DropdownMenuItem<String>(
                          value: key,
                          child: Text(
                            tr("category_$key"),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
              ),
            ),

            SizedBox(height: 30),
            Text(
              tr("number_questions"),
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [5, 10, 15]
                  .map(
                    (n) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: questionCount == n
                            ? Color(0xFFFFC107)
                            : Colors.white24,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() => questionCount = n);
                      },
                      child: Text(
                        "$n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  backgroundColor: Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                ),
                onPressed: () async {
                  final locale = context.locale.languageCode;

                  await QuestionLoader.loadQuestionsFromJson(
                    locale,
                    selectedCategory,
                  );

                  final qBox = Hive.box<Question>('questionsBox');

                  // now filter (safety if you ever have mixed categories in JSON)
                  final filtered =
                      qBox.values
                          .where(
                            (q) => q.category.toLowerCase() == selectedCategory,
                          )
                          .toList()
                        ..shuffle();

                  final selectedQuestions = filtered
                      .take(questionCount)
                      .toList();

                  if (selectedQuestions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr("no_questions_category"))),
                    );
                    return;
                  }

                  ref
                      .read(quizControllerProvider.notifier)
                      .startQuiz(selectedQuestions, context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuizScreen()),
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
