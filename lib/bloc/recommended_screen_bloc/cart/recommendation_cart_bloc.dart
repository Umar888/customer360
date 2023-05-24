import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;
import 'package:gc_customer_app/models/recommendation_Screen_model/product_cart_browse_items.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/product_cart_frequently_baught_items.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';

import '../../../data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import '../../../models/landing_screen/landing_screen_item_availability.dart';
import '../../../primitives/constants.dart';
import '../../../services/storage/shared_preferences_service.dart';

part 'recommendation_cart_event.dart';

part 'recommendation_cart_state.dart';

class RecommendationCartBloc extends Bloc<RecommendationCartEvent, RecommendationCartState> {
  RecommendationScreenRepository recommendationScreenRepository;
  LandingScreenRepository landingScreenRepository = LandingScreenRepository();

  RecommendationCartBloc({required this.recommendationScreenRepository}) : super(CartLoadInitial()) {
    on<LoadCartItems>((event, emit) async {
      emit(CartLoadProgress());
      HttpResponse response = await getCartBrowseItemModel();
      if (response.data != null && response.status == true) {
        ProductCartBrowseItemsModel productCartBrowseItemsModel = ProductCartBrowseItemsModel.fromJson(response.data);
        ProductCartFrequentlyBaughtItemsModel cartFrequentlyBoughtItemsModel =
            await getCartFrequentlyBaughtModel(productCartBrowseItemsModel.message);
        emit(LoadCartItemsSuccess(
            productCartBrowseItemsModel: productCartBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: cartFrequentlyBoughtItemsModel,
            message: "",
            product: asm.Records(childskus: [])));

        for (int i = 0; i < cartFrequentlyBoughtItemsModel.productCartOthers.length; i++) {
          for (int j = 0; j < cartFrequentlyBoughtItemsModel.productCartOthers[i].recommendedProductSet.length; j++) {
            // ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel = await getItemAvailability(cartFrequentlyBoughtItemsModel.productCartOthers[i].recommendedProductSet[j].itemSKU);
            // cartFrequentlyBoughtItemsModel.productCartOthers[i].recommendedProductSet[j].isItemOutOfStock = itemAvailabilityLandingScreenModel.outOfStock;
            // cartFrequentlyBoughtItemsModel.productCartOthers[i].recommendedProductSet[j].isItemOnline = itemAvailabilityLandingScreenModel.inStore;
          }
        }
        emit(LoadCartItemsSuccess(
            productCartBrowseItemsModel: productCartBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: cartFrequentlyBoughtItemsModel,
            message: "done",
            product: asm.Records(childskus: [])));
      } else {
        emit(CartLoadFailure());
      }
    });

    on<GetItemAvailabilityCart>((event, emit) async {
      late var previousState = state as LoadCartItemsSuccess;
      ProductCartFrequentlyBaughtItemsModel response = previousState.productCartFrequentlyBaughtItemsModel!;
      ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel =
          await getItemAvailability(response.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU);
      response.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isItemOutOfStock =
          itemAvailabilityLandingScreenModel.outOfStock;
      response.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isItemOnline =
          itemAvailabilityLandingScreenModel.inStore;
      response.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].hasInfo = true;

      emit(LoadCartItemsSuccess(
          productCartFrequentlyBaughtItemsModel: response,
          productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
          product: previousState.product,
          message: "done"));
    });

    on<EmptyMessage>((event, emit) async {
      late var previousState = state as LoadCartItemsSuccess;
      emit(LoadCartItemsSuccess(
          productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
          productCartFrequentlyBaughtItemsModel: previousState.productCartFrequentlyBaughtItemsModel,
          product: previousState.product,
          message: ""));
    });

