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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              "Question ${quizState.currentIndex + 1}/${quizState.questions.length}",
            ),
            LinearProgressIndicator(
              color: Colors.blue,
              value: (quizState.currentIndex + 1) / quizState.questions.length,
            ),
            SizedBox(height: 40),
            Text(
              currentQ.text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
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
