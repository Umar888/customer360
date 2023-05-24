import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart' as isb;
import 'package:gc_customer_app/data/data_sources/favourite_brand_screen_data_source/favourite_brand_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/favorite_brands_model/favorite_brand_detail_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
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
  List<Records> get productsInCart => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FavouriteBrandScreenBloc favouriteBrandScreenBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  late Records dummyRecords;
  late FavoriteBrandDetailModel dummyFavouriteItems;

  setUp(
    () {
      dummyRecords = Records.fromJson({
        "childskus": [
          {"skuPIMId": ""}
        ]
      });
      dummyFavouriteItems = FavoriteBrandDetailModel(
          wrapperinstance: Wrapperinstance(records: [
        Records(childskus: [Childskus(skuENTId: "")])
      ]));

      var favouriteBrandScreenDataSource = FavouriteBrandScreenDataSource();
      favouriteBrandScreenDataSource.httpService.client = MockClient((request) async {
        if (successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.kSearchDetail}'.escape + r'$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "wrapperinstance": {
                    "records": [dummyRecords]
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
      favouriteBrandScreenBloc = FavouriteBrandScreenBloc(favouriteBrandScreenRepository: FavouriteBrandScreenRepository());
      favouriteBrandScreenBloc.favouriteBrandScreenRepository.favouriteBrandScreenDataSource = favouriteBrandScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        'Load Data',
        build: () => favouriteBrandScreenBloc,
        act: (bloc) => bloc.add(LoadData(
          primaryInstrument: "",
          brandName: "",
          brandItems: [BrandItems(itemSkuID: "")],
          isFavouriteScreen: true,
        )),
        expect: () => [
          isA<FavouriteBrandScreenProgress>(),
          isA<FavouriteBrandScreenSuccess>(),
        ],
      );

      blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        'Empty Message',
        build: () => favouriteBrandScreenBloc,
        seed: () => FavouriteBrandScreenSuccess(
          message: "Success",
          favoriteItems: null,
          brandItems: [],
          product: null,
        ),
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          FavouriteBrandScreenSuccess(message: "", favoriteItems: null, brandItems: [], product: null),
        ],
      );

      blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        'Refresh List',
        build: () => favouriteBrandScreenBloc,
        seed: () => FavouriteBrandScreenSuccess(
          message: "Success",
          favoriteItems: null,
          brandItems: [],
          product: null,
        ),
        act: (bloc) => bloc.add(RefreshList()),
        expect: () => [
          isA<FavouriteBrandScreenSuccess>(),
        ],
      );

      blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        'Initialize Product',
        build: () => favouriteBrandScreenBloc,
        seed: () => FavouriteBrandScreenSuccess(
          message: "Success",
          favoriteItems: null,
          brandItems: [],
          product: null,
        ),
        act: (bloc) => bloc.add(InitializeProduct()),
        expect: () => [
          isA<FavouriteBrandScreenSuccess>(),
        ],
      );

      blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        'Update Product (ifNative = true)',
        build: () => favouriteBrandScreenBloc,
        seed: () => FavouriteBrandScreenSuccess(
          message: "Success",
          favoriteItems: null,
          brandItems: [BrandItems()],
          product: null,
        ),
        act: (bloc) => bloc.add(UpdateProduct(records: Records(), ifNative: true, index: 0)),
        expect: () => [
          isA<FavouriteBrandScreenSuccess>(),
        ],
      );

      blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        'Update Product (ifNative = false)',
        build: () => favouriteBrandScreenBloc,
        seed: () => FavouriteBrandScreenSuccess(
          message: "Success",
          favoriteItems: dummyFavouriteItems,
          brandItems: [BrandItems()],
          product: null,
        ),
        act: (bloc) => bloc.add(UpdateProduct(records: Records(), ifNative: false, index: 0)),
        expect: () => [
          isA<FavouriteBrandScreenSuccess>(),
        ],
      );

      group(
        'Load Product Detail',
        () {
          blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
            'ifNative = true && ifDetail = true',
            build: () => favouriteBrandScreenBloc,
            seed: () => FavouriteBrandScreenSuccess(
              message: "Success",
              favoriteItems: null,
              brandItems: [BrandItems(itemSkuID: "")],
              product: null,
            ),
            act: (bloc) => bloc.add(LoadProductDetail(
              ifNative: true,
              index: 0,
              id: "123",
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              FavouriteBrandScreenSuccess(
                message: "",
                favoriteItems: null,
                brandItems: [BrandItems(itemSkuID: "", records: dummyRecords)],
                product: Records(childskus: []),
              ),
              FavouriteBrandScreenSuccess(
                message: "done",
                favoriteItems: null,
                brandItems: [BrandItems(itemSkuID: "", records: dummyRecords)],
                product: dummyRecords,
              ),
            ],
          );

          blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
            'ifNative = true && ifDetail = false',
            build: () => favouriteBrandScreenBloc,
            seed: () => FavouriteBrandScreenSuccess(
              message: "Success",
              favoriteItems: null,
              brandItems: [BrandItems(itemSkuID: "")],
              product: null,
            ),
            act: (bloc) => bloc.add(LoadProductDetail(
              ifNative: true,
              index: 0,
              id: "123",
              ifDetail: false,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              FavouriteBrandScreenSuccess(
                message: "",
                favoriteItems: null,
                brandItems: [BrandItems(itemSkuID: "", records: dummyRecords)],
                product: Records(childskus: []),
              ),
              FavouriteBrandScreenSuccess(
                message: "done",
                favoriteItems: null,
                brandItems: [BrandItems(itemSkuID: "", records: dummyRecords)],
                product: Records(childskus: []),
              ),
            ],
          );

          blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
            'ifNative = false && ifDetail = true',
            build: () => favouriteBrandScreenBloc,
            seed: () => FavouriteBrandScreenSuccess(
              message: "Success",
              favoriteItems: dummyFavouriteItems,
              brandItems: [BrandItems(itemSkuID: "")],
              product: null,
            ),
            act: (bloc) => bloc.add(LoadProductDetail(
              ifNative: false,
              index: 0,
              id: "123",
              ifDetail: true,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              FavouriteBrandScreenSuccess(
                message: null,
                favoriteItems: dummyFavouriteItems,
                brandItems: [BrandItems(itemSkuID: "")],
                product: Records(childskus: []),
              ),
              FavouriteBrandScreenSuccess(
                message: "done",
                favoriteItems: dummyFavouriteItems,
                brandItems: [BrandItems(itemSkuID: "")],
                product: dummyRecords,
              ),
            ],
          );

          blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
            'ifNative = false && ifDetail = false',
            build: () => favouriteBrandScreenBloc,
            seed: () => FavouriteBrandScreenSuccess(
              message: "Success",
              favoriteItems: dummyFavouriteItems,
              brandItems: [BrandItems(itemSkuID: "")],
              product: null,
            ),
            act: (bloc) {
              bloc.add(LoadProductDetail(
                ifNative: false,
                index: 0,
                id: "123",
                ifDetail: false,
                inventorySearchBloc: MockInventorySearchBloc(),
                state: MockInventorySearchState(),
                customerId: "",
              ));
            },
            expect: () => [
              FavouriteBrandScreenSuccess(
                message: null,
                favoriteItems: dummyFavouriteItems,
                brandItems: [BrandItems(itemSkuID: "")],
                product: Records(childskus: []),
              ),
              FavouriteBrandScreenSuccess(
                message: "done",
                favoriteItems: dummyFavouriteItems,
                brandItems: [BrandItems(itemSkuID: "")],
                product: Records(childskus: []),
              ),
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

      blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        'Load Data Failure',
        build: () => favouriteBrandScreenBloc,
        act: (bloc) => bloc.add(LoadData(
          primaryInstrument: "",
          brandName: "",
          brandItems: [],
          isFavouriteScreen: false,
        )),
        expect: () => [
          isA<FavouriteBrandScreenProgress>(),
          isA<FavouriteBrandScreenSuccess>(),
        ],
      );

      group(
        'Load Product Detail Failure',
        () {
          blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
            'ifNative = true',
            build: () => favouriteBrandScreenBloc,
            seed: () => FavouriteBrandScreenSuccess(
              message: "Success",
              favoriteItems: null,
              brandItems: [BrandItems(itemSkuID: "")],
              product: null,
            ),
            act: (bloc) => bloc.add(LoadProductDetail(
              ifNative: true,
              index: 0,
              id: "123",
              ifDetail: null,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              FavouriteBrandScreenSuccess(
                message: "",
                favoriteItems: null,
                brandItems: [BrandItems(itemSkuID: "")],
                product: Records(childskus: []),
              ),
              FavouriteBrandScreenSuccess(
                message: "Product Record not found",
                favoriteItems: null,
                brandItems: [BrandItems(itemSkuID: "")],
                product: Records(childskus: []),
              ),
            ],
          );

          blocTest<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
            'ifNative = false',
            build: () => favouriteBrandScreenBloc,
            seed: () => FavouriteBrandScreenSuccess(
              message: "Success",
              favoriteItems: dummyFavouriteItems,
              brandItems: [BrandItems(itemSkuID: "")],
              product: null,
            ),
            act: (bloc) => bloc.add(LoadProductDetail(
              ifNative: false,
              index: 0,
              id: "123",
              ifDetail: null,
              inventorySearchBloc: MockInventorySearchBloc(),
              state: MockInventorySearchState(),
              customerId: "",
            )),
            expect: () => [
              FavouriteBrandScreenSuccess(
                message: null,
                favoriteItems: dummyFavouriteItems,
                brandItems: [BrandItems(itemSkuID: "")],
                product: Records(childskus: []),
              ),
              FavouriteBrandScreenSuccess(
                message: "Product Record not found",
                favoriteItems: dummyFavouriteItems,
                brandItems: [BrandItems(itemSkuID: "")],
                product: Records(childskus: []),
              ),
            ],
          );
        },
      );
    },
  );
}
