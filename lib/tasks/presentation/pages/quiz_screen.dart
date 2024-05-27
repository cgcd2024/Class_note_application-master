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
  @override
  Widget build(BuildContext context) {
    final taskModel = widget.processedTasks;

    //임시 리스트
    List<String> localQuizTexts = [
      "문제 : 문제1\n해답 : 해답1\n",
      "문제 : 문제2에요\n해답 : 해답2에요\n",
      "문제 : 문제3입니다\n해답 : 해답3입니다\n"
    ];

    //실제 실행 시 지우기
    taskModel.quizTexts = localQuizTexts;
    //실제 실행 시 활성화
    //List<String> localQuizText = taskModel.quizTexts!.toList();

    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('QnA')),
            body: Center(
                child: (taskModel.quizTexts == null ||
                        taskModel.quizTexts!.isEmpty)
                    ? const Text('생성중')
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: localQuizTexts.length,
                                  itemBuilder: (context, index) {
                                    return quizWidget(
                                        context, localQuizTexts[index]);
                                  }),
                            )
                          ]))));
  }

  Widget quizWidget(BuildContext context, String quizText) {
    Map<String, String> quizMap = {'question': 'q', 'answer': 'a'};

    String slicedString = '';
    var beforeQuestionFin = true;

    for (var i = 5; i < quizText.length; i++) {
      if (quizText[i] != '\n') {
        slicedString += quizText[i];
      } else {
        if (beforeQuestionFin) {
          quizMap['question'] = slicedString;
          beforeQuestionFin = false;
          slicedString = '';
          i += 5;
        } else {
          quizMap['answer'] = slicedString;
          beforeQuestionFin = true;
          slicedString = '';
        }
      }
    }

    return Column(
      children: <Widget>[
        ExpansionTile(
          backgroundColor: Colors.blue[100],
          shape: const Border(),
          title: Row(
            children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: const Text(
                    'Q.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
              const SizedBox(width: 15),
              Flexible(child: Text(quizMap['question']!)),
            ],
          ),
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 5.0, 0.0, 5.0),
                child: Row(children: [
                  Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                      child: const Text('A.',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 15),
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Flexible(
                        child: Text(quizMap['answer']!,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ])),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
