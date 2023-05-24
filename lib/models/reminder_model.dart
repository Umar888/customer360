import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  ReminderModel({
    this.id,
    this.status,
    this.subject,
    this.whoId,
    this.whatId,
    this.activityDate,
    this.createdDate,
    this.lastModifiedDate,
    this.storeTaskTypeC,
    this.emailC,
    this.firstNameC,
    this.lastNameC,
    this.ownerId,
    this.createdById,
    this.lastModifiedById,
    this.modifiedUserC,
    this.modifiedUserR,
    this.lastModifiedBy,
    this.dueDate,
    this.description,
  });

  String? id;
  String? status;
  String? subject;
  String? whoId;
  String? whatId;
  DateTime? activityDate;
  String? dueDate;
  String? createdDate;
  String? lastModifiedDate;
  String? storeTaskTypeC;
  String? emailC;
  String? firstNameC;
  String? lastNameC;
  String? ownerId;
  String? createdById;
  String? lastModifiedById;
  String? modifiedUserC;
  ModifiedUser? modifiedUserR;
  ModifiedUser? lastModifiedBy;
  String? description;

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json["Id"],
        status: json["Status"],
        subject: json["Subject"],
        whoId: json["WhoId"],
        whatId: json["WhatId"],
        activityDate: DateTime.parse(json["ActivityDate"]),
        createdDate: json["CreatedDate"],
        lastModifiedDate: json["LastModifiedDate"],
        storeTaskTypeC: json["Store_Task_Type__c"],
        emailC: json["Email__c"],
        firstNameC: json["First_Name__c"],
        lastNameC: json["Last_Name__c"],
        ownerId: json["OwnerId"],
        createdById: json["CreatedById"],
        lastModifiedById: json["LastModifiedById"],
        modifiedUserC: json["ModifiedUser__c"],
        description: json["Description"],
        modifiedUserR: json["ModifiedUser__r"] == null
            ? null
            : ModifiedUser.fromJson(json["ModifiedUser__r"]),
        lastModifiedBy: json["LastModifiedBy"] == null
            ? null
            : ModifiedUser.fromJson(json["LastModifiedBy"]),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Status": status,
        "Subject": subject,
        "WhoId": whoId,
        "WhatId": whatId,
        "ActivityDate":
            "${activityDate?.year.toString().padLeft(4, '0')}-${activityDate?.month.toString().padLeft(2, '0')}-${activityDate?.day.toString().padLeft(2, '0')}",
        "CreatedDate": createdDate,
        "LastModifiedDate": lastModifiedDate,
        "Store_Task_Type__c": storeTaskTypeC,
        "Email__c": emailC,
        "First_Name__c": firstNameC,
        "Last_Name__c": lastNameC,
        "OwnerId": ownerId,
        "CreatedById": createdById,
        "LastModifiedById": lastModifiedById,
        "ModifiedUser__c": modifiedUserC,
        "Description": description,
        "ModifiedUser__r": modifiedUserR?.toJson(),
        "LastModifiedBy": lastModifiedBy?.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        status,
        subject,
        whoId,
        whatId,
        createdDate,
        lastModifiedDate,
        storeTaskTypeC,
        emailC,
        firstNameC,
        lastNameC,
        ownerId,
        createdById,
        lastModifiedBy,
        modifiedUserC,
        description
      ];
}

class Attributes {
  Attributes({
    this.type,
    this.url,
  });

  String? type;
  String? url;

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        type: json["type"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "url": url,
      };
}

class ModifiedUser {
  ModifiedUser({
    this.attributes,
    this.id,
    this.name,
  });

  Attributes? attributes;
  String? id;
  String? name;

  factory ModifiedUser.fromJson(Map<String, dynamic> json) => ModifiedUser(
        attributes: Attributes.fromJson(json["attributes"]),
        id: json["Id"],
        name: json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "attributes": attributes?.toJson(),
        "Id": id,
        "Name": name,
      };
}
