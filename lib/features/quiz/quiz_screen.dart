import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quiz_controller.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);

    if (quizState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(child: Text("No quiz loaded.")),
      );
    }

    final currentQ = quizState.questions[quizState.currentIndex];
    final selected = quizState.userAnswers[quizState.currentIndex];

    final timeRemaining = quizState.timeRemaining;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              tr(
                "question_progress",
                namedArgs: {
                  "current": "${quizState.currentIndex + 1}",
                  "total": "${quizState.questions.length}",
                },
              ),
            ),
            LinearProgressIndicator(
              color: Color(0xFFFFC107),
              value: (quizState.currentIndex + 1) / quizState.questions.length,
            ),
            SizedBox(height: 40),
            Text(
              currentQ.text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Center(
              child: SizedBox(
                height: 250,
                width: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 4.0,
                      child: CircularProgressIndicator(
                        value: timeRemaining / 10,
                        strokeWidth: 1,
                        color: Colors.greenAccent,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Text(
                      "$timeRemaining",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            ...List.generate(currentQ.options.length, (index) {
              final isSelected = selected == index;

              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: isSelected ? Colors.blue.shade700 : null,
                  ),
                  onPressed: () {
                    ref
                        .read(quizControllerProvider.notifier)
                        .answerCurrent(index, context);
                  },
                  child: Text(
                    currentQ.options[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
