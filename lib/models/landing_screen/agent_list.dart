import 'package:equatable/equatable.dart';

class AgentsList extends Equatable {
  String? message;
  List<AgentList>? agentList;

  AgentsList({this.message, this.agentList});

  AgentsList.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['AgentList'] != null) {
      agentList = <AgentList>[];
      json['AgentList'].forEach((v) {
        agentList!.add(AgentList.fromJson(v));
      });
    } else {
      agentList = <AgentList>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (agentList != null) {
      data['AgentList'] = agentList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [message, agentList];
}

class AgentList extends Equatable {
  Attributes? attributes;
  String? id;
  bool? isAssigning;
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
  Profile? profile;
  Profile? userRole;

  AgentList({
    this.attributes,
    this.id,
    this.isAssigning,
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
    this.profile,
    this.userRole,
  });

  AgentList.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null ? Attributes.fromJson(json['attributes']) : null;
    id = json['Id'];
    name = json['Name'];
    isAssigning = false;
    username = json['Username'];
    lastName = json['LastName'];
    firstName = json['FirstName'];
    employeeNumber = json['EmployeeNumber'];
    email = json['Email'];
    profileId = json['ProfileId'];
    userRoleId = json['UserRoleId'];
    storeIdC = json['StoreId__c'];
    isActive = json['IsActive'];
    profile = json['Profile'] != null ? Profile.fromJson(json['Profile']) : null;
    userRole = json['UserRole'] != null ? Profile.fromJson(json['UserRole']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['Id'] = id;
    data['Name'] = name;
    data['Username'] = username;
    data['LastName'] = lastName;
    data['FirstName'] = firstName;
    data['EmployeeNumber'] = employeeNumber;
    data['Email'] = email;
    data['ProfileId'] = profileId;
    data['UserRoleId'] = userRoleId;
    data['StoreId__c'] = storeIdC;
    data['IsActive'] = isActive;
    if (profile != null) {
      data['Profile'] = profile!.toJson();
    }
    if (userRole != null) {
      data['UserRole'] = userRole!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [
        attributes,
        id,
        isAssigning,
        name,
        username,
        lastName,
        firstName,
        employeeNumber,
        email,
        profileId,
        userRoleId,
        storeIdC,
        isActive,
        profile,
        userRole,
      ];
}

class Attributes extends Equatable {
  String? type;
  String? url;

  Attributes({this.type, this.url});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['url'] = url;
    return data;
  }

  @override
  List<Object?> get props => [type, url];
}

class Profile extends Equatable {
  Attributes? attributes;
  String? id;
  String? name;

  Profile({this.attributes, this.id, this.name});

  Profile.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null ? Attributes.fromJson(json['attributes']) : null;
    id = json['Id'];
    name = json['Name'];
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
  List<Object?> get props => [attributes, id, name];
}
