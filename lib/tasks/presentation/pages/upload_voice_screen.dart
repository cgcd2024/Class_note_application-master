import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart';
import 'package:http/http.dart' as http;
import '../../../routes/pages.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc/tasks_bloc.dart';


class UploadVoiceScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UploadVoiceScreen({Key? key, required this.taskModel}) : super(key: key);

  @override
  _UploadVoiceScreenState createState() => _UploadVoiceScreenState();
}

class _UploadVoiceScreenState extends State<UploadVoiceScreen> {
  var text = "";
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    //이벤트처리를 위해 선언
    context.read<TasksBloc>().add(FetchTaskEvent());
    requestPermissions().then((_) {
      _recorder = FlutterSoundRecorder();
      initRecorder();
    });
  }

  Future<String> convertAacToMp3(String inputPath) async {
    final outputPath = inputPath.replaceAll('.aac', '.mp3');
    final flutterFFmpeg = FlutterFFmpeg();

    int result = await flutterFFmpeg.execute('-y -i "$inputPath" -codec:a libmp3lame -qscale:a 2 "$outputPath"');
    if (result == 0) {
      print('Conversion successful');
      return outputPath;
    } else {
      throw Exception('Failed to convert file');
    }
  }

  Future<void> requestPermissions() async {
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      await Permission.microphone.request();
    }

    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> initRecorder() async {
    try {
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
      _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    } catch (e) {
      print('녹음기 초기화 중 오류 발생: $e');
      _isRecorderInitialized = false;
    }
  }


  Future<void> startRecording() async {
    if (!_isRecorderInitialized || _recorder!.isRecording) {
      print('Recorder not initialized or already recording.');
      return;
    }

    try {
      Directory tempDir = await getTemporaryDirectory();
      _recordedFilePath = '${tempDir.path}/flutter_sound_tmp.aac';
      await _recorder!.startRecorder(toFile: _recordedFilePath);
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Recording start error: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> stopRecording() async {
    if (!_recorder!.isRecording) {
      print('No recording currently active.');
      return;
    }
    try {
      String? path = await _recorder!.stopRecorder();
      if (path == null) {
        print('Error: Recording path is null after stopping the recorder.');
        return;
      }
      setState(() {
        _isRecording = false;
      });
      print('Recording stopped. Original file saved at: $path');
      try {
        String mp3Path = await convertAacToMp3(path);
        print('Conversion to MP3 successful. File saved at: $mp3Path');
        _recordedFilePath = mp3Path;
        try {
          String transcribedText = await convertSpeechToText(mp3Path);
          print('Text conversion successful: $transcribedText');
          List<String> updatedTranscribedTexts = List.from(widget.taskModel.transcribedTexts)
            ..add(transcribedText);
          TaskModel updatedTaskModel = widget.taskModel.copyWith(
              transcribedTexts: updatedTranscribedTexts
          );
          context.read<TasksBloc>().add(UpdateTaskEvent(taskModel: updatedTaskModel));
          context.read<TasksBloc>().add(UploadVoiceFile(taskModel: updatedTaskModel));
          setState(() {
            text = transcribedText;
          });
        } catch (e) {
          print('Error converting speech to text: $e');
        }
      } catch (e) {
        print('Error during AAC to MP3 conversion: $e');
      }
    } catch (e) {
      print('Error stopping the recording: $e');
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }


  Future<String> convertSpeechToText(String filePath) async {
    final apiKey = dotenv.env['API_KEY'];
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
          String transcribedText = responseData['text'];
          return transcribedText;
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
    final taskModel = widget.taskModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('앱 이름'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Task Title: ${taskModel.title}"),
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
                    String transcribedText = await convertSpeechToText(filePath);
                    //ㄴ
                    List<String> updatedTranscribedTexts = List.from(widget.taskModel.transcribedTexts)..add(transcribedText);
                    TaskModel updatedTaskModel = widget.taskModel.copyWith(transcribedTexts: updatedTranscribedTexts);
                    context.read<TasksBloc>().add(UploadVoiceFile(taskModel: updatedTaskModel));
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

            //BLOC 이벤트가 완료되면 UI 처리코드
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
                if (state is VoiceFileUploadSuccess) {
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Converted Texts:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text("${state.processedTasks.first.transcribedTexts}"),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Text("번역 생성이전");
              },
            )
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
