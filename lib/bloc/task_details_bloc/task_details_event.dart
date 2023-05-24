part of 'task_details_bloc.dart';

@freezed
class TaskDetailsEvent {
  factory TaskDetailsEvent.loading(String taskId) = TaskDetailsLoadingEvent;
  factory TaskDetailsEvent.refresh(String tempTaskId) = TaskDetailsRefreshEvent;
  factory TaskDetailsEvent.onlyLoading() = TaskDetailsOnlyLoadingEvent;
}
