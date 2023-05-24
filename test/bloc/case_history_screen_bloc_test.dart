// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/case_history_screen_bloc/case_history_screen_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/case_history_screen_repository/case_history_screen_repository.dart';
import 'package:gc_customer_app/models/case_history_models/case_history_cases_model.dart' as chcm;
import 'package:gc_customer_app/models/case_history_models/case_history_chart_details_model.dart' as chcdm;
import 'package:gc_customer_app/models/case_history_models/open_order_model.dart' as oom;
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CaseHistoryScreenBloc? caseHistoryScreenBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  final Map<String, dynamic> dummyRecordsJsom = {
    "attributes": {"type": "", "url":""},
    "Id": "",
    "CaseNumber" : "",
    "Priority" : "",
    "Status" : "",
    "Account": {"attributes": {"type": "", "url":""}, "Name": ""},
    "Owner": {"attributes": {"type": "", "url":""}, "Name": ""},
    "CreatedDate": "",
    "LastModifiedDate": "",
  };

  late bool successScenario;
  CaseHistoryScreenBloc setUpBloc() {
    var mock = MockClient((request) async {
      if (successScenario) {
        if (request.matches(Endpoints.openCasesList.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"totalSize": 2,"done":true, "records":[dummyRecordsJsom],}), 200);
        } else {
          print("API call not mocked: ${request.url}");
          return Response(json.encode({}), 205);
        }
      } else {
        print("Failed: ${request.url}");
        return Response("", 205);
      }
    });
    return CaseHistoryScreenBloc(caseHistoryScreenRepository: CaseHistoryScreenRepository()..caseHistoryScreenDataSource.httpService.client = mock);
  }

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<CaseHistoryScreenBloc, CaseHistoryScreenState>(
        'Load Data',
        build: () => caseHistoryScreenBloc = setUpBloc(),
        tearDown: () => caseHistoryScreenBloc = null,
        act: (bloc) => bloc.add(LoadData()),
        expect: () => [
          CaseHistoryScreenProgress(),
          CaseHistoryScreenSuccess(
              caseHistoryChartDetails: chcdm.CaseHistoryChartDetails(records: [chcdm.Records.fromJson(dummyRecordsJsom)],totalSize: 2, done: true),
              openCasesListModel: oom.OpenCasesListModel(records: [oom.Records.fromJson(dummyRecordsJsom)],totalSize: 2, done: true),
              caseHistoryListModelClass: chcm.CaseHistoryListModelClass(records: [chcm.Records.fromJson(dummyRecordsJsom)],totalSize: 2, done: true),
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);
    },
  );
}
