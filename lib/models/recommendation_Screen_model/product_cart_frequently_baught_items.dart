import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;

class ProductCartFrequentlyBaughtItemsModel extends Equatable{
  ProductCartFrequentlyBaughtItemsModel({
    required this.productCartOthers,
    required this.message,
  });
  late final List<ProductCartOthers> productCartOthers;
  late final String message;

  ProductCartFrequentlyBaughtItemsModel.fromJson(Map<String, dynamic> json) {
    if (json['productCartOthers'] != null &&
        json['productCartOthers'].isNotEmpty) {
      productCartOthers = List.from(json['productCartOthers'])
          .map((e) => ProductCartOthers.fromJson(e))
          .toList();
    } else {
      productCartOthers = [];
    }

    message = json['message'];
  }


  @override
  // TODO: implement props
  List<Object?> get props => [productCartOthers,message];
}

class ProductCartOthers  extends Equatable{
  ProductCartOthers({
    required this.recommendedProductSet,
    required this.productName,
    required this.productCode,
    required this.previous,
    required this.next,
    required this.lineItemID,
    required this.currentpage,
  });
  late final List<RecommendedProductSet> recommendedProductSet;
  late final String productName;
  late final String productCode;
  late final bool previous;
  late final bool next;
  late final String lineItemID;
  late final int currentpage;

  ProductCartOthers.fromJson(Map<String, dynamic> json) {
    if (json['recommendedProductSet'] != null &&
        json['recommendedProductSet'].isNotEmpty) {
      recommendedProductSet = List.from(json['recommendedProductSet'])
          .map((e) => RecommendedProductSet.fromJson(e))
          .toList();
    } else {
      recommendedProductSet = [];
    }

    productName = json['ProductName'] ?? "";
    productCode = json['ProductCode'] ?? "";
    previous = json['previous'] ?? false;
    next = json['next'] ?? false;
    lineItemID = json['lineItemID'] ?? "";
    currentpage = json['Currentpage'] ?? 0;
  }


  @override
  // TODO: implement props
  List<Object?> get props => [ productName,
  productCode,
  previous,
  next,
  lineItemID,
    recommendedProductSet,
  currentpage];
}

class RecommendedProductSet extends Equatable{
  RecommendedProductSet({
    required this.trimName,
    required this.isUpdating,
    required this.tabName,
    required this.records,
    required this.siteId,
    required this.salePrice,
    required this.quantityFlag,
    required this.quantity,
    required this.productURL,
    required this.productId,
    required this.posSKU,
    required this.name,
    required this.itemSKU,
    required this.imageURL,
    required this.condition,
    required this.isItemOnline,
    required this.isItemOutOfStock,
  });
  late final String trimName;
  late asm.Records records;
  late final String tabName;
  late bool isUpdating;
  late bool? isItemOnline;
  late bool? isItemOutOfStock;
  late bool? hasInfo;
  late final String siteId;
  late final double? salePrice;
  late final bool quantityFlag;
  late final int quantity;
  late final String productURL;
  late final String productId;
  late final String posSKU;
  late final String name;
  late final String itemSKU;
  late final String imageURL;
  late final String condition;

  RecommendedProductSet.fromJson(Map<String, dynamic> json) {
    trimName = json['TrimName'] ?? "";
    isUpdating = false;
    isItemOutOfStock = false;
    isItemOnline = false;
    hasInfo = false;
    tabName = json['tabName'] ?? "";
    siteId = json['siteId'] ?? "";
    salePrice = json['salePrice'] ?? 0.0;
    records = asm.Records(childskus: [],quantity: "-1",productId: "null");
    quantityFlag = json['quantityFlag'] ?? true;
    quantity = json['quantity'] ?? 0;
    productURL = json['productURL'] ?? "";
    productId = json['ProductId'] ?? "";
    posSKU = json['posSKU'] ?? "";
    name = json['name'] ?? "";
    itemSKU = json['itemSKU'] ?? "";
    imageURL = json['imageURL'] ?? "";
    condition = json['Condition'] ?? "";
  }

  @override
  // TODO: implement props
  List<Object?> get props => [hasInfo,isUpdating,trimName,tabName,siteId,salePrice,records,quantityFlag,quantity,productURL,productId,posSKU,name,itemSKU,imageURL,condition,isItemOnline,isItemOutOfStock];
}
