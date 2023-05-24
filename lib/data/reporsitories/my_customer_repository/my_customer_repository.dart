import 'dart:convert';

import 'package:gc_customer_app/data/data_sources/my_customer_data_source/my_customer_data_source.dart';
import 'package:gc_customer_app/models/my_customer/customer_model.dart';
import 'package:gc_customer_app/models/my_customer/employee_my_customer_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

class MyCustomerRepository {
  MyCustomerDataSource myCustomerDataSource = MyCustomerDataSource();

  Future<String> getAllClientsCount(List<String> userIds) async {
    var response = await myCustomerDataSource.getAllCustomerCount(userIds);
    if (response.data['Count'] != null) {
      return response.data['Count'];
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<String> getNewCustomerCount(
      List<String> userIds, DateTime startDate, DateTime endDate) async {
    var response = await myCustomerDataSource.getNewCustomerCount(
        userIds, startDate, endDate);
    if (response.data['Count'] != null) {
      return response.data['Count'];
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<String> getLoggedInUserName(List<String> userIds) async {
    var response = await myCustomerDataSource.getLoggedInUserName(userIds);
    if (response.data['Name'] != null) {
      return response.data['Name'];
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<ListClientResponse> getClientList(List<String> userIds,
      DateTime startDate, DateTime endDate, String filter) async {
    var response = await myCustomerDataSource.getClientList(
        userIds, startDate, endDate, filter);

    if (response.data != null) {
      ListClientResponse list = ListClientResponse.fromJson(response.data);
      return list;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<ListPurchasedResponse> getPurchasedList(List<String>? userIds,
      DateTime startDate, DateTime endDate, String filter,
      [bool? contacted]) async {
    if (userIds == null) {
      String recordId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      userIds = [recordId];
    }
    var response = await myCustomerDataSource.getPurchasedList(
        userIds, startDate, endDate, filter, contacted);
    if (response.data != null) {
      ListPurchasedResponse list =
          ListPurchasedResponse.fromJson(response.data);
      return list;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<ListContactedResponse> getContactedList(List<String>? userIds,
      DateTime startDate, DateTime endDate, String filter,
      [bool? purchased]) async {
    if (userIds == null) {
      String recordId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      userIds = [recordId];
    }
    var response = await myCustomerDataSource.getContactedList(
        userIds, startDate, endDate, filter, purchased);
    if (response.data != null) {
      ListContactedResponse list =
          ListContactedResponse.fromJson(response.data);
      return list;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<List<bool>> getIsAccountManager(String userId) async {
    ///Response: {
    //  "IsManager": true,
    //  "allUsers": true
    //}
    var response = await myCustomerDataSource.getIsAccountManager(userId);
    bool isManager = response.data['IsManager'] ?? false;
    bool isShowAllUsers = response.data['allUsers'] ?? false;
    return [isManager, isShowAllUsers];
  }

  Future<List<EmployeeMyCustomerModel>> getUsersInManagerRole(
      String email) async {
    var response = await myCustomerDataSource.getUsersInManagerRole(email);
    if (response.data['UserList'] != null) {
      List<EmployeeMyCustomerModel> list = response.data['UserList']
          .map<EmployeeMyCustomerModel>(
              (e) => EmployeeMyCustomerModel.fromJson(e))
          .toList();

      return list;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }
}
