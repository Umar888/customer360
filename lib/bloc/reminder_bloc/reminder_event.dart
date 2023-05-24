part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  ReminderEvent();
}

class LoadReminders extends ReminderEvent {
  LoadReminders();

  @override
  List<Object?> get props => [];
}

class SaveReminders extends ReminderEvent {
  final String note;
  final String title;
  final DateTime dueDate;
  SaveReminders(this.note, this.dueDate, this.title);

  @override
  List<Object?> get props => [note, dueDate];
}

class UpdateReminders extends ReminderEvent {
  final String reminderId;
  final String note;
  final String title;
  final DateTime dueDate;
  UpdateReminders(this.note, this.dueDate, this.title, this.reminderId);

  @override
  List<Object?> get props => [note, dueDate, reminderId, title];
}

class DeleteReminders extends ReminderEvent {
  final String reminderId;
  DeleteReminders(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}
