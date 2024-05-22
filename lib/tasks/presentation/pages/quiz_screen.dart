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

    //실제 실행 시 quizTexts 아래 코드로 넣기
    //List<String> quizTexts = taskModel.quizTexts!.toList();

    //임시 리스트
    List<String> quizTexts = [
      "문제 : 문제1\n해답 : 해답1\n",
      "문제 : 문제2에요\n해답 : 해답2에요\n",
      "문제 : 문제3입니다\n해답 : 해답3입니다\n"
    ];

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
        //실제 실행 시 아래 주석 활성화
        //child: (taskModel.quizTexts == null || taskModel.quizTexts!.isEmpty)
        //? const Text('생성중') :
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
