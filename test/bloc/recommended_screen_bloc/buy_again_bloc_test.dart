// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart' as isb;
import 'package:gc_customer_app/bloc/recommended_screen_bloc/buy_again/recommendation_buy_again_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/data/data_sources/recommendation_screen_data_source/recommendation_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/buy_again_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension on String {
  String get escape => RegExp.escape(this);
}

class MockInventorySearchBloc extends Mock implements isb.InventorySearchBloc {}

class MockInventorySearchState extends Mock implements isb.InventorySearchState {
  @override
  List<Records> get productsInCart => [
        Records(childskus: [Childskus(skuENTId: "")])
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecommendationBuyAgainBloc recommendationBuyAgainBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  late Map<String, dynamic> dummyBuyAgainModelJson;
  late BuyAgainModel dummyBuyAgainModel;

  setUp(
    () {
      dummyBuyAgainModelJson = {
        "message": "record found.",
        "productBuyAgainOthers": [
          {
            "recommendedProductSet": [
              {"itemSKU": "", "records": []}
            ]
          }
        ],
        "productBuyAgain": [
          {
            "attributes": {"type": ""},
            "GC_Order__r": {
              "attributes": {"type": ""},
              "Customer__r": {
                "attributes": {"type": ""}
              },
            },
          }
        ],
      };
      dummyBuyAgainModel = BuyAgainModel.fromJson(dummyBuyAgainModelJson);

      var recommendationScreenDataSource = RecommendationScreenDataSource();
      var landingScreenDataSource = LandingScreenDataSource();
      var mockClient = MockClient((request) async {
        if (successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.buyItemList}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode(dummyBuyAgainModelJson), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kSearchDetail}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "wrapperinstance": {
                    "records": [
                      {
                        "childskus": [{}]
                      }
                    ]
                  }
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
      recommendationScreenDataSource.httpService.client = mockClient;
      landingScreenDataSource.httpService.client = mockClient;
      recommendationBuyAgainBloc = RecommendationBuyAgainBloc(recommendationScreenRepository: RecommendationScreenRepository());
      recommendationBuyAgainBloc.recommendationScreenRepository.recommendationScreenDataSource = recommendationScreenDataSource;
      recommendationBuyAgainBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Buy Again Items',
        build: () => recommendationBuyAgainBloc,
        act: (bloc) => bloc.add(BuyAgainItems()),
        expect: () => [
          BuyAgainPageProgress(),
          LoadBuyAgainItemsSuccess(message: "", product: Records(childskus: []), buyAgainModel: dummyBuyAgainModel),
          LoadBuyAgainItemsSuccess(message: "done", product: Records(childskus: []), buyAgainModel: dummyBuyAgainModel),
        ],
      );

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Get Item Availability Buy Again',
        build: () => recommendationBuyAgainBloc,
        seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: ""),
        act: (bloc) => bloc.add(GetItemAvailabilityBuyAgain(childIndex: 0, parentIndex: 0)),
        expect: () => [
          LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done"),
        ],
      );

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Empty Message',
        build: () => recommendationBuyAgainBloc,
        seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: null, product: null, message: "done"),
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          LoadBuyAgainItemsSuccess(buyAgainModel: null, product: null, message: ""),
        ],
      );

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Update Product In Buy Again',
        build: () => recommendationBuyAgainBloc,
        seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: ""),
        act: (bloc) => bloc.add(UpdateProductInBuyAgain(index: 0, records: Records())),
        expect: () => [
          LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done"),
        ],
      );

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Update Product In Buy Again Others',
        build: () => recommendationBuyAgainBloc,
        seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: ""),
        act: (bloc) => bloc.add(UpdateProductInBuyAgainOthers(childIndex: 0, parentIndex: 0, records: Records())),
        expect: () => [
          LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done"),
        ],
      );

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Initialize Product',
        build: () => recommendationBuyAgainBloc,
        seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: ""),
        act: (bloc) => bloc.add(InitializeProduct()),
        expect: () => [
          LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: Records(childskus: []), message: "done"),
        ],
      );

      group(
        'Load Product Detail Buy Again Other',
        () {
          blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
            'ifDetail = true',
            build: () => recommendationBuyAgainBloc,
            seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBuyAgainOther(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done", product: Records(childskus: [])),
              LoadBuyAgainItemsSuccess(
                buyAgainModel: dummyBuyAgainModel,
                message: "done",
                product: dummyBuyAgainModel.productBuyAgainOthers.first.recommendedProductSet.first.records,
              ),
            ],
          );

          blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
            'ifDetail = false',
            build: () => recommendationBuyAgainBloc,
            seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBuyAgainOther(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: false,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done", product: Records(childskus: [])),
            ],
          );
        },
      );

      group(
        'Load Product Detail Buy Again',
        () {
          blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
            'ifDetail = true',
            build: () => recommendationBuyAgainBloc,
            seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBuyAgain(
              index: 0,
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done", product: Records(childskus: [])),
              LoadBuyAgainItemsSuccess(
                buyAgainModel: dummyBuyAgainModel,
                message: "done",
                product: dummyBuyAgainModel.productBuyAgain.first.records,
              ),
            ],
          );

          blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
            'ifDetail = false',
            build: () => recommendationBuyAgainBloc,
            seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBuyAgain(
              index: 0,
              ifDetail: false,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done", product: Records(childskus: [])),
            ],
          );
        },
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Buy Again Items Failure',
        build: () => recommendationBuyAgainBloc,
        act: (bloc) => bloc.add(BuyAgainItems()),
        expect: () => [
          BuyAgainPageProgress(),
          BuyAgainFailure(),
        ],
      );

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Load Product Detail Buy Again Other Failure',
        build: () => recommendationBuyAgainBloc,
        seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: "wow"),
        act: (bloc) => bloc.add(LoadProductDetailBuyAgainOther(
          childIndex: 0,
          parentIndex: 0,
          ifDetail: true,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "",
        )),
        expect: () => [
          LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done", product: Records(childskus: [])),
          LoadBuyAgainItemsSuccess(
            buyAgainModel: dummyBuyAgainModel,
            message: "Product Record not found",
            product: Records(childskus: []),
          ),
        ],
      );

      blocTest<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
        'Load Product Detail Buy Again Failure',
        build: () => recommendationBuyAgainBloc,
        seed: () => LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, product: null, message: "wow"),
        act: (bloc) => bloc.add(LoadProductDetailBuyAgain(
          index: 0,
          ifDetail: true,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "",
        )),
        expect: () => [
          LoadBuyAgainItemsSuccess(buyAgainModel: dummyBuyAgainModel, message: "done", product: Records(childskus: [])),
          LoadBuyAgainItemsSuccess(
            buyAgainModel: dummyBuyAgainModel,
            message: "Product Record not found",
            product: Records(childskus: []),
          ),
        ],
      );
    },
  );
}
