import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/credit_balance_bloc/credit_balance_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CreditBalanceBloc creditBalanceBloc;
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
          if (request.matches(Endpoints.kClientCredit.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "OMSCustomerID": "0",
                  "OMSCustomerEmailID": "",
                  "CurrentBalance": "100.0",
                  "AvailableAmount": "0.0",
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
      creditBalanceBloc = CreditBalanceBloc();
      creditBalanceBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<CreditBalanceBloc, CreditBalanceState>(
        'Load Credit Data',
        build: () => creditBalanceBloc,
        act: (bloc) => bloc.add(LoadCreditData()),
        expect: () => [
          CreditBalanceProgress(),
          CreditBalanceSuccess(balance: CreditBalance(currentBalance: "100.0")),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<CreditBalanceBloc, CreditBalanceState>(
        'Load Credit Data Failure',
        build: () => creditBalanceBloc,
        act: (bloc) => bloc.add(LoadCreditData()),
        expect: () => [
          CreditBalanceProgress(),
          CreditBalanceSuccess(balance: CreditBalance()),
        ],
      );
    },
  );
}
