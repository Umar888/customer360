import 'dart:convert';

import 'package:gc_customer_app/models/add_commission_model/create_commission_model.dart';

class CommissionLogModel {
  CommissionLogModel({
    this.title,
    this.createdDate,
    this.createdBy,
    this.content,
    this.commissionWrapperList,
  });

  String? title;
  String? createdDate;
  String? createdBy;
  String? content;
  List<CommissionEmployee>? commissionWrapperList;

  factory CommissionLogModel.fromJson(Map<String, dynamic> json) {
    return CommissionLogModel(
      title: json["Title"],
      createdDate: json["CreatedDate"],
      createdBy: json["CreatedBy"],
      content: json["Content"],
      commissionWrapperList: List<CommissionEmployee>.from(
          json["CommissionWrapperList"]
              .map((x) => CommissionEmployee.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "Title": title,
        "CreatedDate": createdDate,
        "CreatedBy": createdBy,
        "Content": content,
        "CommissionWrapperList": List<dynamic>.from(
            commissionWrapperList?.map((x) => x.toJson()) ?? []),
      };
}
