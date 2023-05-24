part of 'customer_reminder_bloc.dart';

@immutable
abstract class CustomerReminderEvent extends Equatable {
  CustomerReminderEvent();
  @override
  List<Object> get props => [];
}

class LoadReminderData extends CustomerReminderEvent {}

class LoadReminderReloadData extends CustomerReminderEvent {}

class UpdateReminders extends CustomerReminderEvent {
  final String reminderId;
  final String note;
  final String title;
  final DateTime dueDate;
  UpdateReminders(this.note, this.dueDate, this.title, this.reminderId);
}
