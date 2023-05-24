import 'package:equatable/equatable.dart';

class ApprovalModel extends Equatable {
  ApprovalModel({
    this.shippingAndHandling,
    this.shippingAdjustment,
    this.shipmentOverrideReason,
    this.rejectUrl,
    this.recordId,
    this.orderNumber,
    this.approveUrl,
    this.approvalRequest,
    this.unitPrice,
    this.quantity,
    this.overridePriceReason,
    this.overridePriceApproval,
    this.overridePrice,
    this.itemDesc,
    this.approvalProcessUrl,
    this.notificationDate,
    this.createdDate,
    this.lastModifiedDate,
    this.imageUrl,
  });

  //For Shipping
  double? shippingAndHandling;
  double? shippingAdjustment;
  String? shipmentOverrideReason;
  String? orderNumber;
  String? approvalRequest;

  //For Price
  double? unitPrice;
  double? quantity;
  String? overridePriceReason;
  String? overridePriceApproval;
  double? overridePrice;
  String? itemDesc;

  //For both
  String? recordId;
  String? approveUrl;
  String? rejectUrl;
  String? approvalProcessUrl;
  String? notificationDate;
  DateTime? createdDate;
  DateTime? lastModifiedDate;
  String? imageUrl;

  factory ApprovalModel.fromJson(Map<String, dynamic> json) => ApprovalModel(
        shippingAndHandling: (json["ShippingAndHandling"] is double ||
                json["ShippingAndHandling"] == null)
            ? json["ShippingAndHandling"]
            : double.parse(json["ShippingAndHandling"].toString()),
        shippingAdjustment: (json["ShippingAdjustment"] is double ||
                json["ShippingAdjustment"] == null)
            ? json["ShippingAdjustment"]
            : double.parse(json["ShippingAdjustment"].toString()),
        shipmentOverrideReason: json["ShipmentOverrideReason"],
        rejectUrl: json["RejectUrl"],
        recordId: json["RecordId"],
        orderNumber: json["OrderNumber"],
        approveUrl: json["ApproveUrl"],
        approvalRequest: json["ApprovalRequest"],
        unitPrice: (json["UnitPrice"] is double || json["UnitPrice"] == null)
            ? json["UnitPrice"]
            : double.parse(json["UnitPrice"].toString()),
        quantity: (json["Quantity"] is double || json["Quantity"] == null)
            ? json["Quantity"]
            : double.parse(json["Quantity"].toString()),
        overridePriceReason: json["OverridePriceReason"],
        overridePriceApproval: json["OverridePriceApproval"],
        overridePrice:
            (json["OverridePrice"] is double || json["OverridePrice"] == null)
                ? json["OverridePrice"]
                : double.parse(json["OverridePrice"].toString()),
        itemDesc: json["ItemDesc"],
        approvalProcessUrl: json["ApprovalProcessUrl"],
        notificationDate: json["NotificationDate"],
        imageUrl: json["ImageUrl"],
        lastModifiedDate: json["LastModifiedDate"] == null
            ? null
            : DateTime.parse(json["LastModifiedDate"]),
        createdDate: json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "ShippingAndHandling": shippingAndHandling,
        "ShippingAdjustment": shippingAdjustment,
        "ShipmentOverrideReason": shipmentOverrideReason,
        "RejectUrl": rejectUrl,
        "RecordId": recordId,
        "OrderNumber": orderNumber,
        "ApproveUrl": approveUrl,
        "ApprovalRequest": approvalRequest,
        "UnitPrice": unitPrice,
        "Quantity": quantity,
        "OverridePriceReason": overridePriceReason,
        "OverridePriceApproval": overridePriceApproval,
        "OverridePrice": overridePrice,
        "ItemDesc": itemDesc,
        "ApprovalProcessUrl": approvalProcessUrl,
        "NotificationDate": notificationDate,
        "ImageUrl": imageUrl,
        "LastModifiedDate": lastModifiedDate?.toIso8601String(),
        "CreatedDate": createdDate?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        recordId,
        orderNumber,
        unitPrice,
        quantity,
        shippingAndHandling,
        shippingAdjustment,
        shipmentOverrideReason,
        overridePriceReason,
        overridePriceApproval,
        overridePriceReason,
        itemDesc,
      ];
}
