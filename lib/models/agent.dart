import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/task.dart';

class AgentAPIReturn extends Equatable{
  Agent agent;
  bool userNotExist;
  bool userIsManager;
  String message;
  AgentAPIReturn({required this.agent, required this.userNotExist, required this.userIsManager, required this.message});

  @override
  List<Object?> get props => [agent,userNotExist,userIsManager,message];


}
class Agent extends Equatable{
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

  @override
  List<Object?> get props => [name,id,storeId,employeeId,profileName,storeName,email,phone,isManager,todayTasks,completedTasks,futureTasks,completedTasks,unAssignedTasks,allTasks,pastOpenTasks];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Name'] = name;
    data['Profile']?['Name'] = profileName;
    data['Store_Name__c'] = storeName;
    data['StoreId__c'] = storeId;
    data['EmployeeNumber'] = employeeId;
    data['Email'] = email;
    data['Phone'] = phone;
    data['isManager'] = isManager;
    return data;
  }

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

  factory Agent.fromJson(Map<String, dynamic> json, {bool? isManager, List<TaskModel>? allTasks}) {
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
      allTasks: allTasks ?? [],
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
