part of 'customer_reminder_bloc.dart';

@immutable
abstract class CustomerReminderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomerReminderInitial extends CustomerReminderState {}

class CustomerReminderProgress extends CustomerReminderState {}

class CustomerReminderFailure extends CustomerReminderState {}

class CustomerReminderSuccess extends CustomerReminderState {
  final LandingScreenReminders reminders;

  CustomerReminderSuccess({required this.reminders});

  @override
  List<Object?> get props => [reminders];
}
