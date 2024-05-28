import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart';
import 'dart:async';

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

  void _sendMessage(){
    // 메시지 보낼 때마다 키보드 숨기기
    // FocusScope.of(context).unfocus();
    _controller.clear();
    widget.processedTasks.summaryTexts?.add("gpt@$_userEnterMessage");
    widget.streamController.sink.add(widget.processedTasks.summaryTexts!.length);
    logger.i(widget.processedTasks.summaryTexts);
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top:8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                maxLines: null,
                controller: _controller,
                decoration: InputDecoration(
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
              onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
              icon: Icon(Icons.send),
              color: Colors.blue,
          )
        ],
      ),
    );
  }
}
