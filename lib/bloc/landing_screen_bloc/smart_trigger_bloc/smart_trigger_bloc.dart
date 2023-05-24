import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_task_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'smart_trigger_event.dart';
part 'smart_trigger_state.dart';

class SmartTriggerBloc extends Bloc<SmartTriggerEvent, SmartTriggerState> {
  final LandingScreenRepository landingScreenRepository =
      LandingScreenRepository();

  SmartTriggerBloc() : super(SmartTriggerFailure()) {
    on<LoadTasksData>((event, emit) async {
      emit(SmartTriggerProgress());
      String recordId = await SharedPreferenceService().getValue(agentId);
      await landingScreenRepository.getCustomerTasks(recordId).catchError((_) {
        emit(SmartTriggerFailure());
        return <AggregatedTaskList>[];
      }).then((value) {
        emit(SmartTriggerSuccess(tasks: value));
        return value;
      });
      return;
    });
  }
}
