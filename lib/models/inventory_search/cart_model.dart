import 'package:equatable/equatable.dart';

class ItemsOfCart extends Equatable {
  String itemId;
  String itemQuantity;
  String itemName;
  String itemPrice;
  String itemProCoverage;
  ItemsOfCart({
    required this.itemQuantity,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    this.itemProCoverage = "0",
  });
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quantity'] = itemQuantity;
    data['item_id'] = itemId;
    data['item_name'] = itemName;
    data['item_price'] = itemPrice;
    data['item_pro_coverage'] = itemProCoverage;
    return data;
  }

  @override
  List<Object?> get props => [
        itemQuantity,
        itemId,
        itemName,
        itemPrice,
        itemProCoverage,
      ];
}
