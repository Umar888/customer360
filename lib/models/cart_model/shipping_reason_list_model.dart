class ShippingReasonList {
  List<String>? shippingOverrideReasonList;

  ShippingReasonList({this.shippingOverrideReasonList});

  ShippingReasonList.fromJson(Map<String, dynamic> json) {
    shippingOverrideReasonList =
        json['shippingOverrideReasonList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shippingOverrideReasonList'] = this.shippingOverrideReasonList;
    return data;
  }
}
