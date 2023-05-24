import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/quote_log_bloc/quote_log_bloc.dart';
import 'package:gc_customer_app/data/data_sources/quote_log_data_source/quote_log_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/quote_log_reporsitory/quote_log_repository.dart';
import 'package:gc_customer_app/models/quotes_history_list_model/quotes_history_list_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late QuoteLogBloc? quoteLogBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  final Map<String , dynamic> dummyQuoteHistoryListJson = {
    "subtotal": "100",
    "quoteNumber": "123",
    "lastName": "Doe",
    "itemCount": 4,
    "firstName": "Joe",
    "expiryDate": "2023-12-4",
    "email": "joe.doe@mail.com",
    "createDate": "2023-11-4",
    "createTime": "",
    "ContentUrl": "",
  };
  final QuoteHistoryList dummyQuoteHistoryList = QuoteHistoryList.fromJson(dummyQuoteHistoryListJson);

  QuoteLogBloc setUpBloc()
    {
      var quoteLogDataSource = QuoteLogDataSource()
        ..httpService.client = MockClient((request) async {
          if (successScenario) {
            if (request.matches(Endpoints.kOrderQuote.escape)) {
              print("Success: ${request.url}");
              return Response(json.encode({"quoteHistoryList": [dummyQuoteHistoryList.toJson()], "message": ""}), 200);
            } else {
              print("API call not mocked: ${request.url}");
              return Response(json.encode({}), 205);
            }
          } else {
            print("Failed: ${request.url}");
            return Response("", 205);
          }
        });
      return QuoteLogBloc(quoteLogRepository: QuoteLogRepository(quoteLogDataSource: quoteLogDataSource));
    }

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<QuoteLogBloc, QuoteLogState>(
        'Search Requested',
        build: () => quoteLogBloc = setUpBloc(),
        tearDown: () => quoteLogBloc = null,
        act: (bloc) => bloc.add(PageLoad(orderID: "123")),
        expect: () => [
          quoteLogBloc!.state.copyWith(quoteLogStatus: QuoteLogStatus.loadState, quoteList: []),
          quoteLogBloc!.state.copyWith(quoteLogStatus: QuoteLogStatus.successState, orderDetailModel: [], quoteList: [dummyQuoteHistoryList..isPressed = true]),
        ],
      );

      blocTest<QuoteLogBloc, QuoteLogState>(
        'Empty Message',
        build: () => quoteLogBloc = setUpBloc(),
        tearDown: () => quoteLogBloc = null,
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          quoteLogBloc!.state.copyWith(message: ""),
        ],
      );

      blocTest<QuoteLogBloc, QuoteLogState>(
        'On Press Quote',
        build: () => quoteLogBloc = setUpBloc(),
        tearDown: () => quoteLogBloc = null,
        seed: () => QuoteLogState(quoteList: [dummyQuoteHistoryList, dummyQuoteHistoryList]),
        act: (bloc) => bloc.add(OnPressQuote(index: 1)),
        expect: () => [
          quoteLogBloc!.state.copyWith(quoteList: [QuoteHistoryList.fromJson(dummyQuoteHistoryListJson)..isPressed = true, QuoteHistoryList.fromJson(dummyQuoteHistoryListJson)..isPressed = true], message: "done"),
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
