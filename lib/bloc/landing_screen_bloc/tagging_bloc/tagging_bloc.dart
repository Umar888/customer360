import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_tags_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'tagging_event.dart';

part 'tagging_state.dart';

class TaggingBloc extends Bloc<TaggingEvent, TaggingState> {
  final LandingScreenRepository landingScreenRepository = LandingScreenRepository();

  TaggingBloc() : super(TaggingFailure()) {
    on<LoadTagData>((event, emit) async {
      emit(TaggingProgress());
      String recordId = await SharedPreferenceService().getValue(agentId);
      await landingScreenRepository.getTags(recordId).catchError((_) async {
        emit(TaggingFailure());
        return CustomerTagging();
      }).then((value) {
        emit(TaggingSuccess(tags: value));
        return value;
      });
      return;
    });
  }
}
