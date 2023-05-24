import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_reminders.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'customer_reminder_event.dart';

part 'customer_reminder_state.dart';

class CustomerReminderBloc extends Bloc<CustomerReminderEvent, CustomerReminderState> {
  final LandingScreenRepository landingScreenRepository;

  CustomerReminderBloc(this.landingScreenRepository) : super(CustomerReminderFailure()) {
    on<LoadReminderData>((event, emit) async {
      emit(CustomerReminderProgress());
      String id = await SharedPreferenceService().getValue(agentId);
      String loggedInAgent = await SharedPreferenceService().getValue(loggedInAgentId);
      await landingScreenRepository.getReminders(id, loggedInAgent).catchError((_) {
        print("this is error in reminder $_");
        emit(CustomerReminderFailure());
      }).then((value) {
        emit(CustomerReminderSuccess(reminders: value));
        return value;
      });

      return;
    });
    on<LoadReminderReloadData>((event, emit) async {
      String id = await SharedPreferenceService().getValue(agentId);
      String loggedInAgent = await SharedPreferenceService().getValue(loggedInAgentId);
      await landingScreenRepository.getReminders(id, loggedInAgent).catchError((_) {
        print("this is error in reminder $_");
        emit(CustomerReminderFailure());
      }).then((value) {
        emit(CustomerReminderSuccess(reminders: value));
        return value;
      });

      return;
    });
  }
}
