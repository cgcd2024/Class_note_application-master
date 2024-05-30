import 'dart:async';

import 'package:flutter/material.dart';
import 'package:class_note/tasks/data/local/model/task_model.dart';
import 'package:class_note/tasks/presentation/pages/summary_screen_chat/chat_bubble.dart';

class Message extends StatelessWidget{
  final TaskModel processedTasks;
  final StreamController streamController;
  const Message({Key? key, required this.processedTasks, required this.streamController}) : super(key:key);

  final int price=1;

  @override
  Widget build(BuildContext context) {
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
                String temp=processedTasks.summaryTexts!.reversed.toList()[index].toString();
                var tempIndex=temp.indexOf('@');
                String user=temp.substring(0,tempIndex);
                String message=temp.substring(tempIndex+1);
                return ChatBubbles(message,user=="user",user);
              }
          );
        }
    );
  }

  Stream<int> addStreamValue() {
    return Stream<int>.value(processedTasks.summaryTexts!.length);
  }
}