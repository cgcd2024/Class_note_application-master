import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart';

class UploadVoiceScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UploadVoiceScreen({Key? key, required this.taskModel})
      : super(key: key);

  @override
  _UploadVoiceScreenState createState() => _UploadVoiceScreenState();
}

class _UploadVoiceScreenState extends State<UploadVoiceScreen> {
  var text = "SPEECH TO TEXT";

  Future<String> convertSpeechToText(String filePath) async {
    const apiKey = 'MYAPIKEY';
    var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(({"Authorization": "Bearer $apiKey"}));
    request.fields["model"] = 'whisper-1';
    request.fields["language"] = 'ko';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var response = await request.send();
    var newresponse = await http.Response.fromStream(response);
    if (newresponse.statusCode == 200) {
      var responseData = json.decode(utf8.decode(newresponse.bodyBytes));
      if (responseData.containsKey('text')) {
        return responseData['text'];
      } else {
        throw Exception('API 응답에 텍스트가 포함되어 있지 않습니다.');
      }
    } else {
      throw Exception('API 호출이 실패했습니다. 상태 코드: ${newresponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    String taskTitle = widget.taskModel.title;

    return Scaffold(
      appBar: AppBar(
        title: Text('앱 이름'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Task Title: $taskTitle',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20), // 간격 추가
            ElevatedButton(
              onPressed: () {
                // 음성 녹음 시작
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                minimumSize: Size(200, 200),
                padding: EdgeInsets.all(20),
              ),
              child: SvgPicture.asset(
                'assets/svgs/voice.svg',
                width: 100,
                height: 180,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.isNotEmpty) {
                  String filePath = result.files.single.path!;
                  try {
                    String convertedText = await convertSpeechToText(filePath);
                    setState(() {
                      text = convertedText;
                    });
                  } catch (e) {
                    print('음성을 텍스트로 변환하는 중 오류가 발생했습니다: $e');
                  }
                } else {
                  print('파일을 선택하지 않았습니다.');
                }
              },
              child: Text('Upload'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Converted Text: $text',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
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
        currentIndex: 0,
        onTap: (int index) {
          print("Selected Tab: $index");
        },
      ),
    );
  }
}
