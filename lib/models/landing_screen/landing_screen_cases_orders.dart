class OpenOrdersLandingScreenModel {
  List<OpenOrders>? openOrders;

  OpenOrdersLandingScreenModel({this.openOrders});

  OpenOrdersLandingScreenModel.fromJson(Map<String, dynamic> json) {
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
}

class OpenOrders {
  Attributes? attributes;
  String? id;
  String? name;
  String? createdDate;
  String? lastModifiedDate;
  double? totalC;
  String? orderNumberC;
  String? orderStatusC;
  String? deliveryOptionC;
  GCOrderLineItemsR? gCOrderLineItemsR;

  OpenOrders(
      {this.attributes,
        this.id,
        this.name,
        this.createdDate,
        this.lastModifiedDate,
        this.totalC,
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
    orderNumberC = json['Order_Number__c'];
    orderStatusC = json['Order_Status__c'];
    deliveryOptionC = json['Delivery_Option__c'];
    gCOrderLineItemsR = json['GC_Order_Line_Items__r'] != null
        ? GCOrderLineItemsR.fromJson(json['GC_Order_Line_Items__r'])
        : GCOrderLineItemsR(totalSize: 0);
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
    data['Order_Number__c'] = orderNumberC;
    data['Order_Status__c'] = orderStatusC;
    data['Delivery_Option__c'] = deliveryOptionC;
    if (gCOrderLineItemsR != null) {
      data['GC_Order_Line_Items__r'] = gCOrderLineItemsR!.toJson();
    }
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

class GCOrderLineItemsR {
  int? totalSize;
  bool? done;
  List<Records>? records;

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

class Records {
  Attributes? attributes;
  String? gCOrderC;
  String? id;
  String? itemSKUC;
  String? imageURL1C;
  String? descriptionC;
  double? itemPriceC;
  int? quantityC;

  Records(
      {this.attributes,
        this.gCOrderC,
        this.id,
        this.itemSKUC,
        this.imageURL1C,
        this.descriptionC,
        this.itemPriceC,
        this.quantityC});

  Records.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    gCOrderC = json['GC_Order__c'];
    id = json['Id'];
    itemSKUC = json['Item_SKU__c'];
    imageURL1C = json['Image_URL1__c'];
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