import 'package:flutter/material.dart';
import 'package:class_note/tasks/presentation/pages/summary_screen_chat/message.dart';
import 'package:class_note/tasks/presentation/pages/summary_screen_chat/new_message.dart';
import '../../data/local/model/task_model.dart';
import 'dart:async';


class SummaryScreen extends StatefulWidget {
  final TaskModel processedTasks;

  const SummaryScreen({Key? key, required this.processedTasks})
      : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<String> sentences = [
    "인공지능(AI)은 데이터를 분석하고 패턴을 인식하여 문제를 해결하는 기술입니다.",
    "머신러닝은 AI의 한 분야로, 기계가 스스로 학습하는 능력을 갖추게 합니다.",
    "딥러닝은 인공신경망을 사용해 복잡한 데이터 분석을 수행하는 머신러닝의 하위 분야입니다.",
    "자율주행차는 AI 기술을 활용하여 교통 상황을 인식하고 스스로 주행합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
    "AI 챗봇은 자연어 처리 기술로 사용자와 대화하며 다양한 정보를 제공합니다.",
  ];
  final streamController = StreamController();

  @override
  Widget build(BuildContext context) {
    final taskModel = widget.processedTasks;

    // TODO 실제 동작할 때에는 이 코드 제거
    // taskModel.summaryTexts = sentences;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: Message(processedTasks: taskModel, streamController: streamController,)
            ),
            NewMessage(processedTasks: taskModel,streamController: streamController,),
          ],
        ),
      )
      // Center(
      //   child: (taskModel.summaryTexts == null ||
      //       taskModel.summaryTexts!.isEmpty)
      //       ? const Text('생성중')
      //       : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      //     Expanded(
      //         child: ListView.builder(
      //             itemCount: sentences.length,
      //             itemBuilder: (context, index) {
      //               return chatBubble(context,sentences[index]);
      //             }
      //         )
      //     )
      //   ]
      //   ),
      // ),
    );
  }

  Widget summaryText(BuildContext context,String sentence) {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ExpansionTile(
                  shape: const Border(),
                  title: Text(sentence),
                  children: <Widget>[
                    summaryTextDescribe()
                  ],
                )
            )
        ),
        const Divider(),
      ],
    );
  }

  Widget summaryTextDescribe() {
    return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          child: Card(
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: const Text(
                  '요약문 설명',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87
                  ),
              ),
            ),
          )
    );
  }
}
