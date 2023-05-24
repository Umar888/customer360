import 'dart:convert';

import 'package:equatable/equatable.dart';

class LandingTaskModel extends Equatable{
  List<AggregatedTaskList>? aggregatedTaskList;

  LandingTaskModel({this.aggregatedTaskList});

  LandingTaskModel.fromJson(Map<String, dynamic> json) {
    if (json['AggregatedTaskList'] != null) {
      aggregatedTaskList = <AggregatedTaskList>[];
      json['AggregatedTaskList'].forEach((v) {
        aggregatedTaskList!.add(new AggregatedTaskList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.aggregatedTaskList != null) {
      data['AggregatedTaskList'] =
          this.aggregatedTaskList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [aggregatedTaskList];

}

class AggregatedTaskList extends Equatable{
  String? ownerName;
  String? ownerId;
  List<AllOpenTasks>? allOpenTasks;

  AggregatedTaskList({this.ownerName, this.ownerId, this.allOpenTasks});

  AggregatedTaskList.fromJson(Map<String, dynamic> json) {
    ownerName = json['OwnerName'];
    ownerId = json['OwnerId'];
    if (json['AllOpenTasks'] != null) {
      allOpenTasks = <AllOpenTasks>[];
      json['AllOpenTasks'].forEach((v) {
        allOpenTasks!.add(new AllOpenTasks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OwnerName'] = this.ownerName;
    data['OwnerId'] = this.ownerId;
    if (this.allOpenTasks != null) {
      data['AllOpenTasks'] = this.allOpenTasks!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [ownerName, ownerId, allOpenTasks];

}

class AllOpenTasks extends Equatable{
  Attributes? attributes;
  String? id;
  String? parentTaskC;
  String? status;
  String? subject;
  String? activityDate;
  String? deliveryDateC;
  String? deliveryDateTimeC;
  String? storeTaskTypeC;
  String? emailC;
  String? phoneC;
  String? firstNameC;
  String? lastNameC;
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
  String? dateLabelC;
  String? dayLabelC;

  AllOpenTasks(
      {
        this.attributes,
        this.id,
        this.parentTaskC,
        this.status,
        this.subject,
        this.activityDate,
        this.deliveryDateC,
        this.deliveryDateTimeC,
        this.storeTaskTypeC,
        this.emailC,
        this.phoneC,
        this.firstNameC,
        this.lastNameC,
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
        this.what,
        this.dateLabelC,
        this.dayLabelC,
      });

  AllOpenTasks.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    parentTaskC = json['Parent_Task__c'];
    status = json['Status'];
    subject = json['Subject'];
    activityDate = json['ActivityDate'];
    deliveryDateC = json['DeliveryDate__c'];
    deliveryDateTimeC = json['DeliveryDateTime__c'];
    storeTaskTypeC = json['Store_Task_Type__c'];
    emailC = json['Email__c'];
    phoneC = json['Phone__c'];
    firstNameC = json['First_Name__c'];
    lastNameC = json['Last_Name__c'];
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
    dateLabelC = json['Date_Label__c'];
    dayLabelC = json['Day_Label__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Parent_Task__c'] = this.parentTaskC;
    data['Status'] = this.status;
    data['Subject'] = this.subject;
    data['ActivityDate'] = this.activityDate;
    data['DeliveryDate__c'] = this.deliveryDateC;
    data['DeliveryDateTime__c'] = this.deliveryDateTimeC;
    data['Store_Task_Type__c'] = this.storeTaskTypeC;
    data['Email__c'] = this.emailC;
    data['Phone__c'] = this.phoneC;
    data['First_Name__c'] = this.firstNameC;
    data['Last_Name__c'] = this.lastNameC;
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
    data['Date_Label__c'] = this.dateLabelC;
    data['Day_Label__c'] = this.dayLabelC;
    return data;
  }
  @override
  List<Object?> get props => [
    attributes,
    id,
    parentTaskC,
    status,
    subject,
    activityDate,
    deliveryDateC,
    deliveryDateTimeC,
    storeTaskTypeC,
    emailC,
    phoneC,
    firstNameC,
    lastNameC,
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
    dateLabelC,
    dayLabelC,
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
  List<Object?> get props => [HtmlEscapeMode.attribute, id, name];

}
