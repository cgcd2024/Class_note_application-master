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

class VoiceFileUploaded extends TasksState {
  final TaskModel processedTasks;

  VoiceFileUploaded({required this.processedTasks});
}

class ProcessSuccessed extends TasksState {}

class ProcessLoading extends TasksState {}

// 실패시 처리코드
class VoiceFileUploadFailure extends TasksState {
  final String error;

  VoiceFileUploadFailure(this.error);
}