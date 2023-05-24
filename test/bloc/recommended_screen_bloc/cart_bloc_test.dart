// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart' as isb;
import 'package:gc_customer_app/bloc/recommended_screen_bloc/cart/recommendation_cart_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/data/data_sources/recommendation_screen_data_source/recommendation_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/product_cart_browse_items.dart' hide Records, Childskus;
import 'package:gc_customer_app/models/recommendation_Screen_model/product_cart_frequently_baught_items.dart';
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
  late RecommendationCartBloc recommendationCartBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  late Map<String, dynamic> dummyBrowseItemsModelJson;
  late ProductCartBrowseItemsModel dummyBrowseItemsModel;
  late Map<String, dynamic> dummyFrequentlyBaughtItemsModelJson;
  late ProductCartFrequentlyBaughtItemsModel dummyFrequentlyBaughtItemsModel;

  setUp(
    () {
      dummyBrowseItemsModelJson = {
        "message": "record found.",
        "productCart": [
          {
            "wrapperinstance": {
              "navContent": {"totalERecsNum": 0},
              "records": [
                {
                  "childskus": [
                    {"skuENTId": ""}
                  ]
                }
              ],
            },
            "faceLst": []
          }
        ],
      };
      dummyBrowseItemsModel = ProductCartBrowseItemsModel.fromJson(dummyBrowseItemsModelJson);
      dummyFrequentlyBaughtItemsModelJson = {
        "message": "record found.",
        "productCartOthers": [
          {
            "recommendedProductSet": [
              {"itemSKU": ""}
            ]
          }
        ],
      };
      dummyFrequentlyBaughtItemsModel = ProductCartFrequentlyBaughtItemsModel.fromJson(dummyFrequentlyBaughtItemsModelJson);

      var recommendationScreenDataSource = RecommendationScreenDataSource();
      var landingScreenDataSource = LandingScreenDataSource();
      var mockClient = MockClient((request) async {
        if (successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.recommendationsList}'.escape + r'\?recordId=.+&recommendType=CartOther')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode(dummyFrequentlyBaughtItemsModelJson), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.recommendationsList}'.escape + r'\?recordId=.+&recommendType=Cart')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode(dummyBrowseItemsModelJson), 200);
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
      recommendationCartBloc = RecommendationCartBloc(recommendationScreenRepository: RecommendationScreenRepository());
      recommendationCartBloc.recommendationScreenRepository.recommendationScreenDataSource = recommendationScreenDataSource;
      recommendationCartBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Load Cart Items',
        build: () => recommendationCartBloc,
        act: (bloc) => bloc.add(LoadCartItems()),
        expect: () => [
          CartLoadProgress(),
          LoadCartItemsSuccess(
              message: "",
              product: Records(childskus: []),
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel),
          LoadCartItemsSuccess(
              message: "done",
              product: Records(childskus: []),
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel),
        ],
      );

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Get Item Availability Cart',
        build: () => recommendationCartBloc,
        seed: () => LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            product: null,
            message: ""),
        act: (bloc) => bloc.add(GetItemAvailabilityCart(childIndex: 0, parentIndex: 0)),
        expect: () => [
          LoadCartItemsSuccess(
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
              message: "done"),
        ],
      );

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Empty Message',
        build: () => recommendationCartBloc,
        seed: () => LoadCartItemsSuccess(productCartBrowseItemsModel: null, productCartFrequentlyBaughtItemsModel: null, message: "done"),
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          LoadCartItemsSuccess(productCartBrowseItemsModel: null, productCartFrequentlyBaughtItemsModel: null, message: ""),
        ],
      );

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Update Product In Cart',
        build: () => recommendationCartBloc,
        seed: () => LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            product: null,
            message: ""),
        act: (bloc) => bloc.add(UpdateProductInCart(parentIndex: 0, childIndex: 0, records: Records())),
        expect: () => [
          LoadCartItemsSuccess(
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
              message: "done"),
        ],
      );

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Update Product In Cart Others',
        build: () => recommendationCartBloc,
        seed: () => LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            product: null,
            message: ""),
        act: (bloc) => bloc.add(UpdateProductInCartOthers(childIndex: 0, parentIndex: 0, records: Records())),
        expect: () => [
          LoadCartItemsSuccess(
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
              message: "done"),
        ],
      );

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Initialize Product',
        build: () => recommendationCartBloc,
        seed: () => LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            product: null,
            message: ""),
        act: (bloc) => bloc.add(InitializeProduct()),
        expect: () => [
          LoadCartItemsSuccess(
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
              product: Records(childskus: []),
              message: "done"),
        ],
      );

      group(
        'Load Product Detail Buy Again Other',
        () {
          blocTest<RecommendationCartBloc, RecommendationCartState>(
            'ifDetail = true',
            build: () => recommendationCartBloc,
            seed: () => LoadCartItemsSuccess(
                productCartBrowseItemsModel: dummyBrowseItemsModel,
                productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                product: null,
                message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailCartOthers(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadCartItemsSuccess(
                  productCartBrowseItemsModel: dummyBrowseItemsModel,
                  productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                  message: "done",
                  product: Records(childskus: [])),
              LoadCartItemsSuccess(
                productCartBrowseItemsModel: dummyBrowseItemsModel,
                productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                message: "done",
                product: dummyFrequentlyBaughtItemsModel.productCartOthers.first.recommendedProductSet.first.records,
              ),
            ],
          );

          blocTest<RecommendationCartBloc, RecommendationCartState>(
            'ifDetail = false',
            build: () => recommendationCartBloc,
            seed: () => LoadCartItemsSuccess(
                productCartBrowseItemsModel: dummyBrowseItemsModel,
                productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                product: null,
                message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailCartOthers(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: false,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadCartItemsSuccess(
                  productCartBrowseItemsModel: dummyBrowseItemsModel,
                  productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                  message: "done",
                  product: Records(childskus: [])),
            ],
          );
        },
      );

      group(
        'Load Product Detail Buy Again',
        () {
          blocTest<RecommendationCartBloc, RecommendationCartState>(
            'ifDetail = true',
            build: () => recommendationCartBloc,
            seed: () => LoadCartItemsSuccess(
                productCartBrowseItemsModel: dummyBrowseItemsModel,
                productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                product: null,
                message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailCart(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadCartItemsSuccess(
                  productCartBrowseItemsModel: dummyBrowseItemsModel,
                  productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                  message: "done",
                  product: Records(childskus: [])),
              LoadCartItemsSuccess(
                productCartBrowseItemsModel: dummyBrowseItemsModel,
                productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                message: "done",
                product: dummyBrowseItemsModel.productCart.first.wrapperinstance.records.first.records,
              ),
            ],
          );

          blocTest<RecommendationCartBloc, RecommendationCartState>(
            'ifDetail = false',
            build: () => recommendationCartBloc,
            seed: () => LoadCartItemsSuccess(
                productCartBrowseItemsModel: dummyBrowseItemsModel,
                productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                product: null,
                message: "wow"),
            act: (bloc) => bloc.add(LoadProductDetailCart(
              childIndex: 0,
              parentIndex: 0,
              ifDetail: false,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              LoadCartItemsSuccess(
                  productCartBrowseItemsModel: dummyBrowseItemsModel,
                  productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
                  message: "done",
                  product: Records(childskus: [])),
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

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Load Cart Items Failure',
        build: () => recommendationCartBloc,
        act: (bloc) => bloc.add(LoadCartItems()),
        expect: () => [
          CartLoadProgress(),
          CartLoadFailure(),
        ],
      );

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Load Product Detail Buy Again Other Failure',
        build: () => recommendationCartBloc,
        seed: () => LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            product: null,
            message: "wow"),
        act: (bloc) => bloc.add(LoadProductDetailCartOthers(
          childIndex: 0,
          parentIndex: 0,
          ifDetail: true,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "",
        )),
        expect: () => [
          LoadCartItemsSuccess(
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
              message: "done",
              product: Records(childskus: [])),
          LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            message: "Product Record not found",
            product: Records(childskus: []),
          ),
        ],
      );

      blocTest<RecommendationCartBloc, RecommendationCartState>(
        'Load Product Detail Buy Again Failure',
        build: () => recommendationCartBloc,
        seed: () => LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            product: null,
            message: "wow"),
        act: (bloc) => bloc.add(LoadProductDetailCart(
          childIndex: 0,
          parentIndex: 0,
          ifDetail: true,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "",
        )),
        expect: () => [
          LoadCartItemsSuccess(
              productCartBrowseItemsModel: dummyBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
              message: "done",
              product: Records(childskus: [])),
          LoadCartItemsSuccess(
            productCartBrowseItemsModel: dummyBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: dummyFrequentlyBaughtItemsModel,
            message: "Product Record not found",
            product: Records(childskus: []),
          ),
        ],
      );
    },
  );
}
