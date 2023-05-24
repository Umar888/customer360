class UpdateCart {
  OrderLineItem? orderLineItem;
  String? message;

  UpdateCart({this.orderLineItem, this.message});

  UpdateCart.fromJson(Map<String, dynamic> json) {
    orderLineItem = json['OrderLineItem'] != null
        ? OrderLineItem.fromJson(json['OrderLineItem'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orderLineItem != null) {
      data['OrderLineItem'] = orderLineItem!.toJson();
    }
    data['message'] = message??"";
    return data;
  }
}

class OrderLineItem {
  Attributes? attributes;
  String? id;
  String? name;
  int? quantityC;

  OrderLineItem({this.attributes, this.id, this.name, this.quantityC});

  OrderLineItem.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    name = json['Name'];
    quantityC = json['Quantity__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['Id'] = id;
    data['Name'] = name;
    data['Quantity__c'] = quantityC;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['url'] = url;
    return data;
  }
}