import 'package:collection/collection.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/models/add_commission_model/commission_log_model.dart';
import 'package:gc_customer_app/models/add_commission_model/search_employee_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../data/reporsitories/add_commission_repository/add_commission_repository.dart';
import '../../models/add_commission_model/commissions_employee_model.dart';
import '../../models/add_commission_model/create_commission_model.dart';
import '../../models/add_commission_model/selected_employee_json_model.dart';
import '../../models/add_commission_model/selected_employee_model.dart';

part 'add_commission_state.dart';
part 'add_commission_event.dart';

class AddCommissionBloc extends Bloc<AddCommissionEvent, AddCommissionState> {
  AddCommissionRepository addCommissionRepository;

  String storeId = '';

  Future<List<CommissionLogModel>> getCommissionLog(String orderId) async {
    var userId = await SharedPreferenceService().getValue(loggedInAgentId);
    var response =
        await addCommissionRepository.getCommissionLog(orderId, userId);
    if ((response["notesList"] ?? []).isEmpty) return <CommissionLogModel>[];
    var logs = response["notesList"]
        .map<CommissionLogModel>((e) => CommissionLogModel.fromJson(e))
        .toList();
    return logs;
  }

  AddCommissionBloc({required this.addCommissionRepository})
      : super(AddCommissionState()) {
    on<PageLoad>((event, emit) async {
      emit(state.copyWith(
        addCommissionStatus: AddCommissionStatus.loadState,
      ));
      try {
        var userId = await SharedPreferenceService().getValue(loggedInAgentId);
        var response = await addCommissionRepository.getStartCommission(
            event.orderId, userId);
        CreateCommissionModel selectedEmployees =
            CreateCommissionModel.fromJson(response["CommissionList"]);
        List<SearchedEmployeeModel> sameStoreEmployees = [];
        if ((response["storeEmployees"] ?? []).isNotEmpty) {
          sameStoreEmployees = response["storeEmployees"]
              .map<SearchedEmployeeModel>(
                  (e) => SearchedEmployeeModel.fromJson(e))
              .toList();
          storeId = sameStoreEmployees.first.storeIdC ?? '0';
        }

        // employeesDetailModel
        //     .add(CommissionEmployeesModel.fromJson(response.data));
        emit(state.copyWith(
            addCommissionStatus: AddCommissionStatus.successState,
            listSelectedEmployees: selectedEmployees.commissionWrapperList,
            listEmployeesSameStore: sameStoreEmployees,
            currentPercentage:
                selectedEmployees.totalCommission?.toDouble() ?? 100.0));
      } catch (e) {
        emit(state.copyWith(
            addCommissionStatus: AddCommissionStatus.failedState));
      }
    });

    on<SaveCommission>((event, emit) async {
      emit(state.copyWith(showSubmissionLoading: true));

      // List<SelectedEmployeeJsonModel> selectedEmployeeModel = [];

      // for (CommissionEmployee s in state.listSelectedEmployees) {
      //   selectedEmployeeModel.add(SelectedEmployeeJsonModel(
      //       name: s.employeeName,
      //       employeeNumber: s.employeeId,
      //       commission: (s.employeeCommission ?? 100).toString(),
      //       isEditable: true));
      // }

      //  log(jsonEncode(selectedEmployeeModel));

      try {
        var response = await addCommissionRepository.saveCommission(
            event.selectedEmployeesModel, event.orderID);
        CreateCommissionModel createCommissionModel =
            CreateCommissionModel.fromJson(response.data);
        if (createCommissionModel.totalCommission != null) {
          showMessage(context: event.context,message:"Commission request submitted successfully");
        } else {
          showMessage(context: event.context,message:"Failed to submit commission request");
        }
        emit(state.copyWith(showSubmissionLoading: false));
      } catch (e) {
        showMessage(context: event.context,message:"Failed to submit commission request");
        emit(state.copyWith(showSubmissionLoading: false));
      }
    });

    on<ListSelectedEmployeesSet>((event, emit) {
      emit(state.copyWith(
          listSelectedEmployees: event.selectedEmployeeModel
              .map<CommissionEmployee>((e) => CommissionEmployee(
                  employeeCommission:
                      double.parse(e.percentage?.replaceAll('%', '') ?? '0'),
                  employeeId: e.employeeNumber,
                  employeeName: e.name,
                  isEditable: true))
              .toList()));
    });

    on<ListSelectedEmployeesRemove>((event, emit) {
      List<CommissionEmployee> listSelectedEmployees =
          state.listSelectedEmployees.toList();
      listSelectedEmployees.removeWhere(
        (e) => e.employeeId == event.selectedEmployeeModel.employeeId,
      );
      if (event.selectedEmployeeModel.storeId == storeId) {
        state.listEmployeesSameStore.add(SearchedEmployeeModel(
          employeeNumber: event.selectedEmployeeModel.employeeId ?? '',
          id: event.selectedEmployeeModel.userId ?? '',
          name: event.selectedEmployeeModel.employeeName ?? '',
          storeIdC: event.selectedEmployeeModel.storeId ?? '',
        ));
        state.listEmployeesSameStore
            .sort((a, b) => (a.id ?? '0').compareTo(b.id ?? '0'));
      }
      emit(state.copyWith(
          listSelectedEmployees: listSelectedEmployees,
          listEmployeesSameStore: state.listEmployeesSameStore));
    });

    // on<EmployeesDetailModelRemove>((event, emit) {
    //   List<CommissionEmployeesModel> employeesDetailModel =
    //       state.employeesDetailModel;
    //   employeesDetailModel[0].employeeList!.remove(event.employeeList);
    //   emit(state.copyWith(employeesDetailModel: employeesDetailModel));
    // });

    on<SelectedEmployeeJsonModelClear>((event, emit) {
      emit(state.copyWith(selectedEmployeeJsonModel: []));
    });

    on<SelectedEmployeeJsonModelAdd>((event, emit) {
      SelectedEmployeeJsonModel selectedEmployeeJsonModel =
          SelectedEmployeeJsonModel(
        name: event.selectedEmployeeModel.name,
        employeeNumber: event.selectedEmployeeModel.employeeNumber,
        commission: event.selectedEmployeeModel.percentage!
            .substring(0, event.selectedEmployeeModel.percentage!.length - 1),
        isEditable: true,
      );
      emit(state.copyWith(selectedEmployeeJsonModel: [
        ...state.selectedEmployeeJsonModel,
        selectedEmployeeJsonModel
      ]));
    });

    on<ListSelectedEmployeesAdd>((event, emit) {
      double totalCommission = 0;

      state.listSelectedEmployees.forEach((e) {
        totalCommission += (e.employeeCommission ?? 0);
      });

      CommissionEmployee selectedEmployeeModel = CommissionEmployee(
          employeeCommission: 100 - totalCommission,
          employeeId: event.employee.employeeNumber ?? event.employee.id,
          employeeName: event.employee.name,
          userId: event.employee.id,
          isEditable: false,
          storeId: event.employee.storeIdC);

      state.listEmployeesSameStore.removeWhere(
        (element) => element.employeeNumber == event.employee.employeeNumber,
      );

      emit(state.copyWith(
        listSelectedEmployees: [
          ...state.listSelectedEmployees,
          selectedEmployeeModel
        ],
        listEmployeesSameStore: state.listEmployeesSameStore,
      ));
    });

    on<DivideSelectedEmployeeCommission>((event, emit) {
      List<CommissionEmployee> listSelectedEmployees =
          state.listSelectedEmployees.toList();

      listSelectedEmployees.forEach((em) {
        em.employeeCommission =
            (100 / listSelectedEmployees.length).floor().toDouble();
      });

      var listCommission = listSelectedEmployees
          .map<double>((e) => e.employeeCommission ?? 0)
          .toList();

      if (listCommission.sum < 100) {
        listSelectedEmployees[0].employeeCommission =
            (listSelectedEmployees[0].employeeCommission ?? 0) + 1;
      }

      emit(state.copyWith(
          listSelectedEmployees: listSelectedEmployees,
          needRebuild: !state.needRebuild));
    });
  }
}
