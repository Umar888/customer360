import 'package:equatable/equatable.dart';

class LandingScreenReminders extends Equatable{
  List<AllOpenTasks>? allOpenTasks;

  LandingScreenReminders({this.allOpenTasks});

  LandingScreenReminders.fromJson(Map<String, dynamic> json) {
    if (json['AllOpenTasks'] != null) {
      allOpenTasks = <AllOpenTasks>[];
      json['AllOpenTasks'].forEach((v) {
        allOpenTasks!.add(AllOpenTasks.fromJson(v));
      });
    }
    else{
      allOpenTasks = <AllOpenTasks>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (allOpenTasks != null) {
      data['AllOpenTasks'] = allOpenTasks!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [allOpenTasks];
}

class AllOpenTasks extends Equatable{
  Attributes? attributes;
  String? id;
  String? status;
  String? subject;
  String? description;
  String? whoId;
  String? whatId;
  String? activityDate;
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
  ModifiedUserR? modifiedUserR;
  ModifiedUserR? lastModifiedBy;
  String? dateLabelC;
  String? dayLabelC;

  AllOpenTasks(
      {this.attributes,
        this.id,
        this.status,
        this.subject,
        this.description,
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
        this.dateLabelC,
        this.dayLabelC});

  AllOpenTasks.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id']??"";
    status = json['Status']??"";
    subject = json['Subject']??"";
    description = json['Description']??"";
    whoId = json['WhoId']??"";
    whatId = json['WhatId']??"";
    activityDate = json['ActivityDate']??"";
    createdDate = json['CreatedDate']??"";
    lastModifiedDate = json['LastModifiedDate']??"";
    storeTaskTypeC = json['Store_Task_Type__c']??"";
    emailC = json['Email__c']??"";
    firstNameC = json['First_Name__c']??"";
    lastNameC = json['Last_Name__c']??"";
    ownerId = json['OwnerId']??"";
    createdById = json['CreatedById']??"";
    lastModifiedById = json['LastModifiedById']??"";
    modifiedUserC = json['ModifiedUser__c']??"";
    modifiedUserR = json['ModifiedUser__r'] != null
        ? ModifiedUserR.fromJson(json['ModifiedUser__r'])
        : null;
    lastModifiedBy = json['LastModifiedBy'] != null
        ? ModifiedUserR.fromJson(json['LastModifiedBy'])
        : null;
    dateLabelC = json['Date_Label__c']??"";
    dayLabelC = json['Day_Label__c']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['Id'] = id;
    data['Status'] = status;
    data['Subject'] = subject;
    data['Description'] = description;
    data['WhoId'] = whoId;
    data['WhatId'] = whatId;
    data['ActivityDate'] = activityDate;
    data['CreatedDate'] = createdDate;
    data['LastModifiedDate'] = lastModifiedDate;
    data['Store_Task_Type__c'] = storeTaskTypeC;
    data['Email__c'] = emailC;
    data['First_Name__c'] = firstNameC;
    data['Last_Name__c'] = lastNameC;
    data['OwnerId'] = ownerId;
    data['CreatedById'] = createdById;
    data['LastModifiedById'] = lastModifiedById;
    data['ModifiedUser__c'] = modifiedUserC;
    if (modifiedUserR != null) {
      data['ModifiedUser__r'] = modifiedUserR!.toJson();
    }
    if (lastModifiedBy != null) {
      data['LastModifiedBy'] = lastModifiedBy!.toJson();
    }
    data['Date_Label__c'] = dateLabelC;
    data['Day_Label__c'] = dayLabelC;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [dayLabelC,dateLabelC,lastModifiedBy,modifiedUserR,modifiedUserC,lastModifiedById,
    createdById,ownerId,lastNameC,firstNameC,emailC,storeTaskTypeC,lastModifiedDate,
    createdDate,activityDate,whatId,whoId,description,subject,status,id,attributes];
}

class Attributes extends Equatable{
  String? type;
  String? url;

  Attributes({this.type, this.url});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type']??"";
    url = json['url']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['url'] = url;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [type,url];
}

class ModifiedUserR extends Equatable{
  Attributes? attributes;
  String? id;
  String? name;

  ModifiedUserR({this.attributes, this.id, this.name});

  ModifiedUserR.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id']??"";
    name = json['Name']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['Id'] = id;
    data['Name'] = name;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props =>[attributes,id,name];
}