import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:gc_customer_app/data/reporsitories/approval_process_repository/approval_process_repository.dart';
import 'package:gc_customer_app/models/approval_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'approval_process_event.dart';
part 'approval_process_state.dart';

class ApprovalProcessBloC
    extends Bloc<ApprovalProcessEvent, ApprovalProcessState> {
  final ApprovalProcesssRepository approvalProcesssRepository;

  Future<List<ApprovalModel>> getShippingApproval() async {
    var loggedInId = await SharedPreferenceService().getValue(loggedInAgentId);
    return await approvalProcesssRepository.getApproval(loggedInId);
  }

  ApprovalProcessBloC(this.approvalProcesssRepository)
      : super(ApprovalProcessInitial()) {
    on<LoadApprovalProcess>(
      (event, emit) async {
        emit(ApprovalProcessProgress());
        await getShippingApproval().then((value) async {
          emit(ApprovalProcessSuccess(approvalModels: value));
        }).catchError((error) {
          print(error);
          emit(ApprovalProcessFailure());
        });
      },
    );

    on<ApproveApprovalProcess>(
      (event, emit) async {
        var approvalModels =
            (state as ApprovalProcessSuccess).approvalModels?.toList() ?? [];
        var approvalIndex = approvalModels.indexWhere((e) =>
            e.recordId == event.recordId &&
            (e.orderNumber == event.orderId ||
                event.unitPrice == e.unitPrice?.toString()));
        emit(ApprovalProcessProgress());

        var resp = await approvalProcesssRepository
            .approveApproval(approvalModels[approvalIndex].approveUrl ?? '');
        if (resp['approveStatus']?['isSuccess'] == true) {
          var newApprovalModels = approvalModels.toList();
          newApprovalModels.removeAt(approvalIndex);

          emit(ApprovalProcessSuccess(
              approvalModels: approvalModels,
              message: "Approved",
              itemIndex: approvalIndex));
          await Future.delayed(
            Duration(milliseconds: 500),
            () async {
              emit(ApprovalProcessSuccess(approvalModels: newApprovalModels));
              if (!Platform.environment.containsKey('FLUTTER_TEST') &&
                  await FlutterAppBadger.isAppBadgeSupported()) {
                if (approvalModels.isNotEmpty) {
                  // FlutterAppBadger.updateBadgeCount(newApprovalModels.length);
                } else {
                  FlutterAppBadger.removeBadge();
                }
              }
            },
          );
        } else {
          emit(ApprovalProcessSuccess(approvalModels: approvalModels));
        }
        // return;
      },
    );

    on<RejectApprovalProcesss>(
      (event, emit) async {
        var approvalModels =
            (state as ApprovalProcessSuccess).approvalModels?.toList() ?? [];
        var approvalIndex = approvalModels.indexWhere((e) =>
            e.recordId == event.recordId &&
            (e.orderNumber == event.orderId ||
                event.unitPrice == e.unitPrice?.toString()));
        emit(ApprovalProcessProgress());
        var resp = await approvalProcesssRepository
            .rejectApproval(approvalModels[approvalIndex].rejectUrl ?? '');
        if (resp['approveStatus']?['isSuccess'] == true) {
          var newApprovalModels = approvalModels.toList();
          newApprovalModels.removeAt(approvalIndex);
          emit(ApprovalProcessSuccess(
              approvalModels: approvalModels,
              message: "Rejected",
              itemIndex: approvalIndex));
          await Future.delayed(Duration(milliseconds: 500), () async {
            emit(ApprovalProcessSuccess(approvalModels: newApprovalModels));
            if (!Platform.environment.containsKey('FLUTTER_TEST') &&
            await FlutterAppBadger.isAppBadgeSupported()) {
              if (approvalModels.isNotEmpty) {
                // FlutterAppBadger.updateBadgeCount(newApprovalModels.length);
              } else {
                FlutterAppBadger.removeBadge();
              }
            }
          });
        } else {
          emit(ApprovalProcessSuccess(approvalModels: approvalModels));
        }
        return;
      },
    );
  }
}
