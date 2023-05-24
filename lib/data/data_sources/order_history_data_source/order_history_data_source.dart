import 'dart:convert';
import 'dart:io';

import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class OrderHistoryDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getCustomerOrderInfo(String recordId) async {
    var response =
        await httpService.doGet(path: Endpoints.getCustomerOrderInfo(recordId));
    return response;
  }

  // Future<HttpResponse> getOrderAccessories(String recordId) async {
  //   var response =
  //       await httpService.doGet(path: Endpoints.getOrderAccessories(recordId));
  //   return response;
  // }

  Future<HttpResponse> getOpenOrders(String recordID) async {
    HttpResponse response =
        await httpService.doGet(path: Endpoints.getOpenOrders(recordID));
    return response;
  }

  Future<HttpResponse> getOrderHistory(String recordID, int page) async {
    HttpResponse response = await httpService.doGet(
        path: Endpoints.getOrderHistory(recordID, page));
    return response;
  }
}
