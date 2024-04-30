import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart';
import 'package:http/http.dart' as http;
import '../../../routes/pages.dart';

class UploadVoiceScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UploadVoiceScreen({Key? key, required this.taskModel}) : super(key: key);

  @override
  _UploadVoiceScreenState createState() => _UploadVoiceScreenState();
}

class _UploadVoiceScreenState extends State<UploadVoiceScreen> {
  var text = "SPEECH TO TEXT";
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    initRecorder();
  }

  Future<void> initRecorder() async {
    try {
      await _recorder!.openRecorder();
      _isRecorderInitialized = true; // 녹음기가 성공적으로 초기화되었습니다.
      _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    } catch (e) {
      print('녹음기 초기화 중 오류 발생: $e');
      _isRecorderInitialized = false;
    }
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized) {
      print('녹음기가 아직 초기화되지 않았습니다. 녹음을 시작할 수 없습니다.');
      return; // 초기화가 완료되지 않았으므로 녹음 시작을 하지 않습니다.
    }

    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/flutter_sound_tmp.aac';
      await _recorder!.startRecorder(toFile: filePath);
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('녹음 시작 중 오류 발생: $e');
      // 필요하다면 여기에서 추가적인 예외 처리를 수행할 수 있습니다.
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<void> stopRecording() async {
    String? path = await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
      convertSpeechToText(_recordedFilePath!);  // Automatically start conversion
    });
  }

  Future<String> convertSpeechToText(String filePath) async {
    const apiKey = "myapikey";
    var url = Uri.https("api.openai.com", "/v1/audio/transcriptions");
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({"Authorization": "Bearer $apiKey"});
    request.fields['model'] = 'whisper-1';
    request.fields['language'] = 'ko';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    try {
      var response = await request.send();
      var newResponse = await http.Response.fromStream(response);
      if (newResponse.statusCode == 200) {
        var responseData = json.decode(utf8.decode(newResponse.bodyBytes));
        if (responseData.containsKey('text')) {
          setState(() {
            text = responseData['text'];
          });
          return responseData['text'];
        } else {
          throw Exception('API response does not contain text.');
        }
      } else {
        print('API call failed with status code: ${newResponse.statusCode}');
        throw Exception('API call failed. Status code: ${newResponse.statusCode}');
      }
    } catch (e) {
      print('Exception during API call: $e');
      rethrow;
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? stopRecording : startRecording,
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: _isRecording ? Colors.red : Colors.white,
                minimumSize: Size(200, 200),
                padding: EdgeInsets.all(20),
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 100,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text('Recording Status: ${_isRecording ? "Recording..." : "Stopped"}'),
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
            ),
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
