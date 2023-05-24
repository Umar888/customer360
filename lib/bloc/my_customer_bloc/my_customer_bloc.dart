import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/data/reporsitories/my_customer_repository/my_customer_repository.dart';
import 'package:gc_customer_app/models/my_customer/customer_model.dart';
import 'package:gc_customer_app/models/my_customer/employee_my_customer_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'my_customer_event.dart';
part 'my_customer_state.dart';

class MyCustomerBloC extends Bloc<MyCustomerEvent, MyCustomerState> {
  final MyCustomerRepository myCustomerRepo;
  String selectedEmployeeId = '';
  List<String> recordIds = [];

  MyCustomerBloC(this.myCustomerRepo) : super(MyCustomerState()) {
    on<LoadMyCustomerInformation>(
      (event, emit) async {
        String recordId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        emit(state.copyWith(isLoading: true, loggedInUserId: recordId));
        var resp = await myCustomerRepo.getIsAccountManager(recordId);
        bool isManager = resp.first;
        bool isShowAll = resp.last;
        emit(state.copyWith(isManager: isManager, isShowAllUsers: isShowAll));

        List<EmployeeMyCustomerModel>? employees;
        if (isManager) {
          String loggedEmail =
              await SharedPreferenceService().getValue(loggedInUserEmail);
          await myCustomerRepo.getUsersInManagerRole(loggedEmail).then((value) {
            employees = value;
            emit(state.copyWith(employees: value));
          });
        }
        if ((employees ?? []).isNotEmpty) {
          recordIds = isShowAll
              ? employees!.map<String>((e) => e.id ?? '').toList()
              : [recordId];
        }

        await myCustomerRepo.getLoggedInUserName([recordId]).then(
            (value) => emit(state.copyWith(loggedInUserName: value)));
        await myCustomerRepo
            .getAllClientsCount(recordIds)
            .then((value) => emit(state.copyWith(allCount: value)));
        await myCustomerRepo
            .getNewCustomerCount(recordIds, event.startDate, event.endDate)
            .then((value) => emit(state.copyWith(newCount: value)));
        await myCustomerRepo
            .getClientList(
                recordIds, event.startDate, event.endDate, event.filter)
            .then((value) => emit(state.copyWith(
                  clients: value.clients ?? [],
                  high: value.highCount,
                  medium: value.mediumCount,
                  low: value.lowCount,
                )));

        await myCustomerRepo
            .getContactedList(
                recordIds, event.startDate, event.endDate, event.filter)
            .then((value) => emit(state.copyWith(
                  contacteds: value.contacteds,
                  contactedCount: value.contactedCount,
                  notContactedCount: value.notContactedCount,
                )));

        await myCustomerRepo
            .getPurchasedList(
                recordIds, event.startDate, event.endDate, event.filter)
            .then((value) => emit(state.copyWith(
                  purchaseds: value.purchaseds,
                  purchasedCount: value.purchasedCount,
                  notPurchasedCount: value.notPurchasedCount,
                )))
            .catchError((_) {
          emit(state.copyWith(isLoading: false));
        });
        emit(state.copyWith(isLoading: false));

        // if ((recordId).isNotEmpty) {
        //   var promotions =
        //       await myCustomerRepo.getPromotions(recordId).catchError((_) {
        //     emit(PromotionScreenFailure());
        //   });
        //   var activePros = promotions.last;
        //   emit(PromotionScreenSuccess(
        //       topPromotion: promotions.first, activePromotions: activePros));

        //   return;
        // }

        // emit(PromotionScreenFailure());
        // return;
      },
    );

    on<LoadEmployeeInformation>(
      (event, emit) async {
        String recordId = event.employeeId;
        selectedEmployeeId = recordId;
        recordIds = [recordId];
        emit(state.copyWith(isLoading: true));
        await myCustomerRepo
            .getAllClientsCount(recordIds)
            .then((value) => emit(state.copyWith(allCount: value)));
        await myCustomerRepo
            .getNewCustomerCount(recordIds, event.startDate, event.endDate)
            .then((value) => emit(state.copyWith(newCount: value)));
        await myCustomerRepo
            .getClientList(
                recordIds, event.startDate, event.endDate, event.filter)
            .then((value) => emit(state.copyWith(
                  clients: value.clients ?? [],
                  high: value.highCount,
                  medium: value.mediumCount,
                  low: value.lowCount,
                )));

        await myCustomerRepo
            .getContactedList(
                recordIds, event.startDate, event.endDate, event.filter)
            .then((value) => emit(state.copyWith(
                  contacteds: value.contacteds,
                  contactedCount: value.contactedCount,
                  notContactedCount: value.notContactedCount,
                )));

        await myCustomerRepo
            .getPurchasedList(
                recordIds, event.startDate, event.endDate, event.filter)
            .then((value) => emit(state.copyWith(
                  purchaseds: value.purchaseds,
                  purchasedCount: value.purchasedCount,
                  notPurchasedCount: value.notPurchasedCount,
                )))
            .catchError((_) {
          emit(state.copyWith(isLoading: false));
        });
        emit(state.copyWith(isLoading: false));
      },
    );
  }
}
