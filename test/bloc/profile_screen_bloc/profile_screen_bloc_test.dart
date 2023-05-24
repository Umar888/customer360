import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/profile_screen_bloc.dart';
import 'package:gc_customer_app/data/data_sources/profile_screen/profile_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/profile/profile_screen_repository.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProfileScreenBloc profileScreenBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(
    () {
      var profileScreenDataSource = ProfileScreenDataSource();
      profileScreenDataSource.httpService.client = MockClient(
        (request) async {
          return Response(
              json.encode({"records": [{}]}),
              200);
        },
      );
      profileScreenBloc = ProfileScreenBloc(ProfileScreenRepository());
      profileScreenBloc.profileScreenRepository.profileScreenDataSource = profileScreenDataSource;
    },
  );

  blocTest(
    'Load Data',
    build: () => profileScreenBloc,
    act: (bloc) => bloc.add(LoadData()),
    expect: () => [
      ProfileScreenSuccess(userProfile: UserProfile.fromJson({})),
    ],
  );
}
