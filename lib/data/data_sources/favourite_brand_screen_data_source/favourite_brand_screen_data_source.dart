import 'dart:convert';

import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class FavouriteBrandScreenDataSource {
  final HttpService httpService = HttpService();
  Future<HttpResponse> getFavouriteBrandList(String recordID) async {
    var response = await httpService.doGet(
        path: Endpoints.getFavouriteItemsList(recordID));
    return response;
  }

  Future<HttpResponse> getProductDetail(String recordID, String skuId) async {
    var response = await httpService.doPost(
        path: Endpoints.getSearchDetail(),
        body: RequestBody.getSearchDataInventory(offset: 1, name: skuId));
    return response;
  }
  Future<HttpResponse> getRecordDetail(String recordID, String brandName, String instrumentDetail) async {
    var response = await httpService.doPost(
        path: Endpoints.getSearchDetail(),
        body: RequestBody.getSearchDataInventory(offset: 1, name:instrumentDetail+" "+brandName));
    return response;
  }
}
