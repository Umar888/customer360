import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;

class FavouriteBrandScreenList extends Equatable{
  FavouriteBrandScreenList({
    required this.brands,
  });
  late final List<Brands> brands;
  final List<Items> combinedList = [];

  FavouriteBrandScreenList.fromJson(Map<String, dynamic> json) {
    if (json['brands'] != null && json['brands'].isNotEmpty) {
      brands =
          List.from(json['brands']).map((e) => Brands.fromJson(e)).toList();
    } else {
      brands = [];
    }
    if (brands.isNotEmpty) {
      for (var i = 0; i < brands.length; i++) {
        for (var j = 0; j < brands[i].items.length; j++) {
          combinedList.add(brands[i].items[j]);
        }
      }
    } else {}
  }

  @override
  // TODO: implement props
  List<Object?> get props => [brands,combinedList];
}

class Brands extends Equatable{
  Brands({
    required this.items,
    required this.brandIconName,
    required this.brand,
  });
  late final List<Items> items;
  late final String brandIconName;
  late final String brand;

  Brands.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null && json['items'].isNotEmpty) {
      items = List.from(json['items']).map((e) => Items.fromJson(e)).toList();
    } else {
      items = [];
    }

    brandIconName = json['brandIconName'] ?? '';
    brand = json['brand'] ?? '';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [items,brandIconName,brand];
}

class Items extends Equatable {
  Items({
    required this.unitPrice,
    required this.quantity,
    required this.orderNumber,
    required this.orderID,
    required this.itemSkuID,
    required this.itemID,
    required this.imageUrl,
    required this.records,
    required this.isUpdating,
    required this.description,
    required this.condition,
    required this.brandCode,
  });
  late final String unitPrice;
  late asm.Records records;
  late bool isUpdating;
  late final String quantity;
  late final String orderNumber;
  late final String orderID;
  late final String itemSkuID;
  late final String itemID;
  late final String imageUrl;
  late final String description;
  late final String condition;
  late final String brandCode;

  Items.fromJson(Map<String, dynamic> json) {
    unitPrice = json['UnitPrice'];
    isUpdating = false;
    records = asm.Records(childskus: [],quantity: "-1",productId: "null");
    quantity = json['Quantity'];
    orderNumber = json['OrderNumber'];
    orderID = json['OrderID'];
    itemSkuID = json['ItemSkuID'];
    itemID = json['ItemID'];
    imageUrl = json['ImageUrl'];
    description = json['Description'];
    condition = json['Condition'];
    brandCode = json['BrandCode'];
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    unitPrice,
    quantity,
    orderNumber,
    orderID,
    itemSkuID,
    itemID,
    imageUrl,
    records,
    isUpdating,
    description,
    condition,
    brandCode
  ];
}
