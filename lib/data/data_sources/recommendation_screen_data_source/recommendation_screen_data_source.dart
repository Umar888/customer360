import 'dart:convert';

import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class RecommendationScreenDataSource {
  final HttpService httpService = HttpService();
  Future<HttpResponse> getRecommendationScreenLists(String recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getRecommendationScreenLists(recordID),
    );
    return response;
  }

  Future<HttpResponse> getBuyItemsList(String recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getBuyItemsPageList(recordID),
    );
    return response;
  }

  Future<HttpResponse> getCartBrowseItemsList(String recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getCartBrowsePageList(recordID),
    );
    return response;
  }

  Future<HttpResponse> getCartFrequentlyBaughtItemsList(
      String recordID, String productListNumber) async {
    var response = await httpService.doGet(
      path: Endpoints.getCartFrequentlyBaughtItemsList(
          recordID, productListNumber),
    );
    return response;
  }

  Future<HttpResponse> getProductDetail(String recordID, String skuId) async {
    var response = await httpService.doPost(
        path: Endpoints.getSearchDetail(),
        body: RequestBody.getSearchDataInventory(offset: 1, name: skuId));
    return response;
  }
  Future<HttpResponse> getRecordDetail(String name) async {
    var response = await httpService.doPost(
        path: Endpoints.getSearchDetail(),
        body: RequestBody.getSearchDataInventory(
            offset: 1,
            name: name
        ));
    return response;
  }
}
