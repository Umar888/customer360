class AssignUserModel {
  AssignUserOrder? order;
  String? message;
  bool? isSuccess;

  AssignUserModel({this.order, this.message, this.isSuccess});

  AssignUserModel.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? new AssignUserOrder.fromJson(json['order']) : null;
    message = json['message'];
    isSuccess = json['isSuccess'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    data['message'] = this.message;
    data['isSuccess'] = this.isSuccess;
    return data;
  }
}

class AssignUserOrder {
  Attributes? attributes;
  String? id;
  String? customerC;

  AssignUserOrder({this.attributes, this.id, this.customerC});

  AssignUserOrder.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    customerC = json['Customer__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Customer__c'] = this.customerC;
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
