import 'package:gc_customer_app/bloc/add_commission_bloc/search_employees_bloc/search_employees_bloc.dart';
import 'package:gc_customer_app/models/add_commission_model/create_commission_model.dart';
import 'package:gc_customer_app/models/add_commission_model/search_employee_model.dart';

import '../../../models/add_commission_model/selected_employee_json_model.dart';
import '../../data_sources/add_commission_data_source/add_commission_data_source.dart';

class AddCommissionRepository {
  AddCommissionDataSource addCommissionDataSource;
  AddCommissionRepository({required this.addCommissionDataSource});

  Future<List<SearchedEmployeeModel>> searchEmployees(
      String searchText, EmployeeSearchType type) async {
    var resp = await addCommissionDataSource.searchEmployees(searchText, type);
    if ((resp.data["searchEmployees"] ?? []).isNotEmpty) {
      return resp.data["searchEmployees"].map<SearchedEmployeeModel>((e) {
        return SearchedEmployeeModel.fromJson(e);
      }).toList();
    }
    throw Exception();
  }

  Future<dynamic> getStartCommission(String orderId, String userId) async {
    var resp =
        await addCommissionDataSource.getStartCommission(orderId, userId);
    if (resp.status == true) {
      return resp.data;
    }
    throw Exception();
  }

  // Future<dynamic> getDefaultEmployees(String orderId, String userId) async {
  //   return await addCommissionDataSource.getDefaultEmployees(orderId, userId);
  // }

  Future<dynamic> saveCommission(
      List<CommissionEmployee> selectedEmployeeJsonModel,
      String orderId) async {
    return await addCommissionDataSource.saveCommission(
        selectedEmployeeJsonModel, orderId);
  }

  Future<dynamic> getCommissionLog(String orderId, String userId) async {
    var resp = await addCommissionDataSource.getCommissionLog(orderId, userId);
    if (resp.status == true) {
      return resp.data;
    }
    throw Exception();
  }
}
