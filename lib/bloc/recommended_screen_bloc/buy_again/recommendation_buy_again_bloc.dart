import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_item_availability.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/buy_again_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../../data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import '../../../models/common_models/records_class_model.dart';

part 'recommendation_buy_again_event.dart';

part 'recommendation_buy_again_state.dart';

class RecommendationBuyAgainBloc extends Bloc<RecommendationBuyAgainEvent, RecommendationBuyAgainState> {
  RecommendationScreenRepository recommendationScreenRepository;
  LandingScreenRepository landingScreenRepository = LandingScreenRepository();

  RecommendationBuyAgainBloc({required this.recommendationScreenRepository}) : super(BuyAgainInitial()) {
    on<BuyAgainItems>((event, emit) async {
      emit(BuyAgainPageProgress());
      HttpResponse response = await getBuyAgainPageModel();
      if (response.data != null && response.status == true) {
        BuyAgainModel buyAgainModel = BuyAgainModel.fromJson(response.data);
        log("buyAgainModel.productBuyAgain.length ${buyAgainModel.productBuyAgain.length}");
        emit(LoadBuyAgainItemsSuccess(buyAgainModel: buyAgainModel, message: "", product: Records(childskus: [])));
        for (int i = 0; i < buyAgainModel.productBuyAgainOthers.length; i++) {
          for (int j = 0; j < buyAgainModel.productBuyAgainOthers[i].recommendedProductSet.length; j++) {
            // ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel = await getItemAvailability(buyAgainModel.productBuyAgainOthers[i].recommendedProductSet[j].itemSKU);
            // buyAgainModel.productBuyAgainOthers[i].recommendedProductSet[j].isItemOutOfStock = itemAvailabilityLandingScreenModel.outOfStock;
            // buyAgainModel.productBuyAgainOthers[i].recommendedProductSet[j].isItemOnline = itemAvailabilityLandingScreenModel.inStore;
          }
        }
        emit(LoadBuyAgainItemsSuccess(buyAgainModel: buyAgainModel, message: "done", product: Records(childskus: [])));
      } else {
        emit(BuyAgainFailure());
      }
    });

    on<GetItemAvailabilityBuyAgain>((event, emit) async {
      late var previousState = state as LoadBuyAgainItemsSuccess;
      BuyAgainModel response = previousState.buyAgainModel!;
      ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel =
          await getItemAvailability(response.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU);
      response.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isItemOutOfStock =
          itemAvailabilityLandingScreenModel.outOfStock;
      response.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isItemOnline =
          itemAvailabilityLandingScreenModel.inStore;
      response.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].hasInfo = true;

      emit(LoadBuyAgainItemsSuccess(buyAgainModel: response, product: previousState.product, message: "done"));
    });

    on<EmptyMessage>((event, emit) async {
      late var previousState = state as LoadBuyAgainItemsSuccess;
      emit(LoadBuyAgainItemsSuccess(buyAgainModel: previousState.buyAgainModel, product: previousState.product, message: ""));
    });

    on<UpdateProductInBuyAgain>((event, emit) async {
      late var previousState = state as LoadBuyAgainItemsSuccess;
      BuyAgainModel? recommendationScreenModel = previousState.buyAgainModel!;
      recommendationScreenModel.productBuyAgain[event.index!].records = event.records!;
      emit(LoadBuyAgainItemsSuccess(buyAgainModel: recommendationScreenModel, product: previousState.product, message: "done"));
    });

    on<UpdateProductInBuyAgainOthers>((event, emit) async {
      late var previousState = state as LoadBuyAgainItemsSuccess;
      BuyAgainModel? recommendationScreenModel = previousState.buyAgainModel!;
      recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records = event.records!;
      emit(LoadBuyAgainItemsSuccess(buyAgainModel: recommendationScreenModel, product: previousState.product, message: "done"));
    });

    on<InitializeProduct>((event, emit) async {
      late var previousState = state as LoadBuyAgainItemsSuccess;
      emit(LoadBuyAgainItemsSuccess(buyAgainModel: previousState.buyAgainModel, product: Records(childskus: []), message: "done"));
    });

