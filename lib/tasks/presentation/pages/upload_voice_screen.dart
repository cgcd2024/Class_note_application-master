import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart'; // TaskModel 클래스를 임포트합니다.

class UploadVoiceScreen extends StatefulWidget {
  final TaskModel taskModel; // TaskModel을 실제 사용할 타입으로 변경합니다.

  const UploadVoiceScreen({Key? key, required this.taskModel}) : super(key: key);

  @override
  _UploadVoiceScreenState createState() => _UploadVoiceScreenState();
}

class _UploadVoiceScreenState extends State<UploadVoiceScreen> {
  // 음성 녹음 및 파일 업로드 관련 상태 관리 변수를 여기에 선언합니다.

  @override
  Widget build(BuildContext context) {
    String taskTitle = widget.taskModel.title; // taskModel에서 title 속성에 접근합니다.

    return Scaffold(
      appBar: AppBar(
        title: Text('앱 이름'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Task Title: $taskTitle', // Display task title
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20), // 간격 추가
            ElevatedButton(
              onPressed: () {
                // 음성 녹음 시작
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(), backgroundColor: Colors.white,
                minimumSize: Size(200, 200), // 버튼의 최소 크기 설정
                padding: EdgeInsets.all(20), // 배경색을 흰색으로 설정
              ),
              child: SvgPicture.asset(
                'assets/svgs/voice.svg',
                width: 100,
                height: 180,
                color: Colors.red, // 이미지의 색상을 빨간색으로 변경
              ),
            ),
            SizedBox(height: 10), // 간격 추가
            ElevatedButton(
              onPressed: () {
                // 음성 파일 업로드
              },
              child: Text('Upload'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
        ],
        selectedItemColor: Colors.blue,
        currentIndex: 0, // 현재 선택된 탭의 인덱스
        onTap: (int index) {
          // 탭이 선택될 때 실행될 함수
          print("Selected Tab: $index");
        },
      ),
    );
  }
}
