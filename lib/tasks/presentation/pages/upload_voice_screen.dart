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
import 'package:permission_handler/permission_handler.dart';
import 'package:task_manager_app/tasks/presentation/pages/quiz_screen.dart';
import 'package:task_manager_app/tasks/presentation/pages/summary_screen.dart';
import 'package:task_manager_app/tasks/presentation/pages/tasks_screen.dart';
import '../../data/local/data_sources/tasks_data_provider.dart';
import '../bloc/tasks_bloc.dart';
import 'package:path/path.dart' as path;

class UploadVoiceScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UploadVoiceScreen({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<UploadVoiceScreen> createState() => _UploadVoiceScreenState();
}

class _UploadVoiceScreenState extends State<UploadVoiceScreen> {
  var text = "";
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(FetchTaskEvent());
    _pageController = PageController(initialPage: _selectedIndex);
    requestPermissions().then((_) {
      _recorder = FlutterSoundRecorder();
      initRecorder();
    });
  }

  Future<String> convertSpeechToText(String filePath) async {
    const maxFileSize = 25 * 1024 * 1024;
    const sliceSize = 20 * 1024 * 1024;
    final file = File(filePath);
    final fileSize = await file.length();

    if (fileSize <= maxFileSize) {
      return await processFile(filePath);
    } else {
      String transcribedText = '';
      int start = 0;
      while (start < fileSize) {
        int end = (start + sliceSize < fileSize) ? start + sliceSize : fileSize;
        String slicePath = '${path.dirname(filePath)}/${path.basename(filePath)}.slice$start-$end${path.extension(filePath)}';
        List<int> sliceBytes = await file.openRead(start, end).toList().then((list) => list.expand((x) => x).toList());
        await File(slicePath).writeAsBytes(sliceBytes);
        transcribedText += await processFile(slicePath);
        start += sliceSize;
      }
      return transcribedText;
    }
  }

  Future<String> processFile(String filePath) async {
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
        throw Exception('API call failed. Status code: ${newResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception during API call: $e');
    }
  }

  Future<String> convertM4aToMp3(String inputPath) async {
    final outputPath = inputPath.replaceAll('.m4a', '.mp3');
    final flutterFFmpeg = FlutterFFmpeg();

    int result = await flutterFFmpeg.execute(
        '-y -i "$inputPath" -codec:a libmp3lame -qscale:a 2 "$outputPath"');
    if (result == 0) {
      logger.i('Conversion successful');
      return outputPath;
    } else {
      throw Exception('Failed to convert file');
    }
  }

  Future<String> convertAacToMp3(String inputPath) async {
    final outputPath = inputPath.replaceAll('.aac', '.mp3');
    final flutterFFmpeg = FlutterFFmpeg();

    int result = await flutterFFmpeg.execute(
        '-y -i "$inputPath" -codec:a libmp3lame -qscale:a 2 "$outputPath"');
    if (result == 0) {
      logger.i('Conversion successful');
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
      logger.e('녹음기 초기화 중 오류 발생: $e');
      _isRecorderInitialized = false;
    }
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized || _recorder!.isRecording) {
      logger.w('Recorder not initialized or already recording.');
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
      logger.e('Recording start error: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> stopRecording() async {
    if (!_recorder!.isRecording) {
      return;
    }
    try {
      String? path = await _recorder!.stopRecorder();
      if (path == null) {
        return;
      }
      setState(() {
        _isRecording = false;
      });
      try {
        String mp3Path = await convertAacToMp3(path);
        _recordedFilePath = mp3Path;
        try {
          String transcribedText = await convertSpeechToText(mp3Path);
          List<String> updatedTranscribedTexts = List.from(widget.taskModel.transcribedTexts)..add(transcribedText);
          TaskModel updatedTaskModel = widget.taskModel.copyWith(transcribedTexts: updatedTranscribedTexts);
          context.read<TasksBloc>().add(UpdateTaskEvent(taskModel: updatedTaskModel));
          context.read<TasksBloc>().add(UploadVoiceFile(taskModel: updatedTaskModel));
          setState(() {
            text = transcribedText;
          });
        } catch (e) {
          logger.e('Error converting speech to text: $e');
        }
      } catch (e) {
        logger.e('Error during AAC to MP3 conversion: $e');
      }
    } catch (e) {
      logger.e('Error stopping the recording: $e');
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final taskModel = widget.taskModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 이름'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TasksScreen(),
              ),
            );
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Task Title: ${taskModel.title}"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isRecording ? stopRecording : startRecording,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: _isRecording ? Colors.red : Colors.white,
                    minimumSize: const Size(200, 200),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 100,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Recording Status: ${_isRecording ? "Recording..." : "Stopped"}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.isNotEmpty) {
                      String filePath = result.files.single.path!;
                      if (path.extension(filePath).toLowerCase() == '.m4a') {
                        filePath = await convertM4aToMp3(filePath);
                      }
                      try {
                        String transcribedText = await convertSpeechToText(filePath);
                        List<String> updatedTranscribedTexts = List.from(widget.taskModel.transcribedTexts)..add(transcribedText);
                        TaskModel updatedTaskModel = widget.taskModel.copyWith(transcribedTexts: updatedTranscribedTexts);
                        context.read<TasksBloc>().add(UploadVoiceFile(taskModel: updatedTaskModel));
                      } catch (e) {
                        logger.e('음성을 텍스트로 변환하는 중 오류가 발생했습니다: $e');
                      }
                    } else {
                      logger.e('파일을 선택하지 않았습니다.');
                    }
                  },
                  child: const Text('Upload'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SummaryScreen(processedTasks: taskModel),
          QuizScreen(processedTasks: taskModel)
        ],
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
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey[50],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

