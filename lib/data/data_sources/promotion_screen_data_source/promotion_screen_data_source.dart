import 'dart:convert';

import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class PromotionsScreenDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getPromotions(String recordId) async {
    var response =
        await httpService.doGet(path: Endpoints.getPromotions(recordId));
    return response;
  }

  Future<HttpResponse> getPromotionDetail(String promotionId) async {
    var response = await httpService.doGet(
        path: Endpoints.getPromotionDetail(promotionId));
    return response;
  }

  Future<HttpResponse> getPromotionDetailService(
      String serviceCommunicationId) async {
    var response = await httpService.doGet(
        path: Endpoints.getPromotionDetailService(serviceCommunicationId),
        headers: kPurchaseChannelHeaders);
    return response;
  }
}
