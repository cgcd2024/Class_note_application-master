import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/pages.dart';
import '../../data/local/model/task_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../bloc/tasks_bloc.dart';

class SummaryScreen extends StatefulWidget {
  final TaskModel taskModel; // TaskModel 객체를 필수 매개변수로 추가

  // 생성자에서 TaskModel을 필수로 받도록 설정함
  const SummaryScreen({Key? key, required this.taskModel}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  var before = '강원도 삼척시 대이리 동굴 지대에 위치한 대금굴은 인근에 있는 환선굴, 관음굴과 비슷한 시기에 형성된 동굴로 동굴 발견까지 4년, 시설물 설치 3년, 총 7년의 준비 기간 끝에 일반에 개방하였다.동굴 내부에는 종유석, 석순, 석주 등 동굴 생성물이 잘 발달되어 있으며, 특히 지하에는 근원지를 알 수 없는 많은 양의 동굴수가 흘러 여러 개의 크고 작은 폭포와 동굴 호수가 형성되어 있는 것이 특징이다.현재 대금굴은 모노레일로만 접근이 가능, 최소 방문 하루 전에 온라인 예매를 해야 입장이 가능하다. 대금굴 예매 시간은 모노레일 출발시간이며, 도보 이동을 위해 반드시 30분 전까지 매표소에 도착해야 한다.'; // Replace with your text

  Future<String> summarizeText(String before) async {
    final apiKey = dotenv.env['API_KEY']; // Replace with your actual API key
    final endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model':'gpt-3.5-turbo',
        "messages": [
          {
            "role": "system",
            "content": "You are a helpful assistant."
          },
          {
            "role": "user",
            "content": "다음 문장을 요약해주세요. $before" // 이 부분 chatgpt에 묻는 것처럼 수정
          }
        ]
        // 'max_tokens': 50, // Adjust the summary length as needed
      }),
    );
    print(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final summary = decoded['choices'][0]['message']['content'] as String;
      return summary;
    } else {
      throw Exception('Failed to summarize text');
    }
  }


  @override
  Widget build(BuildContext context) {
    // StatefulWidget에서는 widget 프로퍼티를 통해 StatefulWidget의 변수에 접근
    final taskModel = widget.taskModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Summary Screen'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, Pages.uploadVoice, arguments: widget.taskModel),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Task Title: ${taskModel.title}"), // TaskModel의 title을 화면에 표시
            SizedBox(height: 10),
            Text("Task Description: ${taskModel.description}"),// TaskModel의 description을 화면에 표시
            //processTask가 완료되었을때 화면처리
            BlocConsumer<TasksBloc, TasksState>(
              listener: (context, state) {
                if (state is VoiceFileUploadSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('File uploaded successfully!'),
                    ),
                  );
                }
              },
              builder: (context, state) {
                //TODO summary를 출력하는건 VoiceFileUploadSuccess된 순간만 유지됨 (해결하는법?)
                if (state is VoiceFileUploadSuccess) { // VoiceFileUploadSuccess 이벤트 발생 후
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '요약본 : ',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text("${state.processedTasks.first.summaryTexts}"),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Text("요약 생성전"); // 다른 상태에 대한 빈 위젯 반환
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async{
                  String sum=await summarizeText(before);
                  setState(() {
                    before=sum;
                  });
                },
                child: Text("summarizing")),
            SizedBox(height: 10),
            Text(before),
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
