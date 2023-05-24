import 'package:gc_customer_app/models/task_detail_model/task.dart';

class Agent {
  final String? name;
  final String? id;
  final String? storeId;
  final String? employeeId;
  final String? profileName;
  final String? storeName;
  final String? email;
  final String? phone;
  final bool isManager;
  final List<TaskModel> todayTasks;
  final List<TaskModel> pastOpenTasks;
  final List<TaskModel> futureTasks;
  final List<TaskModel> completedTasks;
  final List<TaskModel> unAssignedTasks;
  final List<TaskModel> allTasks;

  Agent({
    this.id,
    this.name,
    this.storeId,
    this.employeeId,
    this.profileName,
    this.storeName,
    this.email,
    this.phone,
    this.todayTasks = const[],
    this.pastOpenTasks =const [],
    this.futureTasks = const[],
    this.completedTasks = const[],
    this.unAssignedTasks = const[],
    this.allTasks =const [],
    this.isManager = false,
  });

  factory Agent.fromJson(Map<String, dynamic> json, {bool? isManager}) {
    return Agent(
      id: json['Id'],
      name: json['Name'],
      storeId: json['StoreId__c'],
      employeeId: json['EmployeeNumber'],
      profileName: json['Profile']?['Name'],
      storeName: json['Store_Name__c'],
      email: json['Email'],
      phone: json['MobilePhone'] ?? json['Phone'],
      isManager: isManager ?? false,
    );
  }

  factory Agent.fromTeamTaskListJson(Map<String, dynamic> json) {
    var todayTasks = <TaskModel>[];
    var pastOpenTasks = <TaskModel>[];
    var futureTasks = <TaskModel>[];
    var completedTasks = <TaskModel>[];
    var unAssignedTasks = <TaskModel>[];
    var allTasks = <TaskModel>[];

    for (var taskJson in json['TodayOpenTasks']) {
      todayTasks.add(TaskModel.fromJson(taskJson));
    }
    for (var taskJson in json['PastOpenTasks']) {
      pastOpenTasks.add(TaskModel.fromJson(taskJson));
    }
    for (var taskJson in json['FutureOpenTasks']) {
      futureTasks.add(TaskModel.fromJson(taskJson));
    }
    for (var taskJson in json['CompletedTasks']) {
      completedTasks.add(TaskModel.fromJson(taskJson));
    }
    for (var taskJson in json['UnassignedOpenTasks']) {
      unAssignedTasks.add(TaskModel.fromJson(taskJson));
    }
    for (var taskJson in json['AllOpenTasks']) {
      allTasks.add(TaskModel.fromJson(taskJson));
    }

    return Agent(
      id: json['OwnerId'],
      name: json['OwnerName'],
      todayTasks: todayTasks,
      pastOpenTasks: pastOpenTasks,
      futureTasks: futureTasks,
      completedTasks: completedTasks,
      unAssignedTasks: unAssignedTasks,
      allTasks: allTasks,
    );
  }
}
