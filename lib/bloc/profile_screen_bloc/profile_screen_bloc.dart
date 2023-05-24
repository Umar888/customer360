import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/profile/profile_screen_repository.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'profile_screen_event.dart';
part 'profile_screen_state.dart';

class ProfileScreenBloc extends Bloc<ProfileScreenEvent, ProfileScreenState> {
  final ProfileScreenRepository profileScreenRepository;

  ProfileScreenBloc(this.profileScreenRepository)
      : super(ProfileScreenFailure()) {
    on<LoadData>((event, emit) async {
      String? userId = '0054M000004UMmEQAW';
      // await SharedPreferenceService().getUserToken(key: kUserId);
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if (userId.isNotEmpty && (userRecordId).isNotEmpty) {
        var userProfile =
            await profileScreenRepository.getClientProfile(userRecordId);

        emit(ProfileScreenSuccess(userProfile: userProfile));

        return;
      }

      emit(ProfileScreenFailure());
      return;
    });
  }
}
