import 'dart:convert';
import 'dart:developer';

import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class OrderPrinterDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getPrinterTypes() async {
    var response = await httpService.doGet(path: Endpoints.getPrinterTypes());
    return response;
  }

  Future<HttpResponse> getOrderPrinters(String loggedInId) async {
    var response =
        await httpService.doGet(path: Endpoints.getPrinters(loggedInId));
    return response;
  }

  Future<HttpResponse> printOrder(String recordId, String printerValue) async {
    var response = await httpService.doPost(
        path: Endpoints.printOrder(),
        body: {"printerValue": printerValue, "recordId": recordId});
    return response;
  }

  Future<HttpResponse> fetchStoreAddress(String loggedInId) async {
    var response = await httpService.doGet(
        path: Endpoints.fetchStoreAddress(loggedInId));
    return response;
  }
  Future<HttpResponse> printLoggingCall(String printerName, String data) async{
    var response = await httpService.doPost(
        path: Endpoints.printLoggingAPI(),
        body: RequestBody.getPrintLoggingBody(printerName: printerName, printData: data));
    return response;
  }
}
