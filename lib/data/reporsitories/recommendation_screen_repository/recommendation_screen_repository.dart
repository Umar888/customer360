import 'dart:convert';
import 'dart:developer';

import 'package:gc_customer_app/data/data_sources/recommendation_screen_data_source/recommendation_screen_data_source.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/product_cart_frequently_baught_items.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'    as asm;
import 'package:gc_customer_app/models/recommendation_Screen_model/recommendation_screen_browse_history_model.dart';

class RecommendationScreenRepository {
  RecommendationScreenDataSource recommendationScreenDataSource =
      RecommendationScreenDataSource();
  Future<RecommendationScreenModel> getRecommendationsList(String recordID) async {

    var response = await recommendationScreenDataSource.getRecommendationScreenLists(recordID);
    if (response.data != null &&
        response.data["message"].toString().toLowerCase() ==
            "record found.") {
      RecommendationScreenModel landingScreenRecommendationModel =
      RecommendationScreenModel.fromJson(response.data);
      return landingScreenRecommendationModel;
    } else {
      return RecommendationScreenModel(productBrowsing: [],productBrowsingOthers: [], message: "No Record Found");
    }
  }

  Future<dynamic> getBuyItemsData(String recordID) async {
    var response =
        await recommendationScreenDataSource.getBuyItemsList(recordID);
    return response;
  }

  Future<dynamic> getCartBrowseItemsModel(String recordID) async {
    var response =
        await recommendationScreenDataSource.getCartBrowseItemsList(recordID);
    return response;
  }

  Future<dynamic> getCartFrequentlyBaughtModel(
      String recordID, String productListNumber) async {
    var response = await recommendationScreenDataSource
        .getCartFrequentlyBaughtItemsList(recordID, productListNumber);
    if (response.data != null && response.status == true) {
      ProductCartFrequentlyBaughtItemsModel
          productCartFrequentlyBaughtItemsModel =
          ProductCartFrequentlyBaughtItemsModel.fromJson(response.data);
      return productCartFrequentlyBaughtItemsModel;
    } else {}
  }

  Future<asm.Records> getProductDetail(String recordID, String skuId) async {
    var response = await recommendationScreenDataSource.getProductDetail(recordID, skuId);
    if (response.data != null && response.data['wrapperinstance'] != null && response.data['wrapperinstance']['records'] != null && (response.data['wrapperinstance']['records']).isNotEmpty) {
      return asm.Records.fromJson(
          response.data['wrapperinstance']['records'][0]);
    }
    else{
      return asm.Records(childskus: [],quantity: "-1",productId: skuId);
    }
  }
  Future<asm.Records> getRecordDetail(String name) async {
    var response = await recommendationScreenDataSource.getRecordDetail(name);
    if (response.data != null && response.data['wrapperinstance'] != null && response.data['wrapperinstance']['records'] != null && (response.data['wrapperinstance']['records']).isNotEmpty) {
      return asm.Records.fromJson(
          response.data['wrapperinstance']['records'][0]);
    }
    else{
      return asm.Records(childskus: [],quantity: "-1",productId: name);
    }
  }
}
