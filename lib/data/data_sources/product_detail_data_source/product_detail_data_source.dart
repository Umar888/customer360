import 'dart:convert';

import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import '../../../models/inventory_search/add_search_model.dart';

class ProductDetailDataSource {
  final HttpService httpService = HttpService();

  Future<dynamic> getAddresses(String skuENTId) async {
    var response = await httpService.doGet(
        path: "${Endpoints.getInventoryDetail(skuENTId)}");
    return response;
  }

  Future<WarrantiesModel> getWarranties(String skuEntId) async {
    var response =
        await httpService.doGet(path: Endpoints.getWarranties(skuEntId));
    if (response != null &&
        response.data != null &&
        response.data["Warranties"] != null &&
        response.data["Warranties"].isNotEmpty) {
      return WarrantiesModel.fromJson(response.data);
    } else {
      return WarrantiesModel(warranties: []);
    }
  }

  Future<HttpResponse> getProductDetail(String recordID, String skuId) async {
    var response = await httpService.doPost(
        path: Endpoints.getSearchDetail(),
        body: RequestBody.getSearchDataInventory(offset: 1, name: skuId));
    return response;
  }

  Future<HttpResponse> getBundles(String skuId) async {
    String userRecordId = await SharedPreferenceService().getValue(agentId);

    var response = await httpService.doGet(
        path: Endpoints.getProductBundles(skuId, userRecordId));
    return response;
  }

  Future<HttpResponse> getItemEligibility(
      String itemSKuID, String loggedInUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getItemEligibility(itemSKuID, loggedInUserId));
    return response;
  }

  Future<dynamic> addToCartAndCreateOrder(
      Records records, String customerID, String orderID) async {
    var response = await httpService.doPost(
        path: Endpoints.addToCartAndCreateOrder(),
        body: RequestBody.getAddToCartAndCreateOrder(
            records: records, orderId: orderID, customerID: customerID),
        tokenRequired: true);
    return response;
  }

  Future<dynamic> updateCartAdd(
      Records records, String customerID, String orderID, int quantity) async {
    var response = await httpService.doPatch(
        path: Endpoints.updateCartAndCreateOrder() + records.oliRecId!,
        body: json.encode(RequestBody.getUpdateCartAdd(quantity: quantity)),
        tokenRequired: true);
    return response;
  }

  Future<dynamic> updateCartDelete(
      Records records, String customerID, String orderID, int quantity) async {
    var response = await httpService.doPatch(
        path: Endpoints.updateCartAndCreateOrder() + records.oliRecId!,
        body: json.encode(RequestBody.getUpdateCartDeleted()),
        tokenRequired: true);
    return response;
  }

  Future<dynamic> selectInventoryReason(String orderId, String nodeId,
      int stockLevel, String sourcingReason) async {
    var response = await httpService.doPost(
        path: Endpoints.selectInventoryUpdateReason(),
        body: {
          "nodeId": nodeId,
          "nodeStock": stockLevel,
          "sourcingReason": sourcingReason,
          "oliRecId": orderId,
        },
        tokenRequired: true);
    return response;
  }
}
