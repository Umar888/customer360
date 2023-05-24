import 'package:flutter/material.dart';

class SelectedEmployeeModel {
  String? name;
  String? employeeNumber;
  Attribute? attributes;
  String? id;
  String? percentage;
  List<String>? listPercentage;
  TabController tabController;


  SelectedEmployeeModel({this.percentage,this.attributes,this.employeeNumber,this.id, this.name, this.listPercentage,required this.tabController});

}
class Attribute {
  String? type;
  String? url;

  Attribute({this.type, this.url});
}