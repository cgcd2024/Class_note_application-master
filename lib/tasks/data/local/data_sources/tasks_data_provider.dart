import 'dart:convert';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:class_note/tasks/data/local/model/task_model.dart';
import 'package:class_note/utils/exception_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../../../../utils/constants.dart';

var logger = Logger();

class TaskDataProvider {
  List<TaskModel> tasks = [];
  SharedPreferences? prefs;

  TaskDataProvider(this.prefs);

  // 로컬에 있는 task 데이터를 불러와서 taskmodel형 list로 변환
  Future<List<TaskModel>> getTasks() async {
    try {
      final List<String>? savedTasks = prefs!.getStringList(Constants.taskKey);
      if (savedTasks != null) {
        // json으로 List<taskModel> 만듬
        tasks = savedTasks
            .map((taskJson) => TaskModel.fromJson(json.decode(taskJson)))
            .toList();
        // 완료된 task가 뒤로 가게 정렬
        tasks.sort((a, b) {
          if (a.completed == b.completed) {
            return 0;
          } else if (a.completed) {
            return 1;
          } else {
            return -1;
          }
        });
      }
      return tasks;
    } catch (e) {
      throw Exception(handleException(e));
    }
  }

  // List<taskModel> 정렬 함수, 0: 날짜순, 1: 완료task가 앞에 가게끔 정렬, 2: 완료 task가 뒤로 가게끔 정렬
  Future<List<TaskModel>> sortTasks(int sortOption) async {
    switch (sortOption) {
      case 0:
        tasks.sort((a, b) {
          // Sort by date
          if (a.makeDateTime!.isAfter(b.makeDateTime!)) {
            return 1;
          } else if (a.makeDateTime!.isBefore(b.makeDateTime!)) {
            return -1;
          }
          return 0;
        });
        break;
      case 1:
        //sort by completed tasks
        tasks.sort((a, b) {
          if (!a.completed && b.completed) {
            return 1;
          } else if (a.completed && !b.completed) {
            return -1;
          }
          return 0;
        });
        break;
      case 2:
        //sort by pending tasks
        tasks.sort((a, b) {
          if (a.completed == b.completed) {
            return 0;
          } else if (a.completed) {
            return 1;
          } else {
            return -1;
          }
        });
        break;
    }
    return tasks;
  }

