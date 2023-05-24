class AddToCartAndCreateOrder {
  String? orderId;
  String? oliRecId;
  String? oliCount;
  bool? isWarrantyFlag;

  AddToCartAndCreateOrder({this.orderId, this.oliRecId, this.oliCount, this.isWarrantyFlag});

  AddToCartAndCreateOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    oliRecId = json['oliRecId'];
    oliCount = json['oliCount'];
    isWarrantyFlag = json['isWarrantyFlag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['oliRecId'] = oliRecId;
    data['oliCount'] = oliCount;
    data['isWarrantyFlag'] = isWarrantyFlag;
    return data;
  }
}
