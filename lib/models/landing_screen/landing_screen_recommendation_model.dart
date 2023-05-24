import 'package:equatable/equatable.dart';

class LandingScreenRecommendationModel extends Equatable{
  List<ProductBrowsingOthers>? productBrowsingOthers;
  List<ProductBrowsing>? productBrowsing;
  String? message;
  int? status;

  LandingScreenRecommendationModel(
      {this.productBrowsingOthers, this.productBrowsing, this.status, this.message});

  LandingScreenRecommendationModel.fromJson(Map<String, dynamic> json) {
    if (json['productBrowsingOthers'] != null) {
      productBrowsingOthers = <ProductBrowsingOthers>[];
      json['productBrowsingOthers'].forEach((v) {
        productBrowsingOthers!.add(ProductBrowsingOthers.fromJson(v));
      });
    }
    else{
      productBrowsingOthers = <ProductBrowsingOthers>[];
    }
    if (json['productBrowsing'] != null && json['productBrowsing'].isNotEmpty) {
      productBrowsing = <ProductBrowsing>[];
      json['productBrowsing'].forEach((v) {
        productBrowsing!.add(ProductBrowsing.fromJson(v));
      });
    }
    else{
      productBrowsing = <ProductBrowsing>[];
      print(productBrowsing);
    }
    message = json['message'];
    status = 200;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (productBrowsingOthers != null) {
      data['productBrowsingOthers'] =
          productBrowsingOthers!.map((v) => v.toJson()).toList();
    }
    if (productBrowsing != null) {
      data['productBrowsing'] =
          productBrowsing!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }

  @override
  List<Object?> get props => [
    productBrowsing,
    productBrowsingOthers,
    message,
    status,
  ];
}

class ProductBrowsingOthers extends Equatable{
  List<RecommendedProductSet>? recommendedProductSet;

  ProductBrowsingOthers({this.recommendedProductSet});

  ProductBrowsingOthers.fromJson(Map<String, dynamic> json) {
    if (json['recommendedProductSet'] != null) {
      recommendedProductSet = <RecommendedProductSet>[];
      json['recommendedProductSet'].forEach((v) {
        recommendedProductSet!.add(RecommendedProductSet.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (recommendedProductSet != null) {
      data['recommendedProductSet'] =
          recommendedProductSet!.map((v) => v.toJson()).toList();
    }
    return data;
  }
  @override
  List<Object?> get props => [recommendedProductSet];

}

class RecommendedProductSet extends Equatable{
  String? trimName;
  String? tabName;
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
  bool? outOfStock;
  bool? noInfo;
  bool? inStore;

  RecommendedProductSet(
      {this.trimName,
        this.tabName,
        this.outOfStock,
        this.noInfo,
        this.inStore,
        this.siteId,
        this.salePrice,
        this.quantityFlag,
        this.quantity,
        this.productURL,
        this.productId,
        this.posSKU,
        this.name,
        this.itemSKU,
        this.imageURL,
        this.condition,
      });

  RecommendedProductSet.fromJson(Map<String, dynamic> json) {
    trimName = json['TrimName'];
    outOfStock=false;
    noInfo=true;
    inStore=false;
    tabName = json['tabName'];
    siteId = json['siteId'];
    salePrice = json['salePrice']??"0.00";
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TrimName'] = trimName;
    data['tabName'] = tabName;
    data['siteId'] = siteId;
    data['salePrice'] = salePrice;
    data['quantityFlag'] = quantityFlag;
    data['quantity'] = quantity;
    data['productURL'] = productURL;
    data['ProductId'] = productId;
    data['posSKU'] = posSKU;
    data['name'] = name;
    data['itemSKU'] = itemSKU;
    data['imageURL'] = imageURL;
    data['Condition'] = condition;
    return data;
  }
  @override
  List<Object?> get props => [
    trimName,
    tabName,
    outOfStock,
    noInfo,
    inStore,
    siteId,
    salePrice,
    quantityFlag,
    quantity,
    productURL,
    productId,
    posSKU,
    name,
    itemSKU,
    imageURL,
    condition,
  ];

}

class ProductBrowsing extends Equatable{
  List<RecommendedProductSet>? recommendedProductSet;

  ProductBrowsing({this.recommendedProductSet});

  ProductBrowsing.fromJson(Map<String, dynamic> json) {
    if (json['recommendedProductSet'] != null) {
      recommendedProductSet = <RecommendedProductSet>[];
      json['recommendedProductSet'].forEach((v) {
        recommendedProductSet!.add(RecommendedProductSet.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (recommendedProductSet != null) {
      data['recommendedProductSet'] =
          recommendedProductSet!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [recommendedProductSet];
}
