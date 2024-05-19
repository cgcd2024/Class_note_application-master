import 'package:flutter/material.dart';
import '../../data/local/model/task_model.dart';

class QuizScreen extends StatefulWidget {
  final TaskModel processedTasks;
  const QuizScreen({Key? key, required this.processedTasks}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  //TODO 더미데이터를 넣어서 ui 디자인 코드 만들어주세요
  @override
  Widget build(BuildContext context) {
    final taskModel = widget.processedTasks;

    return Scaffold(
      body: Center(
        child: (taskModel.quizTexts == null || taskModel.quizTexts!.isEmpty)
            ? const Text('생성중')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Quiz page: ${taskModel.title}"),
            Text("Task Description: ${taskModel.description}"),
            ...taskModel.quizTexts!.map((text) => Text(text)).toList(),
          ],
        ),
      ),
    );
  }
}
