import 'package:equatable/equatable.dart';

class CreateCommissionModel {
  double? totalCommission;
  bool? isEditable;
  List<CommissionEmployee>? commissionWrapperList;

  CreateCommissionModel(
      {this.totalCommission, this.isEditable, this.commissionWrapperList});

  CreateCommissionModel.fromJson(Map<String, dynamic> json) {
    totalCommission = (json['totalCommission'] ?? 100).toDouble();
    isEditable = json['isEditable'];
    if (json['CommissionWrapperList'] != null) {
      commissionWrapperList = <CommissionEmployee>[];
      json['CommissionWrapperList'].forEach((v) {
        commissionWrapperList!.add(CommissionEmployee.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCommission'] = totalCommission;
    data['isEditable'] = isEditable;
    if (commissionWrapperList != null) {
      data['CommissionWrapperList'] =
          commissionWrapperList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommissionEmployee extends Equatable {
  String? userId;
  bool? isEditable;
  String? employeeName;
  String? employeeId;
  String? storeId;
  double? employeeCommission;

  CommissionEmployee(
      {this.isEditable,
      this.employeeName,
      this.employeeId,
      this.storeId,
      this.userId,
      this.employeeCommission});

  CommissionEmployee.fromJson(Map<String, dynamic> json) {
    isEditable = json['isEditable'];
    employeeName = json['employeeName'];
    employeeId = json['employeeId'];
    userId = json['Id'];
    employeeCommission = json['employeeCommission'] is String
        ? double.parse(json['employeeCommission'])
        : (json['employeeCommission'] ?? 100).toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isEditable'] = isEditable;
    data['employeeName'] = employeeName;
    data['employeeId'] = employeeId;
    data['Id'] = userId;
    data['employeeCommission'] = employeeCommission;
    return data;
  }

  @override
  List<Object?> get props =>
      [employeeName, employeeId, userId, employeeCommission];
}
