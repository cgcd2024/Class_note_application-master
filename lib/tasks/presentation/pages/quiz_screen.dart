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

    List<String> quizTexts = taskModel.quizTexts!.toList();

    for (var i = 0; i < QnAdic.length; i++) {
      String slicedString = '';
      var beforeQuestionFin = true;
      for (var j = 0; j < quizTexts[i].length; j++) {
        if (quizTexts[i][j] != '\n') {
          slicedString += quizTexts[i][j];
        } else {
          if (beforeQuestionFin) {
            QnAdic[i]['question'] = slicedString;
            beforeQuestionFin = false;
          } else {
            QnAdic[i]['answer'] = slicedString;
          }
          slicedString = '';
        }
      }
    }

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
