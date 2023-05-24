import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';

class CartArguments {
  final String orderId;
  final String orderLineItemId;
  final String orderNumber;
  final String orderDate;
  final String userName;
  final CustomerInfoModel customerInfoModel;
  final String userId;
  final String email;
  final String phone;
  final bool isFromNotificaiton;

  CartArguments(
      {required this.orderId,
      required this.orderLineItemId,
      required this.orderNumber,
      required this.orderDate,
      required this.userName,
      required this.customerInfoModel,
      required this.userId,
      required this.email,
      required this.phone,
      this.isFromNotificaiton = false});
}
