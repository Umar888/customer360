class TestModel {
  List<Orders>? orders;
  CurrentTask? currentTask;

  TestModel({this.orders, this.currentTask});

  TestModel.fromJson(Map<String, dynamic> json) {
    if (json['Orders'] != null) {
      orders = <Orders>[];
      json['Orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
    currentTask = json['CurrentTask'] != null
        ? new CurrentTask.fromJson(json['CurrentTask'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orders != null) {
      data['Orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    if (this.currentTask != null) {
      data['CurrentTask'] = this.currentTask!.toJson();
    }
    return data;
  }
}

class Orders {
  String? taskType;
  bool? showOrderPage;
  String? orderNumber;
  String? orderNo;
  List<OrderLines>? orderLines;
  String? orderDate;
  String? grandTotal;
  String? email;
  String? brandCode;
  String? brand;

  Orders(
      {this.taskType,
        this.showOrderPage,
        this.orderNumber,
        this.orderNo,
        this.orderLines,
        this.orderDate,
        this.grandTotal,
        this.email,
        this.brandCode,
        this.brand});

  Orders.fromJson(Map<String, dynamic> json) {
    taskType = json['TaskType'];
    showOrderPage = json['showOrderPage'];
    orderNumber = json['OrderNumber'];
    orderNo = json['OrderNo'];
    if (json['OrderLines'] != null) {
      orderLines = <OrderLines>[];
      json['OrderLines'].forEach((v) {
        orderLines!.add(new OrderLines.fromJson(v));
      });
    }
    orderDate = json['OrderDate'];
    grandTotal = json['GrandTotal'];
    email = json['email'];
    brandCode = json['BrandCode'];
    brand = json['Brand'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TaskType'] = this.taskType;
    data['showOrderPage'] = this.showOrderPage;
    data['OrderNumber'] = this.orderNumber;
    data['OrderNo'] = this.orderNo;
    if (this.orderLines != null) {
      data['OrderLines'] = this.orderLines!.map((v) => v.toJson()).toList();
    }
    data['OrderDate'] = this.orderDate;
    data['GrandTotal'] = this.grandTotal;
    data['email'] = this.email;
    data['BrandCode'] = this.brandCode;
    data['Brand'] = this.brand;
    return data;
  }
}

class OrderLines {
  bool? warrantyEligible;
  String? warrantyDays;
  String? unitPrice;
  String? taskType;
  String? serviceUrl;
  String? orderedQty;
  String? itemStatus;
  String? itemShortDesc;
  String? itemNumber;
  String? itemID;
  String? imageUrl;
  String? deliveryDays;
  String? deliveredDateTime;
  String? deliveredDate;

  OrderLines(
      {this.warrantyEligible,
        this.warrantyDays,
        this.unitPrice,
        this.taskType,
        this.serviceUrl,
        this.orderedQty,
        this.itemStatus,
        this.itemShortDesc,
        this.itemNumber,
        this.itemID,
        this.imageUrl,
        this.deliveryDays,
        this.deliveredDateTime,
        this.deliveredDate});

  OrderLines.fromJson(Map<String, dynamic> json) {
    warrantyEligible = json['warrantyEligible'];
    warrantyDays = json['warrantyDays'];
    unitPrice = json['UnitPrice'];
    taskType = json['TaskType'];
    serviceUrl = json['ServiceUrl'];
    orderedQty = json['OrderedQty'];
    itemStatus = json['ItemStatus'];
    itemShortDesc = json['ItemShortDesc'];
    itemNumber = json['ItemNumber'];
    itemID = json['ItemID'];
    imageUrl = json['ImageUrl'];
    deliveryDays = json['deliveryDays'];
    deliveredDateTime = json['deliveredDateTime'];
    deliveredDate = json['deliveredDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['warrantyEligible'] = this.warrantyEligible;
    data['warrantyDays'] = this.warrantyDays;
    data['UnitPrice'] = this.unitPrice;
    data['TaskType'] = this.taskType;
    data['ServiceUrl'] = this.serviceUrl;
    data['OrderedQty'] = this.orderedQty;
    data['ItemStatus'] = this.itemStatus;
    data['ItemShortDesc'] = this.itemShortDesc;
    data['ItemNumber'] = this.itemNumber;
    data['ItemID'] = this.itemID;
    data['ImageUrl'] = this.imageUrl;
    data['deliveryDays'] = this.deliveryDays;
    data['deliveredDateTime'] = this.deliveredDateTime;
    data['deliveredDate'] = this.deliveredDate;
    return data;
  }
}

class CurrentTask {
  Attributes? attributes;
  String? id;
  String? status;
  String? subject;
  String? activityDate;
  String? storeTaskTypeC;
  String? phoneC;
  String? firstNameC;
  String? ownerId;
  String? createdById;
  String? createdDate;
  String? lastModifiedById;
  String? lastModifiedDate;
  String? whoId;
  String? whatId;
  Owner? owner;
  Owner? createdBy;
  Owner? lastModifiedBy;
  Owner? who;
  Owner? what;

  CurrentTask(
      {this.attributes,
        this.id,
        this.status,
        this.subject,
        this.activityDate,
        this.storeTaskTypeC,
        this.phoneC,
        this.firstNameC,
        this.ownerId,
        this.createdById,
        this.createdDate,
        this.lastModifiedById,
        this.lastModifiedDate,
        this.whoId,
        this.whatId,
        this.owner,
        this.createdBy,
        this.lastModifiedBy,
        this.who,
        this.what});

  CurrentTask.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    status = json['Status'];
    subject = json['Subject'];
    activityDate = json['ActivityDate'];
    storeTaskTypeC = json['Store_Task_Type__c'];
    phoneC = json['Phone__c'];
    firstNameC = json['First_Name__c'];
    ownerId = json['OwnerId'];
    createdById = json['CreatedById'];
    createdDate = json['CreatedDate'];
    lastModifiedById = json['LastModifiedById'];
    lastModifiedDate = json['LastModifiedDate'];
    whoId = json['WhoId'];
    whatId = json['WhatId'];
    owner = json['Owner'] != null ? new Owner.fromJson(json['Owner']) : null;
    createdBy = json['CreatedBy'] != null
        ? new Owner.fromJson(json['CreatedBy'])
        : null;
    lastModifiedBy = json['LastModifiedBy'] != null
        ? new Owner.fromJson(json['LastModifiedBy'])
        : null;
    who = json['Who'] != null ? new Owner.fromJson(json['Who']) : null;
    what = json['What'] != null ? new Owner.fromJson(json['What']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Status'] = this.status;
    data['Subject'] = this.subject;
    data['ActivityDate'] = this.activityDate;
    data['Store_Task_Type__c'] = this.storeTaskTypeC;
    data['Phone__c'] = this.phoneC;
    data['First_Name__c'] = this.firstNameC;
    data['OwnerId'] = this.ownerId;
    data['CreatedById'] = this.createdById;
    data['CreatedDate'] = this.createdDate;
    data['LastModifiedById'] = this.lastModifiedById;
    data['LastModifiedDate'] = this.lastModifiedDate;
    data['WhoId'] = this.whoId;
    data['WhatId'] = this.whatId;
    if (this.owner != null) {
      data['Owner'] = this.owner!.toJson();
    }
    if (this.createdBy != null) {
      data['CreatedBy'] = this.createdBy!.toJson();
    }
    if (this.lastModifiedBy != null) {
      data['LastModifiedBy'] = this.lastModifiedBy!.toJson();
    }
    if (this.who != null) {
      data['Who'] = this.who!.toJson();
    }
    if (this.what != null) {
      data['What'] = this.what!.toJson();
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

class Owner {
  Attributes? attributes;
  String? id;
  String? name;

  Owner({this.attributes, this.id, this.name});

  Owner.fromJson(Map<String, dynamic> json) {
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
