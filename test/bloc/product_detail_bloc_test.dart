import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart' as isb;
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/inventory_search/cart_model.dart';
import 'package:gc_customer_app/models/product_detail_model/bundle_model.dart';
import 'package:gc_customer_app/models/product_detail_model/color_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/models/product_detail_model/other_store_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

class MockInventorySearchBloc extends Mock implements isb.InventorySearchBloc {
  @override
  isb.InventorySearchState get state => MockInventorySearchState();
}

class MockInventorySearchState extends Mock implements isb.InventorySearchState {
  @override
  List<Records> get productsInCart => [
        Records(childskus: [Childskus(skuENTId: "")])
      ];

  @override
  String get orderId => "123";
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProductDetailBloc? productDetailBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  final Map<String, dynamic> dummyRecordsJson = {
    "childskus": [
      {
        "skuENTId": "",
        "skuImageUrl": "image.url",
        "skuCondition": "condition1",
      }
    ],
    "productName": "name",
  };
  final Map<String, dynamic> dummyWarrantiesModelJson = {
    "Warranties": [
      {
        "styleDescription1": "",
        "price": null,
        "id": "456",
        "enterpriseSkuId": "",
        "enterprisePIMId": "",
        "displayName": "",
      }
    ],
  };

  final Records dummyRecords = Records.fromJson(dummyRecordsJson);
  final WarrantiesModel dummyWarrantiesModel = WarrantiesModel.fromJson(dummyWarrantiesModelJson);

  final List<ColorModel> dummyColors = [
    ColorModel(color: Colors.pink, name: "Pink"),
    ColorModel(color: Colors.green, name: "Green"),
    ColorModel(color: Colors.yellow, name: "Yellow"),
    ColorModel(color: Colors.purple, name: "Purple"),
    ColorModel(color: Colors.blue, name: "Blue"),
    ColorModel(color: Colors.pink, name: "Pink"),
    ColorModel(color: Colors.orange, name: "Orange"),
  ];

