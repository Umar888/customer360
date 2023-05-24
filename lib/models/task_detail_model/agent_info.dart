class AgentInfo {
  List<AgentTaskCountList>? agentTaskCountList;
  AgentInfo({this.agentTaskCountList});

  AgentInfo.fromJson(dynamic json) {
    if (json['AgentTaskCountList'] != null) {
      agentTaskCountList = <AgentTaskCountList>[];
      json['AgentTaskCountList'].forEach((v) {
        agentTaskCountList!.add(AgentTaskCountList.fromJson(v));
      });
    }
  }
}

class AgentTaskCountList {
  User? user;
  int? unassignedOpenTasks;
  int? todayOpenTasks;
  int? pastOpenTasks;
  int? futureOpenTasks;
  bool? isLoading;
  int? completedTasks;
  int? allOpenTasks;

  AgentTaskCountList(
      {this.user,
      this.unassignedOpenTasks,
      this.todayOpenTasks,
      this.isLoading,
      this.pastOpenTasks,
      this.futureOpenTasks,
      this.completedTasks,
      this.allOpenTasks});

  AgentTaskCountList.fromJson(dynamic json) {
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    unassignedOpenTasks = json['UnassignedOpenTasks'];
    todayOpenTasks = json['TodayOpenTasks'];
    pastOpenTasks = json['PastOpenTasks'];
    futureOpenTasks = json['FutureOpenTasks'];
    completedTasks = json['CompletedTasks'];
    allOpenTasks = json['AllOpenTasks'];
    isLoading = false;
  }
}

class User {
  String? id;
  String? name;
  String? username;
  String? lastName;
  String? firstName;
  String? employeeNumber;
  String? email;
  String? profileId;
  String? userRoleId;
  String? storeIdC;
  bool? isActive;

  User({
    this.id,
    this.name,
    this.username,
    this.lastName,
    this.firstName,
    this.employeeNumber,
    this.email,
    this.profileId,
    this.userRoleId,
    this.storeIdC,
    this.isActive,
  });

  User.fromJson(dynamic json) {
    id = json['Id'];
    name = json['Name'];
    username = json['Username'];
    lastName = json['LastName'];
    firstName = json['FirstName'];
    employeeNumber = json['EmployeeNumber'];
    email = json['Email'];
    profileId = json['ProfileId'];
    userRoleId = json['UserRoleId'];
    storeIdC = json['StoreId__c'];
    isActive = json['IsActive'];
  }
}
