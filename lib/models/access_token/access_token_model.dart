class AccessTokenModel {
  bool? success;
  String? msg;
  Data? data;

  AccessTokenModel({this.success, this.msg, this.data});

  AccessTokenModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  TokenData? tokenData;
  UserData? userData;

  Data({this.tokenData, this.userData});

  Data.fromJson(Map<String, dynamic> json) {
    tokenData = json['tokenData'] != null
        ? new TokenData.fromJson(json['tokenData'])
        : null;
    userData = json['userData'] != null
        ? new UserData.fromJson(json['userData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tokenData != null) {
      data['tokenData'] = this.tokenData!.toJson();
    }
    if (this.userData != null) {
      data['userData'] = this.userData!.toJson();
    }
    return data;
  }
}

class TokenData {
  String? tokenType;
  int? expiresIn;
  String? accessToken;
  String? scope;
  String? refreshToken;
  String? idToken;

  TokenData(
      {this.tokenType,
        this.expiresIn,
        this.accessToken,
        this.scope,
        this.refreshToken,
        this.idToken});

  TokenData.fromJson(Map<String, dynamic> json) {
    tokenType = json['token_type'];
    expiresIn = json['expires_in'];
    accessToken = json['access_token'];
    scope = json['scope'];
    refreshToken = json['refresh_token'];
    idToken = json['id_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token_type'] = this.tokenType;
    data['expires_in'] = this.expiresIn;
    data['access_token'] = this.accessToken;
    data['scope'] = this.scope;
    data['refresh_token'] = this.refreshToken;
    data['id_token'] = this.idToken;
    return data;
  }
}

class UserData {
  String? department;
  String? company;
  String? jobCode;
  String? city;
  String? employeeId;
  String? name;
  String? email;

  UserData(
      {this.department,
        this.company,
        this.jobCode,
        this.city,
        this.employeeId,
        this.name,
        this.email});

  UserData.fromJson(Map<String, dynamic> json) {
    department = json['department'];
    company = json['company'];
    jobCode = json['jobCode'];
    city = json['city'];
    employeeId = json['employeeId'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['department'] = this.department;
    data['company'] = this.company;
    data['jobCode'] = this.jobCode;
    data['city'] = this.city;
    data['employeeId'] = this.employeeId;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}
