// ignore_for_file: non_constant_identifier_names

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
      body: Center(
        child: (taskModel.quizTexts == null || taskModel.quizTexts!.isEmpty)
            ? const Text('생성중')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Quiz page: ${taskModel.title}"),
                  Text("Task Description: ${taskModel.description}"),
                  ...taskModel.quizTexts!.map((text) => Text(text)).toList(),
                  ExpansionTile(
                    shape: const Border(),
                    title: Text(QnAdic[0]['question']!),
                    children: <Widget>[
                      ListTile(
                        title: Text(QnAdic[0]['answer']!),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    shape: const Border(),
                    title: Text(QnAdic[1]['question']!),
                    children: <Widget>[
                      ListTile(
                        title: Text(QnAdic[1]['answer']!),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    shape: const Border(),
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
