import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/model/task_model.dart';
import '../../data/repository/task_repository.dart';

part 'tasks_event.dart';

part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;

  TasksBloc(this.taskRepository) : super(FetchTasksSuccess(tasks: const [])) {
    on<AddNewTaskEvent>(_addNewTask);
    on<FetchTaskEvent>(_fetchTasks);
    on<UpdateTaskEvent>(_updateTask);
    on<DeleteTaskEvent>(_deleteTask);
    on<SortTaskEvent>(_sortTasks);
    on<SearchTaskEvent>(_searchTasks);
    on<UploadVoiceFile>(_uploadVoiceFile);
    on<StartProcessing>(_startProcessing);
  }

  _startProcessing(StartProcessing event, Emitter<TasksState> emit) async {
    return emit(ProcessLoading());
  }

  //_uploadVoiceFile이 되면, processtask를 싫행함
  _uploadVoiceFile(UploadVoiceFile event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final processedTasks = await taskRepository.processTasks(event.taskModel);
      final updatedProcessedTasks = await taskRepository.updateTask(processedTasks);
      return emit(VoiceFileUploaded(processedTasks: updatedProcessedTasks));
    } catch (exception) {
      emit(VoiceFileUploadFailure(exception.toString()));
    }
  }


  _addNewTask(AddNewTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      if (event.taskModel.title.trim().isEmpty) {
        return emit(AddTaskFailure(error: '과목을 입력하세요'));
      }
      if (event.taskModel.description.trim().isEmpty) {
        return emit(AddTaskFailure(error: '메모를 입력하세요'));
      }
      if (event.taskModel.makeDateTime == null) {
        return emit(AddTaskFailure(error: 'Missing task start date'));
      }
      // if (event.taskModel.startDateTime == null) {
      //   return emit(AddTaskFailure(error: 'Missing task start date'));
      // }
      // if (event.taskModel.stopDateTime == null) {
      //   return emit(AddTaskFailure(error: 'Missing task stop date'));
      // }
      await taskRepository.createNewTask(event.taskModel);
      emit(AddTasksSuccess());
      final tasks = await taskRepository.getTasks();
      return emit(FetchTasksSuccess(tasks: tasks));
    } catch (exception) {
      emit(AddTaskFailure(error: exception.toString()));
    }
  }

  void _fetchTasks(FetchTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await taskRepository.getTasks();
      return emit(FetchTasksSuccess(tasks: tasks));
    } catch (exception) {
      emit(LoadTaskFailure(error: exception.toString()));
    }
  }

  _updateTask(UpdateTaskEvent event, Emitter<TasksState> emit) async {
    try {
      if (event.taskModel.title.trim().isEmpty) {
        return emit(UpdateTaskFailure(error: 'Task title cannot be blank'));
      }
      if (event.taskModel.description.trim().isEmpty) {
        return emit(
            UpdateTaskFailure(error: 'Task description cannot be blank'));
      }
      if (event.taskModel.makeDateTime == null) {
        return emit(UpdateTaskFailure(error: 'Missing task start date'));
      }
      // if (event.taskModel.startDateTime == null) {
      //   return emit(UpdateTaskFailure(error: 'Missing task start date'));
      // }
      // if (event.taskModel.stopDateTime == null) {
      //   return emit(UpdateTaskFailure(error: 'Missing task stop date'));
      // }
      emit(TasksLoading());
      final tasks = await taskRepository.updateTask(event.taskModel);
      emit(VoiceFileUploaded(processedTasks: tasks));
      return emit(FetchTasksSuccess(tasks: tasks));
    } catch (exception) {
      emit(UpdateTaskFailure(error: exception.toString()));
    }
  }

  _deleteTask(DeleteTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await taskRepository.deleteTask(event.taskModel);
      return emit(FetchTasksSuccess(tasks: tasks));
    } catch (exception) {
      emit(LoadTaskFailure(error: exception.toString()));
    }
  }

  _sortTasks(SortTaskEvent event, Emitter<TasksState> emit) async {
    final tasks = await taskRepository.sortTasks(event.sortOption);
    return emit(FetchTasksSuccess(tasks: tasks));
  }

  _searchTasks(SearchTaskEvent event, Emitter<TasksState> emit) async {
    final tasks = await taskRepository.searchTasks(event.keywords);
    return emit(FetchTasksSuccess(tasks: tasks, isSearching: true));
  }
}