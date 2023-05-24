import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/task_details_loading_bloc/task_details_loading_bloc.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TaskDetailsLoadingBloc? taskDetailsBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  late MockClient mockClient;

  setUp(() => {
        mockClient = MockClient((request) async {
          if (successScenario) {
            if (request.matches(Endpoints.kSmartTriggers.escape)) {
              print("Success: ${request.url}");
              return Response(json.encode({'CurrentTask': {'Id':"123"}}), 200);
            } else {
              print("API call not mocked: ${request.url}");
              return Response(json.encode({}), 205);
            }
          } else {
            print("Failed: ${request.url}");
            return Response(json.encode({}), 205);
          }
        })
      });

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<TaskDetailsLoadingBloc, TaskDetailsLoadingState>(
        'Task Details Loading Fetch Event',
        setUp: () => taskDetailsBloc = TaskDetailsLoadingBloc()..httpService.client = mockClient,
        tearDown: () => taskDetailsBloc = null,
        build: () => taskDetailsBloc!,
        act: (bloc) => bloc.add(TaskDetailsLoadingFetchEvent("123")),
        expect: () => [
          TaskDetailsFetchingState(TaskDetailLoadingStatus.loading, []),
          TaskDetailsFetchingState(TaskDetailLoadingStatus.success, [TaskModel.fromJson({"Id": "123"})]),        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<TaskDetailsLoadingBloc, TaskDetailsLoadingState>(
        'Task Details Loading Fetch Event Failure',
        setUp: () => taskDetailsBloc = TaskDetailsLoadingBloc()..httpService.client = mockClient,
        tearDown: () => taskDetailsBloc = null,
        build: () => taskDetailsBloc!,
        act: (bloc) => bloc.add(TaskDetailsLoadingFetchEvent("123")),
        expect: () => [
          TaskDetailsFetchingState(TaskDetailLoadingStatus.loading, []),
          TaskDetailsFetchingState(TaskDetailLoadingStatus.failed, []),        ],
      );
    },
  );
}
