import 'dart:async';
import 'dart:io';
import 'package:class_note/tasks/presentation/pages/upload_voice/process_voicefile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:class_note/tasks/data/local/model/task_model.dart';
import 'package:class_note/tasks/presentation/pages/quiz_screen.dart';
import 'package:class_note/tasks/presentation/pages/summary_screen.dart';
import 'package:class_note/tasks/presentation/pages/tasks_screen.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/local/data_sources/tasks_data_provider.dart';
import '../bloc/tasks_bloc.dart';
import 'package:path/path.dart' as path;

class UploadVoiceScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UploadVoiceScreen({Key? key, required this.taskModel})
      : super(key: key);

  @override
  State<UploadVoiceScreen> createState() => _UploadVoiceScreenState();
}

class _UploadVoiceScreenState extends State<UploadVoiceScreen> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;
  int _elapsedTimeInSeconds = 0;

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
      _elapsedTimeInSeconds = 0; // 타이머 초기화
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTimeInSeconds++;
        });
      });
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
      _timer.cancel();
      String? path = await _recorder!.stopRecorder();
      setState(() {
        context.read<TasksBloc>().add(StartProcessing());
      });
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
          widget.taskModel.transcribedTexts = transcribedText;
          setState(() {
            context
                .read<TasksBloc>()
                .add(UploadVoiceFile(taskModel: widget.taskModel));
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

  // Future<String> convertSpeechToText(String filePath) async {
  //   const maxFileSize = 25 * 1024 * 1024;
  //   const sliceSize = 20 * 1024 * 1024;
  //   final file = File(filePath);
  //   final fileSize = await file.length();
  //
  //   if (fileSize <= maxFileSize) {
  //     return await processFile(filePath);
  //   } else {
  //     String transcribedText = '';
  //     int start = 0;
  //     while (start < fileSize) {
  //       int end = (start + sliceSize < fileSize) ? start + sliceSize : fileSize;
  //       String slicePath =
  //           '${path.dirname(filePath)}/${path.basename(
  //           filePath)}.slice$start-$end${path.extension(filePath)}';
  //       List<int> sliceBytes = await file
  //           .openRead(start, end)
  //           .toList()
  //           .then((list) => list.expand((x) => x).toList());
  //       await File(slicePath).writeAsBytes(sliceBytes);
  //       transcribedText += await processFile(slicePath);
  //       start += sliceSize;
  //     }
  //     return transcribedText;
  //   }
  // }
  //
  // Future<String> processFile(String filePath) async {
  //   final apiKey = dotenv.env['API_KEY'];
  //   var url = Uri.https("api.openai.com", "/v1/audio/transcriptions");
  //   var request = http.MultipartRequest('POST', url);
  //   request.headers.addAll({"Authorization": "Bearer $apiKey"});
  //   request.fields['model'] = 'whisper-1';
  //   request.fields['language'] = 'ko';
  //   request.files.add(await http.MultipartFile.fromPath('file', filePath));
  //   try {
  //     var response = await request.send();
  //     var newResponse = await http.Response.fromStream(response);
  //     if (newResponse.statusCode == 200) {
  //       var responseData = json.decode(utf8.decode(newResponse.bodyBytes));
  //       if (responseData.containsKey('text')) {
  //         String transcribedText = responseData['text'];
  //         return transcribedText;
  //       } else {
  //         throw Exception('API response does not contain text.');
  //       }
  //     } else {
  //       throw Exception(
  //           'API call failed. Status code: ${newResponse.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Exception during API call: $e');
  //   }
  // }
  //
  // Future<String> convertM4aToMp3(String inputPath) async {
  //   final outputPath = inputPath.replaceAll('.m4a', '.mp3');
  //   final flutterFFmpeg = FlutterFFmpeg();
  //
  //   int result = await flutterFFmpeg.execute(
  //       '-y -i "$inputPath" -codec:a libmp3lame -qscale:a 2 "$outputPath"');
  //   if (result == 0) {
  //     logger.i('Conversion successful');
  //     return outputPath;
  //   } else {
  //     throw Exception('Failed to convert file');
  //   }
  // }
  //
  // Future<String> convertAacToMp3(String inputPath) async {
  //   final outputPath = inputPath.replaceAll('.aac', '.mp3');
  //   final flutterFFmpeg = FlutterFFmpeg();
  //
  //   int result = await flutterFFmpeg.execute(
  //       '-y -i "$inputPath" -codec:a libmp3lame -qscale:a 2 "$outputPath"');
  //   if (result == 0) {
  //     logger.i('Conversion successful');
  //     return outputPath;
  //   } else {
  //     throw Exception('Failed to convert file');
  //   }
  // }
  //
  // Future<void> requestPermissions() async {
  //   var micStatus = await Permission.microphone.status;
  //   if (!micStatus.isGranted) {
  //     await Permission.microphone.request();
  //   }
  //
  //   var storageStatus = await Permission.storage.status;
  //   if (!storageStatus.isGranted) {
  //     await Permission.storage.request();
  //   }
  // }
  //
  // Future<void> initRecorder() async {
  //   try {
  //     await _recorder!.openRecorder();
  //     _isRecorderInitialized = true;
  //     _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
  //   } catch (e) {
  //     logger.e('녹음기 초기화 중 오류 발생: $e');
  //     _isRecorderInitialized = false;
  //   }
  // }
  //
  // Future<void> startRecording() async {
  //   if (!_isRecorderInitialized || _recorder!.isRecording) {
  //     logger.w('Recorder not initialized or already recording.');
  //     return;
  //   }
  //   try {
  //     _elapsedTimeInSeconds = 0; // 타이머 초기화
  //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //       setState(() {
  //         _elapsedTimeInSeconds++;
  //       });
  //     });
  //     Directory tempDir = await getTemporaryDirectory();
  //     _recordedFilePath = '${tempDir.path}/flutter_sound_tmp.aac';
  //     await _recorder!.startRecorder(toFile: _recordedFilePath);
  //     setState(() {
  //       _isRecording = true;
  //     });
  //   } catch (e) {
  //     logger.e('Recording start error: $e');
  //     setState(() {
  //       _isRecording = false;
  //     });
  //   }
  // }
  //
  //
  // Future<void> stopRecording() async {
  //   if (!_recorder!.isRecording) {
  //     return;
  //   }
  //   try {
  //     _timer.cancel();
  //     String? path = await _recorder!.stopRecorder();
  //     setState(() {
  //       context.read<TasksBloc>().add(StartProcessing());
  //     });
  //     if (path == null) {
  //       return;
  //     }
  //     setState(() {
  //       _isRecording = false;
  //     });
  //     try {
  //       String mp3Path = await convertAacToMp3(path);
  //       _recordedFilePath = mp3Path;
  //       try {
  //         String transcribedText = await convertSpeechToText(mp3Path);
  //         widget.taskModel.transcribedTexts = transcribedText;
  //         setState(() {
  //           context
  //               .read<TasksBloc>()
  //               .add(UploadVoiceFile(taskModel: widget.taskModel));
  //         });
  //       } catch (e) {
  //         logger.e('Error converting speech to text: $e');
  //       }
  //     } catch (e) {
  //       logger.e('Error during AAC to MP3 conversion: $e');
  //     }
  //   } catch (e) {
  //     logger.e('Error stopping the recording: $e');
  //   }
  // }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    _pageController.dispose();
    _timer.cancel();
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

  String _formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}H : ${minutes.toString().padLeft(2, '0')}M :${remainingSeconds.toString().padLeft(2, '0')}S';
  }

  @override
  Widget build(BuildContext context) {
    final taskModel = widget.taskModel;
    return Scaffold(
      appBar: AppBar(
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
            child: BlocBuilder<TasksBloc, TasksState>(
              builder: (context, state) {
                if (state is FetchTasksSuccess &&
                    widget.taskModel.transcribedTexts == '') {
                  return _buildInitialUI();
                } else if (state is ProcessLoading || state is TasksLoading) {
                  return _buildLoadingUI();
                } else if (state is VoiceFileUploaded) {
                  return _buildUploadedUI();
                } else {
                  return _buildUploadedUI();
                }
              },
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

  Widget _buildInitialUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.taskModel.title,
          style: TextStyle(
            color: Colors.blueGrey.shade800,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _isRecording ? stopRecording : startRecording,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: const Size(200, 200),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            size: 100,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _isRecording ? _formatElapsedTime(_elapsedTimeInSeconds) : "녹음중이 아닙니다",
          style: TextStyle(
            color: Colors.blueGrey.shade600,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (result != null && result.files.isNotEmpty) {
              setState(() {
                context
                    .read<TasksBloc>()
                    .add(StartProcessing());
              });
              String filePath = result.files.single.path!;
              if (path.extension(filePath).toLowerCase() == '.m4a') {
                filePath = await convertM4aToMp3(filePath);
              }
              try {
                String transcribedText = await convertSpeechToText(filePath);
                widget.taskModel.transcribedTexts = transcribedText;
                setState(() {
                  context
                      .read<TasksBloc>()
                      .add(UploadVoiceFile(taskModel: widget.taskModel));
                });
              } catch (e) {
                logger.e('음성을 텍스트로 변환하는 중 오류가 발생했습니다: $e');
              }
            } else {
              logger.e('파일을 선택하지 않았습니다.');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            elevation: 2,
          ),
          child: const Text('Upload'),
        ),
      ],
    );
  }

  Widget _buildLoadingUI() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 20),
          Text(
            '번역 생성중...!!',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedUI() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            color: Colors.lightBlue,
            size: 40.0,
          ),
          SizedBox(height: 10),
          Text(
            '수업 관련 요약과 퀴즈가 생성되었습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
