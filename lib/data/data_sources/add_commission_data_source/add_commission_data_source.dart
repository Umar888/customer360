import 'dart:convert';

import 'package:gc_customer_app/bloc/add_commission_bloc/search_employees_bloc/search_employees_bloc.dart';
import 'package:gc_customer_app/models/add_commission_model/create_commission_model.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';

import '../../../models/add_commission_model/selected_employee_json_model.dart';
import '../../../primitives/constants.dart';
import '../../../services/networking/endpoints.dart';
import '../../../services/networking/networking_service.dart';
import '../../../services/networking/request_body.dart';
import '../../../services/storage/shared_preferences_service.dart';

class AddCommissionDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getStartCommission(String orderId, String userId) async {
    var response = await httpService.doGet(
        path: Endpoints.getStartCommission(orderId, userId));
    return response;
  }

  Future<HttpResponse> searchEmployees(
      String searchText, EmployeeSearchType type) async {
    var response = await httpService.doGet(
        path: type == EmployeeSearchType.id
            ? Endpoints.searchEmployeesById(searchText)
            : Endpoints.searchEmployeesByName(searchText));
    return response;
  }

  Future<dynamic> saveCommission(
      List<CommissionEmployee> selectedEmployees, String orderId) async {
    var loggedInUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);

    var response = await httpService.doPost(
        path: Endpoints.saveCommission(),
        body: RequestBody.saveCommissionBody(
          employees: selectedEmployees,
          orderId: orderId,
          userId: loggedInUserId,
        ));
    return response;
  }

  Future<HttpResponse> getCommissionLog(String orderId, String userId) async {
    var response = await httpService.doGet(
        path: Endpoints.getCommissionLog(orderId, userId));
    return response;
  }
}
