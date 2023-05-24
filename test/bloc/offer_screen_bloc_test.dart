import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart' hide EmptyMessage;
import 'package:gc_customer_app/bloc/offers_screen_bloc/offers_screen_bloc.dart';
import 'package:gc_customer_app/data/data_sources/favourite_brand_screen_data_source/favourite_brand_screen_data_source.dart';
import 'package:gc_customer_app/data/data_sources/offers_screen_data_repository/offers_screen_data_repository.dart';
import 'package:gc_customer_app/data/reporsitories/offers_screen_repository/offers_screen_repository.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

class MockInventorySearchBloc extends Mock implements InventorySearchBloc {}

class MockInventorySearchState extends Mock implements InventorySearchState {
  @override
  List<Records> get productsInCart => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late OffersScreenBloc offersScreenBloc;
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
      {"skuENTId": ""}
    ],
  };

  setUp(
    () {
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
          } else if (request.matches('/services/apexrest/GC_C360_OffersAPI'.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "offers": [{}],
                  "message": "done"
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
      var offersScreenDataSource = OffersScreenDataSource()..httpService.client = mock;
      var favouriteBrandScreenDataSource = FavouriteBrandScreenDataSource()..httpService.client = mock;
      offersScreenBloc = OffersScreenBloc(offersScreenRepository: OffersScreenRepository());
      offersScreenBloc.offersScreenRepository.offersScreenDataSource = offersScreenDataSource;
      offersScreenBloc.favouriteBrandScreenRepository.favouriteBrandScreenDataSource = favouriteBrandScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Load Data',
        build: () => offersScreenBloc,
        act: (bloc) => bloc.add(LoadData(offers: [])),
        expect: () => [
          OfferScreenProgress(),
          OfferScreenSuccess(
            offersScreenModel: [],
            message: "",
            product: Records(childskus: []),
          ),
        ],
      );

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Empty Message',
        build: () => offersScreenBloc,
        seed: () => OfferScreenSuccess(offersScreenModel: [], message: "done", product: Records()),
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          OfferScreenSuccess(
            offersScreenModel: [],
            product: Records(),
            message: "",
          ),
        ],
      );

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Update Product',
        build: () => offersScreenBloc,
        seed: () => OfferScreenSuccess(offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records()))], message: "", product: Records()),
        act: (bloc) => bloc.add(UpdateProduct(records: Records(), index: 0)),
        expect: () => [
          OfferScreenSuccess(
            offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records()))],
            product: Records(),
            message: "done",
          ),
        ],
      );

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Initialize Product',
        build: () => offersScreenBloc,
        seed: () => OfferScreenSuccess(offersScreenModel: [], message: "", product: Records()),
        act: (bloc) => bloc.add(InitializeProduct()),
        expect: () => [
          OfferScreenSuccess(
            offersScreenModel: [],
            product: Records(childskus: []),
            message: "",
          ),
        ],
      );

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Load Product Detail ifDetail = true',
        build: () => offersScreenBloc,
        seed: () => OfferScreenSuccess(
          offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records(), enterpriseSkuId: ""))],
          message: "",
          product: Records(),
        ),
        act: (bloc) => bloc.add(LoadProductDetail(
          index: 0,
          ifDetail: true,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "123",
        )),
        expect: () => [
          OfferScreenSuccess(
            offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records.fromJson(dummyRecordsJson), enterpriseSkuId: "", isUpdating: false))],
            product: Records(childskus: []),
            message: "done",
          ),
          OfferScreenSuccess(
            offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records.fromJson(dummyRecordsJson), enterpriseSkuId: "", isUpdating: false))],
            product: Records.fromJson(dummyRecordsJson),
            message: "done",
          ),
        ],
      );

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Load Product Detail ifDetail = false',
        build: () => offersScreenBloc,
        seed: () => OfferScreenSuccess(
          offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records(), enterpriseSkuId: ""))],
          message: "",
          product: Records(),
        ),
        act: (bloc) => bloc.add(LoadProductDetail(
          index: 0,
          ifDetail: false,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "123",
        )),
        expect: () => [
          OfferScreenSuccess(
            offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records.fromJson(dummyRecordsJson), enterpriseSkuId: "", isUpdating: false))],
            product: Records(childskus: []),
            message: "done",
          ),
        ],
      );

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Load Offers',
        build: () => offersScreenBloc,
        act: (bloc) => bloc.add(LoadOffers()),
        expect: () => [
          OfferScreenSuccess(offersScreenModel: [Offers()], message: 'done', product: null),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<OffersScreenBloc, OfferScreenState>(
        'Load Product Detail Failure',
        build: () => offersScreenBloc,
        seed: () => OfferScreenSuccess(
          offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records(), enterpriseSkuId: ""))],
          message: "",
          product: Records(),
        ),
        act: (bloc) => bloc.add(LoadProductDetail(
          index: 0,
          ifDetail: false,
          inventorySearchBloc: MockInventorySearchBloc(),
          state: MockInventorySearchState(),
          customerId: "123",
        )),
        expect: () => [
          OfferScreenSuccess(
            offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records(), enterpriseSkuId: "", isUpdating: false))],
            product: Records(childskus: []),
            message: "done",
          ),
          OfferScreenSuccess(
            offersScreenModel: [Offers(flashDeal: FlashDeal(records: Records(), enterpriseSkuId: "", isUpdating: false))],
            product: Records(childskus: []),
            message: "Product Record not found",
          ),
        ],
      );
    },
  );
}
