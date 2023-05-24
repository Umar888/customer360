class DeleteOrderModel {
  Order? order;
  String? message;

  DeleteOrderModel({this.order, this.message});

  DeleteOrderModel.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Order {
  Attributes? attributes;
  String? id;
  String? orderStatusC;
  String? nLNReasonC;

  Order({this.attributes, this.id, this.orderStatusC, this.nLNReasonC});

  Order.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    orderStatusC = json['Order_Status__c'];
    nLNReasonC = json['NLN_Reason__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Order_Status__c'] = this.orderStatusC;
    data['NLN_Reason__c'] = this.nLNReasonC;
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
