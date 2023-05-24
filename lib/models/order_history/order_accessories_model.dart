class OrderAccessoriesModel {
  String? epsilonCustomerKey;
  PurchaseChannel? purchaseChannel;
  PurchaseCategory? purchaseCategory;
  List<History>? history;

  OrderAccessoriesModel(
      {this.epsilonCustomerKey,
        this.purchaseChannel,
        this.purchaseCategory,
        this.history});

  OrderAccessoriesModel.fromJson(Map<String, dynamic> json) {
    epsilonCustomerKey = json['Epsilon_Customer_Key'];
    purchaseChannel = json['PurchaseChannel'] != null
        ? PurchaseChannel.fromJson(json['PurchaseChannel'])
        : null;
    purchaseCategory = json['PurchaseCategory'] != null
        ? PurchaseCategory.fromJson(json['PurchaseCategory'])
        : null;
    if (json['history'] != null) {
      history = <History>[];
      json['history'].forEach((v) {
        history!.add(History.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Epsilon_Customer_Key'] = epsilonCustomerKey;
    if (purchaseChannel != null) {
      data['PurchaseChannel'] = purchaseChannel!.toJson();
    }
    if (purchaseCategory != null) {
      data['PurchaseCategory'] = purchaseCategory!;
    }
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseChannel {
  String? web;
  String? retail;

  PurchaseChannel({this.web, this.retail});

  PurchaseChannel.fromJson(Map<String, dynamic> json) {
    web = json['Web'];
    retail = json['Retail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Web'] = web;
    data['Retail'] = retail;
    return data;
  }
}

class PurchaseCategory {
  Map<String, dynamic>? data;

  PurchaseCategory({this.data});
  PurchaseCategory.fromJson(Map<String, dynamic> json) {
    assert(json is Map);
    data= json;
  }
}

class History {
  String? salesBrand;
  String? orderNumber;
  String? orderDate;
  String? orderPurchaseChannel;
  List<LineItems>? lineItems;

  History(
      {this.salesBrand,
        this.orderNumber,
        this.orderDate,
        this.orderPurchaseChannel,
        this.lineItems});

  History.fromJson(Map<String, dynamic> json) {
    salesBrand = json['SalesBrand'];
    orderNumber = json['OrderNumber'];
    orderDate = json['OrderDate'];
    orderPurchaseChannel = json['OrderPurchaseChannel'];
    if (json['LineItems'] != null) {
      lineItems = <LineItems>[];
      json['LineItems'].forEach((v) {
        lineItems!.add(LineItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['SalesBrand'] = salesBrand;
    data['OrderNumber'] = orderNumber;
    data['OrderDate'] = orderDate;
    data['OrderPurchaseChannel'] = orderPurchaseChannel;
    if (lineItems != null) {
      data['LineItems'] = lineItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LineItems {
  String? enterpriseSKU;
  String? sKU;
  String? title;
  String? quantity;
  String? lineItemPurchaseChannel;
  String? lineItemPurchaseCategory;
  String? sellingPrice;
  String? purchasedPrice;

  LineItems(
      {this.enterpriseSKU,
        this.sKU,
        this.title,
        this.quantity,
        this.lineItemPurchaseChannel,
        this.lineItemPurchaseCategory,
        this.sellingPrice,
        this.purchasedPrice});

  LineItems.fromJson(Map<String, dynamic> json) {
    enterpriseSKU = json['EnterpriseSKU'];
    sKU = json['SKU'];
    title = json['Title'];
    quantity = json['Quantity'];
    lineItemPurchaseChannel = json['LineItemPurchaseChannel'];
    lineItemPurchaseCategory = json['LineItemPurchaseCategory'];
    sellingPrice = json['SellingPrice'];
    purchasedPrice = json['PurchasedPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['EnterpriseSKU'] = enterpriseSKU;
    data['SKU'] = sKU;
    data['Title'] = title;
    data['Quantity'] = quantity;
    data['LineItemPurchaseChannel'] = lineItemPurchaseChannel;
    data['LineItemPurchaseCategory'] = lineItemPurchaseCategory;
    data['SellingPrice'] = sellingPrice;
    data['PurchasedPrice'] = purchasedPrice;
    return data;
  }
}
