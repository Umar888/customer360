import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/data/data_sources/order_history_data_source/order_history_data_source.dart';
import 'package:gc_customer_app/data/data_sources/order_lookup_data_source/order_lookup_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_history_screen_repository/order_history_repository.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/models/order_history/customer_order_info_model.dart';
import 'package:gc_customer_app/models/order_history/open_order_model.dart' hide Records;
import 'package:gc_customer_app/models/order_history/order_history_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late OrderHistoryBloc orderHistoryBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  final Map<String, dynamic> dummyOpenOrderModelJson = {
    "OpenOrders": [
      {
        "GC_Order_Line_Items__r": {
          "records": [
            {"Item_SKU__c": ""}
          ]
        }
      }
    ]
  };
  final OpenOrderModel dummyOpenOrderModel = OpenOrderModel.fromJson(dummyOpenOrderModelJson);

  setUp(
    () {
      var mock = MockClient((request) async {
        if (successScenario) {
          if (request.matches(Endpoints.kOpenOrders.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode(dummyOpenOrderModelJson), 200);
          } else if (request.matches(Endpoints.kItemAvailability.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "outOfStock": false,
                  "noInfo": true,
                  "inStore": false,
                }),
                200);
          } else if (request.matches(Endpoints.kOrderHistory.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "OrderHistory": [{}]
                }),
                200);
          }  else if (request.matches(Endpoints.kCustomerOrderInfo.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "records": [<String, dynamic>{}],
                }),
                200);
          }  else if (request.matches(Endpoints.kClientOrderLookUp.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "responseList": [<String, dynamic>{}],
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
      var orderHistoryDataSource = OrderHistoryDataSource()..httpService.client = mock;
      var orderLookUpDataSource = OrderLookUpDataSource()..httpService.client = mock;
      var landingScreenDataSource = LandingScreenDataSource()..httpService.client = mock;
      orderHistoryBloc = OrderHistoryBloc(landingScreenRepository: LandingScreenRepository(), orderHistoryRepository: OrderHistoryRepository());
      orderHistoryBloc.orderHistoryRepository.orderHistoryDataSource = orderHistoryDataSource;
      orderHistoryBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
      orderHistoryBloc.orderLookUpRepository.orderLookUpDataSource = orderLookUpDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'Empty Message',
        build: () => orderHistoryBloc,
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [OrderHistoryState().copyWith(message: "")],
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'Get Open Orders',
        build: () => orderHistoryBloc,
        act: (bloc) => bloc.add(GetOpenOrders()),
        expect: () => [
          OrderHistoryState().copyWith(
            fetchingOpenOrders: false,
            message: "",
            openOrderModel: dummyOpenOrderModel,
            orderHistoryStatus: OrderHistoryStatus.success,
          ),
          OrderHistoryState().copyWith(
            openOrderModel: dummyOpenOrderModel,
            fetchingOpenOrders: false,
            message: "done",
          )
        ],
      );

      group(
        'Fetch Order History',
        () {
          blocTest<OrderHistoryBloc, OrderHistoryState>(
            'Fetch Order History with current page = 1',
            build: () => orderHistoryBloc,
            act: (bloc) => bloc.add(FetchOrderHistory(currentPage: 1)),
            expect: () => [
              OrderHistoryState().copyWith(
                fetchOrderHistory: true,
                currentPage: 1,
              ),
              OrderHistoryState().copyWith(
                fetchOrderHistory: false,
                currentPage: 1,
                orderHistory: [OrderDetail.fromJson({})],
                haveMore: true,
                isFetchDone: true,
                message: "done",
              )
            ],
          );

          blocTest<OrderHistoryBloc, OrderHistoryState>(
            'Fetch Order History with current page = 2',
            build: () => orderHistoryBloc,
            act: (bloc) => bloc.add(FetchOrderHistory(currentPage: 2)),
            expect: () => [
              OrderHistoryState().copyWith(
                fetchOrderHistory: true,
                currentPage: 2,
              ),
              OrderHistoryState().copyWith(
                fetchOrderHistory: false,
                currentPage: 2,
                orderHistory: [OrderDetail.fromJson({})],
                haveMore: true,
                isFetchDone: true,
                message: "done",
              )
            ],
          );
        },
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'Get Item Stock',
        build: () => orderHistoryBloc,
        seed: () => OrderHistoryState(openOrderModel: dummyOpenOrderModel),
        act: (bloc) => bloc.add(GetItemStock(itemSkuId: "", orderIndex: 0, recordIndex: 0)),
        expect: () => [
          OrderHistoryState().copyWith(
            openOrderModel: dummyOpenOrderModel,
            message: "done",
          ),
        ],
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'Load Data Order History',
        build: () => orderHistoryBloc,
        act: (bloc) => bloc.add(LoadDataOrderHistory()),
        expect: () => [
          OrderHistoryState().copyWith(
            orderHistoryStatus: OrderHistoryStatus.initial,
          ),
          OrderHistoryState().copyWith(
            fetchingOpenOrders: true,
            fetchOrderHistory: true,
            orderHistoryStatus: OrderHistoryStatus.success,
            customerOrderInfoModel: CustomerOrderInfoModel(records: [Records()]),
            lastPurchased: DateTime.now().toString(),
            cancelledOrder: "3/57 5.9%",
          ),
        ],
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'Search Order History with empty searchText',
        build: () => orderHistoryBloc,
        act: (bloc) => bloc.add(SearchOrderHistory("")),
        expect: () => [
          OrderHistoryState().copyWith(
            searchedOrderHistory: OrderHistory(),
          ),
        ],
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'Search Order History with non empty searchText',
        build: () => orderHistoryBloc,
        act: (bloc) => bloc.add(SearchOrderHistory("abc")),
        expect: () => [
          OrderHistoryState().copyWith(
            searchedOrderHistory: OrderHistory(lineItems: <LineItems>[]),
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'Search Order History with non empty searchText Failure',
        build: () => orderHistoryBloc,
        act: (bloc) => bloc.add(SearchOrderHistory("abc")),
        expect: () => [
          OrderHistoryState().copyWith(
            searchedOrderHistory: OrderHistory(),
          ),
        ],
      );
    },
  );
}
