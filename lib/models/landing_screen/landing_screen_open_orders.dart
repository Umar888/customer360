class LandingScreenOpenOrderModels {
  List<OpenOrders>? openOrders;

  LandingScreenOpenOrderModels({this.openOrders});

  LandingScreenOpenOrderModels.fromJson(Map<String, dynamic> json) {
    if (json['OpenOrders'] != null) {
      openOrders = <OpenOrders>[];
      json['OpenOrders'].forEach((v) {
        openOrders!.add(new OpenOrders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.openOrders != null) {
      data['OpenOrders'] = this.openOrders!.map((v) => v.toJson()).toList();
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
  String? brandCodeC;
  String? customerC;
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
        this.brandCodeC,
        this.customerC,
        this.deliveryOptionC,
        this.gCOrderLineItemsR});

  OpenOrders.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    name = json['Name'];
    createdDate = json['CreatedDate'];
    lastModifiedDate = json['LastModifiedDate'];
    totalC = json['Total__c'];
    orderNumberC = json['Order_Number__c'];
    orderStatusC = json['Order_Status__c'];
    brandCodeC = json['Brand_Code__c'];
    customerC = json['Customer__c'];
    deliveryOptionC = json['Delivery_Option__c'];
    gCOrderLineItemsR = json['GC_Order_Line_Items__r'] != null
        ? new GCOrderLineItemsR.fromJson(json['GC_Order_Line_Items__r'])
        : GCOrderLineItemsR(totalSize: 0,done: false,records: []);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['CreatedDate'] = this.createdDate;
    data['LastModifiedDate'] = this.lastModifiedDate;
    data['Total__c'] = this.totalC;
    data['Order_Number__c'] = this.orderNumberC;
    data['Order_Status__c'] = this.orderStatusC;
    data['Brand_Code__c'] = this.brandCodeC;
    data['Customer__c'] = this.customerC;
    data['Delivery_Option__c'] = this.deliveryOptionC;
    if (this.gCOrderLineItemsR != null) {
      data['GC_Order_Line_Items__r'] = this.gCOrderLineItemsR!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['url'] = this.url;
    return data;
  }
}

class GCOrderLineItemsR {
  int? totalSize;
  bool? done;
  List<Records>? records;

  GCOrderLineItemsR({this.totalSize, this.done, this.records});

  GCOrderLineItemsR.fromJson(Map<String, dynamic> json) {
    totalSize = json['totalSize']??0;
    done = json['done']??false;
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    }
    else{
      records = <Records>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalSize'] = this.totalSize;
    data['done'] = this.done;
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Records {
  Attributes? attributes;
  String? gCOrderC;
  String? id;
  String? name;
  String? descriptionC;
  String? itemIdC;
  double? itemPriceC;
  int? quantityC;
  String? statusC;
  String? imageURLC;
  String? imageURL1C;
  String? condtionC;
  String? itemStatusC;
  String? itemSKUC;
  String? pIMSkuC;
  String? pOSSkuC;

  Records(
      {this.attributes,
        this.gCOrderC,
        this.id,
        this.name,
        this.descriptionC,
        this.itemIdC,
        this.itemPriceC,
        this.quantityC,
        this.statusC,
        this.imageURLC,
        this.imageURL1C,
        this.condtionC,
        this.itemStatusC,
        this.itemSKUC,
        this.pIMSkuC,
        this.pOSSkuC});

  Records.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    gCOrderC = json['GC_Order__c'];
    id = json['Id'];
    name = json['Name'];
    descriptionC = json['Description__c'];
    itemIdC = json['Item_Id__c'];
    itemPriceC = json['Item_Price__c'];
    quantityC = json['Quantity__c'];
    statusC = json['Status__c'];
    imageURLC = json['Image_URL__c'];
    imageURL1C = json['Image_URL1__c'];
    condtionC = json['Condtion__c'];
    itemStatusC = json['ItemStatus__c'];
    itemSKUC = json['Item_SKU__c'];
    pIMSkuC = json['PIM_Sku__c'];
    pOSSkuC = json['POS_Sku__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['GC_Order__c'] = this.gCOrderC;
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['Description__c'] = this.descriptionC;
    data['Item_Id__c'] = this.itemIdC;
    data['Item_Price__c'] = this.itemPriceC;
    data['Quantity__c'] = this.quantityC;
    data['Status__c'] = this.statusC;
    data['Image_URL__c'] = this.imageURLC;
    data['Image_URL1__c'] = this.imageURL1C;
    data['Condtion__c'] = this.condtionC;
    data['ItemStatus__c'] = this.itemStatusC;
    data['Item_SKU__c'] = this.itemSKUC;
    data['PIM_Sku__c'] = this.pIMSkuC;
    data['POS_Sku__c'] = this.pOSSkuC;
    return data;
  }
}
