part of 'reminder_bloc.dart';

enum ReminderState {
  initState,
  loadState,
  successState,
  failedState,
}

class ReminderInitial extends Equatable {
  final ReminderState? reminderState;
  final ReminderModel? reminderModel;
  final List<ReminderModel>? reminders;
  ReminderInitial({
    this.reminderState,
    this.reminderModel,
    this.reminders,
  });

  ReminderInitial copyWith(
      {ReminderState? reminderState,
      ReminderModel? reminderModel,
      List<ReminderModel>? reminders}) {
    return ReminderInitial(
        reminderState: reminderState ?? this.reminderState,
        reminderModel: reminderModel ?? this.reminderModel,
        reminders: reminders ?? this.reminders);
  }

  @override
  List<Object?> get props => [reminderState, reminderModel];
}
