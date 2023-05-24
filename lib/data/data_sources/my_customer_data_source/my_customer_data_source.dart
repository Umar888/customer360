import 'dart:convert';

import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:intl/intl.dart';

class MyCustomerDataSource {
  final HttpService httpService = HttpService();

  var dateFormat = DateFormat('yyyy-MM-dd');

  Future<HttpResponse> getAllCustomerCount(List<String> userIds) async {
    var response = await httpService.doPost(
        path: Endpoints.getAllClientsCount(),
        body: {"UserIds": userIds},
        addLoggedInUserId: false);
    return response;
  }

  Future<HttpResponse> getNewCustomerCount(
      List<String> userIds, DateTime startDate, DateTime endDate) async {
    var response = await httpService.doPost(
        path: Endpoints.getNewCustomerCount(),
        body: {
          "UserIds": userIds,
          "StartDate": dateFormat.format(startDate),
          "EndDate": dateFormat.format(endDate)
        },
        addLoggedInUserId: false);
    return response;
  }

  Future<HttpResponse> getLoggedInUserName(List<String> userIds) async {
    var response = await httpService.doPost(
        path: Endpoints.getLoggedUserName(),
        body: {"UserIds": userIds},
        addLoggedInUserId: false);
    return response;
  }

  Future<HttpResponse> getClientList(List<String> userIds, DateTime startDate,
      DateTime endDate, String filter) async {
    var response = await httpService.doPost(
        path: Endpoints.getClientList(),
        body: {
          "Filter": filter,
          "UserIds": userIds,
          "StartDate": dateFormat.format(startDate),
          "EndDate": dateFormat.format(endDate)
        },
        addLoggedInUserId: false);
    return response;
  }

  Future<HttpResponse> getPurchasedList(
      List<String> userIds, DateTime startDate, DateTime endDate, String filter,
      [bool? contacted]) async {
    var response = await httpService.doPost(
        path: Endpoints.getPurchasedList(),
        body: {
          "Filter": filter,
          "UserIds": userIds,
          "StartDate": dateFormat.format(startDate),
          "EndDate": dateFormat.format(endDate),
          "Contacted": contacted,
        },
        addLoggedInUserId: false);
    return response;
  }

  Future<HttpResponse> getContactedList(
      List<String> userIds, DateTime startDate, DateTime endDate, String filter,
      [bool? purchased]) async {
    var response = await httpService.doPost(
        path: Endpoints.getContactedList(),
        body: {
          "Filter": filter,
          "UserIds": userIds,
          "StartDate": dateFormat.format(startDate),
          "EndDate": dateFormat.format(endDate),
          "Purchased": purchased
        },
        addLoggedInUserId: false);
    return response;
  }

  Future<HttpResponse> getIsAccountManager(String userId) async {
    var response = await httpService.doPost(
        path: Endpoints.getIsAccountManager(),
        body: {"userId": userId},
        addLoggedInUserId: false);
    return response;
  }

  Future<HttpResponse> getUsersInManagerRole(String email) async {
    var response = await httpService.doPost(
        path: Endpoints.getUsersInManagerRole(),
        body: {"emailId": email},
        addLoggedInUserId: false);
    return response;
  }
}
