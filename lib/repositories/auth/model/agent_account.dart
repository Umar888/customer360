class AgentAccountModel {
  List<UserList>? userList;
  String? message;

  AgentAccountModel({this.userList, this.message});

  AgentAccountModel.fromJson(Map<String, dynamic> json) {
    if (json['UserList'] != null) {
      userList = <UserList>[];
      json['UserList'].forEach((v) {
        userList!.add(new UserList.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userList != null) {
      data['UserList'] = this.userList!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class UserList {
  User? user;
  bool? isManager;

  UserList({this.user, this.isManager});

  UserList.fromJson(Map<String, dynamic> json) {
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
    isManager = json['IsManager'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    data['IsManager'] = this.isManager;
    return data;
  }
}

class User {
  Attributes? attributes;
  String? id;
  String? name;
  String? username;
  String? lastName;
  String? firstName;
  String? employeeNumber;
  String? email;
  String? phone;
  String? mobilePhone;
  String? profileId;
  String? userRoleId;
  String? smallPhotoUrl;
  String? fullPhotoUrl;
  String? storeIdC;
  String? jobcodeC;
  bool? isActive;
  Profile? profile;
  Profile? userRole;
  String? storeNameC;

  User(
      {this.attributes,
        this.id,
        this.name,
        this.username,
        this.lastName,
        this.firstName,
        this.employeeNumber,
        this.email,
        this.phone,
        this.mobilePhone,
        this.profileId,
        this.userRoleId,
        this.smallPhotoUrl,
        this.fullPhotoUrl,
        this.storeIdC,
        this.jobcodeC,
        this.isActive,
        this.profile,
        this.userRole,
        this.storeNameC});

  User.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    name = json['Name'];
    username = json['Username'];
    lastName = json['LastName'];
    firstName = json['FirstName'];
    employeeNumber = json['EmployeeNumber'];
    email = json['Email'];
    phone = json['Phone'];
    mobilePhone = json['MobilePhone'];
    profileId = json['ProfileId'];
    userRoleId = json['UserRoleId'];
    smallPhotoUrl = json['SmallPhotoUrl'];
    fullPhotoUrl = json['FullPhotoUrl'];
    storeIdC = json['StoreId__c'];
    jobcodeC = json['Jobcode__c'];
    isActive = json['IsActive'];
    profile =
    json['Profile'] != null ? new Profile.fromJson(json['Profile']) : null;
    userRole = json['UserRole'] != null
        ? new Profile.fromJson(json['UserRole'])
        : null;
    storeNameC = json['Store_Name__c'];
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
    data['Phone'] = this.phone;
    data['MobilePhone'] = this.mobilePhone;
    data['ProfileId'] = this.profileId;
    data['UserRoleId'] = this.userRoleId;
    data['SmallPhotoUrl'] = this.smallPhotoUrl;
    data['FullPhotoUrl'] = this.fullPhotoUrl;
    data['StoreId__c'] = this.storeIdC;
    data['Jobcode__c'] = this.jobcodeC;
    data['IsActive'] = this.isActive;
    if (this.profile != null) {
      data['Profile'] = this.profile!.toJson();
    }
    if (this.userRole != null) {
      data['UserRole'] = this.userRole!.toJson();
    }
    data['Store_Name__c'] = this.storeNameC;
    return data;
  }
}

class Attributes {
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
}

class Profile {
  Attributes? attributes;
  String? id;
  String? name;

  Profile({this.attributes, this.id, this.name});

  Profile.fromJson(Map<String, dynamic> json) {
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
}