    on<UpdateProductInCart>((event, emit) async {
      late var previousState = state as LoadCartItemsSuccess;
      ProductCartBrowseItemsModel? recommendationScreenModel = previousState.productCartBrowseItemsModel!;
      recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].records = event.records!;
      emit(LoadCartItemsSuccess(
          productCartBrowseItemsModel: recommendationScreenModel,
          productCartFrequentlyBaughtItemsModel: previousState.productCartFrequentlyBaughtItemsModel,
          product: previousState.product,
          message: "done"));
    });

    on<UpdateProductInCartOthers>((event, emit) async {
      late var previousState = state as LoadCartItemsSuccess;
      ProductCartFrequentlyBaughtItemsModel? recommendationScreenModel = previousState.productCartFrequentlyBaughtItemsModel!;
      recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records = event.records!;
      emit(LoadCartItemsSuccess(
          productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
          productCartFrequentlyBaughtItemsModel: recommendationScreenModel,
          product: previousState.product,
          message: "done"));
    });

    on<InitializeProduct>((event, emit) async {
      late var previousState = state as LoadCartItemsSuccess;
      emit(LoadCartItemsSuccess(
          productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
          productCartFrequentlyBaughtItemsModel: previousState.productCartFrequentlyBaughtItemsModel,
          product: asm.Records(childskus: []),
          message: "done"));
    });

    on<LoadProductDetailCartOthers>((event, emit) async {
      var previousState = state as LoadCartItemsSuccess;
      ProductCartFrequentlyBaughtItemsModel? recommendationScreenModel = previousState.productCartFrequentlyBaughtItemsModel!;
      recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = true;
      emit(LoadCartItemsSuccess(
          productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
          productCartFrequentlyBaughtItemsModel: recommendationScreenModel,
          product: asm.Records(childskus: []),
          message: "done"));

      asm.Records product =
          await getProductDetail(recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU);

      if (product.childskus != null && product.childskus!.isNotEmpty) {
        recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;
        recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records = product;
        if (event.ifDetail!) {
          emit(LoadCartItemsSuccess(
              productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: recommendationScreenModel,
              product: event.ifDetail! ? product : asm.Records(childskus: []),
              message: event.ifDetail! ? "done" : "Product record found, now you can add it into cart"));
        } else {
          event.inventorySearchBloc.add(GetWarranties(
              records: event.state.productsInCart
                      .where((element) =>
                          element.childskus!.first.skuENTId ==
                          recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                      .isNotEmpty
                  ? event.state.productsInCart.firstWhere((element) =>
                      element.childskus!.first.skuENTId ==
                      recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                  : recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records,
              productId: recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU,
              skuEntId: product.childskus!.first.skuPIMId ?? ""));
          emit(LoadCartItemsSuccess(
              productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
              productCartFrequentlyBaughtItemsModel: recommendationScreenModel,
              product: event.ifDetail! ? product : asm.Records(childskus: []),
              message: event.ifDetail! ? "done" : "done"));
        }
      } else {
        recommendationScreenModel.productCartOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;
        emit(LoadCartItemsSuccess(
            productCartBrowseItemsModel: previousState.productCartBrowseItemsModel,
            productCartFrequentlyBaughtItemsModel: recommendationScreenModel,
            product: asm.Records(childskus: []),
            message: "Product Record not found"));
      }
    });

    on<LoadProductDetailCart>((event, emit) async {
      var previousState = state as LoadCartItemsSuccess;
      ProductCartBrowseItemsModel? recommendationScreenModel = previousState.productCartBrowseItemsModel!;
      recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].isUpdating = true;
      emit(LoadCartItemsSuccess(
          productCartBrowseItemsModel: recommendationScreenModel,
          productCartFrequentlyBaughtItemsModel: previousState.productCartFrequentlyBaughtItemsModel,
          product: asm.Records(childskus: []),
          message: "done"));

      asm.Records product = await getProductDetail(
          recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].childskus.first.skuENTId);

      if (product.childskus != null && product.childskus!.isNotEmpty) {
        recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].isUpdating = false;
        recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].records = product;

        if (event.ifDetail!) {
          emit(LoadCartItemsSuccess(
              productCartBrowseItemsModel: recommendationScreenModel,
              productCartFrequentlyBaughtItemsModel: previousState.productCartFrequentlyBaughtItemsModel,
              product: event.ifDetail! ? product : asm.Records(childskus: []),
              message: event.ifDetail! ? "done" : "Product record found, now you can add it into cart"));
        } else {
          event.inventorySearchBloc.add(GetWarranties(
              records: event.state.productsInCart
                      .where((element) =>
                          element.childskus!.first.skuENTId ==
                          recommendationScreenModel
                              .productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].childskus.first.skuENTId)
                      .isNotEmpty
                  ? event.state.productsInCart.firstWhere((element) =>
                      element.childskus!.first.skuENTId ==
                      recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].childskus.first.skuENTId)
                  : recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].records,
              productId:
                  recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].childskus.first.skuENTId,
              skuEntId: product.childskus!.first.skuPIMId ?? ""));
          emit(LoadCartItemsSuccess(
              productCartBrowseItemsModel: recommendationScreenModel,
              productCartFrequentlyBaughtItemsModel: previousState.productCartFrequentlyBaughtItemsModel,
              product: event.ifDetail! ? product : asm.Records(childskus: []),
              message: event.ifDetail! ? "done" : "done"));
        }
      } else {
        recommendationScreenModel.productCart[event.parentIndex!].wrapperinstance.records[event.childIndex!].isUpdating = false;
        emit(LoadCartItemsSuccess(
            productCartBrowseItemsModel: recommendationScreenModel,
            productCartFrequentlyBaughtItemsModel: previousState.productCartFrequentlyBaughtItemsModel,
            product: asm.Records(childskus: []),
            message: "Product Record not found"));
      }
    });
  }

  Future<HttpResponse> getCartBrowseItemModel() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response = await recommendationScreenRepository.getCartBrowseItemsModel(id);
    return response;
  }

  Future<ProductCartFrequentlyBaughtItemsModel> getCartFrequentlyBaughtModel(String productListNumber) async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response = await recommendationScreenRepository.getCartFrequentlyBaughtModel(id, productListNumber);
    return response;
  }

  Future<asm.Records> getProductDetail(String skuId) async {
    var id = await SharedPreferenceService().getValue(agentId);
    asm.Records product = await recommendationScreenRepository.getProductDetail(id, skuId);
    print("product.productName => ${product.childskus!.length}");

    return product;
  }

  Future<asm.Records> getRecordDetail(String name) async {
    asm.Records product = await recommendationScreenRepository.getRecordDetail(name);
    print("product.productName => ${product.productId!}");
    return product;
  }

  Future<ItemAvailabilityLandingScreenModel> getItemAvailability(String itemSkuId) async {
    var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);

    final response = await landingScreenRepository.getItemAvailability(itemSkuId, loggedInUserId);
    return response;
  }
}
