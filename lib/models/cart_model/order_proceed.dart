class OrderProceed {
  String? orderId;
  String? message;

  OrderProceed({this.orderId, this.message});

  OrderProceed.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['message'] = message;
    return data;
  }
}