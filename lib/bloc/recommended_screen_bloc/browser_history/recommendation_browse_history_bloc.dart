import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_item_availability.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/recommendation_screen_browse_history_model.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../../models/common_models/records_class_model.dart';
import '../../../primitives/constants.dart';

part 'recommendation_browse_history_event.dart';

part 'recommendation_browse_history_state.dart';

class RecommendationBrowseHistoryBloc extends Bloc<RecommendationScreenEvent, RecommendationBrowseHistoryState> {
  RecommendationScreenRepository recommendationScreenRepository;
  LandingScreenRepository landingScreenRepository = LandingScreenRepository();

  RecommendationBrowseHistoryBloc({required this.recommendationScreenRepository}) : super(BrowseHistoryInitial()) {
    on<LoadBrowseHistoryItems>((event, emit) async {
      emit(BrowseHistoryProgress());
      RecommendationScreenModel response = await getBrowsedHistoryResponse();
      emit(BrowseHistorySuccess(recommendationScreenModel: response, message: "", product: Records(childskus: [])));

      for (int i = 0; i < response.productBrowsingOthers.length; i++) {
        for (int j = 0; j < response.productBrowsingOthers[i].recommendedProductSet.length; j++) {}
      }

      emit(BrowseHistorySuccess(recommendationScreenModel: response, message: "done", product: Records(childskus: [])));
    });

    on<EmptyMessage>((event, emit) async {
      late var previousState = state as BrowseHistorySuccess;
      emit(BrowseHistorySuccess(recommendationScreenModel: previousState.recommendationScreenModel, product: previousState.product, message: ""));
    });

    on<GetItemAvailabilityBrowsing>((event, emit) async {
      late var previousState = state as BrowseHistorySuccess;
      RecommendationScreenModel response = previousState.recommendationScreenModel!;
      ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel =
          await getItemAvailability(response.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU);
      response.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isItemOutOfStock =
          itemAvailabilityLandingScreenModel.outOfStock;
      response.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isItemOnline =
          itemAvailabilityLandingScreenModel.inStore;
      response.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].hasInfo = true;

      emit(BrowseHistorySuccess(recommendationScreenModel: response, product: previousState.product, message: "done"));
    });

    on<UpdateProductInBrowsing>((event, emit) async {
      late var previousState = state as BrowseHistorySuccess;
      RecommendationScreenModel? recommendationScreenModel = previousState.recommendationScreenModel!;
      recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].records = event.records!;
      emit(BrowseHistorySuccess(recommendationScreenModel: recommendationScreenModel, product: previousState.product, message: "done"));
    });

    on<UpdateProductInBrowsingOthers>((event, emit) async {
      late var previousState = state as BrowseHistorySuccess;
      RecommendationScreenModel? recommendationScreenModel = previousState.recommendationScreenModel!;
      recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records = event.records!;
      emit(BrowseHistorySuccess(recommendationScreenModel: recommendationScreenModel, product: previousState.product, message: "done"));
    });

    on<InitializeProduct>((event, emit) async {
      late var previousState = state as BrowseHistorySuccess;
      emit(BrowseHistorySuccess(recommendationScreenModel: previousState.recommendationScreenModel, product: Records(childskus: []), message: ""));
    });

    on<LoadProductDetailBrowseOtherHistory>((event, emit) async {
      var previousState = state as BrowseHistorySuccess;
      RecommendationScreenModel? recommendationScreenModel = previousState.recommendationScreenModel!;
      recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = true;
      emit(BrowseHistorySuccess(recommendationScreenModel: recommendationScreenModel, message: "done", product: Records(childskus: [])));
      Records product = await getProductDetail(
          recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU);

      if (product.childskus != null && product.childskus!.isNotEmpty) {
        recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;
        recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records = product;

        if (event.ifDetail!) {
          emit(BrowseHistorySuccess(
              recommendationScreenModel: recommendationScreenModel,
              product: event.ifDetail! ? product : Records(childskus: []),
              message: event.ifDetail! ? "done" : "Product record found"));
        } else {
          event.inventorySearchBloc.add(GetWarranties(
              records: event.state.productsInCart
                      .where((element) =>
                          element.childskus!.first.skuENTId ==
                          recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                      .isNotEmpty
                  ? event.state.productsInCart.firstWhere((element) =>
                      element.childskus!.first.skuENTId ==
                      recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                  : recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].records,
              productId: recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU,
              skuEntId: product.childskus!.first.skuPIMId ?? ""));

          emit(BrowseHistorySuccess(
              recommendationScreenModel: recommendationScreenModel,
              product: event.ifDetail! ? product : Records(childskus: []),
              message: event.ifDetail! ? "done" : "done"));
        }
      } else {
        recommendationScreenModel.productBrowsingOthers[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;
        emit(BrowseHistorySuccess(
            recommendationScreenModel: recommendationScreenModel, message: "Product Record not found", product: Records(childskus: [])));
      }
    });

    on<LoadProductDetailBrowseHistory>((event, emit) async {
      var previousState = state as BrowseHistorySuccess;
      RecommendationScreenModel? recommendationScreenModel = previousState.recommendationScreenModel!;
      recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = true;
      emit(BrowseHistorySuccess(recommendationScreenModel: recommendationScreenModel, message: "done", product: Records(childskus: [])));
      Records product =
          await getProductDetail(recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU);

      if (product.childskus != null && product.childskus!.isNotEmpty) {
        recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;
        recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].records = product;

        print("event.ifDetail ${event.ifDetail}");
        if (event.ifDetail!) {
          emit(BrowseHistorySuccess(recommendationScreenModel: recommendationScreenModel, product: product, message: "done"));
        } else {
          event.inventorySearchBloc.add(GetWarranties(
              records: event.state.productsInCart
                      .where((element) =>
                          element.childskus!.first.skuENTId ==
                          recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                      .isNotEmpty
                  ? event.state.productsInCart.firstWhere((element) =>
                      element.childskus!.first.skuENTId ==
                      recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU)
                  : recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].records,
              productId: recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].itemSKU,
              skuEntId: product.childskus!.first.skuPIMId ?? ""));
          emit(BrowseHistorySuccess(recommendationScreenModel: recommendationScreenModel, product: Records(childskus: []), message: "done"));
        }
      } else {
        recommendationScreenModel.productBrowsing[event.parentIndex!].recommendedProductSet[event.childIndex!].isUpdating = false;

        emit(BrowseHistorySuccess(
            recommendationScreenModel: recommendationScreenModel, message: "Product Record not found", product: Records(childskus: [])));
      }
    });
  }

  Future<RecommendationScreenModel> getBrowsedHistoryResponse() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response = await recommendationScreenRepository.getRecommendationsList(id);
    return response;
  }

  Future<Records> getProductDetail(String skuId) async {
    var id = await SharedPreferenceService().getValue(agentId);
    Records product = await recommendationScreenRepository.getProductDetail(id, skuId);
    return product;
  }

  Future<Records> getRecordDetail(String name) async {
    Records product = await recommendationScreenRepository.getRecordDetail(name);
    return product;
  }

  Future<ItemAvailabilityLandingScreenModel> getItemAvailability(String itemSkuId) async {
    var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);

    final response = await landingScreenRepository.getItemAvailability(itemSkuId, loggedInUserId);
    return response;
  }
}
