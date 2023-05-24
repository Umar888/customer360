import 'package:equatable/equatable.dart';

class OrderLookupModel extends Equatable {
  OrderLookupModel({
    this.storeName,
    this.storeId,
    this.storeDirection,
    this.shipZip,
    this.orderStatus,
    this.orderNo,
    this.orderId,
    this.orderDate,
    this.items,
    this.grandTotal,
    this.fulfillmentType,
    this.eventType,
    this.entryType,
    this.brand,
    this.quoteNo,
  });

  String? storeName;
  String? storeId;
  String? storeDirection;
  String? shipZip;
  String? orderStatus;
  String? orderNo;
  String? orderId;
  DateTime? orderDate;
  List<Item?>? items;
  double? grandTotal;
  String? fulfillmentType;
  String? eventType;
  String? entryType;
  String? brand;
  String? quoteNo;

  factory OrderLookupModel.fromJson(Map<String, dynamic> json) {
    var status = json["OrderStatus"];
    if (status != null) {
      status =
          status[0].toString().toUpperCase() + status.toString().substring(1);
    }
    return OrderLookupModel(
      storeName: json["StoreName"],
      storeId: json["StoreID"],
      storeDirection: json["StoreDirection"],
      shipZip: json["ShipZip"],
      orderStatus: status,
      orderNo: json["OrderNo"],
      orderId: json["OrderId"],
      orderDate: (json["OrderDate"] ?? 'null') == 'null'
          ? null
          : DateTime.parse(json["OrderDate"]),
      items: json["Items"] == null
          ? []
          : List<Item?>.from(json["Items"]!.map((x) => Item.fromJson(x))),
      grandTotal: json["GrandTotal"]?.toDouble(),
      fulfillmentType: json["FulfillmentType"],
      eventType: json["EventType"],
      entryType: json["EntryType"],
      brand: json["Brand"],
      quoteNo: json["QuoteNo"],
    );
  }

  Map<String, dynamic> toJson() => {
        "StoreName": storeName,
        "StoreID": storeId,
        "StoreDirection": storeDirection,
        "ShipZip": shipZip,
        "OrderStatus": orderStatus,
        "OrderNo": orderNo,
        "OrderId": orderId,
        "OrderDate": orderDate?.toIso8601String(),
        "Items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x!.toJson())),
        "GrandTotal": grandTotal,
        "FulfillmentType": fulfillmentType,
        "EventType": eventType,
        "EntryType": entryType,
        "Brand": brand,
        "QuoteNo": quoteNo,
      };

  @override
  List<Object?> get props => [
        storeId,
        storeName,
        storeDirection,
        shipZip,
        orderStatus,
        orderNo,
        orderId,
        orderDate,
        grandTotal,
        fulfillmentType,
        entryType,
        entryType,
        brand,
        quoteNo,
      ];
}

class Item {
  Item({
    this.unitPrice,
    this.trackingNo,
    this.statusDate,
    this.orderLineKey,
    this.orderedQuantity,
    this.lineItem,
    this.itemStatus,
    this.itemId,
    this.itemDesc,
    this.imageUrl,
  });

  String? unitPrice;
  String? trackingNo;
  String? statusDate;
  String? orderLineKey;
  int? orderedQuantity;
  int? lineItem;
  String? itemStatus;
  String? itemId;
  String? itemDesc;
  String? imageUrl;

  factory Item.fromJson(Map<String, dynamic> json) {
    var status = json["ItemStatus"];
    if (status != null) {
      status =
          status[0].toString().toUpperCase() + status.toString().substring(1);
    }
    return Item(
      unitPrice: json["UnitPrice"],
      trackingNo: json["TrackingNo"],
      statusDate: json["StatusDate"],
      orderLineKey: json["OrderLineKey"],
      orderedQuantity: json["OrderedQuantity"],
      lineItem: json["LineItem"],
      itemStatus: status,
      itemId: json["ItemID"],
      itemDesc: json["ItemDesc"],
      imageUrl: json["ImageUrl"],
    );
  }

  Map<String, dynamic> toJson() => {
        "UnitPrice": unitPrice,
        "TrackingNo": trackingNo,
        "StatusDate": statusDate,
        "OrderLineKey": orderLineKey,
        "OrderedQuantity": orderedQuantity,
        "LineItem": lineItem,
        "ItemStatus": itemStatus,
        "ItemID": itemId,
        "ItemDesc": itemDesc,
        "ImageUrl": imageUrl,
      };
}
