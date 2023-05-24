part of 'task_details_loading_bloc.dart';

@freezed
class TaskDetailsLoadingEvent {

  factory TaskDetailsLoadingEvent.loading() = TaskDetailsLoadingLoaderEvent;
  factory TaskDetailsLoadingEvent.fetching(String taskId) = TaskDetailsLoadingFetchEvent;
}
