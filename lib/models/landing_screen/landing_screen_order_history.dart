import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;

class LandingScreenOrderHistory extends Equatable {
  List<OrderHistoryLandingScreen>? orderHistory;
  List<FavoriteBrandsLandingScreen>? brands;

  LandingScreenOrderHistory({this.orderHistory, this.brands});

  LandingScreenOrderHistory.fromJson(Map<String, dynamic> json) {
    if (json['OrderHistory'] != null) {
      orderHistory = <OrderHistoryLandingScreen>[];
      json['OrderHistory'].forEach((v) {
        orderHistory!.add(new OrderHistoryLandingScreen.fromJson(v));
      });
    }
    else{
      orderHistory = <OrderHistoryLandingScreen>[];
    }
    if (json['brands'] != null) {
      brands = <FavoriteBrandsLandingScreen>[];
      json['brands'].forEach((v) {
        brands!.add(new FavoriteBrandsLandingScreen.fromJson(v));
      });
    }
    else{
      brands = <FavoriteBrandsLandingScreen>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderHistory != null) {
      data['OrderHistory'] = this.orderHistory!.map((v) => v.toJson()).toList();
    }
    if (this.brands != null) {
      data['brands'] = this.brands!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [orderHistory,brands];
}

class OrderHistoryLandingScreen extends Equatable{
  bool? selectedIndexFlag;
  String? salesBrand;
  String? orderUrl;
  String? orderStatus;
  String? orderPurchaseChannel;
  String? orderNumber;
  double? paymentMethodTotal;
  String? orderDate;
  List<LineItems>? lineItems;

  OrderHistoryLandingScreen(
      {this.selectedIndexFlag,
        this.salesBrand,
        this.orderUrl,
        this.orderStatus,
        this.orderPurchaseChannel,
        this.orderNumber,
        this.paymentMethodTotal,
        this.orderDate,
        this.lineItems});

  OrderHistoryLandingScreen.fromJson(Map<String, dynamic> json) {
    selectedIndexFlag = json['selectedIndexFlag']??"";
    salesBrand = json['SalesBrand']??"";
    orderUrl = json['OrderUrl']??"";
    orderStatus = json['OrderStatus']??"";
    orderPurchaseChannel = json['OrderPurchaseChannel']??"";
    orderNumber = json['OrderNumber']??"";
    paymentMethodTotal = json['PaymentMethodTotal']??0.00;
    orderDate = json['OrderDate'];
    if (json['LineItems'] != null) {
      lineItems = <LineItems>[];
      json['LineItems'].forEach((v) {
        lineItems!.add(new LineItems.fromJson(v));
      });
    }
    else{
      lineItems = <LineItems>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['selectedIndexFlag'] = this.selectedIndexFlag;
    data['SalesBrand'] = this.salesBrand;
    data['OrderUrl'] = this.orderUrl;
    data['OrderStatus'] = this.orderStatus;
    data['OrderPurchaseChannel'] = this.orderPurchaseChannel;
    data['OrderNumber'] = this.orderNumber;
    data['PaymentMethodTotal'] = this.paymentMethodTotal;
    data['OrderDate'] = this.orderDate;
    if (this.lineItems != null) {
      data['LineItems'] = this.lineItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    selectedIndexFlag,
    salesBrand,
    orderUrl,
    orderStatus,
    orderPurchaseChannel,
    orderNumber,
    orderDate,
    lineItems
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
  // TODO: implement props
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
    enterpriseSKU
  ];
}

class FavoriteBrandsLandingScreen extends Equatable{
  List<BrandItems>? items;
  String? brandIconName;
  String? brand;

  FavoriteBrandsLandingScreen({this.items, this.brandIconName, this.brand});

  FavoriteBrandsLandingScreen.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <BrandItems>[];
      json['items'].forEach((v) {
        items!.add(new BrandItems.fromJson(v));
      });
    }
    brandIconName = json['brandIconName'];
    brand = json['brand'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['brandIconName'] = this.brandIconName;
    data['brand'] = this.brand;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    items,brand,brandIconName
  ];
}

/*class BrandItems extends Equatable{
  String? warrantyStyleDesc;
  String? warrantySkuId;
  double? warrantyPrice;
  String? warrantyId;
  String? warrantyDisplayName;
  double? unitPrice;
  String? trackingNo;
  String? title;
  String? itemSkuID;
  String? sellingPrice;
  int? quantity;
  String? purchasedPrice;
  String? productId;
  String? posSkuId;
  String? pOS;
  String? pimSkuId;
  String? pIM;
  String? overridePriceReason;
  String? overridePriceApproval;
  double? overridePrice;
  double? marginValue;
  double? margin;
  String? lineItemStatus;
  String? lineItemPurchaseChannel;
  String? lineItemPurchaseCategory;
  String? itemStatus;
  String? itemNumber;
  String? itemId;
  String? itemDesc;
  String? imageUrl;
  String? enterpriseSKU;
  double? discountedMarginValue;
  double? discountedMargin;
  double? cost;
  String? condition;
  asm.Records? records;
  bool? isUpdating;


  BrandItems(
      {this.warrantyStyleDesc,
        this.warrantySkuId,
        this.warrantyPrice,
        this.warrantyId,
        this.warrantyDisplayName,
        this.unitPrice,
        this.trackingNo,
        this.title,
        this.itemSkuID,
        this.sellingPrice,
        this.quantity,
        this.purchasedPrice,
        this.productId,
        this.posSkuId,
        this.pOS,
        this.pimSkuId,
        this.pIM,
        this.overridePriceReason,
        this.overridePriceApproval,
        this.overridePrice,
        this.marginValue,
        this.margin,
        this.lineItemStatus,
        this.lineItemPurchaseChannel,
        this.lineItemPurchaseCategory,
        this.itemStatus,
        this.itemNumber,
        this.records,
        this.isUpdating,
        this.itemId,
        this.itemDesc,
        this.imageUrl,
        this.enterpriseSKU,
        this.discountedMarginValue,
        this.discountedMargin,
        this.cost,
        this.condition});

  BrandItems.fromJson(Map<String, dynamic> json) {
    warrantyStyleDesc = json['WarrantyStyleDesc'];
    warrantySkuId = json['WarrantySkuId'];
    warrantyPrice = json['WarrantyPrice'];
    warrantyId = json['WarrantyId'];
    warrantyDisplayName = json['WarrantyDisplayName'];
    unitPrice = json['UnitPrice'];
    trackingNo = json['TrackingNo'];
    title = json['Title']??"";
    itemSkuID = json['SKU'];
    sellingPrice = json['SellingPrice'];
    quantity = double.parse(json['Quantity'].toString()).toInt();
    purchasedPrice = json['PurchasedPrice'];
    productId = json['ProductId'];
    posSkuId = json['PosSkuId'];
    pOS = json['POS'];
    pimSkuId = json['PimSkuId'];
    pIM = json['PIM'];
    overridePriceReason = json['OverridePriceReason'];
    overridePriceApproval = json['OverridePriceApproval'];
    overridePrice = json['OverridePrice'];
    marginValue = json['MarginValue'];
    margin = json['Margin'];
    isUpdating = false;
    records = asm.Records(childskus: [],quantity: "-1",productId: "null");
    lineItemStatus = json['LineItemStatus'];
    lineItemPurchaseChannel = json['LineItemPurchaseChannel'];
    lineItemPurchaseCategory = json['LineItemPurchaseCategory'];
    itemStatus = json['ItemStatus'];
    itemNumber = json['ItemNumber'];
    itemId = json['ItemId'];
    itemDesc = json['ItemDesc'];
    imageUrl = json['ImageUrl'];
    enterpriseSKU = json['EnterpriseSKU'];
    discountedMarginValue = json['DiscountedMarginValue'];
    discountedMargin = json['DiscountedMargin'];
    cost = json['Cost'];
    condition = json['Condition']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['WarrantyStyleDesc'] = this.warrantyStyleDesc;
    data['WarrantySkuId'] = this.warrantySkuId;
    data['WarrantyPrice'] = this.warrantyPrice;
    data['WarrantyId'] = this.warrantyId;
    data['WarrantyDisplayName'] = this.warrantyDisplayName;
    data['UnitPrice'] = this.unitPrice;
    data['TrackingNo'] = this.trackingNo;
    data['Title'] = this.title;
    data['SKU'] = this.itemSkuID;
    data['SellingPrice'] = this.sellingPrice;
    data['Quantity'] = this.quantity;
    data['PurchasedPrice'] = this.purchasedPrice;
    data['ProductId'] = this.productId;
    data['PosSkuId'] = this.posSkuId;
    data['POS'] = this.pOS;
    data['PimSkuId'] = this.pimSkuId;
    data['PIM'] = this.pIM;
    data['OverridePriceReason'] = this.overridePriceReason;
    data['OverridePriceApproval'] = this.overridePriceApproval;
    data['OverridePrice'] = this.overridePrice;
    data['MarginValue'] = this.marginValue;
    data['Margin'] = this.margin;
    data['LineItemStatus'] = this.lineItemStatus;
    data['LineItemPurchaseChannel'] = this.lineItemPurchaseChannel;
    data['LineItemPurchaseCategory'] = this.lineItemPurchaseCategory;
    data['ItemStatus'] = this.itemStatus;
    data['ItemNumber'] = this.itemNumber;
    data['ItemId'] = this.itemId;
    data['ItemDesc'] = this.itemDesc;
    data['ImageUrl'] = this.imageUrl;
    data['EnterpriseSKU'] = this.enterpriseSKU;
    data['DiscountedMarginValue'] = this.discountedMarginValue;
    data['DiscountedMargin'] = this.discountedMargin;
    data['Cost'] = this.cost;
    data['Condition'] = this.condition;
    return data;
  }

  @override
  List<Object?> get props => [
    warrantyStyleDesc,
    warrantySkuId,
    warrantyPrice,
    warrantyId,
    warrantyDisplayName,
    unitPrice,
    trackingNo,
    title,
    itemSkuID,
    sellingPrice,
    quantity,
    purchasedPrice,
    productId,
    posSkuId,
    pOS,
    pimSkuId,
    pIM,
    overridePriceReason,
    overridePriceApproval,
    overridePrice,
    marginValue,
    margin,
    lineItemStatus,
    lineItemPurchaseChannel,
    lineItemPurchaseCategory,
    itemStatus,
    itemNumber,
    records,
    isUpdating,
    itemId,
    itemDesc,
    imageUrl,
    enterpriseSKU,
    discountedMarginValue,
    discountedMargin,
    cost,
    condition
  ];
}*/

class BrandItems extends Equatable{
  String? unitPrice;
  String? quantity;
  String? orderNumber;
  String? orderID;
  String? itemSkuID;
  String? itemID;
  String? imageUrl;
  asm.Records? records;
  bool? isUpdating;
  String? description;
  String? condition;
  String? brandCode;

  BrandItems(
      {this.unitPrice,
        this.quantity,
        this.orderNumber,
        this.orderID,
        this.itemSkuID,
        this.itemID,
        this.records,
        this.isUpdating = false,
        this.imageUrl,
        this.description,
        this.condition,
        this.brandCode});

  BrandItems.fromJson(Map<String, dynamic> json) {
    unitPrice = json['UnitPrice'].toString() ??"0";
    quantity = json['Quantity'].toString();
    orderNumber = json['OrderNumber'];
    orderID = json['OrderID'];
    itemSkuID = json['ItemSkuID'];
    itemID = json['ItemID'];
    isUpdating = false;
    records = asm.Records(childskus: [],quantity: "-1",productId: "null");
    imageUrl = json['ImageUrl'];
    description = json['Description'];
    condition = json['Condition'];
    brandCode = json['BrandCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UnitPrice'] = this.unitPrice;
    data['Quantity'] = this.quantity;
    data['OrderNumber'] = this.orderNumber;
    data['OrderID'] = this.orderID;
    data['ItemSkuID'] = this.itemSkuID;
    data['ItemID'] = this.itemID;
    data['ImageUrl'] = this.imageUrl;
    data['Description'] = this.description;
    data['Condition'] = this.condition;
    data['BrandCode'] = this.brandCode;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    unitPrice,
    quantity,
    orderNumber,
    orderID,
    itemSkuID,
    itemID,
    records,
    isUpdating,
    imageUrl,
    description,
    condition,
    brandCode
  ];
}

