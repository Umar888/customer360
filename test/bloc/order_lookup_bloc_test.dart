// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/order_lookup_bloc/order_lookup_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/order_lookup_repository/order_lookup_repository.dart';
import 'package:gc_customer_app/models/order_lookup_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late OrderLookUpBloC? orderLookUpBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  OrderLookUpBloC setUpBloc() {
    var mock = MockClient((request) async {
      if (successScenario) {
        if (request.matches(Endpoints.kClientOrderLookUp.escape)) {
          print("Success: ${request.url}");
          return Response(
              json.encode({
                "responseList": [{}],
                "responseOpenList": [{}]
              }),
              200);
        } else {
          print("API call not mocked: ${request.url}");
          return Response(json.encode({}), 205);
        }
      } else {
        print("Failed: ${request.url}");
        return Response("", 205);
      }
    });
    return OrderLookUpBloC(orderLookUpRepo: OrderLookUpRepository()..orderLookUpDataSource.httpService.client = mock);
  }

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<OrderLookUpBloC, OrderLookUpState>(
        'Load Order Printers - searchText contains GCQ',
        build: () => orderLookUpBloc = setUpBloc(),
        tearDown: () => orderLookUpBloc = null,
        act: (bloc) => bloc.add(SearchOrders("GCQ dummy")),
        expect: () => [
          OrderLookUpProgress(),
          OrderLookUpSuccess(orders: [OrderLookupModel.fromJson({}), OrderLookupModel.fromJson({})]),
        ],
      );

      blocTest<OrderLookUpBloC, OrderLookUpState>(
        'Load Order Printers - searchText does not contains GCQ',
        build: () => orderLookUpBloc = setUpBloc(),
        tearDown: () => orderLookUpBloc = null,
        act: (bloc) => bloc.add(SearchOrders(" dummy")),
        expect: () => [
          OrderLookUpProgress(),
          OrderLookUpSuccess(orders: [OrderLookupModel.fromJson({}), OrderLookupModel.fromJson({})]),
        ],
      );

      blocTest<OrderLookUpBloC, OrderLookUpState>(
        'Clear Order LookUp',
        build: () => orderLookUpBloc = setUpBloc(),
        tearDown: () => orderLookUpBloc = null,
        act: (bloc) => bloc.add(ClearOrderLookUp()),
        expect: () => [
          OrderLookUpInitial(),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<OrderLookUpBloC, OrderLookUpState>(
        'Load Order Printers Failure',
        build: () => orderLookUpBloc = setUpBloc(),
        tearDown: () => orderLookUpBloc = null,
        act: (bloc) => bloc.add(SearchOrders("GCQ dummy")),
        expect: () => [
          OrderLookUpProgress(),
          isA<OrderLookUpFailure>(),
          OrderLookUpSuccess(orders: []),
        ],
      );
    },
  );
}
