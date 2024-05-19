import 'package:flutter/material.dart';
import '../../data/local/model/task_model.dart';

class SummaryScreen extends StatefulWidget {
  final TaskModel processedTasks;
  const SummaryScreen({Key? key, required this.processedTasks}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  //TODO 더미데이터를 넣어서 ui 디자인 코드 만들어주세요
  @override
  Widget build(BuildContext context) {
    final taskModel = widget.processedTasks;
    return Scaffold(
      body: Center(
        child: (taskModel.summaryTexts == null || taskModel.summaryTexts!.isEmpty)
            ? const Text('생성중')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("summary page: ${taskModel.title}"),
            Text("Task Description: ${taskModel.description}"),
            ...taskModel.summaryTexts!.map((text) => Text(text)).toList(),
          ],
        ),
      ),
    );
  }
}
