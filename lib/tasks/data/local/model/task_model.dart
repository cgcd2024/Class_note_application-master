class TaskModel {
  String id;
  String title;
  String description;
  DateTime? startDateTime;
  DateTime? stopDateTime;
  bool completed;
  List<String> transcribedTexts; // 변환된 텍스트 목록을 저장하는 리스트 추가
  List<String>? summaryTexts; // 요약된 텍스트 리스트

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.stopDateTime,
    this.completed = false,
    this.transcribedTexts = const [], // 기본값으로 빈 리스트 설정
    this.summaryTexts,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'startDateTime': startDateTime?.toIso8601String(),
      'stopDateTime': stopDateTime?.toIso8601String(),
      'transcribedTexts': transcribedTexts, // 리스트를 JSON 배열로 변환
      'summaryTexts' : summaryTexts,
    };
  }


  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      startDateTime: DateTime.parse(json['startDateTime']),
      stopDateTime: DateTime.parse(json['stopDateTime']),
      transcribedTexts: json['transcribedTexts'] != null ? List<String>.from(json['transcribedTexts']) : [], // JSON 배열을 List<String>으로 변환
      summaryTexts: json['summaryTexts'] != null ? List<String>.from(json['summaryTexts']) : []
    );
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, description: $description, '
        'startDateTime: $startDateTime, stopDateTime: $stopDateTime, '
        'completed: $completed,'
        'transcribedTexts: $transcribedTexts'
        'summaryTexts: $summaryTexts'
        '}';
  }
}
