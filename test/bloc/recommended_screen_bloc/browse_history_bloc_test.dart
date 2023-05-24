// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart' as isb;
import 'package:gc_customer_app/bloc/recommended_screen_bloc/browser_history/recommendation_browse_history_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/data/data_sources/recommendation_screen_data_source/recommendation_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/recommendation_screen_browse_history_model.dart';
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
  late RecommendationBrowseHistoryBloc recommendationBrowseHistoryBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  late Map<String, dynamic> dummyRecommendationScreenModelJson;
  late RecommendationScreenModel dummyRecommendationScreenModel;

  setUp(
    () {
      dummyRecommendationScreenModelJson = {
        "message": "record found.",
        "productBrowsingOthers": [
          {
            "recommendedProductSet": [
              {"itemSKU": "", "records": []}
            ]
          }
        ],
        "productBrowsing": [
          {
            "recommendedProductSet": [
              {"itemSKU": ""}
            ]
          }
        ],
      };
      dummyRecommendationScreenModel = RecommendationScreenModel.fromJson(dummyRecommendationScreenModelJson);

      var recommendationScreenDataSource = RecommendationScreenDataSource();
      var landingScreenDataSource = LandingScreenDataSource();
      var mockClient = MockClient((request) async {
        if (successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.recommendationsList}'.escape + r'\?recordId=.+&recommendType=BrowsingHistory')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode(dummyRecommendationScreenModelJson), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kItemAvailability}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
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
      recommendationBrowseHistoryBloc = RecommendationBrowseHistoryBloc(recommendationScreenRepository: RecommendationScreenRepository());
      recommendationBrowseHistoryBloc.recommendationScreenRepository.recommendationScreenDataSource = recommendationScreenDataSource;
      recommendationBrowseHistoryBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Load Browse History Items',
        build: () => recommendationBrowseHistoryBloc,
        act: (bloc) => bloc.add(LoadBrowseHistoryItems()),
        expect: () => [
          BrowseHistoryProgress(),
          BrowseHistorySuccess(message: "", product: Records(childskus: []), recommendationScreenModel: dummyRecommendationScreenModel),
          BrowseHistorySuccess(message: "done", product: Records(childskus: []), recommendationScreenModel: dummyRecommendationScreenModel),
        ],
      );

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Empty Message',
        build: () => recommendationBrowseHistoryBloc,
        seed: () => BrowseHistorySuccess(recommendationScreenModel: null, product: null, message: "done"),
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          BrowseHistorySuccess(recommendationScreenModel: null, product: null, message: ""),
        ],
      );

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Get Item Availability Browsing',
        build: () => recommendationBrowseHistoryBloc,
        seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: ""),
        act: (bloc) => bloc.add(GetItemAvailabilityBrowsing(childIndex: 0, parentIndex: 0)),
        expect: () => [
          BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done"),
        ],
      );

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Update Product In Browsing',
        build: () => recommendationBrowseHistoryBloc,
        seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: ""),
        act: (bloc) => bloc.add(UpdateProductInBrowsing(childIndex: 0, parentIndex: 0, records: Records())),
        expect: () => [
          BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done"),
        ],
      );

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Update Product In Browsing Others',
        build: () => recommendationBrowseHistoryBloc,
        seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: ""),
        act: (bloc) => bloc.add(UpdateProductInBrowsingOthers(childIndex: 0, parentIndex: 0, records: Records())),
        expect: () => [
          BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done"),
        ],
      );

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Initialize Product',
        build: () => recommendationBrowseHistoryBloc,
        seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: ""),
        act: (bloc) => bloc.add(InitializeProduct()),
        expect: () => [
          BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: Records(childskus: [])),
        ],
      );

      group(
        'Load Product Detail Browse Other History',
        () {
          blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
            'ifDetail = true',
            build: () => recommendationBrowseHistoryBloc,
            seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBrowseOtherHistory(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done", product: Records(childskus: [])),
              BrowseHistorySuccess(
                recommendationScreenModel: dummyRecommendationScreenModel,
                message: "done",
                product: dummyRecommendationScreenModel.productBrowsingOthers.first.recommendedProductSet.first.records,
              ),
            ],
          );

          blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
            'ifDetail = false',
            build: () => recommendationBrowseHistoryBloc,
            seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBrowseOtherHistory(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: false,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done", product: Records(childskus: [])),
            ],
          );
        },
      );

      group(
        'Load Product Detail Browse History',
        () {
          blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
            'ifDetail = true',
            build: () => recommendationBrowseHistoryBloc,
            seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBrowseHistory(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done", product: Records(childskus: [])),
              BrowseHistorySuccess(
                recommendationScreenModel: dummyRecommendationScreenModel,
                message: "done",
                product: dummyRecommendationScreenModel.productBrowsing.first.recommendedProductSet.first.records,
              ),
            ],
          );

          blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
            'ifDetail = false',
            build: () => recommendationBrowseHistoryBloc,
            seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailBrowseHistory(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: false,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done", product: Records(childskus: [])),
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

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Load Product Detail Browse Other History Failure',
        build: () => recommendationBrowseHistoryBloc,
        seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: "wow"),
        act: (bloc) => bloc.add(LoadProductDetailBrowseOtherHistory(
          childIndex: 0,
          parentIndex: 0,
          ifDetail: true,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "",
        )),
        expect: () => [
          BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done", product: Records(childskus: [])),
          BrowseHistorySuccess(
            recommendationScreenModel: dummyRecommendationScreenModel,
            message: "Product Record not found",
            product: Records(childskus: []),
          ),
        ],
      );

      blocTest<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
        'Load Product Detail Browse History Failure',
        build: () => recommendationBrowseHistoryBloc,
        seed: () => BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, product: null, message: "wow"),
        act: (bloc) => bloc.add(LoadProductDetailBrowseHistory(
          childIndex: 0,
          parentIndex: 0,
          ifDetail: true,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "",
        )),
        expect: () => [
          BrowseHistorySuccess(recommendationScreenModel: dummyRecommendationScreenModel, message: "done", product: Records(childskus: [])),
          BrowseHistorySuccess(
            recommendationScreenModel: dummyRecommendationScreenModel,
            message: "Product Record not found",
            product: Records(childskus: []),
          ),
        ],
      );
    },
  );
}
