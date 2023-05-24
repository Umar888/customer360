import 'package:equatable/equatable.dart';

class EmployeeMyCustomerModel extends Equatable {
  EmployeeMyCustomerModel({
    this.id,
    this.email,
    this.firstName,
    this.jobcodeC,
    this.lastName,
    this.name,
    this.storeIdC,
  });

  String? id;
  String? email;
  String? firstName;
  String? jobcodeC;
  String? lastName;
  String? name;
  String? storeIdC;

  factory EmployeeMyCustomerModel.fromJson(Map<String, dynamic> json) => EmployeeMyCustomerModel(
        id: json["Id"],
        email: json["Email"],
        firstName: json["FirstName"],
        jobcodeC: json["Jobcode__c"],
        lastName: json["LastName"],
        name: json["Name"],
        storeIdC: json["StoreId__c"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Email": email,
        "FirstName": firstName,
        "Jobcode__c": jobcodeC,
        "LastName": lastName,
        "Name": name,
        "StoreId__c": storeIdC,
      };

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        jobcodeC,
        lastName,
        name,
        storeIdC,
      ];
}