  Future<void> createTask(TaskModel taskModel) async {
    try {
      //taskModel을 받아서 tasks에 추가
      tasks.add(taskModel);
      //요건 main.dart에서 언급한 로컬 저장소에 변경된 tasks를 넣음
      final List<String> taskJsonList =
          tasks.map((task) => json.encode(task.toJson())).toList();
      await prefs!.setStringList(Constants.taskKey, taskJsonList);
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    try {
      // 업데이트하는 요소(taskModel)과 기존의 요소(element)를 id가 같은것을 찾아서 바꿔치기
      tasks[tasks.indexWhere((element) => element.id == taskModel.id)] =
          taskModel;
      // 다시 getTasks에서 했던 것처럼 정렬
      tasks.sort((a, b) {
        if (a.completed == b.completed) {
          return 0;
        } else if (a.completed) {
          return 1;
        } else {
          return -1;
        }
      });
      // 애도 로컬에 다시 저장
      final List<String> taskJsonList =
          tasks.map((task) => json.encode(task.toJson())).toList();
      prefs!.setStringList(Constants.taskKey, taskJsonList);
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  // 위에꺼랑 같음
  Future<List<TaskModel>> deleteTask(TaskModel taskModel) async {
    try {
      tasks.remove(taskModel);
      final List<String> taskJsonList =
          tasks.map((task) => json.encode(task.toJson())).toList();
      prefs!.setStringList(Constants.taskKey, taskJsonList);
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> searchTasks(String keywords) async {
    var searchText = keywords.toLowerCase();
    // tasks 복제
    List<TaskModel> matchedTasked = tasks;
    // title 혹은 desc에 keyword가 포함되는것들만 반환
    return matchedTasked.where((task) {
      final titleMatches = task.title.toLowerCase().contains(searchText);
      final descriptionMatches =
          task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
  }

  Future<TaskModel> processTasks(TaskModel taskModel) async {
    // 문백별로 나누는 코드
    taskModel.splitTranscribedTextsByContext =
        await _splitTranscribedTextByContext(taskModel.transcribedTexts);

    //text to summary 코드
    taskModel.summaryTexts = await Future.wait(
        taskModel.splitTranscribedTextsByContext!.map((myString) async {
      return "gpt@${await _summaryTasks(input: myString)}";
    }).toList());

    // summary to quiz 코드
    taskModel.quizTexts = await Future.wait(
        taskModel.splitTranscribedTextsByContext!.map((myString) async {
      return await _quizTasks(input: myString);
    }).toList());

    // prefeb에 저장하는 코드

    return taskModel;
  }

  Future<String> _quizTasks({required String input}) async {
    final apiKey = dotenv.env['API_KEY'];
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        "messages": [
          {
            "role": "system",
            "content":
                "너는 user가 보낸 글의 내용을 기반으로 주관식 문제를 만들어내는 봇이야. 문제를 만들고 해답을 알려 줘."
          },
          {"role": "assistant", "content": "문제 : \n해답 : \n"},
          {"role": "user", "content": input}
        ],
        'max_tokens': 300,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final quiz = decoded['choices'][0]['message']['content'] as String;
      return quiz;
    } else {
      throw Exception('Failed to summarize text');
    }
  }

  //객관식
  Future<String> _multipleChoiceTasks({required String input}) async {
    final apiKey = dotenv.env['API_KEY'];
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        "messages": [
          {
            "role": "system",
            "content":
                "너는 user가 보낸 글의 내용을 4-multiple choice 문제를 만들어내는 봇이야. assistant에 없는 개행문자를 추가하지 말아 줘."
          },
          {
            "role": "assistant",
            "content":
                "문제 : 다음 중 가장 큰 행성은?\n1. 목성\n2. 지구\n3. 화성\n4. 천왕성\n해답 : 1. 목성"
          },
          {"role": "user", "content": input}
        ],
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final quiz = decoded['choices'][0]['message']['content'] as String;
      return quiz;
    } else {
      throw Exception('Failed to summarize text');
    }
  }

  Future<String> _summaryTasks({required String input}) async {
    final apiKey = dotenv.env['API_KEY']; // Replace with your actual API key
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        "messages": [
          {"role": "system", "content": "다음 문장을 요약해주세요"},
          {"role": "user", "content": input}
        ]
        // 'max_tokens': 50, // Adjust the summary length as needed
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final summary = decoded['choices'][0]['message']['content'] as String;
      return summary;
    } else {
      throw Exception('Failed to summarize text');
    }
  }

  // TODO 통짜 스트링 문맥별로 나누는 것
  Future<List<String>> _splitTranscribedTextByContext(String text) async {
    List<String> splitHalfList = _splitTextHalf(text);

    List<String> splitByContextList =
        await Future.wait(splitHalfList.map((myString) async {
      return await _splitTextByContextUsingGPT(input: myString);
    }).toList());
    String splitByContext = splitByContextList.join("");
    splitByContext = splitByContext.replaceAll("\n", "");

    List<String> result = splitByContext.split('#');
    return result;
  }

// TODO 스트링 반갈
  List<String> _splitTextHalf(String text) {
    List<String> result = [];
    var tempIndex = text.lastIndexOf('. ', text.length ~/ 2);
    result.add(text.substring(0, tempIndex + 2));
    result.add(text.substring(tempIndex + 2));
    return result;
  }

// TODO 문맥별 나누기
  Future<String> _splitTextByContextUsingGPT({required String input}) async {
    final apiKey = dotenv.env['API_KEY'];
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        "messages": [
          {
            "role": "system",
            "content": "이 글을 문맥별로 나누어주세요. 문맥 사이에는 # 기호를 넣어주세요."
          },
          {"role": "user", "content": input}
        ]
        // 'max_tokens': 50, // Adjust the summary length as needed
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final quiz = decoded['choices'][0]['message']['content'] as String;
      return quiz;
    } else {
      throw Exception('Failed to summarize text');
    }
  }
}
