import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/task_details_bloc/task_details_bloc.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TaskDetailsBloc? taskDetailsBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late MockClient mockClient;

  setUp(() => {
        mockClient = MockClient((request) async {
          if (request.matches(Endpoints.kSmartTriggers.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  'CurrentTask': {},
                  'Orders': [],
                  'OrderLines': [],
                }),
                200);
          } else {
            print("API call not mocked: ${request.url}");
            return Response(json.encode({}), 205);
          }
        })
      });

  blocTest<TaskDetailsBloc, TaskDetailsState>(
    'Task Details Loading Event',
    setUp: () => taskDetailsBloc = TaskDetailsBloc()..httpService.client = mockClient,
    tearDown: () => taskDetailsBloc = null,
    build: () => taskDetailsBloc!,
    act: (bloc) => bloc.add(TaskDetailsLoadingEvent("123")),
    expect: () => [
      TaskDetailsLoadingState(),
      TaskDetailsLoadedState([], TaskModel()),
    ],
  );

  blocTest<TaskDetailsBloc, TaskDetailsState>(
    'Task Details Refresh Event',
    setUp: () => taskDetailsBloc = TaskDetailsBloc()..httpService.client = mockClient,
    tearDown: () => taskDetailsBloc = null,
    build: () => taskDetailsBloc!,
    act: (bloc) => bloc.add(TaskDetailsRefreshEvent("123")),
    expect: () => [
      TaskDetailsLoadingState(),
      TaskDetailsLoadedState([], TaskModel()),
    ],
  );

  blocTest<TaskDetailsBloc, TaskDetailsState>(
    'Task Details Only Loading Event',
    setUp: () => taskDetailsBloc = TaskDetailsBloc()..httpService.client = mockClient,
    tearDown: () => taskDetailsBloc = null,
    build: () => taskDetailsBloc!,
    act: (bloc) => bloc.add(TaskDetailsOnlyLoadingEvent()),
    expect: () => [
      TaskDetailsLoadingState(),
    ],
  );
}
