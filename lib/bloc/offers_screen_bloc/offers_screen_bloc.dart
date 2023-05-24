import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/data_sources/favourite_brand_screen_data_source/favourite_brand_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/offers_screen_repository/offers_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/models/inventory_search/add_search_model.dart'
    as asm;

import '../../models/cart_model/cart_warranties_model.dart';
import '../../models/common_models/records_class_model.dart';
import '../../services/storage/shared_preferences_service.dart';

part 'offers_screen_event.dart';
part 'offers_screen_state.dart';

class OffersScreenBloc extends Bloc<OffersScreenEvent, OfferScreenState> {
  late OffersScreenRepository offersScreenRepository;
  FavouriteBrandScreenRepository favouriteBrandScreenRepository =
      FavouriteBrandScreenRepository();

  OffersScreenBloc({required this.offersScreenRepository})
      : super(OfferScreenProgress()) {
    on<LoadData>((event, emit) async {
      emit(OfferScreenProgress());
      emit(OfferScreenSuccess(
          offersScreenModel: event.offers,
          message: "",
          product:  Records(childskus: [])));
    });

    on<EmptyMessage>((event, emit) async {
      late var previousState = state as OfferScreenSuccess;
      emit(OfferScreenSuccess(
          offersScreenModel: previousState.offersScreenModel,
          product: previousState.product,
          message: ""));
    });

    on<UpdateProduct>((event, emit) async {
      late var previousState = state as OfferScreenSuccess;
      List<Offers>? recommendationScreenModel =
          previousState.offersScreenModel!;
      recommendationScreenModel[event.index!].flashDeal!.records =
          event.records!;
      emit(OfferScreenSuccess(
          offersScreenModel: recommendationScreenModel,
          product: previousState.product,
          message: "done"));
    });

    on<InitializeProduct>((event, emit) async {
      late var previousState = state as OfferScreenSuccess;
      emit(OfferScreenSuccess(
          offersScreenModel: previousState.offersScreenModel,
          product:  Records(childskus: []),
          message: ""));
    });

    on<LoadProductDetail>((event, emit) async {
      var previousState = state as OfferScreenSuccess;
      List<Offers>? recommendationScreenModel =
          previousState.offersScreenModel!;
      recommendationScreenModel[event.index!].flashDeal!.isUpdating = true;
      emit(OfferScreenSuccess(
          offersScreenModel: recommendationScreenModel,
          message: "done",
          product:  Records(childskus: [])));
       Records product = await getProductDetail(
          recommendationScreenModel[event.index!].flashDeal!.enterpriseSkuId!);

      if (product.childskus != null && product.childskus!.isNotEmpty) {
        recommendationScreenModel[event.index!].flashDeal!.isUpdating = false;
        recommendationScreenModel[event.index!].flashDeal!.records = product;

        if (event.ifDetail!) {
          emit(OfferScreenSuccess(
              offersScreenModel: recommendationScreenModel,
              product: event.ifDetail! ? product :  Records(childskus: []),
              message: event.ifDetail! ? "done" : "Product record found"));
        } else {
          event.inventorySearchBloc.add(GetWarranties(
              records: event.state.productsInCart
                      .where((element) =>
                          element.childskus!.first.skuENTId ==
                          recommendationScreenModel[event.index!]
                              .flashDeal!
                              .enterpriseSkuId!)
                      .isNotEmpty
                  ? event.state.productsInCart.firstWhere((element) =>
                      element.childskus!.first.skuENTId ==
                      recommendationScreenModel[event.index!]
                          .flashDeal!
                          .enterpriseSkuId!)
                  : recommendationScreenModel[event.index!].flashDeal!.records!,
              productId: recommendationScreenModel[event.index!].flashDeal!.enterpriseSkuId!,
              skuEntId: product.childskus!.first.skuPIMId??""));
          emit(OfferScreenSuccess(
              offersScreenModel: recommendationScreenModel,
              product: event.ifDetail! ? product :  Records(childskus: []),
              message: event.ifDetail! ? "done" : "done"));
        }
      } else {
        recommendationScreenModel[event.index!].flashDeal!.isUpdating = false;
        emit(OfferScreenSuccess(
            offersScreenModel: recommendationScreenModel,
            message: "Product Record not found",
            product:  Records(childskus: [])));
      }
    });

    on<LoadOffers>((event, emit) async {
      LandingScreenOffersModel landingScreenOffersModel = await getOffers();

      // emit(state.copyWith(
      //   landingScreenOffersModel: landingScreenOffersModel,
      //   gettingOffers: false,
      //   message: "",
      // ));
      emit(OfferScreenSuccess(
          offersScreenModel: landingScreenOffersModel.offers,
          message:
              (landingScreenOffersModel.offers ?? []).isEmpty ? '' : 'done',
          product: null));
    });
  }

  Future<dynamic> getCompaniesOffers() async {
    final response = await OffersScreenRepository().getCompanyOffers();
    return response;
  }

  Future< Records> getProductDetail(String skuId) async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await favouriteBrandScreenRepository.getProductDetail(id, skuId);
    return response;
  }

  Future<LandingScreenOffersModel> getOffers() async {
    final response = await offersScreenRepository.getCompanyOffers();
    return response;
  }
}
