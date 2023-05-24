part of 'smart_trigger_bloc.dart';

@immutable
abstract class SmartTriggerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SmartTriggerInitial extends SmartTriggerState {}

class SmartTriggerProgress extends SmartTriggerState {}

class SmartTriggerFailure extends SmartTriggerState {}

class SmartTriggerSuccess extends SmartTriggerState {
  final List<AggregatedTaskList> tasks;

  SmartTriggerSuccess({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}
