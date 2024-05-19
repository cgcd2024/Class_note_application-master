part of 'tasks_bloc.dart';

@immutable
abstract class TasksState {
}

class FetchTasksSuccess extends TasksState {
  final List<TaskModel> tasks;
  final bool isSearching;

  FetchTasksSuccess({required this.tasks, this.isSearching = false});
}

class AddTasksSuccess extends TasksState {}

class LoadTaskFailure extends TasksState {
  final String error;

  LoadTaskFailure({required this.error});
}

class AddTaskFailure extends TasksState {
  final String error;

  AddTaskFailure({required this.error});
}

class TasksLoading extends TasksState {}

class UpdateTaskFailure extends TasksState {
  final String error;

  UpdateTaskFailure({required this.error});
}


class UpdateTaskSuccess extends TasksState {}

// VoiceFileUploadSuccess 성공시 이벤트 처리
class VoiceFileUploadSuccess extends TasksState {
  final TaskModel processedTasks;

  VoiceFileUploadSuccess({required this.processedTasks});

  TaskModel getProcessedTasks() {
    return processedTasks;
  }
}

// 실패시 처리코드
class VoiceFileUploadFailure extends TasksState {
  final String error;

  VoiceFileUploadFailure(this.error);
}