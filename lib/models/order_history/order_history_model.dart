import 'package:equatable/equatable.dart';

class OrderHistoryModel extends Equatable{
  List<OrderHistory>? orderHistory;

  OrderHistoryModel({this.orderHistory});

  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['OrderHistory'] != null) {
      orderHistory = <OrderHistory>[];
      json['OrderHistory'].forEach((v) {
        orderHistory!.add(OrderHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orderHistory != null) {
      data['OrderHistory'] = orderHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [orderHistory];
}

class OrderHistory extends Equatable{
  bool? selectedIndexFlag;
  String? salesBrand;
  double? paymentMethodTotal;
  String? orderUrl;
  String? orderStatus;
  String? orderPurchaseChannel;
  String? orderNumber;
  String? orderDate;
  List<LineItems>? lineItems;

  OrderHistory(
      {this.selectedIndexFlag,
      this.salesBrand,
      this.paymentMethodTotal,
      this.orderUrl,
      this.orderStatus,
      this.orderPurchaseChannel,
      this.orderNumber,
      this.orderDate,
      this.lineItems});

  OrderHistory.fromJson(Map<String, dynamic> json) {
    selectedIndexFlag = json['selectedIndexFlag'];
    salesBrand = json['SalesBrand'];
    paymentMethodTotal = json['PaymentMethodTotal'] ?? 0.0;
    orderUrl = json['OrderUrl'];
    orderStatus = json['OrderStatus'] ?? "";
    orderPurchaseChannel = json['OrderPurchaseChannel'];
    orderNumber = json['OrderNumber'];
    orderDate = json['OrderDate'] == 'null' || (json['OrderDate'] ?? '').isEmpty
        ? null
        : json['OrderDate'];
    if (json['LineItems'] != null) {
      lineItems = <LineItems>[];
      json['LineItems'].forEach((v) {
        lineItems!.add(new LineItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['selectedIndexFlag'] = this.selectedIndexFlag;
    data['SalesBrand'] = this.salesBrand;
    data['PaymentMethodTotal'] = this.paymentMethodTotal;
    data['OrderUrl'] = this.orderUrl;
    data['OrderStatus'] = this.orderStatus;
    data['OrderPurchaseChannel'] = this.orderPurchaseChannel;
    data['OrderNumber'] = this.orderNumber;
    data['OrderDate'] = this.orderDate;
    if (this.lineItems != null) {
      data['LineItems'] = this.lineItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [
    selectedIndexFlag,
    salesBrand,
    paymentMethodTotal,
    orderUrl,
    orderStatus,
    orderPurchaseChannel,
    orderNumber,
    // orderDate,
    lineItems,
  ];
}

class LineItems extends Equatable{
  String? trackingNo;
  String? title;
  String? sKU;
  String? sellingPrice;
  String? quantity;
  String? purchasedPrice;
  String? lineItemStatus;
  String? lineItemPurchaseChannel;
  String? lineItemPurchaseCategory;
  String? imageUrl;
  String? enterpriseSKU;

  LineItems(
      {this.trackingNo,
      this.title,
      this.sKU,
      this.sellingPrice,
      this.quantity,
      this.purchasedPrice,
      this.lineItemStatus,
      this.lineItemPurchaseChannel,
      this.lineItemPurchaseCategory,
      this.imageUrl,
      this.enterpriseSKU});

  LineItems.fromJson(Map<String, dynamic> json) {
    trackingNo = json['TrackingNo'];
    title = json['Title'];
    sKU = json['SKU'];
    sellingPrice = json['SellingPrice'];
    quantity = json['Quantity'];
    purchasedPrice = json['PurchasedPrice'];
    lineItemStatus = json['LineItemStatus'];
    lineItemPurchaseChannel = json['LineItemPurchaseChannel'];
    lineItemPurchaseCategory = json['LineItemPurchaseCategory'];
    imageUrl = json['ImageUrl'];
    enterpriseSKU = json['EnterpriseSKU'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TrackingNo'] = this.trackingNo;
    data['Title'] = this.title;
    data['SKU'] = this.sKU;
    data['SellingPrice'] = this.sellingPrice;
    data['Quantity'] = this.quantity;
    data['PurchasedPrice'] = this.purchasedPrice;
    data['LineItemStatus'] = this.lineItemStatus;
    data['LineItemPurchaseChannel'] = this.lineItemPurchaseChannel;
    data['LineItemPurchaseCategory'] = this.lineItemPurchaseCategory;
    data['ImageUrl'] = this.imageUrl;
    data['EnterpriseSKU'] = this.enterpriseSKU;
    return data;
  }

  @override
  List<Object?> get props => [
    trackingNo,
    title,
    sKU,
    sellingPrice,
    quantity,
    purchasedPrice,
    lineItemStatus,
    lineItemPurchaseChannel,
    lineItemPurchaseCategory,
    imageUrl,
    enterpriseSKU,
  ];
}
