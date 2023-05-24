import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/data/reporsitories/reminder_screen_repository/reminder_screen_repository.dart';
import 'package:gc_customer_app/models/reminder_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloC extends Bloc<ReminderEvent, ReminderInitial> {
  final ReminderScreenReponsitory reminderRepo;

  ReminderBloC({required this.reminderRepo}) : super(ReminderInitial()) {
    on<LoadReminders>(
      (event, emit) async {
        String userId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        String userRecordId = await SharedPreferenceService().getValue(agentId);

        if (userId.isNotEmpty && userRecordId.isNotEmpty) {
          var reminders = await reminderRepo.getReminders(userRecordId, userId);

          emit(state.copyWith(
              reminderState: ReminderState.successState,
              reminders: reminders,
              reminderModel: null));

          return;
        }

        emit(state.copyWith(reminderState: ReminderState.failedState));
        return;
      },
    );

    on<SaveReminders>(
      (event, emit) async {
        String userId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        String userRecordId = await SharedPreferenceService().getValue(agentId);

        if (userId.isNotEmpty && userRecordId.isNotEmpty) {
          emit(state.copyWith(reminderState: ReminderState.loadState));
          var reminder = await reminderRepo.saveReminder(
              userId, userRecordId, event.note, event.dueDate,
              alertType: event.title);

          emit(state.copyWith(
              reminders: null,
              reminderState: ReminderState.successState,
              reminderModel: reminder));
          return;
        }
        emit(state.copyWith(reminderState: ReminderState.failedState));
        return;
      },
    );

    on<UpdateReminders>(
      (event, emit) async {
        String userId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        String userRecordId = await SharedPreferenceService().getValue(agentId);

        if (userId.isNotEmpty && userRecordId.isNotEmpty) {
          emit(state.copyWith(reminderState: ReminderState.loadState));
          var reminder = await reminderRepo.updateReminder(
              userId, userRecordId, event.reminderId, event.note, event.dueDate,
              alertType: event.title);

          emit(state.copyWith(
              reminders: null,
              reminderState: ReminderState.successState,
              reminderModel: reminder));
          return;
        }
        emit(state.copyWith(reminderState: ReminderState.failedState));
        return;
      },
    );
  }
}
