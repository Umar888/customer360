import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class LandingScreenDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getCustomerProfile(String email) async {
    var response =
        await httpService.doGet(path: Endpoints.getCustomerInfo(email));
    return response;
  }
  Future<HttpResponse> getCustomerSearchById(String appName,String recordId, String loggedinUserId) async {
    var response = await httpService.doPost(
        path: Endpoints.getCustomerSearchPost(),
        body: RequestBody.searchById(appName: appName,
        recordId: recordId, loggedinUserId: loggedinUserId));
    return response;
  }
  Future<HttpResponse> getCustomerProfileById(String id) async {
    var response =
        await httpService.doGet(path: Endpoints.getCustomerInfoById(id));
    return response;
  }

  Future<HttpResponse> getRecommendation(String type, String id) async {
    var response =
        await httpService.doGet(path: Endpoints.getRecommendation(type, id));
    return response;
  }

  Future<HttpResponse> getReminders(String recordID, String userID) async {
    var response = await httpService.doGet(
        path: kIsWeb
            ? Endpoints.getRemindersOnWeb(recordID)
            : Endpoints.getReminders(recordID, userID));
    return response;
  }

  Future<HttpResponse> getOpenOrders(String recordID) async {
    HttpResponse response =
        await httpService.doGet(path: Endpoints.getOpenOrders(recordID));
    return response;
  }

  Future<HttpResponse> getOrderHistory(String recordID) async {
    HttpResponse response =
        await httpService.doGet(path: Endpoints.getOrderHistory(recordID,1));
    return response;
  }

  Future<HttpResponse> getOpenCases(String recordID) async {
    var response =
        await httpService.doGet(path: Endpoints.getOpenCases(recordID));
    return response;
  }

  Future<HttpResponse> getItemAvailability(
      String itemSKuID, String loggedInUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getItemAvailability(itemSKuID, loggedInUserId));
    return response;
  }

  Future<HttpResponse> getFavoriteBrands(String recordID) async {
    var response =
        await httpService.doGet(path: Endpoints.getFavoriteBrands(recordID));
    return response;
  }

  Future<HttpResponse> getTags(String recordID) async {
    var response = await httpService.doGet(path: Endpoints.getTags(recordID));
    return response;
  }

  Future<HttpResponse> getOffers() async {
    var response = await httpService.doGet(path: Endpoints.getOffers());
    return response;
  }

  Future<HttpResponse> getAssignedAgent(
      String recordID, String loggedInUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getAssignedAgent(recordID, loggedInUserId));
    return response;
  }

  Future<HttpResponse> assignAgent(String recordID, String agentId) async {
    var response = await httpService.doPost(
        path: Endpoints.assignAgent(recordID, agentId),
        body: RequestBody.getAssignAgentBody(recordID, agentId));
    return response;
  }

  Future<HttpResponse> getAgentList(
      String recordID, String loggedInUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getAssignedAgentList(recordID, loggedInUserId));
    return response;
  }

  Future<HttpResponse> getCustomerTasks(String id) async {
    var response = await httpService.doGet(
        path: Endpoints.getCustomerTasks(id),
        // body: jsonEncode(
        //     RequestBody.getMetricsAndSmartTriggersBody(myNewTeam, id)),
        tokenRequired: true);
    return response;
  }

  Future<HttpResponse> getCreditBalance(String email) async {
    var response =
        await httpService.doGet(path: Endpoints.getCreditBalance(email));
    return response;
  }
}
