import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/tagging_bloc/tagging_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_tags_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TaggingBloc taggingBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;

  setUp(
    () {
      var landingScreenDataSource = LandingScreenDataSource();
      landingScreenDataSource.httpService.client = MockClient((request) async {
        if (successScenario) {
          if (request.matches(Endpoints.kTags.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "customerTagging": [{}]
                }),
                200);
          } else {
            print("API call not mocked: ${request.url}");
            return Response(json.encode({}), 205);
          }
        } else {
          print("Failed: ${request.url}");
          return Response(json.encode({}), 205);
        }
      });
      taggingBloc = TaggingBloc();
      taggingBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<TaggingBloc, TaggingState>(
        'Load Tag Data',
        build: () => taggingBloc,
        act: (bloc) => bloc.add(LoadTagData()),
        expect: () => [
          TaggingProgress(),
          TaggingFailure(),
          TaggingSuccess(tags: CustomerTagging()),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<TaggingBloc, TaggingState>(
        'Load Tag Data Failure',
        build: () => taggingBloc,
        act: (bloc) => bloc.add(LoadTagData()),
        expect: () => [
          TaggingProgress(),
          TaggingSuccess(
              tags: CustomerTagging.fromJson({
            "Lessons_Customer__c": false,
            "Open_Box_Purchaser__c": false,
            "Loyalty_Customer__c": false,
            "Used_Purchaser__c": false,
            "Synchrony_Customer__c": false,
            "Vintage_Purchaser__c": false
          })),
        ],
      );
    },
  );
}
