import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/local/data_sources/tasks_data_provider.dart';

Future<String> convertSpeechToText(String filePath) async {
  const maxFileSize = 25 * 1024 * 1024;
  const sliceSize = 20 * 1024 * 1024;
  final file = File(filePath);
  final fileSize = await file.length();

  if (fileSize <= maxFileSize) {
    return await processFile(filePath);
  } else {
    String transcribedText = '';
    int start = 0;
    while (start < fileSize) {
      int end = (start + sliceSize < fileSize) ? start + sliceSize : fileSize;
      String slicePath =
          '${path.dirname(filePath)}/${path.basename(
          filePath)}.slice$start-$end${path.extension(filePath)}';
      List<int> sliceBytes = await file
          .openRead(start, end)
          .toList()
          .then((list) => list.expand((x) => x).toList());
      await File(slicePath).writeAsBytes(sliceBytes);
      transcribedText += await processFile(slicePath);
      start += sliceSize;
    }
    return transcribedText;
  }
}

Future<String> processFile(String filePath) async {
  final apiKey = dotenv.env['API_KEY'];
  var url = Uri.https("api.openai.com", "/v1/audio/transcriptions");
  var request = http.MultipartRequest('POST', url);
  request.headers.addAll({"Authorization": "Bearer $apiKey"});
  request.fields['model'] = 'whisper-1';
  request.fields['language'] = 'ko';
  request.files.add(await http.MultipartFile.fromPath('file', filePath));
  try {
    var response = await request.send();
    var newResponse = await http.Response.fromStream(response);
    if (newResponse.statusCode == 200) {
      var responseData = json.decode(utf8.decode(newResponse.bodyBytes));
      if (responseData.containsKey('text')) {
        String transcribedText = responseData['text'];
        return transcribedText;
      } else {
        throw Exception('API response does not contain text.');
      }
    } else {
      throw Exception(
          'API call failed. Status code: ${newResponse.statusCode}');
    }
  } catch (e) {
    throw Exception('Exception during API call: $e');
  }
}

Future<String> convertM4aToMp3(String inputPath) async {
  final outputPath = inputPath.replaceAll('.m4a', '.mp3');
  final flutterFFmpeg = FlutterFFmpeg();

  int result = await flutterFFmpeg.execute(
      '-y -i "$inputPath" -codec:a libmp3lame -qscale:a 2 "$outputPath"');
  if (result == 0) {
    logger.i('Conversion successful');
    return outputPath;
  } else {
    throw Exception('Failed to convert file');
  }
}

Future<String> convertAacToMp3(String inputPath) async {
  final outputPath = inputPath.replaceAll('.aac', '.mp3');
  final flutterFFmpeg = FlutterFFmpeg();

  int result = await flutterFFmpeg.execute(
      '-y -i "$inputPath" -codec:a libmp3lame -qscale:a 2 "$outputPath"');
  if (result == 0) {
    logger.i('Conversion successful');
    return outputPath;
  } else {
    throw Exception('Failed to convert file');
  }
}

Future<void> requestPermissions() async {
  var micStatus = await Permission.microphone.status;
  if (!micStatus.isGranted) {
    await Permission.microphone.request();
  }

  var storageStatus = await Permission.storage.status;
  if (!storageStatus.isGranted) {
    await Permission.storage.request();
  }
}
