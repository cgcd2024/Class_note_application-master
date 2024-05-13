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
