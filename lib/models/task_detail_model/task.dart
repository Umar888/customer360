import 'package:equatable/equatable.dart';

class TaskModel extends Equatable{
  Attributes? attributes;
  String? id;
  String? status;
  String? subject;
  String? activityDate;
  String? storeTaskTypeC;
  String? emailC;
  String? phoneC;
  String? firstNameC;
  String? description;
  String? ownerId;
  String? createdById;
  String? createdDate;
  String? lastModifiedById;
  String? lastModifiedDate;
  String? whoId;
  String? whatId;
  Owner? owner;
  Owner? createdBy;
  Owner? lastModifiedBy;
  Owner? who;
  Owner? what;

  TaskModel(
      {this.attributes,
        this.id,
        this.status,
        this.subject,
        this.activityDate,
        this.storeTaskTypeC,
        this.emailC,
        this.phoneC,
        this.firstNameC,
        this.description,
        this.ownerId,
        this.createdById,
        this.createdDate,
        this.lastModifiedById,
        this.lastModifiedDate,
        this.whoId,
        this.whatId,
        this.owner,
        this.createdBy,
        this.lastModifiedBy,
        this.who,
        this.what,});

  TaskModel.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    status = json['Status'];
    subject = json['Subject'];
    activityDate = json['ActivityDate'];
    storeTaskTypeC = json['Store_Task_Type__c'];
    emailC = json['Email__c'];
    phoneC = json['Phone__c'];
    firstNameC = json['First_Name__c'];
    description = json['Description'];
    ownerId = json['OwnerId'];
    createdById = json['CreatedById'];
    createdDate = json['CreatedDate'];
    lastModifiedById = json['LastModifiedById'];
    lastModifiedDate = json['LastModifiedDate'];
    whoId = json['WhoId'];
    whatId = json['WhatId'];
    owner = json['Owner'] != null ? new Owner.fromJson(json['Owner']) : null;
    createdBy = json['CreatedBy'] != null
        ? new Owner.fromJson(json['CreatedBy'])
        : null;
    lastModifiedBy = json['LastModifiedBy'] != null
        ? new Owner.fromJson(json['LastModifiedBy'])
        : null;
    who = json['Who'] != null ? new Owner.fromJson(json['Who']) : null;
    what = json['What'] != null ? new Owner.fromJson(json['What']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Status'] = this.status;
    data['Subject'] = this.subject;
    data['ActivityDate'] = this.activityDate;
    data['Store_Task_Type__c'] = this.storeTaskTypeC;
    data['Email__c'] = this.emailC;
    data['Phone__c'] = this.phoneC;
    data['First_Name__c'] = this.firstNameC;
    data['Description'] = this.description;
    data['OwnerId'] = this.ownerId;
    data['CreatedById'] = this.createdById;
    data['CreatedDate'] = this.createdDate;
    data['LastModifiedById'] = this.lastModifiedById;
    data['LastModifiedDate'] = this.lastModifiedDate;
    data['WhoId'] = this.whoId;
    data['WhatId'] = this.whatId;
    if (this.owner != null) {
      data['Owner'] = this.owner!.toJson();
    }
    if (this.createdBy != null) {
      data['CreatedBy'] = this.createdBy!.toJson();
    }
    if (this.lastModifiedBy != null) {
      data['LastModifiedBy'] = this.lastModifiedBy!.toJson();
    }
    if (this.who != null) {
      data['Who'] = this.who!.toJson();
    }
    if (this.what != null) {
      data['What'] = this.what!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [
    attributes,
    id,
    status,
    subject,
    activityDate,
    storeTaskTypeC,
    emailC,
    phoneC,
    firstNameC,
    description,
    ownerId,
    createdById,
    createdDate,
    lastModifiedById,
    lastModifiedDate,
    whoId,
    whatId,
    owner,
    createdBy,
    lastModifiedBy,
    who,
    what,
  ];
}

class Attributes extends Equatable{
  String? type;
  String? url;

  Attributes({this.type, this.url});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['url'] = this.url;
    return data;
  }
  @override
  List<Object?> get props => [type, url];
}

class Owner extends Equatable{
  Attributes? attributes;
  String? id;
  String? name;

  Owner({this.attributes, this.id, this.name});

  Owner.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Name'] = this.name;
    return data;
  }

  @override
  List<Object?> get props => [attributes, id, name];
}


