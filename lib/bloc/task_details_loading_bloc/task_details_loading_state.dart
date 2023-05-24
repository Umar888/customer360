part of 'task_details_loading_bloc.dart';

enum TaskDetailLoadingStatus {loading, success, failed,initial}

@freezed
class TaskDetailsLoadingState with _$TaskDetailsLoadingState {
  factory TaskDetailsLoadingState.loaded(TaskDetailLoadingStatus taskDetailLoadingStatus, List<TaskModel> task) = TaskDetailsFetchingState;
}