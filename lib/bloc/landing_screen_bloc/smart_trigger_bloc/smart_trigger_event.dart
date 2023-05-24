part of 'smart_trigger_bloc.dart';

@immutable
abstract class SmartTriggerEvent extends Equatable {
  SmartTriggerEvent();
  @override
  List<Object> get props => [];
}

class LoadTasksData extends SmartTriggerEvent {}
