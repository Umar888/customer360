import 'dart:io';

import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:gc_customer_app/data/data_sources/approval_process_data_source/approval_process_data_source.dart';
import 'package:gc_customer_app/models/approval_model.dart';

class ApprovalProcesssRepository {
  ApprovalProcesssDataSource approvalProcesssDataSource =
      ApprovalProcesssDataSource();

  Future<List<ApprovalModel>> getApproval(String loggedInId) async {
    var response = await approvalProcesssDataSource.getApproval(loggedInId);

    List<ApprovalModel> approvals = [];
    if (response.data['ShippingOverrideApprovals'] != null) {
      approvals.addAll(response.data['ShippingOverrideApprovals']
              ?.map<ApprovalModel>((pr) => ApprovalModel.fromJson(pr))
              .toList() ??
          <ApprovalModel>[]);
    }
    if (response.data['PriceOverrideApprovals'] != null) {
      approvals.addAll(response.data['PriceOverrideApprovals']
              ?.map<ApprovalModel>((pr) => ApprovalModel.fromJson(pr))
              .toList() ??
          <ApprovalModel>[]);
    }

    if (!Platform.environment.containsKey('FLUTTER_TEST') &&
        await FlutterAppBadger.isAppBadgeSupported()) {
      if (approvals.isNotEmpty) {
        // FlutterAppBadger.updateBadgeCount(approvals.length);
      } else {
        FlutterAppBadger.removeBadge();
      }
    }

    return approvals;
  }

  Future approveApproval(String approveURL) async {
    var response = await approvalProcesssDataSource.approveApproval(approveURL);
    if (response.data != null) {
      return response.data;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future rejectApproval(String rejectURL) async {
    var response = await approvalProcesssDataSource.rejectApproval(rejectURL);
    if (response.data != null) {
      return response.data;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }
}
