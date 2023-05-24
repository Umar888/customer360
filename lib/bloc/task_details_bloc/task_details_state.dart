part of 'task_details_bloc.dart';

@freezed
class TaskDetailsState with _$TaskDetailsState {

  factory TaskDetailsState.initial() = TaskDetailsInitialState;

  factory TaskDetailsState.loading() = TaskDetailsLoadingState;

  factory TaskDetailsState.loaded(List<Order> orders, TaskModel task) = TaskDetailsLoadedState;

}