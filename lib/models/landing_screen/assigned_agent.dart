import 'package:equatable/equatable.dart';

class AssignedAgent extends Equatable {
  String? message;
  AgentStore? agentStore;
  AgentCC? agentCC;

  AssignedAgent({this.message, this.agentStore, this.agentCC});

  AssignedAgent.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    agentStore = json['AgentStore'] != null ? new AgentStore.fromJson(json['AgentStore']) : null;
    agentCC = json['AgentCC'] != null ? new AgentCC.fromJson(json['AgentCC']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.agentStore != null) {
      data['AgentStore'] = this.agentStore!.toJson();
    }
    if (this.agentCC != null) {
      data['AgentCC'] = this.agentCC!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [message, agentStore, agentCC];
}

class AgentStore extends Equatable {
  Attributes? attributes;
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
  Profile? profile;
  Profile? userRole;

  AgentStore({
    this.attributes,
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
    this.profile,
    this.userRole,
  });

  AgentStore.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null ? new Attributes.fromJson(json['attributes']) : null;
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
    profile = json['Profile'] != null ? new Profile.fromJson(json['Profile']) : null;
    userRole = json['UserRole'] != null ? new Profile.fromJson(json['UserRole']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Username'] = this.username;
    data['LastName'] = this.lastName;
    data['FirstName'] = this.firstName;
    data['EmployeeNumber'] = this.employeeNumber;
    data['Email'] = this.email;
    data['ProfileId'] = this.profileId;
    data['UserRoleId'] = this.userRoleId;
    data['StoreId__c'] = this.storeIdC;
    data['IsActive'] = this.isActive;
    if (this.profile != null) {
      data['Profile'] = this.profile!.toJson();
    }
    if (this.userRole != null) {
      data['UserRole'] = this.userRole!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [
        attributes,
        id,
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['url'] = this.url;
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
    attributes = json['attributes'] != null ? new Attributes.fromJson(json['attributes']) : null;
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

class AgentCC extends Equatable {
  Attributes? attributes;
  String? id;
  String? name;
  String? username;
  String? lastName;
  String? firstName;
  String? email;
  String? profileId;
  String? userRoleId;
  String? storeIdC;
  bool? isActive;
  Profile? profile;
  Profile? userRole;

  AgentCC({
    this.attributes,
    this.id,
    this.name,
    this.username,
    this.lastName,
    this.firstName,
    this.email,
    this.profileId,
    this.userRoleId,
    this.storeIdC,
    this.isActive,
    this.profile,
    this.userRole,
  });

  AgentCC.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null ? new Attributes.fromJson(json['attributes']) : null;
    id = json['Id'];
    name = json['Name'];
    username = json['Username'];
    lastName = json['LastName'];
    firstName = json['FirstName'];
    email = json['Email'];
    profileId = json['ProfileId'];
    userRoleId = json['UserRoleId'];
    storeIdC = json['StoreId__c'];
    isActive = json['IsActive'];
    profile = json['Profile'] != null ? new Profile.fromJson(json['Profile']) : null;
    userRole = json['UserRole'] != null ? new Profile.fromJson(json['UserRole']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Username'] = this.username;
    data['LastName'] = this.lastName;
    data['FirstName'] = this.firstName;
    data['Email'] = this.email;
    data['ProfileId'] = this.profileId;
    data['UserRoleId'] = this.userRoleId;
    data['StoreId__c'] = this.storeIdC;
    data['IsActive'] = this.isActive;
    if (this.profile != null) {
      data['Profile'] = this.profile!.toJson();
    }
    if (this.userRole != null) {
      data['UserRole'] = this.userRole!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [
        attributes,
        id,
        name,
        username,
        lastName,
        firstName,
        email,
        profileId,
        userRoleId,
        storeIdC,
        isActive,
        profile,
        userRole,
      ];
}
