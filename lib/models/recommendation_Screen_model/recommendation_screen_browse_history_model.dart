import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;

class RecommendationScreenModel extends Equatable {
  RecommendationScreenModel({
    required this.productBrowsingOthers,
    required this.productBrowsing,
    required this.message,
  });
  late final List<ProductBrowsingOthers> productBrowsingOthers;
  late final List<ProductBrowsing> productBrowsing;
  late final String message;

  RecommendationScreenModel.fromJson(Map<String, dynamic> json) {
    if (json['productBrowsingOthers'] != null &&
        json['productBrowsingOthers'].isNotEmpty) {
      productBrowsingOthers = List.from(json['productBrowsingOthers'])
          .map((e) => ProductBrowsingOthers.fromJson(e))
          .toList();
    } else {
      productBrowsingOthers = [];
    }
    if (json['productBrowsing'] != null && json['productBrowsing'].isNotEmpty) {
      productBrowsing = List.from(json['productBrowsing'])
          .map((e) => ProductBrowsing.fromJson(e))
          .toList();
    } else {
      productBrowsing = [];
    }

    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
    };
  }

  @override
  List<Object?> get props => [message,productBrowsing,productBrowsingOthers];
}

class ProductBrowsingOthers extends Equatable {
  ProductBrowsingOthers({
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

  ProductBrowsingOthers.fromJson(Map<String, dynamic> json) {
    if (json['recommendedProductSet'] != null) {
      recommendedProductSet = List.from(json['recommendedProductSet'])
          .map((e) => RecommendedProductSet.fromJson(e))
          .toList();
    } else {
      recommendedProductSet = [];
    }

    productName = json['ProductName'] ?? "";
    productCode = json['ProductCode'] ?? "";
    previous = json['previous'] ?? true;
    next = json['next'] ?? true;
    lineItemID = json['lineItemID'] ?? "";
    currentpage = json['Currentpage'] ?? 0;
  }

  @override
  List<Object?> get props => [productName,productCode,previous,next,lineItemID,currentpage];
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
  late final String tabName;
  late asm.Records records;
  late bool isUpdating;
  late bool? isItemOnline;
  late bool? hasInfo;
  late bool? isItemOutOfStock;
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
    hasInfo = false;
    isItemOutOfStock = false;
    isItemOnline = false;
    records = asm.Records(childskus: [],quantity: "-1",productId: "null");
    tabName = json['tabName'] ?? "";
    siteId = json['siteId'] ?? "";
    salePrice = json['salePrice'] ?? 0.0;
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

class ProductBrowsing extends Equatable{
  ProductBrowsing({
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

  ProductBrowsing.fromJson(Map<String, dynamic> json) {
    if (json['recommendedProductSet'] != null) {
      recommendedProductSet = List.from(json['recommendedProductSet'])
          .map((e) => RecommendedProductSet.fromJson(e))
          .toList();
    } else {
      recommendedProductSet = [];
    }

    productName = json['ProductName'] ?? '';
    productCode = json['ProductCode'] ?? '';
    previous = json['previous'] ?? false;
    next = json['next'] ?? false;
    lineItemID = json['lineItemID'] ?? '';
    currentpage = json['Currentpage'] ?? 0;
  }

  @override
  List<Object?> get props => [recommendedProductSet,productName,productCode,previous,next,lineItemID,currentpage];
}
