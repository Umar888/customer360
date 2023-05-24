// class CommissionEmployeesModel {
//   List<EmployeeList>? employeeList;

//   CommissionEmployeesModel({this.employeeList});

//   CommissionEmployeesModel.fromJson(Map<String, dynamic> json) {
//     if (json['employeeList'] != null) {
//       employeeList = <EmployeeList>[];
//       json['employeeList'].forEach((v) {
//         employeeList!.add(EmployeeList.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (employeeList != null) {
//       data['employeeList'] = employeeList!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class EmployeeList {
//   String? id;
//   String? employeeNumber;
//   String? storeIdC;
//   String? name;

//   EmployeeList({this.id, this.employeeNumber, this.name, this.storeIdC});

//   EmployeeList.fromJson(Map<String, dynamic> json) {
//     id = json['Id'];
//     employeeNumber = json['EmployeeNumber'];
//     storeIdC = json["StoreId__c"];
//     name = json['Name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['Id'] = id;
//     data['EmployeeNumber'] = employeeNumber;
//     data['StoreId__c'] = storeIdC;
//     data['Name'] = name;
//     return data;
//   }
// }

// class Attributes {
//   String? type;
//   String? url;

//   Attributes({this.type, this.url});

//   Attributes.fromJson(Map<String, dynamic> json) {
//     type = json['type'];
//     url = json['url'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['type'] = type;
//     data['url'] = url;
//     return data;
//   }
// }
