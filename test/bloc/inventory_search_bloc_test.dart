// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart' hide EmptyMessage;
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/data_sources/favourite_brand_screen_data_source/favourite_brand_screen_data_source.dart';
import 'package:gc_customer_app/data/data_sources/inventory_search_data_source/inventory_search_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/inventory_search_reporsitory/inventory_search_repository.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/favorite_brands_model/favorite_brand_detail_model.dart';
import 'package:gc_customer_app/models/inventory_search/add_search_model.dart';
import 'package:gc_customer_app/models/inventory_search/cart_model.dart';
import 'package:gc_customer_app/models/inventory_search/options_model_for_filters.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension on String {
  String get escape => RegExp.escape(this);
}

class MockFavouriteBrandScreenBloc extends Mock implements FavouriteBrandScreenBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late InventorySearchBloc inventorySearchBloc;
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

  final AddSearchModel dummySearchDetailModel = AddSearchModel.fromJson({
    "wrapperinstance": {
      "records": [dummyRecordsJson],
      "facet": [
        {
          "refinement": [
            {"onPressed": false}
          ]
        }
      ],
    },
  });

  setUp(
    () {
      var inventorySearchDataSource = InventorySearchDataSource();
      var favouriteBrandScreenDataSource = FavouriteBrandScreenDataSource();
      var mockClient = MockClient((request) async {
        if (successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.recommendationsList}'.escape + r'\?recordId=.+&recommendType=BrowsingHistory')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kItemAvailability}'.escape + r'.+&recordType=moreInfo')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({"moreInfo": []}), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kSearchDetail}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode(dummySearchDetailModel.toJson()), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kWarrantiesUpdate}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "Warranties": [],
                  "message": "Success",
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kAddToCartAndProductOrder.replaceAll("?", "\?")}'.escape)
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({"orderId": "", "oliRecId": "", "message": "done"}), 200);
          } else {
            print("API call not mocked: ${request.url}");
            return Response(json.encode({}), 205);
          }
        } else {
          print("Failed: ${request.url}");
          return Response(json.encode({}), 205);
        }
      });
      inventorySearchDataSource.httpService.client = mockClient;
      favouriteBrandScreenDataSource.httpService.client = mockClient;
      inventorySearchBloc = InventorySearchBloc(
          favouriteBrandScreenRepository: FavouriteBrandScreenRepository(),
          inventorySearchRepository: InventorySearchRepository(inventorySearchDataSource: inventorySearchDataSource));
      inventorySearchBloc.favouriteBrandScreenRepository.favouriteBrandScreenDataSource = favouriteBrandScreenDataSource;
      inventorySearchBloc.cartRepository.cartDataSource.httpService.client = mockClient;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Page Load',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(productsInCart: [Records.fromJson(dummyRecordsJson)]),
        act: (bloc) => bloc.add(PageLoad(offset: 0, name: "Joe Doe", isFirstTime: true)),
        expect: () => [
          InventorySearchState(inventorySearchStatus: InventorySearchStatus.loadState, productsInCart: [Records.fromJson(dummyRecordsJson)]),
          InventorySearchState(
            searchDetailModel: [dummySearchDetailModel],
            fetchInventoryData: true,
            productsInCart: [Records.fromJson(dummyRecordsJson)],
            inventorySearchStatus: InventorySearchStatus.successState,
            searchString: "Joe Doe",
            sortName: sortByText,
            currentPage: 1,
            haveMore: true,
            showDiscount: false,
            selectedChoice: '',
            offset: 0,
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Fetch Inventory Pagination Data',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) =>
            bloc.add(FetchInventoryPaginationData(choice: "", currentPage: 0, searchDetailModel: [dummySearchDetailModel], searchName: "Guitar")),
        expect: () => [
          InventorySearchState(paginationFetching: true, message: "done", searchDetailModel: [dummySearchDetailModel]),
          InventorySearchState(
            searchDetailModel: [dummySearchDetailModel],
            haveMore: false,
            paginationFetching: false,
            message: "done",
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Get Warranties',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(GetWarranties(skuEntId: "", records: Records(childskus: []), productId: "123")),
        expect: () => [
          InventorySearchState(isUpdating: true, updateID: "123", message: "done"),
          InventorySearchState(isUpdating: true, fetchWarranties: true, updateID: "123", message: "done"),
          InventorySearchState(
            searchDetailModel: [],
            fetchWarranties: false,
            isUpdating: false,
            updateID: "",
            warrantiesRecord: [Records(childskus: [])],
            showDialog: true,
            message: "done",
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Clear Warranties',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(ClearWarranties()),
        expect: () => [
          InventorySearchState(fetchWarranties: false, warrantiesModel: [], warrantiesRecord: []),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Change Show Dialog',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(ChangeShowDialog(true)),
        expect: () => [
          InventorySearchState(showDialog: true),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Inventory Search Fetch',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(InventorySearchFetch(
          name: "Guitar",
          choice: "",
          productsInCart: [],
          searchDetailModel: [dummySearchDetailModel],
          favoriteItems: FavoriteBrandDetailModel(),
          isFavouriteScreen: false,
          isOfferScreen: false,
        )),
        expect: () => [
          InventorySearchState(loadingSearch: true),
          InventorySearchState(
            searchDetailModel: [dummySearchDetailModel],
            loadingSearch: false,
            currentPage: 1,
            haveMore: true,
            inventorySearchStatus: InventorySearchStatus.successState,
            searchString: "Guitar",
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Change View Type',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(ChangeViewType(view: "List")),
        expect: () => [
          InventorySearchState(viewType: "List"),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Set Cart',
        build: () => inventorySearchBloc,
        seed: () => (InventorySearchState(searchDetailModel: [dummySearchDetailModel])),
        act: (bloc) => bloc.add(SetCart(itemOfCart: [], records: [
          Records(childskus: [Childskus(skuENTId: "")])
        ], orderId: "123")),
        expect: () => [
          InventorySearchState(
            orderId: "123",
            message: "done",
            itemOfCart: [],
            productsInCart: [
              Records(childskus: [Childskus(skuENTId: "")])
            ],
            searchDetailModel: [dummySearchDetailModel],
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Add To Cart',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) => bloc.add(AddToCart(
          productId: "789",
          orderItem: "",
          warranties: Warranties(id: ""),
          ifWarranties: true,
          records: Records(childskus: [Childskus(skuENTId: "", skuPrice: "")], quantity: "0", productName: ""),
          customerID: "",
          orderID: "123",
          skUid: "456",
          favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
        )),
        expect: () => [
          InventorySearchState(
            message: "",
            isUpdating: true,
            updateID: "789",
            updateSKUID: "456",
            searchDetailModel: [dummySearchDetailModel],
          ),
          InventorySearchState(
            orderId: "",
            searchDetailModel: [dummySearchDetailModel],
            isUpdating: false,
            itemOfCart: [ItemsOfCart(itemQuantity: "1.0", itemId: "", itemName: "", itemPrice: "", itemProCoverage: "0.0")],
            updateID: "",
            updateSKUID: "",
            orderLineItemId: "",
            message: "done",
            productsInCart: [
              Records(childskus: [Childskus(skuENTId: "", skuPrice: "")], quantity: "1.0", productName: "", oliRecId: "")
            ],
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Add To Cart 2',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) => bloc.add(AddToCart(
          productId: "789",
          orderItem: "",
          warranties: Warranties(id: ""),
          ifWarranties: true,
          records: Records(childskus: [Childskus(skuENTId: "", skuPrice: "")], quantity: "1", productName: "", oliRecId: "1"),
          customerID: "",
          orderID: "123",
          skUid: "456",
          favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
        )),
        expect: () => [
          InventorySearchState(
            message: "",
            isUpdating: true,
            updateID: "789",
            updateSKUID: "456",
            searchDetailModel: [dummySearchDetailModel],
          ),
          InventorySearchState(
            orderId: "",
            searchDetailModel: [dummySearchDetailModel],
            isUpdating: false,
            itemOfCart: [ItemsOfCart(itemQuantity: "2.0", itemId: "", itemName: "", itemPrice: "", itemProCoverage: "0.0")],
            updateID: "",
            updateSKUID: "",
            orderLineItemId: "",
            message: "done",
            productsInCart: [],
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Add To Cart 3',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) => bloc.add(AddToCart(
          productId: "789",
          orderItem: "",
          warranties: Warranties(id: ""),
          quantity: 1,
          ifWarranties: true,
          records: Records(childskus: [Childskus(skuENTId: "", skuPrice: "")], quantity: "2", productName: "", oliRecId: "1"),
          customerID: "",
          orderID: "123",
          skUid: "456",
          favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
        )),
        expect: () => [
          InventorySearchState(
            message: "",
            isUpdating: true,
            updateID: "789",
            updateSKUID: "456",
            searchDetailModel: [dummySearchDetailModel],
          ),
          InventorySearchState(
            orderId: "",
            searchDetailModel: [dummySearchDetailModel],
            isUpdating: false,
            itemOfCart: [ItemsOfCart(itemQuantity: "1", itemId: "", itemName: "", itemPrice: "", itemProCoverage: "0.0")],
            updateID: "",
            updateSKUID: "456",
            orderLineItemId: "",
            message: "done",
            productsInCart: [],
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Add To Cart 4',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) => bloc.add(AddToCart(
          productId: "789",
          orderItem: "",
          warranties: Warranties(id: ""),
          quantity: 1,
          ifWarranties: true,
          records: Records(childskus: [Childskus(skuENTId: "", skuPrice: "")], quantity: "0", productName: "", oliRecId: "1"),
          customerID: "",
          orderID: "123",
          skUid: "456",
          favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
        )),
        expect: () => [
          InventorySearchState(
            message: "",
            isUpdating: true,
            updateID: "789",
            updateSKUID: "456",
            searchDetailModel: [dummySearchDetailModel],
          ),
          InventorySearchState(
            orderId: "",
            searchDetailModel: [dummySearchDetailModel],
            isUpdating: false,
            itemOfCart: [ItemsOfCart(itemQuantity: "1", itemId: "", itemName: "", itemPrice: "", itemProCoverage: "0.0")],
            updateID: "",
            orderLineItemId: "",
            message: "done",
            productsInCart: [
              Records(childskus: [Childskus(skuENTId: "", skuPrice: "")], quantity: "1", productName: "", oliRecId: "")
            ],
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Update Bottom Cart',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(UpdateBottomCart(items: [])),
        expect: () => [
          InventorySearchState(productsInCart: []),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Fetch Eligibility',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) => bloc.add(FetchEligibility(index: 0)),
        expect: () => [
          InventorySearchState(searchDetailModel: [dummySearchDetailModel], message: "done"),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Update Bottom Cart With Items',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(UpdateBottomCartWithItems(items: [], records: [Records()])),
        expect: () => [
          InventorySearchState(productsInCart: [Records()]),
        ],
      );

      group(
        'Remove From Cart',
        () {
          group(
            'quantity = -1',
            () {
              blocTest<InventorySearchBloc, InventorySearchState>(
                'e.quantity = 1',
                build: () => inventorySearchBloc,
                seed: () => InventorySearchState(
                  searchDetailModel: [dummySearchDetailModel],
                  productsInCart: [
                    Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                  ],
                  itemOfCart: [
                    ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
                  ],
                ),
                act: (bloc) => bloc.add(RemoveFromCart(
                  records: Records(quantity: "1", childskus: [Childskus(skuENTId: "")], oliRecId: ""),
                  productId: "789",
                  customerID: "456",
                  orderID: "123",
                  favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
                )),
                expect: () => [
                  InventorySearchState(searchDetailModel: [dummySearchDetailModel], isUpdating: true, updateID: "789", message: ""),
                  InventorySearchState(
                    isUpdating: false,
                    searchDetailModel: [dummySearchDetailModel],
                    updateID: "",
                    message: "done",
                    itemOfCart: [],
                    productsInCart: [],
                  )
                ],
              );

              blocTest<InventorySearchBloc, InventorySearchState>(
                'e.quantity = 2',
                build: () => inventorySearchBloc,
                seed: () => InventorySearchState(
                  searchDetailModel: [dummySearchDetailModel],
                  productsInCart: [
                    Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                  ],
                  itemOfCart: [
                    ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
                  ],
                ),
                act: (bloc) => bloc.add(RemoveFromCart(
                  records: Records(quantity: "2", childskus: [Childskus(skuENTId: "")], oliRecId: ""),
                  productId: "789",
                  customerID: "456",
                  orderID: "123",
                  favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
                )),
                expect: () => [
                  InventorySearchState(
                    searchDetailModel: [dummySearchDetailModel],
                    isUpdating: true,
                    updateID: "789",
                    message: "",
                    productsInCart: [
                      Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                    ],
                    itemOfCart: [
                      ItemsOfCart(itemQuantity: "1.0", itemId: "", itemName: "", itemPrice: ""),
                    ],
                  ),
                  InventorySearchState(
                    isUpdating: false,
                    searchDetailModel: [dummySearchDetailModel],
                    updateID: "",
                    message: "done",
                    productsInCart: [
                      Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                    ],
                    itemOfCart: [
                      ItemsOfCart(itemQuantity: "1.0", itemId: "", itemName: "", itemPrice: ""),
                    ],
                  )
                ],
              );
            },
          );

          blocTest<InventorySearchBloc, InventorySearchState>(
            'quantity = -2',
            build: () => inventorySearchBloc,
            seed: () => InventorySearchState(
              searchDetailModel: [dummySearchDetailModel],
              productsInCart: [
                Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
              ],
              itemOfCart: [
                ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
              ],
            ),
            act: (bloc) => bloc.add(RemoveFromCart(
              records: Records(quantity: "1", childskus: [Childskus(skuENTId: "")], oliRecId: ""),
              productId: "789",
              customerID: "456",
              orderID: "123",
              quantity: -2,
              favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
            )),
            expect: () => [
              InventorySearchState(
                isUpdating: false,
                updateID: "",
                searchDetailModel: [dummySearchDetailModel],
                message: "Cart Cleared Successfully",
                itemOfCart: [],
                productsInCart: [],
              ),
            ],
          );

          blocTest<InventorySearchBloc, InventorySearchState>(
            'quantity = 0',
            build: () => inventorySearchBloc,
            seed: () => InventorySearchState(
              searchDetailModel: [dummySearchDetailModel],
              productsInCart: [
                Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
              ],
              itemOfCart: [
                ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
              ],
            ),
            act: (bloc) => bloc.add(RemoveFromCart(
              records: Records(quantity: "1", childskus: [Childskus(skuENTId: "")], oliRecId: ""),
              productId: "789",
              customerID: "456",
              orderID: "123",
              quantity: 0,
              favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
            )),
            expect: () => [
              InventorySearchState(
                isUpdating: true,
                updateID: "789",
                message: "",
                searchDetailModel: [dummySearchDetailModel],
              ),
              InventorySearchState(
                isUpdating: false,
                searchDetailModel: [dummySearchDetailModel],
                updateID: "",
                message: "done",
                itemOfCart: [],
                productsInCart: [],
              ),
            ],
          );

          group(
            'quantity = 1',
            () {
              blocTest<InventorySearchBloc, InventorySearchState>(
                'e.quantity = 1',
                build: () => inventorySearchBloc,
                seed: () => InventorySearchState(
                  searchDetailModel: [dummySearchDetailModel],
                  productsInCart: [
                    Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                  ],
                  itemOfCart: [
                    ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
                  ],
                ),
                act: (bloc) => bloc.add(RemoveFromCart(
                  records: Records(quantity: "1", childskus: [Childskus(skuENTId: "")], oliRecId: ""),
                  productId: "789",
                  customerID: "456",
                  orderID: "123",
                  quantity: 1,
                  favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
                )),
                expect: () => [
                  InventorySearchState(
                    isUpdating: true,
                    updateID: "789",
                    message: "",
                    searchDetailModel: [dummySearchDetailModel],
                  ),
                  InventorySearchState(
                    isUpdating: false,
                    searchDetailModel: [dummySearchDetailModel],
                    updateID: "",
                    message: "done",
                    itemOfCart: [],
                    productsInCart: [],
                  ),
                ],
              );

              blocTest<InventorySearchBloc, InventorySearchState>(
                'e.quantity = 2',
                build: () => inventorySearchBloc,
                seed: () => InventorySearchState(
                  searchDetailModel: [dummySearchDetailModel],
                  productsInCart: [
                    Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                  ],
                  itemOfCart: [
                    ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
                  ],
                ),
                act: (bloc) => bloc.add(RemoveFromCart(
                  records: Records(quantity: "2", childskus: [Childskus(skuENTId: "")], oliRecId: ""),
                  productId: "789",
                  customerID: "456",
                  orderID: "123",
                  quantity: 1,
                  favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
                )),
                expect: () => [
                  InventorySearchState(
                    isUpdating: true,
                    updateID: "789",
                    message: "",
                    searchDetailModel: [dummySearchDetailModel],
                    productsInCart: [
                      Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                    ],
                    itemOfCart: [
                      ItemsOfCart(itemQuantity: "1.0", itemId: "", itemName: "", itemPrice: ""),
                    ],
                  ),
                  InventorySearchState(
                    isUpdating: false,
                    searchDetailModel: [dummySearchDetailModel],
                    updateID: "",
                    message: "done",
                    productsInCart: [
                      Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
                    ],
                    itemOfCart: [
                      ItemsOfCart(itemQuantity: "1.0", itemId: "", itemName: "", itemPrice: ""),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Change Show Discount',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(ChangeShowDiscount(showDiscount: true)),
        expect: () => [
          InventorySearchState(showDiscount: true),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Change Selected Choice',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(
          searchDetailModel: [dummySearchDetailModel],
          options: [OptionsModel(title: "", onPressed: true)],
        ),
        act: (bloc) => bloc.add(ChangeSelectedChoice(
          choice: "",
          searchText: "",
          searchDetailModel: [dummySearchDetailModel],
          productsInCart: [],
          favoriteItems: FavoriteBrandDetailModel(),
          indexOfItem: 0,
          isFavouriteScreen: false,
          isOfferScreen: false,
        )),
        expect: () => [
          InventorySearchState(
            searchDetailModel: [dummySearchDetailModel],
            loadingSearch: true,
            showDiscount: false,
            selectedChoice: "",
            currentPage: 1,
            haveMore: true,
            sortName: sortByText,
            options: [OptionsModel(title: "", onPressed: false)],
          ),
          InventorySearchState(
            searchDetailModel: [dummySearchDetailModel..wrapperinstance?.records?.first.quantity = "0"],
            loadingSearch: false,
            currentPage: 1,
            options: [OptionsModel(title: "", onPressed: false)],
            inventorySearchStatus: InventorySearchStatus.successState,
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Change Selected Sort',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(ChangeSelectedSort(sort: sortByText)),
        expect: () => [
          InventorySearchState(selectedSort: sortByText),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Update Scale',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(UpdateScale(prevScale: 2.0, zoom: 2.0)),
        expect: () => [
          InventorySearchState(scale: 4.0),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Commit Scale',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(CommitScale(scale: 2.0)),
        expect: () => [
          InventorySearchState(prevScale: 2.0),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Update Position',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(UpdatePosition(newPosition: Offset(25.0, 20.0))),
        expect: () => [
          InventorySearchState(position: Offset(25.0, 20.0)),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Change Selected Discount',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(ChangeSelectedDiscount(discount: "25.0")),
        expect: () => [
          InventorySearchState(selectedDiscount: "25.0"),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Add Options',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(AddOptions()),
        expect: () => [
          InventorySearchState(options: [
            OptionsModel(
              title: "Best Match",
              onPressed: false,
            ),
            OptionsModel(
              title: "Top Seller",
              onPressed: false,
            ),
            OptionsModel(
              title: "Customer Ratings",
              onPressed: false,
            ),
            OptionsModel(
              title: "Price: High to Low",
              onPressed: false,
            ),
            OptionsModel(
              title: "Price: Low to High",
              onPressed: false,
            ),
            OptionsModel(
              title: "Newest First",
              onPressed: false,
            ),
            OptionsModel(
              title: "Brand A-Z",
              onPressed: false,
            ),
          ]),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Add Filters',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) => bloc.add(AddFilters(childIndex: 0, parentIndex: 0)),
        expect: () => [
          InventorySearchState(searchDetailModel: [dummySearchDetailModel], message: "done"),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'On Expand Main Tile',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(OnExpandMainTile(searchDetailModel: [dummySearchDetailModel], index: 0)),
        expect: () => [
          InventorySearchState(searchDetailModel: [dummySearchDetailModel], message: "zebon"),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Empty Message',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          InventorySearchState(message: ""),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Done Message',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(DoneMessage()),
        expect: () => [
          InventorySearchState(message: "done"),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'On Clear Filters',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(OnClearFilters(
          searchDetailModel: [dummySearchDetailModel],
          buildOnTap: false,
          isFavouriteScreen: false,
          brandName: "",
          primaryInstrument: "",
          brandItems: [],
          favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
          favoriteItems: FavoriteBrandDetailModel(),
          productsInCart: [],
        )),
        expect: () => [
          InventorySearchState(
            searchDetailModel: [dummySearchDetailModel],
            message: "Done",
            loadingSearch: false,
            currentPage: 1,
            haveMore: true,
            options: [],
            sortName: "Sort By",
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Search Product With Filters',
        build: () => inventorySearchBloc,
        act: (bloc) => bloc.add(SearchProductWithFilters(
          "",
          searchDetailModel: [dummySearchDetailModel],
          productsInCart: [],
          choice: "",
          filteredListOfRefinements: [],
          favoriteItems: FavoriteBrandDetailModel(),
          isFavouriteScreen: false,
          brandItems: [],
          brandName: "",
          primaryInstrument: "",
          isOfferScreen: false,
        )),
        expect: () => [
          InventorySearchState(loadingSearch: true, showDiscount: false),
          InventorySearchState(
            searchDetailModel: [dummySearchDetailModel],
            showDiscount: false,
            inventorySearchStatus: InventorySearchStatus.successState,
            currentPage: 1,
            haveMore: true,
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Add To Cart Failure',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(searchDetailModel: [dummySearchDetailModel]),
        act: (bloc) => bloc.add(AddToCart(
          productId: "789",
          orderItem: "",
          warranties: Warranties(id: ""),
          ifWarranties: true,
          records: Records(childskus: [Childskus(skuENTId: "", skuPrice: "")], quantity: "0", productName: ""),
          customerID: "",
          orderID: "123",
          skUid: "456",
          favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
        )),
        expect: () => [
          InventorySearchState(
            message: "",
            isUpdating: true,
            updateID: "789",
            updateSKUID: "456",
            searchDetailModel: [dummySearchDetailModel],
          ),
          InventorySearchState(
            orderId: "",
            searchDetailModel: [dummySearchDetailModel],
            isUpdating: false,
            itemOfCart: [],
            updateID: "",
            updateSKUID: "",
            orderLineItemId: "",
            message: "Cannot create order. Check your network connection!",
            productsInCart: [],
          ),
        ],
      );

      blocTest<InventorySearchBloc, InventorySearchState>(
        'Remove From Cart Failure',
        build: () => inventorySearchBloc,
        seed: () => InventorySearchState(
          searchDetailModel: [dummySearchDetailModel],
          productsInCart: [
            Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
          ],
          itemOfCart: [
            ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
          ],
        ),
        act: (bloc) => bloc.add(RemoveFromCart(
          records: Records(quantity: "1", childskus: [Childskus(skuENTId: "")], oliRecId: ""),
          productId: "789",
          customerID: "456",
          orderID: "123",
          favouriteBrandScreenBloc: MockFavouriteBrandScreenBloc(),
        )),
        expect: () => [
          InventorySearchState(
            isUpdating: true,
            searchDetailModel: [dummySearchDetailModel],
            message: "",
            updateID: "789",
            itemOfCart: [
              ItemsOfCart(itemQuantity: "", itemId: "", itemName: "", itemPrice: ""),
            ],
            productsInCart: [
              Records(quantity: "1", childskus: [Childskus()], oliRecId: ""),
            ],
          )
        ],
      );
    },
  );
}
