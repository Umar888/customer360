import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/smart_trigger_bloc/smart_trigger_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/models/landing_screen/landing_task_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SmartTriggerBloc smartTriggerBloc;
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
          if (request.matches(Endpoints.kCustomerTasks.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "AggregatedTaskList": [{}]
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
      smartTriggerBloc = SmartTriggerBloc();
      smartTriggerBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<SmartTriggerBloc, SmartTriggerState>(
        'Load Tasks Data',
        build: () => smartTriggerBloc,
        act: (bloc) => bloc.add(LoadTasksData()),
        expect: () => [
          SmartTriggerProgress(),
          SmartTriggerSuccess(tasks: [AggregatedTaskList.fromJson({})]),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<SmartTriggerBloc, SmartTriggerState>(
        'Load Tasks Data Failure',
        build: () => smartTriggerBloc,
        act: (bloc) => bloc.add(LoadTasksData()),
        expect: () => [
          SmartTriggerProgress(),
          SmartTriggerFailure(),
          SmartTriggerSuccess(tasks: []),
        ],
      );
    },
  );
}
