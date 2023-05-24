import 'package:equatable/equatable.dart';

class TaskModel extends Equatable{
  final String? id;
  String? status;
  final String? subject;
  final String? taskType;
  final String? taskDate;
  final String? phone;
  final String? email;
  final String? contactName;
  final String? lastModifiedDate;
  final String? modifiedBy;
  final String? assignedTo;
  final String? assignedToId;
  final String? modifiedById;
  final String? whoId;
  final String? whatId;
  final String? firstName;
  final String? lastName;
  String? description;
  final String? dateLabel;
  final String? whoName;
  String? dueDate;
  String? dayLabel;


  @override
  List<Object?> get props => [id,status,subject,taskType,taskDate,phone,email,contactName,
  lastModifiedDate,modifiedBy,modifiedById,assignedTo,assignedToId,whatId,whoId,firstName,lastName,
  description,dayLabel,whoName,dueDate,dayLabel];


  TaskModel({
    this.id,
    this.status,
    this.subject,
    this.taskType,
    this.taskDate,
    this.phone,
    this.email,
    this.contactName,
    this.lastModifiedDate,
    this.modifiedBy,
    this.assignedTo,
    this.description,
    this.assignedToId,
    this.modifiedById,
    this.whoId,
    this.whatId,
    this.firstName,
    this.lastName,
    this.dateLabel,
    this.whoName,
    this.dueDate,
    this.dayLabel,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['Id'],
      status: json['Status'],
      subject: json['Subject'],
      taskDate: json['ActivityDate'],
      taskType: json['Store_Task_Types__c'] != null &&
              json['Store_Task_Types__c'] != ''
          ? json['Store_Task_Types__c']
          : json['Store_Task_Type__c'],
      phone: json['Phone__c'],
      email: json['Email__c'],
      contactName: json['Contact_Name__c'] ?? json['Who']?['Name'],
      lastModifiedDate: json['LastModifiedDate'],
      modifiedBy: json['LastModifiedBy']?['Name'],
      assignedTo: json['Owner']?['Name'],
      description: json['Description'],
      assignedToId: json['OwnerId'],
      modifiedById: json['LastModifiedBy']?['Id'],
      whoId: json['WhoId'],
      whatId: json['WhatId'],
      firstName: json['First_Name__c'],
      lastName: json['Last_Name__c'],
      dateLabel: json['Date_Label__c'],
      dayLabel: json['Day_Label__c'],
    );
  }
}
