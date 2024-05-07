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

  Future<List<TaskModel>> getTasks() async {
    try {
      final List<String>? savedTasks = prefs!.getStringList(Constants.taskKey);
      if (savedTasks != null) {
        tasks = savedTasks
            .map((taskJson) => TaskModel.fromJson(json.decode(taskJson)))
            .toList();
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
      tasks.add(taskModel);
      final List<String> taskJsonList =
          tasks.map((task) => json.encode(task.toJson())).toList();
      await prefs!.setStringList(Constants.taskKey, taskJsonList);
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    try {
      tasks[tasks.indexWhere((element) => element.id == taskModel.id)] =
          taskModel;
      tasks.sort((a, b) {
        if (a.completed == b.completed) {
          return 0;
        } else if (a.completed) {
          return 1;
        } else {
          return -1;
        }
      });
      final List<String> taskJsonList = tasks.map((task) =>
          json.encode(task.toJson())).toList();
      prefs!.setStringList(Constants.taskKey, taskJsonList);
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

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
    List<TaskModel> matchedTasked = tasks;
    return matchedTasked.where((task) {
      final titleMatches = task.title.toLowerCase().contains(searchText);
      final descriptionMatches = task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
  }

  Future<String> summaryTasks({
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
            "content": "다음 문장을 요약해주세요. $input" // 이 부분 chatgpt에 묻는 것처럼 수정
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
