import 'package:equatable/equatable.dart';

class SearchedEmployeeModel extends Equatable {
  SearchedEmployeeModel({
    this.id,
    this.name,
    this.storeIdC,
    this.employeeNumber,
  });

  String? id;
  String? name;
  String? storeIdC;
  String? employeeNumber;

  factory SearchedEmployeeModel.fromJson(Map<String, dynamic> json) =>
      SearchedEmployeeModel(
        id: json["Id"] ?? '',
        name: json["Name"] ?? '',
        storeIdC: json["StoreId__c"] ?? '',
        employeeNumber: json["EmployeeNumber"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "StoreId__c": storeIdC,
        "EmployeeNumber": employeeNumber,
      };

  @override
  List<Object?> get props => [id, name, storeIdC, employeeNumber];
}
