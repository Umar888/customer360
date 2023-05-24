import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/data_sources/inventory_search_data_source/inventory_search_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/inventory_search_reporsitory/inventory_search_repository.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/common_models/facet.dart' as filter;
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;
import 'package:gc_customer_app/models/favorite_brands_model/favorite_brand_detail_model.dart';
import 'package:gc_customer_app/models/inventory_search/add_search_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../models/favourite_brand_screen_list.dart';

part 'favourite_brand_screen_event.dart';
part 'favourite_brand_screen_state.dart';

class FavouriteBrandScreenBloc
    extends Bloc<FavouriteBrandScreenEvent, FavouriteBrandScreenState> {
  FavouriteBrandScreenRepository favouriteBrandScreenRepository;
  InventorySearchRepository inventorySearchRepository =
      InventorySearchRepository(
          inventorySearchDataSource: InventorySearchDataSource());
  FavouriteBrandScreenBloc({required this.favouriteBrandScreenRepository})
      : super(FavouriteBrandScreenInitial()) {
    on<LoadData>((event, emit) async {
      emit(FavouriteBrandScreenProgress());
      FavoriteBrandDetailModel favoriteBrandDetailModel =
          await getRecordDetail(event.brandName!, event.primaryInstrument!);
          if (event.isFavouriteScreen) {
            favoriteBrandDetailModel.wrapperinstance!.records!.clear();
          }
      // Commented this line as it was not being used and was affecting the performance
      // List<filter.Facet> filters = await getFiltersList();
      List<dynamic> result = [];
      for (final e1 in event.brandItems!) {
        for (final e2 in favoriteBrandDetailModel.wrapperinstance!.records!) {
            if (e1.itemSkuID == e2.childskus!.first.skuENTId) {
              result.add(e2);
            }
        }
      }
      print("result length ${result.length}");
      print("favoriteBrandDetailModel.wrapperinstance!.records! length ${favoriteBrandDetailModel.wrapperinstance!.records!.length}");
      for(final e3 in result){
       favoriteBrandDetailModel.wrapperinstance!.records!.remove(e3);
      }
      emit(FavouriteBrandScreenSuccess(
        favoriteItems: favoriteBrandDetailModel,
        message: "",
        brandItems: event.brandItems,
        product: asm.Records(childskus: []),
      ));
    });

    on<EmptyMessage>((event, emit) async {
      late var previousState = state as FavouriteBrandScreenSuccess;
      emit(FavouriteBrandScreenSuccess(
          favoriteItems: previousState.favoriteItems,
          product: previousState.product,
          message: "",
          brandItems: previousState.brandItems));
    });
    on<RefreshList>((event, emit) async {
        late var previousState = state as FavouriteBrandScreenSuccess;
        emit(FavouriteBrandScreenSuccess(
            favoriteItems: previousState.favoriteItems,
            product: previousState.product,
            message: Random().nextInt(10000).toString(),
            brandItems: previousState.brandItems));
    });

    on<InitializeProduct>((event, emit) async {
      late var previousState = state as FavouriteBrandScreenSuccess;
      emit(FavouriteBrandScreenSuccess(
          favoriteItems: previousState.favoriteItems,
          product: asm.Records(childskus: []),
          message: "",
        brandItems: previousState.brandItems,
      ));
    });

    on<UpdateProduct>((event, emit) async {
      if(state is FavouriteBrandScreenSuccess) {
        late var previousState = state as FavouriteBrandScreenSuccess;
        if (event.ifNative!) {
          List<BrandItems>? recommendationScreenModel = previousState
              .brandItems!;
          recommendationScreenModel[event.index!].records = event.records!;
          emit(FavouriteBrandScreenSuccess(brandItems: recommendationScreenModel, product: previousState.product, message: "done", favoriteItems: previousState.favoriteItems));
        } else {
          FavoriteBrandDetailModel favoriteBrandDetailModel =
          previousState.favoriteItems!;
          favoriteBrandDetailModel
              .wrapperinstance!.records![event.index!].records = event.records;
          emit(FavouriteBrandScreenSuccess(
              favoriteItems: favoriteBrandDetailModel,
              product: previousState.product,
              message: "done",
              brandItems: previousState.brandItems));
        }
      }
    });

    on<SetProductWarranty>((event, emit) async {
      var previousState = state as FavouriteBrandScreenSuccess;

    });
    on<LoadProductDetail>((event, emit) async {
      var previousState = state as FavouriteBrandScreenSuccess;
      if (event.ifNative!) {
        List<BrandItems>? recommendationScreenModel = previousState.brandItems!;
        recommendationScreenModel[event.index!].isUpdating = true;
        emit(FavouriteBrandScreenSuccess(
            brandItems: recommendationScreenModel,
            favoriteItems: previousState.favoriteItems,
            message: recommendationScreenModel[event.index!].itemSkuID,
            product: asm.Records(childskus: [])));
        asm.Records product = await getProductDetail(
            recommendationScreenModel[event.index!].itemSkuID!);
        if (product.childskus != null && product.childskus!.isNotEmpty) {
          recommendationScreenModel[event.index!].records = product;
          if (event.ifDetail!) {
            recommendationScreenModel[event.index!].isUpdating = false;
            emit(FavouriteBrandScreenSuccess(
                brandItems: recommendationScreenModel,
                favoriteItems: previousState.favoriteItems,
                product: event.ifDetail! ? product : asm.Records(childskus: []),
                message: event.ifDetail! ? "done" : "Product record found"));
          }
          else {
            event.inventorySearchBloc.add(GetWarranties(
                records: event.state.productsInCart
                        .where((element) =>
                            element.childskus!.first.skuENTId ==
                            recommendationScreenModel[event.index!].itemSkuID!)
                        .isNotEmpty
                    ? event.state.productsInCart.firstWhere((element) =>
                        element.childskus!.first.skuENTId ==
                        recommendationScreenModel[event.index!].itemSkuID)
                    : recommendationScreenModel[event.index!].records!,
                skuEntId: product.childskus!.first.skuPIMId!,
                productId: event.id
            ));

            recommendationScreenModel[event.index!].isUpdating = false;

            emit(FavouriteBrandScreenSuccess(
                brandItems: recommendationScreenModel,
                favoriteItems: previousState.favoriteItems,
                product: event.ifDetail! ? product : asm.Records(childskus: []),
                message: event.ifDetail! ? "done" : "done"));
          }
        } else {
          recommendationScreenModel[event.index!].isUpdating = false;
          emit(FavouriteBrandScreenSuccess(
              brandItems: recommendationScreenModel,
              favoriteItems: previousState.favoriteItems,
              message: "Product Record not found",
              product: asm.Records(childskus: [])));
        }
      }
      else {
        FavoriteBrandDetailModel favoriteBrandDetailModel =
            previousState.favoriteItems!;
        favoriteBrandDetailModel
            .wrapperinstance!.records![event.index!].isUpdating = true;
        emit(FavouriteBrandScreenSuccess(
            brandItems: previousState.brandItems,
            favoriteItems: favoriteBrandDetailModel,
            message: favoriteBrandDetailModel
                .wrapperinstance!.records![event.index!].productId,
            product: asm.Records(childskus: [])));

        asm.Records product = await getProductDetail(favoriteBrandDetailModel
            .wrapperinstance!
            .records![event.index!]
            .childskus!
            .first
            .skuENTId!);
        if (product.childskus != null && product.childskus!.isNotEmpty) {
          favoriteBrandDetailModel.wrapperinstance!.records![event.index!].records = product;
          if (event.ifDetail!) {
            favoriteBrandDetailModel.wrapperinstance!.records![event.index!].isUpdating = false;
            emit(FavouriteBrandScreenSuccess(
                brandItems: previousState.brandItems,
                favoriteItems: favoriteBrandDetailModel,
                product: event.ifDetail! ? product : asm.Records(childskus: []),
                message: event.ifDetail! ? "done" : "Product record found"));
          }
          else {
            event.inventorySearchBloc.add(GetWarranties(
                records: event.state.productsInCart
                        .where((element) =>
                            element.childskus!.first.skuENTId ==
                            favoriteBrandDetailModel
                                .wrapperinstance!
                                .records![event.index!]
                                .childskus!
                                .first
                                .skuENTId!)
                        .isNotEmpty
                    ? event.state.productsInCart.firstWhere((element) =>
                        element.childskus!.first.skuENTId ==
                        favoriteBrandDetailModel.wrapperinstance!
                            .records![event.index!].childskus!.first.skuENTId!)
                    : favoriteBrandDetailModel
                        .wrapperinstance!.records![event.index!].records!,
                skuEntId: product.childskus!.first.skuPIMId??"",
                productId: event.id));

            favoriteBrandDetailModel.wrapperinstance!.records![event.index!].isUpdating = false;

            emit(FavouriteBrandScreenSuccess(
                brandItems: previousState.brandItems,
                favoriteItems: favoriteBrandDetailModel,
                product: event.ifDetail! ? product : asm.Records(childskus: []),
                message: event.ifDetail! ? "done" : "done"));
          }
        } else {
          favoriteBrandDetailModel
              .wrapperinstance!.records![event.index!].isUpdating = false;
          emit(FavouriteBrandScreenSuccess(
              brandItems: previousState.brandItems,
              favoriteItems: favoriteBrandDetailModel,
              message: "Product Record not found",
              product: asm.Records(childskus: [])));
        }
      }
    });
  }

  Future<FavouriteBrandScreenList> getNewArrivedItemsList() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await favouriteBrandScreenRepository.getFavrouriteItems(id);
    return response;
  }

  Future<asm.Records> getProductDetail(String skuId) async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await favouriteBrandScreenRepository.getProductDetail(id, skuId);
    return response;
  }

  Future<FavoriteBrandDetailModel> getRecordDetail(
      String brandName, String instrumentName) async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response = await favouriteBrandScreenRepository.getRecordDetail(
        id, brandName, instrumentName);
    return response;
  }

  Future<List<filter.Facet>> getFiltersList() async {
    InventorySearchRepository inventorySearchRepository =
        InventorySearchRepository(
            inventorySearchDataSource: InventorySearchDataSource());
    List<AddSearchModel> searchDetailModel = [];

    final responseJson =
        await inventorySearchRepository.fetchSearchedData('', 0);
    searchDetailModel.add(AddSearchModel.fromJson(responseJson.data));

    return searchDetailModel.first.wrapperinstance!.facet!;
  }
}
