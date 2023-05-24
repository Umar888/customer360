import 'package:equatable/equatable.dart';

class LandingScreenRecommendationModelBuyAgain extends Equatable{
  List<ProductBuyAgain>? productBuyAgain;
  String? message;

  LandingScreenRecommendationModelBuyAgain(
      {this.productBuyAgain, this.message});

  LandingScreenRecommendationModelBuyAgain.fromJson(Map<String, dynamic> json) {
    if (json['productBuyAgain'] != null) {
      productBuyAgain = <ProductBuyAgain>[];
      json['productBuyAgain'].forEach((v) {
        productBuyAgain!.add(new ProductBuyAgain.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.productBuyAgain != null) {
      data['productBuyAgain'] =
          this.productBuyAgain!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
  @override
  List<Object?> get props => [message, productBuyAgain];

}

class ProductBuyAgain extends Equatable{
  Attributes? attributes;
  String? id;
  String? gCOrderC;
  String? descriptionC;
  String? itemIdFormulaC;
  String? pIMSkuC;
  String? itemIdC;
  String? condtionC;
  String? imageURLC;
  double? itemPriceC;
  int? quantityC;
  double? warrantyPriceC;
  String? itemSKUC;
  GCOrderR? gCOrderR;
  bool? outOfStock;
  bool? noInfo;
  bool? inStore;


  ProductBuyAgain(
      {
        this.attributes,
        this.id,
        this.gCOrderC,
        this.descriptionC,
        this.itemIdFormulaC,
        this.pIMSkuC,
        this.itemIdC,
        this.condtionC,
        this.imageURLC,
        this.outOfStock,
        this.noInfo,
        this.inStore,
        this.itemPriceC,
        this.quantityC,
        this.warrantyPriceC,
        this.itemSKUC,
        this.gCOrderR,
      });

  ProductBuyAgain.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    outOfStock=false;
    noInfo=true;
    inStore=false;
    gCOrderC = json['GC_Order__c'];
    descriptionC = json['Description__c'];
    itemIdFormulaC = json['Item_Id_formula__c'];
    pIMSkuC = json['PIM_Sku__c'];
    itemIdC = json['Item_Id__c'];
    condtionC = json['Condtion__c'];
    imageURLC = json['Image_URL__c'];
    itemPriceC = json['Item_Price__c'];
    quantityC = json['Quantity__c'];
    warrantyPriceC = json['Warranty_price__c'];
    itemSKUC = json['Item_SKU__c'];
    gCOrderR = json['GC_Order__r'] != null
        ? new GCOrderR.fromJson(json['GC_Order__r'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['GC_Order__c'] = this.gCOrderC;
    data['Description__c'] = this.descriptionC;
    data['Item_Id_formula__c'] = this.itemIdFormulaC;
    data['PIM_Sku__c'] = this.pIMSkuC;
    data['Item_Id__c'] = this.itemIdC;
    data['Condtion__c'] = this.condtionC;
    data['Image_URL__c'] = this.imageURLC;
    data['Item_Price__c'] = this.itemPriceC;
    data['Quantity__c'] = this.quantityC;
    data['Warranty_price__c'] = this.warrantyPriceC;
    data['Item_SKU__c'] = this.itemSKUC;
    if (this.gCOrderR != null) {
      data['GC_Order__r'] = this.gCOrderR!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [
    attributes,
    id,
    gCOrderC,
    descriptionC,
    itemIdFormulaC,
    pIMSkuC,
    itemIdC,
    condtionC,
    imageURLC,
    outOfStock,
    noInfo,
    inStore,
    itemPriceC,
    quantityC,
    warrantyPriceC,
    itemSKUC,
    gCOrderR,
  ];

}

class Attributes extends Equatable{
  String? type;
  String? url;

  Attributes({this.type, this.url});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['url'] = this.url;
    return data;
  }
  @override
  List<Object?> get props => [type, url];

}

class GCOrderR extends Equatable{
  Attributes? attributes;
  String? id;
  String? siteIdC;
  String? name;
  String? customerC;
  CustomerR? customerR;

  GCOrderR(
      {this.attributes,
        this.id,
        this.siteIdC,
        this.name,
        this.customerC,
        this.customerR,
      });

  GCOrderR.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    siteIdC = json['Site_Id__c'];
    name = json['Name'];
    customerC = json['Customer__c'];
    customerR = json['Customer__r'] != null
        ? new CustomerR.fromJson(json['Customer__r'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Site_Id__c'] = this.siteIdC;
    data['Name'] = this.name;
    data['Customer__c'] = this.customerC;
    if (this.customerR != null) {
      data['Customer__r'] = this.customerR!.toJson();
    }
    return data;
  }
  @override
  List<Object?> get props => [
    attributes,
    id,
    siteIdC,
    name,
    customerC,
    customerR,
  ];

}

class CustomerR extends Equatable{
  Attributes? attributes;
  String? id;
  String? personEmail;

  CustomerR({this.attributes, this.id, this.personEmail});

  CustomerR.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    personEmail = json['PersonEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['PersonEmail'] = this.personEmail;
    return data;
  }
  @override
  List<Object?> get props => [attributes, id, personEmail];

}
