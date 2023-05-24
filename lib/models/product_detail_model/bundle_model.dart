
import 'package:equatable/equatable.dart';

import '../common_models/records_class_model.dart';

class ProductDetailBundlesModel {
  List<ProductRecommands>? productRecommands;
  String? message;

  ProductDetailBundlesModel({this.productRecommands, this.message});

  ProductDetailBundlesModel.fromJson(Map<String, dynamic> json) {
    if (json['productRecommands'] != null) {
      productRecommands = <ProductRecommands>[];
      json['productRecommands'].forEach((v) {
        productRecommands!.add(new ProductRecommands.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.productRecommands != null) {
      data['productRecommands'] =
          this.productRecommands!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class ProductRecommands extends Equatable{
  List<RecommendedProductSet>? recommendedProductSet;
  String? productName;
  String? productCode;
  bool? previous;
  bool? next;
  String? lineItemID;
  int? currentpage;

  ProductRecommands(
      {this.recommendedProductSet,
        this.productName,
        this.productCode,
        this.previous,
        this.next,
        this.lineItemID,
        this.currentpage});

  ProductRecommands.fromJson(Map<String, dynamic> json) {
    if (json['recommendedProductSet'] != null) {
      recommendedProductSet = <RecommendedProductSet>[];
      json['recommendedProductSet'].forEach((v) {
        recommendedProductSet!.add(new RecommendedProductSet.fromJson(v));
      });
    }
    else{
      recommendedProductSet = <RecommendedProductSet>[];
    }
    productName = json['ProductName'];
    productCode = json['ProductCode'];
    previous = json['previous'];
    next = json['next'];
    lineItemID = json['lineItemID'];
    currentpage = json['Currentpage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.recommendedProductSet != null) {
      data['recommendedProductSet'] =
          this.recommendedProductSet!.map((v) => v.toJson()).toList();
    }
    data['ProductName'] = this.productName;
    data['ProductCode'] = this.productCode;
    data['previous'] = this.previous;
    data['next'] = this.next;
    data['lineItemID'] = this.lineItemID;
    data['Currentpage'] = this.currentpage;
    return data;
  }

  @override
  List<Object?> get props => [
    recommendedProductSet,
    productName,
    productCode,
    previous,
    next,
    lineItemID,
    currentpage,
  ];
}

class RecommendedProductSet extends Equatable{
  String? trimName;
  String? tabName;
  Records? records;
  String? siteId;
  double? salePrice;
  bool? quantityFlag;
  int? quantity;
  String? productURL;
  String? productId;
  String? posSKU;
  String? name;
  String? itemSKU;
  String? imageURL;
  String? condition;

  RecommendedProductSet(
      {this.trimName,
        this.tabName,
        this.siteId,
        this.salePrice,
        this.quantityFlag,
        this.quantity,
        this.records,
        this.productURL,
        this.productId,
        this.posSKU,
        this.name,
        this.itemSKU,
        this.imageURL,
        this.condition});

  RecommendedProductSet.fromJson(Map<String, dynamic> json) {
    trimName = json['TrimName'];
    tabName = json['tabName'];
    records = Records(childskus: [],quantity: "-1",productId: "null",isUpdating: false);
    siteId = json['siteId'];
    salePrice = json['salePrice'];
    quantityFlag = json['quantityFlag'];
    quantity = json['quantity'];
    productURL = json['productURL'];
    productId = json['ProductId'];
    posSKU = json['posSKU'];
    name = json['name'];
    itemSKU = json['itemSKU'];
    imageURL = json['imageURL'];
    condition = json['Condition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TrimName'] = this.trimName;
    data['tabName'] = this.tabName;
    data['siteId'] = this.siteId;
    data['salePrice'] = this.salePrice;
    data['quantityFlag'] = this.quantityFlag;
    data['quantity'] = this.quantity;
    data['productURL'] = this.productURL;
    data['ProductId'] = this.productId;
    data['posSKU'] = this.posSKU;
    data['name'] = this.name;
    data['itemSKU'] = this.itemSKU;
    data['imageURL'] = this.imageURL;
    data['Condition'] = this.condition;
    return data;
  }

  @override
  List<Object?> get props => [
    trimName,
    tabName,
    siteId,
    salePrice,
    quantityFlag,
    quantity,
    records,
    productURL,
    productId,
    posSKU,
    name,
    itemSKU,
    imageURL,
    condition,
  ];
}
