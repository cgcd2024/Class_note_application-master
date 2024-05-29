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

    List<String> quizTexts = taskModel.quizTexts!.toList();

    return Scaffold(
      body: Center(
        child: (taskModel.quizTexts == null ||
            taskModel.quizTexts!.isEmpty)
            ? const Text('생성중')
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quizTexts.length,
                itemBuilder: (context, index) {
                  return quizWidget(context, quizTexts[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget quizWidget(BuildContext context, String quizText) {
    Map<String, String> quizMap = {'question': 'q', 'answer': 'a'};

    String slicedString = '';
    var beforeQuestionFin = true;

    for (var i = 0; i < quizText.length; i++) {
      slicedString += quizText[i];
      if (quizText[i] == '\n' && beforeQuestionFin) {
        quizMap['question'] = slicedString;
        beforeQuestionFin = false;
        slicedString = '';
        //i += 5;
      }
      if (i == quizText.length - 1 && !beforeQuestionFin) {
        quizMap['answer'] = slicedString;
        beforeQuestionFin = true;
        slicedString = '';
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
                ),
              ),
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
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        quizMap['answer']!,
                        style: const TextStyle(fontSize: 16),
                        softWrap: true, // 줄 바꿈 허용
                        maxLines: 10, // 최대 줄 수 설정
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}