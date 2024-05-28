import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart';
import 'package:task_manager_app/tasks/presentation/pages/summary_screen_chat/chat_bubble.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:chatgpt_completions/chatgpt_completions.dart';

class Message extends StatelessWidget{
  final TaskModel processedTasks;
  final StreamController streamController;
  const Message({Key? key, required this.processedTasks, required this.streamController}) : super(key:key);

  final int price=1;

  @override
  Widget build(BuildContext context) {
    final List<String> mySummaryTexts=processedTasks.summaryTexts!.reversed.toList();
    // Logger().i(processedTasks.summaryTexts?.reversed.runtimeType);

    return StreamBuilder(
        initialData: processedTasks.summaryTexts!.length,
        stream: streamController.stream,
        builder: (context, text){
          if(processedTasks.summaryTexts==null){
            return const Center(
              child: CircularProgressIndicator()
            );
          }
          return ListView.builder(
              reverse: true,
              itemCount: text.data,
              itemBuilder: (context, index){
                Logger().w(index);
                return ChatBubbles(processedTasks.summaryTexts!.reversed.toList()[index].toString(),true,"username");
              }
          );
        }
    );
  }

  Stream<int> addStreamValue() {
    return Stream<int>.value(processedTasks.summaryTexts!.length);
  }

  Future<String> _summaryDescribeTasks({required String input}) async {
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
          {"role": "system", "content": "다음 문장을 설명해주세요."},
          {"role": "user", "content": input}
        ]
        // 'max_tokens': 50, // Adjust the summary length as needed
      }),
    );
    Logger().i('openai response: '
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