    on<LoadProductDetailBuyAgainOther>((event, emit) async {
      late var previousState = state as LoadBuyAgainItemsSuccess;
      BuyAgainModel? recommendationScreenModel = previousState.buyAgainModel!;
      recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = true;
      emit(LoadBuyAgainItemsSuccess(buyAgainModel: recommendationScreenModel, message: "done", product: Records(childskus: [])));
      Records product = await getProductDetail(
          recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU);

      if (product.childskus != null && product.childskus!.isNotEmpty) {
        recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;
        recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records = product;

        if (event.ifDetail!) {
          emit(LoadBuyAgainItemsSuccess(
              buyAgainModel: recommendationScreenModel,
              product: event.ifDetail! ? product : Records(childskus: []),
              message: event.ifDetail! ? "done" : "Product record found, now you can add it into cart"));
        } else {
          event.inventorySearchBloc.add(GetWarranties(
              records: event.state.productsInCart
                      .where((element) =>
                          element.childskus!.first.skuENTId ==
                          recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                      .isNotEmpty
                  ? event.state.productsInCart.firstWhere((element) =>
                      element.childskus!.first.skuENTId ==
                      recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                  : recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records,
              productId: recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU,
              skuEntId: product.childskus!.first.skuPIMId ?? ""));
          emit(LoadBuyAgainItemsSuccess(
              buyAgainModel: recommendationScreenModel,
              product: event.ifDetail! ? product : Records(childskus: []),
              message: event.ifDetail! ? "done" : "done"));
        }
      } else {
        recommendationScreenModel.productBuyAgainOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;

        emit(
            LoadBuyAgainItemsSuccess(buyAgainModel: recommendationScreenModel, message: "Product Record not found", product: Records(childskus: [])));
      }
    });

    on<LoadProductDetailBuyAgain>((event, emit) async {
      late var previousState = state as LoadBuyAgainItemsSuccess;
      BuyAgainModel? recommendationScreenModel = previousState.buyAgainModel!;
      recommendationScreenModel.productBuyAgain[event.index!].isUpdating = true;
      emit(LoadBuyAgainItemsSuccess(buyAgainModel: recommendationScreenModel, message: "done", product: Records(childskus: [])));
      Records product = await getProductDetail(recommendationScreenModel.productBuyAgain[event.index!].itemSKUC);

      if (product.childskus != null && product.childskus!.isNotEmpty) {
        recommendationScreenModel.productBuyAgain[event.index!].isUpdating = false;
        recommendationScreenModel.productBuyAgain[event.index!].records = product;

        if (event.ifDetail!) {
          print("event.ifDetail! ${event.ifDetail!}");
          emit(LoadBuyAgainItemsSuccess(buyAgainModel: recommendationScreenModel, product: product, message: "done"));
        } else {
          event.inventorySearchBloc.add(GetWarranties(
              records: event.state.productsInCart
                      .where((element) => element.childskus!.first.skuENTId == recommendationScreenModel.productBuyAgain[event.index!].itemSKUC)
                      .isNotEmpty
                  ? event.state.productsInCart
                      .firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenModel.productBuyAgain[event.index!].itemSKUC)
                  : recommendationScreenModel.productBuyAgain[event.index!].records,
              productId: recommendationScreenModel.productBuyAgain[event.index!].itemSKUC,
              skuEntId: product.childskus!.first.skuPIMId ?? ""));

          emit(LoadBuyAgainItemsSuccess(
              buyAgainModel: recommendationScreenModel,
              product: event.ifDetail! ? product : Records(childskus: []),
              message: event.ifDetail! ? "done" : "done"));
        }
      } else {
        recommendationScreenModel.productBuyAgain[event.index!].isUpdating = false;

        emit(
            LoadBuyAgainItemsSuccess(buyAgainModel: recommendationScreenModel, message: "Product Record not found", product: Records(childskus: [])));
      }
    });
  }

  Future<HttpResponse> getBuyAgainPageModel() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response = await recommendationScreenRepository.getBuyItemsData(id);
    return response;
  }

  Future<Records> getProductDetail(String skuId) async {
    var id = await SharedPreferenceService().getValue(agentId);
    Records product = await recommendationScreenRepository.getProductDetail(id, skuId);
//    print("product.productName => ${product.childskus!.length}");
    return product;
  }

  Future<ItemAvailabilityLandingScreenModel> getItemAvailability(String itemSkuId) async {
    var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);

    final response = await landingScreenRepository.getItemAvailability(itemSkuId, loggedInUserId);
    return response;
  }
}
