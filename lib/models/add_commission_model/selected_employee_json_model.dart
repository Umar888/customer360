import 'package:flutter/material.dart';

class SelectedEmployeeJsonModel {
  String? name;
  String? employeeNumber;
  String? commission;
  bool?  isEditable;


  SelectedEmployeeJsonModel({this.name,this.commission,this.isEditable,this.employeeNumber});

  Map<String, dynamic> toJson() => {
    'employeeCommission' : commission,
    'employeeId' : employeeNumber,
    'employeeName' : name,
    'isEditable' : isEditable,
  };

}