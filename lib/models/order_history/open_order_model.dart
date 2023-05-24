import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class OpenOrderModel extends Equatable{
  List<OpenOrders>? openOrders;

  OpenOrderModel({this.openOrders});

  OpenOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['OpenOrders'] != null) {
      openOrders = <OpenOrders>[];
      json['OpenOrders'].forEach((v) {
        openOrders!.add(OpenOrders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (openOrders != null) {
      data['OpenOrders'] = openOrders!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [openOrders];
}

class OpenOrders extends Equatable{
  Attributes? attributes;
  String? id;
  String? name;
  String? createdDate;
  String? lastModifiedDate;
  double? totalC;
  double? totalLineAmountC;
  String? orderNumberC;
  String? orderStatusC;
  String? deliveryOptionC;
  GCOrderLineItemsR? gCOrderLineItemsR;

  @override
  List<Object?> get props => [attributes,id,name,createdDate,lastModifiedDate,totalC,totalLineAmountC,orderNumberC,orderStatusC,deliveryOptionC,gCOrderLineItemsR];

  OpenOrders(
      {this.attributes,
        this.id,
        this.name,
        this.createdDate,
        this.lastModifiedDate,
        this.totalC,
        this.totalLineAmountC,
        this.orderNumberC,
        this.orderStatusC,
        this.deliveryOptionC,
        this.gCOrderLineItemsR});

  OpenOrders.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    name = json['Name'];
    createdDate = json['CreatedDate'];
    lastModifiedDate = json['LastModifiedDate'];
    totalC = json['Total__c'];
    totalLineAmountC = json['TotalLineAmount__c'];
    orderNumberC = json['Order_Number__c'];
    orderStatusC = json['Order_Status__c'];
    deliveryOptionC = json['Delivery_Option__c'];
    gCOrderLineItemsR = json['GC_Order_Line_Items__r'] != null
        ? GCOrderLineItemsR.fromJson(json['GC_Order_Line_Items__r'])
        : GCOrderLineItemsR(totalSize: 0,records: []);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['Id'] = id;
    data['Name'] = name;
    data['CreatedDate'] = createdDate;
    data['LastModifiedDate'] = lastModifiedDate;
    data['Total__c'] = totalC;
    data['TotalLineAmount__c'] = totalLineAmountC;
    data['Order_Number__c'] = orderNumberC;
    data['Order_Status__c'] = orderStatusC;
    data['Delivery_Option__c'] = deliveryOptionC;
    if (gCOrderLineItemsR != null) {
      data['GC_Order_Line_Items__r'] = gCOrderLineItemsR!.toJson();
    }
    return data;
  }
}

class Attributes extends Equatable{
  String? type;
  String? url;
  @override
  List<Object?> get props => [type,url];

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

class GCOrderLineItemsR extends Equatable{
  int? totalSize;
  bool? done;
  List<Records>? records;

  @override
  List<Object?> get props => [totalSize,done,records];

  GCOrderLineItemsR({this.totalSize, this.done, this.records});

  GCOrderLineItemsR.fromJson(Map<String, dynamic> json) {
    totalSize = json['totalSize'];
    done = json['done'];
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(Records.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalSize'] = totalSize;
    data['done'] = done;
    if (records != null) {
      data['records'] = records!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Records extends Equatable{
  Attributes? attributes;
  String? gCOrderC;
  String? id;
  String? itemSKUC;
  String? imageURL1C;
  String? descriptionC;
  double? itemPriceC;
  int? quantityC;
  bool? outOfStock;
  bool? noInfo;
  bool? inStore;

  @override
  List<Object?> get props => [attributes,gCOrderC,id,itemSKUC,imageURL1C,itemPriceC,descriptionC,quantityC,outOfStock,noInfo,inStore];

  Records(
      {this.attributes,
        this.gCOrderC,
        this.id,
        this.itemSKUC,
        this.imageURL1C,
        this.outOfStock,
        this.noInfo,
        this.inStore,
        this.descriptionC,
        this.itemPriceC,
        this.quantityC});

  Records.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    gCOrderC = json['GC_Order__c'];
    id = json['Id'];
    outOfStock = false;
    noInfo =true;
    inStore = false;
    itemSKUC = json['Item_SKU__c'];
    imageURL1C = json['Image_URL__c'];
    descriptionC = json['Description__c'];
    itemPriceC = json['Item_Price__c'];
    quantityC = json['Quantity__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['GC_Order__c'] = gCOrderC;
    data['Id'] = id;
    data['Item_SKU__c'] = itemSKUC;
    data['Image_URL1__c'] = imageURL1C;
    data['Description__c'] = descriptionC;
    data['Item_Price__c'] = itemPriceC;
    data['Quantity__c'] = quantityC;
    return data;
  }
}
