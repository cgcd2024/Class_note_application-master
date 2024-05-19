import 'package:flutter/material.dart';
import '../../../routes/pages.dart';
import '../../data/local/model/task_model.dart';

class QuizScreen extends StatefulWidget {
  final TaskModel processedTasks; // TaskModel 객체를 필수 매개변수로 추가

  // 생성자에서 TaskModel을 필수로 받도록 설정함
  const QuizScreen({Key? key, required this.processedTasks}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}


class _QuizScreenState extends State<QuizScreen> {
  var before = '';

  @override
  Widget build(BuildContext context) {
    final taskModel = widget.processedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Screen'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, Pages.uploadVoice, arguments: widget.processedTasks),
        ),
      ),
      body: Center(
        child: (taskModel.quizTexts == null || taskModel.quizTexts!.isEmpty)
            ? const Text('생성중')
        //TODO UI 디자인해서 여기를 만들어주세요
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Task Title: ${taskModel.title}"),
            Text("Task Description: ${taskModel.description}"),
            ...taskModel.quizTexts!.map((text) => Text(text)).toList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
        ],
        backgroundColor: Colors.grey[50],
        selectedItemColor: Colors.black,  // 선택된 아이템의 색상을 검정색으로 설정
        unselectedItemColor: Colors.black,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(
                  context,
                  Pages.createSummary, arguments: widget.processedTasks
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(
                  context,
                  Pages.createQuiz, arguments: widget.processedTasks
              );
              break;
          }
        },
      ),
    );
  }
}
