import 'package:equatable/equatable.dart';

class DiscountModel extends Equatable{
  DiscountModel({
    this.skuId,
    this.quantity,
    this.orderDiscountShare,
    this.orderDiscountPromoId,
    this.orderDiscountCouponCode,
  });

  String? skuId;
  String? quantity;
  String? orderDiscountShare;
  String? orderDiscountPromoId;
  String? orderDiscountCouponCode;

  factory DiscountModel.fromJson(Map<String, dynamic> json) => DiscountModel(
        skuId: json["SKUId"],
        quantity: json["quantity"],
        orderDiscountShare: json["orderDiscountShare"],
        orderDiscountPromoId: json["orderDiscountPromoId"],
        orderDiscountCouponCode: json["orderDiscountCouponCode"],
      );

  Map<String, dynamic> toJson() => {
        "SKUId": skuId,
        "quantity": quantity,
        "orderDiscountShare": orderDiscountShare,
        "orderDiscountPromoId": orderDiscountPromoId,
        "orderDiscountCouponCode": orderDiscountCouponCode,
      };

  @override
  List<Object?> get props => [
    skuId,
    quantity,
    orderDiscountShare,
    orderDiscountPromoId,
    orderDiscountCouponCode,
  ];
}
