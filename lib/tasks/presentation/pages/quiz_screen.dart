import 'package:flutter/material.dart';
import '../../../routes/pages.dart';
import '../../data/local/model/task_model.dart';

class QuizScreen extends StatefulWidget {
  final TaskModel taskModel; // TaskModel 객체를 필수 매개변수로 추가

  // 생성자에서 TaskModel을 필수로 받도록 설정
  const QuizScreen({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    // StatefulWidget에서는 widget 프로퍼티를 통해 StatefulWidget의 변수에 접근
    final taskModel = widget.taskModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUIZ Screen'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, Pages.uploadVoice, arguments: widget.taskModel),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Task Title: ${taskModel.title}"), // TaskModel의 title을 화면에 표시
            const SizedBox(height: 10),
            Text("Task Description: ${taskModel.description}"), // TaskModel의 description을 화면에 표시
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
                  Pages.createSummary, arguments: widget.taskModel
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(
                  context,
                  Pages.createQuiz, arguments: widget.taskModel
              );
              break;
          }
        },
      ),
    );
  }
}
