class OrderItem {
  final double? itemPrice;
  final String? trackingNumber;
  final String? orderLineKey;
  final int? orderedQuantity;
  final int? lineItem;
  final String? status;
  final String? itemId;
  final String? description;
  final String? imageUrl;
  final String? deliveredDate;
  final String? deliveryDays;
  final String? warrantyDays;
  final bool? warrantyEligible;
  bool? isLoading;
  bool? isForceClosing;
  bool? isCompleting;
  bool? isForceClosed;
  bool? isCompleted;
  bool? isUpdateRescheduling;
  final String? taskType;
  final String? deliveredDateTime;
  String? itemStatus;
  String? feedback;
  String? feedbackDateTime;
  String? OrderLineKey;
  String? ItemDesc;

  OrderItem._({
    this.status,
    this.itemPrice,
    this.imageUrl,
    this.description,
    this.itemId,
    this.isForceClosing,
    this.isCompleting,
    this.isForceClosed,
    this.isCompleted,
    this.lineItem,
    this.isLoading,
    this.isUpdateRescheduling,
    this.orderedQuantity,
    this.orderLineKey,
    this.trackingNumber,
    this.deliveredDate,
    this.deliveryDays,
    this.warrantyDays,
    this.feedback,
    this.feedbackDateTime,
    this.itemStatus,
    this.ItemDesc,
    this.OrderLineKey,
    this.warrantyEligible,
    this.taskType,
    this.deliveredDateTime,
  });

  factory OrderItem.fromTaskJson(Map<String, dynamic> json) {
    return OrderItem._(
        itemPrice: double.tryParse(json['UnitPrice']),
        trackingNumber: json['TrackingNo'],
        isLoading: false,
        isForceClosing: false,
        isCompleting: false,
        isForceClosed: false,
        isCompleted: false,
        isUpdateRescheduling: false,
        orderLineKey: json['OrderLineKey'],
        orderedQuantity: json['OrderedQuantity']??0,
        lineItem: json['LineItem'],
        status: json['ItemStatus'],
        itemId: json['ItemID'],
        description: json['ItemShortDesc'],
        feedback: "",
        feedbackDateTime: "",
        imageUrl: json['ImageUrl'],
        deliveryDays: json['deliveryDays'],
        OrderLineKey: json['OrderLineKey'],
        ItemDesc: json['ItemDesc'],
        warrantyEligible: json['warrantyEligible'],
        warrantyDays: json['warrantyDays']);
  }

  factory OrderItem.fromTaskOrderLineJson(Map<String, dynamic> json) {
    return OrderItem._(
      itemPrice: double.tryParse(json['UnitPrice']),
      orderedQuantity: int.tryParse(json['OrderedQty']),
      description: json['ItemShortDesc'],
      itemId: json['ItemID'],
      imageUrl: json['ImageUrl'],
      isLoading: false,
      isForceClosing: false,
      isForceClosed: false,
      isCompleted: false,
      isCompleting: false,
      feedback: "",
      feedbackDateTime: "",
      isUpdateRescheduling: false,
      deliveredDate: json['deliveredDate'],
      warrantyEligible: json['warrantyEligible'],
      deliveryDays: json['deliveryDays'],
      warrantyDays: json['warrantyDays'],
      taskType: json['TaskType'],
      deliveredDateTime: json['deliveredDateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemId': itemId,
      'ItemShortDesc': description,
      'UnitPrice': itemPrice,
      'TaskType':taskType,
      'OrderedQty': orderedQuantity,
      'ItemStatus': itemStatus,
    };
  }
}
