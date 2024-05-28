import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/routes/app_router.dart';
import 'package:task_manager_app/bloc_state_observer.dart';
import 'package:task_manager_app/routes/pages.dart';
import 'package:task_manager_app/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:task_manager_app/tasks/data/repository/task_repository.dart';
import 'package:task_manager_app/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task_manager_app/utils/color_palette.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:html' show AnchorElement;
import 'dart:convert' show utf8;


Future<void> main() async {
  // exLogger().demo(); // logger 예시
  WidgetsFlutterBinding.ensureInitialized(); // 앱의 여러가지 기능을 수행하기 위해 초기화해야 함
  Bloc.observer = BlocStateOberver();
  final SharedPreferences preferences = await SharedPreferences.getInstance(); // 기기 내의 파일 불러오기
  // original code => SharedPreferences preferences = await SharedPreferences.getInstance();
  await dotenv.load(fileName: "assets/config/.env"); // api key 가져오기

  runApp(MyApp(
    preferences: preferences,
  ));
  // runApp(const Counter());
}

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  final int price = 2000;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(
        title: const Text('Stream builder'),
      ),
      body: StreamBuilder<int>(
        initialData: price, //0. 초기 값 : 2000
        stream: addStreamValue(), //1. addStreamValue로 새로운 데이터가 들어 올때마다
        builder: (context, snapshot) {
          //2. snapshot 에 저장하고 builder 메소드를 통해 새로운 데이터로 화면에 갱신
          final priceNum = snapshot.data.toString();
          return Center(
            child: Text(
              priceNum,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.blue,
              ),
            ),
          );
        },
      ),
    )
    );
  }

  Stream<int> addStreamValue() {
    return Stream<int>.periodic(
        Duration(seconds: 1), (counter) => price + counter);
  }
}

// TODO text파일로 저장하는 메소드
void saveTextFile(String text, String filename) {
  AnchorElement()
    ..href = '${Uri.dataFromString(text, mimeType: 'text/plain', encoding: utf8)}'
    ..download = filename
    ..style.display = 'none'
    ..click();
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
        create: (context) =>
            TaskRepository(taskDataProvider: TaskDataProvider(preferences)),
        child: BlocProvider(
            create: (context) =>
                TasksBloc(context.read<TaskRepository>()),
            child: MaterialApp(
              title: 'appname',
              debugShowCheckedModeBanner: false,
              initialRoute: Pages.initial,
              onGenerateRoute: onGenerateRoute,
              theme: ThemeData(
                fontFamily: 'Sora',
                visualDensity: VisualDensity.adaptivePlatformDensity,
                canvasColor: Colors.transparent,
                colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
                useMaterial3: true,
              ),
            )));
  }
}
