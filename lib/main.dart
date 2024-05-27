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
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:html' show AnchorElement;
import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;


Future<void> main() async {
  // exLogger().demo(); // logger 예시
  WidgetsFlutterBinding.ensureInitialized(); // 앱의 여러가지 기능을 수행하기 위해 초기화해야 함
  Bloc.observer = BlocStateOberver();
  final SharedPreferences preferences = await SharedPreferences.getInstance(); // 기기 내의 파일 불러오기
  // original code => SharedPreferences preferences = await SharedPreferences.getInstance();
  await dotenv.load(fileName: "assets/config/.env"); // api key 가져오기
  String temp='침착맨은 26일 자신의 유튜브 채널에서 라이브 방송을 진행하면서 "탄원서 낸 사람이 나 맞다"라고 인정했다. 이어 "탄원서 제출자가 이병견으로 나왔던데, 졸렬하게 나라는 사람을 숨기고 싶어서 그런 건 아니다. 서류를 낼 때 뒤에 주민등록증 사본을 붙여 보냈는데 이유는 모르겠지만 이병견으로 올라갔다"라고 덧붙였다. 탄원서를 작성한 이유에 대해서는 "그저 개인적인 마음으로, 한 번만 더 기회를 줬으면 해서 쓴 것"이라며 "하이브와 어도어가 서로 잘하고 못하는지는 관계자가 아니라 잘 모른다. 다만 해임이 안 됐으면 하는 이유는 민희진 대표를 몇 번 봤을 때, 뉴진스와 민희진 대표의 시너지가 좋았다. 부모님까지도 사이가 좋을 뿐더러 내가 만났을 때 (뉴진스와) 돈독해 보였다. 또 민희진 대표가 자부심을 갖고 일한다는 걸 느꼈기 때문"이라고 전했다. 탄원서 작성 자체에 불만을 가진 이들에게는 "원래 탄원서는 시끄러워질 일도, 이렇게 알려질 것도 아니고 해명할 일도 아니다. 탄원서를 쓰면 누구의 편을 든다고 생각하는 것 자체가 이해가 안 된다"라며 "제가 탄원서를 쓴 게 너무 서운하면 그냥 가라. 이걸로 서운하면 언젠가는 헤어질 일이고 서로 안 맞는 것"이라고 일침했다. 더불어 "해명 요구 좀 하지 않았으면 좋겠다. 굉장히 심각한 일이라 당연히 해명이 필요하면 하겠지만, 별것도 아닌 일 가지고 며칠 내내 해명을 요구하니까 좀 짜증 난다"라고 토로했다. 지난 24일 민희진 대표와 작업한 경험이 있는 국내외 스태프들이 주축이 돼 법원에 탄원서를 제출한 것으로 알려졌다. 그런데 탄원서 명단에 침착맨 본명 이병건과 유사한 "이병견"이라는 이름이 있어 침착맨이 참여했다는 추측이 확산됐다. 하이브는 민희진 대표 등이 경영권 탈취를 하려 했다며 민희진 대표를 배임 등 혐의로 고발, 해임을 추진 중이다. 민희진 대표는 이에 맞서 기자회견을 열어 혐의를 부인했고, 현재 법원에 해임을 막을 의결권 행사금지 가처분신청을 냈다. 뉴진스 멤버들의 부모들 또한 엔터테인먼트 분쟁 전문 변호사를 선임해 "민희진 대표와 함께 하고 싶다"는 취지의 탄원서를 법원에 제출한 것으로 알려졌다. 뉴진스 멤버들도 탄원서를 제출했지만 구체적인 내용은 알려지지 않았다. 다만 부모들의 입장과 크게 다르지 않을 것으로 보인다. 하이브 측에서는 하이브 방시혁 의장을 포함해 플레디스 한성수 설립자, 쏘스뮤직 소성진 대표 등 하이브 자회사 관계자들과 소속 프로듀서들이 "민희진 대표의 사익 추구로 엔터테인먼트 산업이 흔들려선 안 된다"는 내용의 탄원서를 제출했다. 민희진 대표 등 경영진 교체가 안건으로 상정된 어도어 임시 주주총회는 오는 31일 열리며 가처분신청에 대한 법원의 판단은 이번주 중 나올 전망이다.';
  List<String> temp1=await _splitTranscribedTextByContext(temp);
  print(temp1);
  runApp(MyApp(
    preferences: preferences,
  ));
}

// TODO 통짜 스트링 문맥별로 나누는 것
Future<List<String>> _splitTranscribedTextByContext(String text) async {
  List<String> splitHalfList=_splitTextHalf(text);

  List<String> splitByContextList =
  await Future.wait(splitHalfList.map((myString) async {
    return await _splitTextByContextUsingGPT(input: myString);
  }).toList());
  String splitByContext=splitByContextList.join("");

  List<String> result=splitByContext.split('#');
  return result;
}

List<String> _splitTextHalf(String text){
  List<String> result=[];
  var tempIndex=text.lastIndexOf('. ',(text.length/2).toInt())+2;
  result.add(text.substring(0,tempIndex+2));
  result.add(text.substring(tempIndex+2));
  return result;
}

Future<String> _splitTextByContextUsingGPT({required String input}) async {
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
        {"role": "system", "content": "이 글을 문맥별로 나누어주세요. 문맥 사이에는 # 기호를 넣어주세요."},
        {"role": "user", "content": input}
      ]
      // 'max_tokens': 50, // Adjust the summary length as needed
    }),
  );
  logger.i('openai response: '
      '${utf8.decode(response.bodyBytes)}');

  if (response.statusCode == 200) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final quiz = decoded['choices'][0]['message']['content'] as String;
    return quiz;
  } else {
    throw Exception('Failed to summarize text');
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
