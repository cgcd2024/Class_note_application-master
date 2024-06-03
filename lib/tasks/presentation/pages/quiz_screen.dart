import 'package:flutter/material.dart';
import '../../data/local/model/task_model.dart';

class QuizScreen extends StatefulWidget {
  final TaskModel processedTasks;

  const QuizScreen({Key? key, required this.processedTasks}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskModel = widget.processedTasks;

    List<String> quizTexts = taskModel.quizTexts?.toList() ?? [];

    return Scaffold(
      body: (taskModel.quizTexts == null || taskModel.quizTexts!.isEmpty)
          ? const Center(
          child: Text(
            '녹음파일을 업로드 해주세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ))
          : Column(
        children: [
          Container(
            height: 60,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / quizTexts.length,
                backgroundColor: Colors.grey[300],
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: quizTexts.length,
              itemBuilder: (context, index) {
                return quizWidget(context, quizTexts[index], index);
              },
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            //color: Colors.white, // 배경색 설정
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('이전'),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (_currentPage < quizTexts.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('다음'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget quizWidget(BuildContext context, String quizText, int index) {
    Map<String, dynamic> quizMap = parseQuizText(quizText);

    String? selectedAnswer = _selectedAnswers[index];
    String correctAnswer = quizMap['correctAnswer'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${quizMap['question']}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...List.generate(4, (i) {
            return CheckboxListTile(
              title: Text('${quizMap['choices'][i]}'),
              value: selectedAnswer == quizMap['choices'][i],
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedAnswers[index] = quizMap['choices'][i];
                  } else {
                    _selectedAnswers.remove(index);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 20),
          if (selectedAnswer != null)
            Text(
              selectedAnswer == correctAnswer
                  ? '정답입니다!'
                  : '틀렸습니다. 문제를 다시 풀어보세요!',
              style: TextStyle(
                fontSize: 16,
                color:
                selectedAnswer == correctAnswer ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> parseQuizText(String quizText) {
    String sanitizedQuizText = quizText.replaceAll(RegExp(r'\n+'), '\n');

    List<String> parts = sanitizedQuizText.split('\n');
    String question = parts.isNotEmpty ? parts[0] : '';
    List<String> choicesText = parts.sublist(1, 6);
    List<String> choices = [];
    RegExp choiceRegExp = RegExp(r'^\d+\.\s');
    for (var choiceText in choicesText) {
      String? choiceNumber = choiceRegExp.stringMatch(choiceText);
      String choiceContent = choiceNumber != null ? choiceText.substring(
          choiceNumber.length) : '';
      choices.add(choiceContent.trim());
    }

    int correctAnswerIndex = extractAnswerNumber(quizText);
    String correctAnswer = '';
    if (correctAnswerIndex != -1 && correctAnswerIndex <= choices.length) {
      correctAnswer = choices[correctAnswerIndex - 1];
    }

    return {
      'question': question.replaceFirst('문제 :', '').trim(),
      'choices': choices,
      'correctAnswer': correctAnswer,
    };
  }

  int extractAnswerNumber(String text) {
    final RegExp answerRegExp = RegExp(r'해답\s*:\s*(\d+)\.');

    final Match? match = answerRegExp.firstMatch(text);

    if (match != null && match.groupCount >= 1) {
      final String answerNumberString = match.group(1)!;
      return int.parse(answerNumberString);
    } else {
      return -1;
    }
  }
}