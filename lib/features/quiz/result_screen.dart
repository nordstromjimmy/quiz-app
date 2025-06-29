import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          ...quizState.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final selected = quizState.userAnswers[index];
            final isCorrect = selected == question.correctIndex;

            return Card(
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
                      ),
                    ),
                    SizedBox(height: 8),
                    if (isCorrect)
                      Text(
                        "✅ ${tr("correct")}: ${question.options[question.correctIndex]}",
                        style: TextStyle(fontSize: 15),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "❌ ${tr("your_answer")}: "
                            "${selected != null && selected >= 0 ? question.options[selected] : tr("no_answer")}\n"
                            "✅ ${tr("correct_answer")}: ${question.options[question.correctIndex]}",
                            style: TextStyle(fontSize: 15),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "ℹ️ ${question.explanation}",
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
          Column(
            children: [
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black, width: 1),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
                child: Text(
                  tr("back_home"),
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
