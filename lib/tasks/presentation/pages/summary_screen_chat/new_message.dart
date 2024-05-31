import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:class_note/tasks/data/local/model/task_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../bloc/tasks_bloc.dart';


var logger=Logger();


class NewMessage extends StatefulWidget {
  final TaskModel processedTasks;
  final StreamController streamController;
  const NewMessage({Key? key, required this.processedTasks, required this.streamController}) : super(key:key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller=TextEditingController();
  var _userEnterMessage='';
  var loading='Blorfendip';
  bool isWait=false;


  void _sendMessage() async{
    if(_userEnterMessage.trim().isEmpty){
      return;
    }
    isWait=true;

    _controller.clear();
    widget.processedTasks.summaryTexts?.add("user@$_userEnterMessage");
    widget.streamController.sink.add(widget.processedTasks.summaryTexts!.length);


    widget.processedTasks.summaryTexts?.add("gpt@$loading");
    var nowLength=widget.processedTasks.summaryTexts!.length;
    widget.streamController.sink.add(nowLength);


    // Logger().wtf("[${nowLength-1}] : ${widget.processedTasks.summaryTexts?[nowLength-1]}");
    widget.processedTasks.summaryTexts?[nowLength-1] = "gpt@${await _askTasks(input: _userEnterMessage)}";
    // Logger().wtf("[${nowLength-1}] : ${widget.processedTasks.summaryTexts?[nowLength-1]}");
    widget.streamController.sink.add(nowLength);

    setState(() {
      context
          .read<TasksBloc>()
          .add(UpdateTaskEvent(taskModel: widget.processedTasks));
    });
    logger.wtf(widget.processedTasks);
    isWait=false;
    // logger.i(widget.processedTasks.summaryTexts);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top:8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                maxLines: null,
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Send a Message...'
                ),
                onChanged: (value){
                    setState(() {
                      _userEnterMessage=value;
                    });
                },
              )
          ),
          IconButton(
              onPressed: isWait ? null : _sendMessage,
              icon: const Icon(Icons.send),
              color: Colors.blue,
          )
        ],
      ),
    );
  }

  Future<String> _askTasks({required String input}) async {
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
          {"role": "system", "content": "Your helpful assistant"},
          {"role": "user", "content": input}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final quiz = decoded['choices'][0]['message']['content'] as String;
      return quiz;
    } else {
      throw Exception('Failed to task');
    }
  }
}
