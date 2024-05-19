import 'package:flutter/material.dart';
import '../../data/local/model/task_model.dart';

class QuizScreen extends StatefulWidget {
  final TaskModel processedTasks;
  const QuizScreen({Key? key, required this.processedTasks}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final taskModel = widget.processedTasks;

    List<Map<String, String>> QnAdic = [
      {'question': 'question1', 'answer': 'answer1'},
      {'question': 'question2', 'answer': 'answer2'},
      {'question': 'question3', 'answer': 'answer3'}
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ExpansionTile(
              title: Text(QnAdic[0]['question']!),
              children: <Widget>[
                ListTile(
                  title: Text(QnAdic[0]['answer']!),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(QnAdic[1]['question']!),
              children: <Widget>[
                ListTile(
                  title: Text(QnAdic[1]['answer']!),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(QnAdic[2]['question']!),
              children: <Widget>[
                ListTile(
                  title: Text(QnAdic[2]['answer']!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