  ProductDetailBloc setUpBloc() {
    var mock = MockClient((request) async {
      if (successScenario) {
        if (request.matches(Endpoints.kSearchDetail.escape)) {
          print("Success: ${request.url}");
          return Response(
              json.encode({
                "wrapperinstance": {
                  "records": [dummyRecordsJson]
                }
              }),
              200);
        } else if (request.matches(Endpoints.kStoreZipAddress.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({}), 200);
        } else if (request.matches(Endpoints.kWarranties.escape)) {
          return Response(json.encode(dummyWarrantiesModelJson), 200);
        } else if (request.matches(Endpoints.lRecommendation.escape)) {
          print("Success: ${request.url}");
          return Response(
              json.encode({
                "productRecommands": [{}]
              }),
              200);
        } else if (request.matches(Endpoints.kUpdateCartAndProductOrder.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"message": "done", "orderId": "", "oliRecId": ""}), 200);
        } else if (request.matches(Endpoints.kWarrantiesUpdate.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({}), 200);
        } else if (request.matches(Endpoints.kItemAvailability.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({}), 200);
        } else if (request.matches(Endpoints.kClientOrderCalculation.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({}), 200);
        } else {
          print("API call not mocked: ${request.url}");
          return Response(json.encode({}), 205);
        }
      } else {
        print("Failed: ${request.url}");
        return Response(jsonEncode({}), 205);
      }
    });
    var productDetailDataSource = ProductDetailDataSource()..httpService.client = mock;
    return ProductDetailBloc(productDetailRepository: ProductDetailRepository(productDetailDataSource: productDetailDataSource))
      ..cartRepository.cartDataSource.httpService.client = mock;
  }

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest(
        'Page Load',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(PageLoad(
          skuENTId: "123",
          warrantyId: "456",
          productsInCart: [dummyRecords],
          orderId: "",
          orderLineItemId: "",
          inventorySearchBloc: MockInventorySearchBloc(),
        )),
        expect: () => [
          ProductDetailState(productDetailStatus: ProductDetailStatus.loadState),
          ProductDetailState(
            getZipCodeList: [GetZipCodeList.fromJson({})],
            colors: dummyColors,
            loadingBundles: true,
            fetchEligibility: true,
            currentColor: [dummyColors[0]],
            productDetailStatus: ProductDetailStatus.successState,
            records: [dummyRecords],
            orderId: "123",
            images: dummyRecords.childskus?.map((e) => e.skuImageUrl).whereType<String>().toList() ?? [],
            proCoverage: [],
            currentImage: dummyRecords.childskus?.first.skuImageUrl ?? "",
            currentCondition: "condition1",
            proCoverageModel: [dummyWarrantiesModel],
            currentProCoverage: [dummyWarrantiesModel.warranties!.first],
            getZipCodeListSearch: [GetZipCodeList(mainNodeData: [], otherNodeData: [])],
            isInStoreLoading: false,
          ),
          productDetailBloc!.state.copyWith(loadingBundles: false, productRecommands: [ProductRecommands.fromJson({})], fetchEligibility: true),
          productDetailBloc!.state.copyWith(
            moreInfo: [],
            mainNodeData: [],
            fetchEligibility: false,
          ),
        ],
      );

      blocTest(
        'Clear Message',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(ClearMessage()),
        expect: () => [
          ProductDetailState(message: ""),
        ],
      );

      blocTest(
        'Get Product Detail',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        seed: () => ProductDetailState(productRecommands: [
          ProductRecommands(recommendedProductSet: [RecommendedProductSet(records: Records())])
        ]),
        act: (bloc) => bloc.add(GetProductDetail(
          index: 0,
          id: "123",
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "456",
        )),
        expect: () => [
          ProductDetailState(productRecommands: [
            ProductRecommands(recommendedProductSet: [RecommendedProductSet(records: Records(records: dummyRecords, isUpdating: false))])
          ], message: "done"),
        ],
      );

      blocTest(
        'Set Current Image',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(SetCurrentImage(image: "abc")),
        expect: () => [
          ProductDetailState(currentImage: "abc"),
        ],
      );

      blocTest(
        'Set Expand Bundle',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(SetExpandBundle(expandBundle: true)),
        expect: () => [
          ProductDetailState(expandBundle: true),
        ],
      );

      blocTest(
        'Set Expand Color',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(SetExpandColor(expandColor: true)),
        expect: () => [
          ProductDetailState(expandColor: true),
        ],
      );

      blocTest(
        'Set Expand Coverage',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(SetExpandCoverage(expandCoverage: true)),
        expect: () => [
          ProductDetailState(expandCoverage: true),
        ],
      );

      blocTest(
        'Set Expand Eligibility',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(SetExpandEligibility(value: true)),
        expect: () => [
          ProductDetailState(expandEligibility: true),
        ],
      );

      blocTest(
        'Set Current Coverage',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        seed: () => ProductDetailState(proCoverageModel: [dummyWarrantiesModel], records: [dummyRecords], productsInCart: [dummyRecords]),
        act: (bloc) => bloc.add(SetCurrentCoverage(
          currentCoverage: dummyWarrantiesModel.warranties!.first,
          inventorySearchBloc: MockInventorySearchBloc(),
          itemsOfCart: [ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: "")],
          orderID: "123",
          productsInCart: [],
          orderLineItemID: "456",
          styleDescription1: "Description",
        )),
        expect: () => [
          productDetailBloc!.state.copyWith(
            records: [dummyRecords],
            currentProCoverage: [],
          ),
          productDetailBloc!.state.copyWith(
            records: [dummyRecords],
            currentProCoverage: [dummyWarrantiesModel.warranties!.first],
          ),
        ],
      );

      blocTest(
        'Set Current Color',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(SetCurrentColor(currentColor: dummyColors[0])),
        expect: () => [
          ProductDetailState(currentColor: [dummyColors[0]]),
        ],
      );

      blocTest(
        'Update Bottom Cart With Items',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(UpdateBottomCartWithItems(records: [dummyRecords], items: [])),
        expect: () => [
          ProductDetailState(productsInCart: [dummyRecords]),
        ],
      );

      blocTest(
        'Update Bottom Cart',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(UpdateBottomCart(items: [dummyRecords])),
        expect: () => [
          ProductDetailState(productsInCart: [dummyRecords]),
        ],
      );

      blocTest(
        'Get Address Product',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(GetAddressProduct(skuENTId: "123")),
        expect: () => [
          ProductDetailState(productDetailStatus: ProductDetailStatus.loadState),
          ProductDetailState(
            productDetailStatus: ProductDetailStatus.successState,
            getZipCodeList: [GetZipCodeList.fromJson({})],
            getZipCodeListSearch: [GetZipCodeList.fromJson({})],
          ),
        ],
      );

      blocTest(
        'Search Address Product searchName = empty',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(SearchAddressProduct(searchName: "")),
        expect: () => [
          ProductDetailState(getZipCodeListSearch: []),
        ],
      );

      blocTest(
        'Search Address Product searchName != empty',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        seed: () => ProductDetailState(getZipCodeList: [
          GetZipCodeList(
            otherStores: [OtherStoreModel()],
            otherNodeData: [],
          )
        ]),
        act: (bloc) => bloc.add(SearchAddressProduct(searchName: "Description")),
        expect: () => [
          productDetailBloc!.state.copyWith(
            productDetailStatus: ProductDetailStatus.successState,
            getZipCodeListSearch: [GetZipCodeList(otherStores: [])],
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest(
        'Page Load Failure',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        act: (bloc) => bloc.add(PageLoad(
          skuENTId: "123",
          warrantyId: "456",
          productsInCart: [dummyRecords],
          orderId: "",
          orderLineItemId: "",
          inventorySearchBloc: MockInventorySearchBloc(),
        )),
        expect: () => [
          ProductDetailState(productDetailStatus: ProductDetailStatus.loadState),
          ProductDetailState(
            productsInCart: [dummyRecords],
            records: [],
            productDetailStatus: ProductDetailStatus.successState,
            isInStoreLoading: false,
          ),
        ],
      );

      blocTest(
        'Get Product Detail Failure',
        build: () => productDetailBloc = setUpBloc(),
        tearDown: () => productDetailBloc = null,
        seed: () => ProductDetailState(productRecommands: [
          ProductRecommands(recommendedProductSet: [RecommendedProductSet(records: Records())])
        ]),
        act: (bloc) => bloc.add(GetProductDetail(
          index: 0,
          id: "123",
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "456",
        )),
        expect: () => [
          ProductDetailState(productRecommands: [
            ProductRecommands(recommendedProductSet: [RecommendedProductSet(records: Records())])
          ], message: "done"),
          ProductDetailState(productRecommands: [
            ProductRecommands(recommendedProductSet: [RecommendedProductSet(records: Records())])
          ], message: "Product detail not found"),
        ],
      );
    },
  );
}
