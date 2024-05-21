import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart';
import 'package:task_manager_app/utils/exception_handler.dart';
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
    }catch(e){
      throw Exception(handleException(e));
    }
  }

  // List<taskModel> 정렬 함수, 0: 날짜순, 1: 완료task가 앞에 가게끔 정렬, 2: 완료 task가 뒤로 가게끔 정렬
  Future<List<TaskModel>> sortTasks(int sortOption) async {
    switch (sortOption) {
      case 0:
        tasks.sort((a, b) {
          // Sort by date
          if (a.startDateTime!.isAfter(b.startDateTime!)) {
            return 1;
          } else if (a.startDateTime!.isBefore(b.startDateTime!)) {
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
      final List<String> taskJsonList = tasks.map((task) =>
          json.encode(task.toJson())).toList();
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
      final List<String> taskJsonList = tasks.map((task) =>
          json.encode(task.toJson())).toList();
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
      final descriptionMatches = task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
  }

  Future<List<TaskModel>> processTasks(TaskModel taskModel) async {
    // TODO text to summary 코드
    taskModel.summaryTexts = await Future.wait(taskModel.transcribedTexts.map((myString) async {
      return await _summaryTasks(input: myString);
    }).toList());

    // TODO summary to quiz 코드 여기가 완료되었다면, 주석을 풀면 됨
    // taskModel.quizTexts = await Future.wait(taskModel.transcribedTexts.map((myString) async {
    //   return await _quizTasks(input: myString);
    // }).toList());

    tasks[tasks.indexWhere((element) => element.id == taskModel.id)] = taskModel;
    final List<String> taskJsonList = tasks.map((task) => json.encode(task.toJson())).toList();
    prefs!.setStringList(Constants.taskKey, taskJsonList);
    return tasks;
  }

  Future<String> _quizTasks({
    required String input
  }) async {
    final apiKey = dotenv.env['API_KEY']; // Replace with your actual API key
    const endpoint = 'https://api.openai.com/v1/chat/completions';

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
            "content": "다음 문장을 요약해주세요. $input"
          }
        ]
        // 'max_tokens': 50, // Adjust the summary length as needed
      }),
    );
    logger.i('openai response: '
        '${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final summary = decoded['choices'][0]['message']['content'] as String;
      return summary;
    } else {
      throw Exception('Failed to summarize text');
    }
  }


  Future<String> _summaryTasks({
    required String input
  }) async {
    final apiKey = dotenv.env['API_KEY']; // Replace with your actual API key
    const endpoint = 'https://api.openai.com/v1/chat/completions';

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
            "content": "다음 문장을 요약해주세요. $input"
          }
        ]
        // 'max_tokens': 50, // Adjust the summary length as needed
      }),
    );
    logger.i('openai response: '
        '${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final summary = decoded['choices'][0]['message']['content'] as String;
      return summary;
    } else {
      throw Exception('Failed to summarize text');
    }
  }
}
