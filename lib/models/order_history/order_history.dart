import 'package:equatable/equatable.dart';

class OrderHistory extends Equatable{
  bool? isStoreOnline;
  String? storeID;
  String? storeStatus;
  String? dateOfOrder;
  List<OrderItems>? orderItems;
  OrderHistory({
    this.storeID,
    this.isStoreOnline,
    this.storeStatus,
    this.dateOfOrder,
    this.orderItems
  });
  @override
  List<Object?> get props => [storeStatus,isStoreOnline,storeID,dateOfOrder,orderItems];

}
// ignore: must_be_immutable
class OrderItems extends Equatable{
  bool? isItemOnline;
  bool? isItemOutOfStock;
  bool? isNetwork = false;
  String? itemSku;
  String? itemPrice;
  String? itemPic;
  String? itemName;
  OrderItems({
    this.isItemOnline,
    this.itemSku,
    this.isItemOutOfStock,
    this.itemPrice,
    this.isNetwork,
    this.itemPic,
    this.itemName,
  });
  @override
  List<Object?> get props => [isNetwork,itemSku,isItemOnline,isItemOutOfStock,itemPrice,itemPic,itemName];

}
