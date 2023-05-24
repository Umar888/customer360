import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;

class BuyAgainModel extends Equatable{
  BuyAgainModel({
    required this.productBuyAgainOthers,
    required this.productBuyAgain,
    required this.message,
  });

  late final List<ProductBuyAgainOthers> productBuyAgainOthers;
  late final List<ProductBuyAgain> productBuyAgain;
  late final String message;

  BuyAgainModel.fromJson(Map<String, dynamic> json) {
    if (json['productBuyAgainOthers'] != null) {
      productBuyAgainOthers = List.from(json['productBuyAgainOthers'])
          .map((e) => ProductBuyAgainOthers.fromJson(e))
          .toList();
    } else {
      productBuyAgainOthers = [];
    }
    if (json['productBuyAgain'] != null) {
      productBuyAgain = List.from(json['productBuyAgain'])
          .map((e) => ProductBuyAgain.fromJson(e))
          .toList();
    } else {
      productBuyAgain = [];
    }

    message = json['message'];
  }


  @override
  // TODO: implement props
  List<Object?> get props => [productBuyAgainOthers,productBuyAgain,message];
}

class ProductBuyAgainOthers extends Equatable{
  ProductBuyAgainOthers({
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

  ProductBuyAgainOthers.fromJson(Map<String, dynamic> json) {
    if (json['recommendedProductSet'] != null &&
        json['recommendedProductSet'].isNotEmpty) {
      recommendedProductSet = List.from(json['recommendedProductSet'])
          .map((e) => RecommendedProductSet.fromJson(e))
          .toList();
    } else {
      recommendedProductSet = [];
    }

    productName = json['ProductName']??'';
    productCode = json['ProductCode']??'';
    previous = json['previous']??false;
    next = json['next']??false;
    lineItemID = json['lineItemID']??'';
    currentpage = json['Currentpage']??0;
  }


  @override
  // TODO: implement props
  List<Object?> get props => [recommendedProductSet,productName,productCode,previous,next,lineItemID,currentpage];
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
    isItemOutOfStock = false;
    hasInfo = false;
    isItemOnline = false;
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
  List<Object?> get props => [hasInfo, isUpdating,trimName,tabName,siteId,salePrice,records,quantityFlag,quantity,productURL,productId,posSKU,name,itemSKU,imageURL,condition,isItemOnline,isItemOutOfStock];
}

class ProductBuyAgain extends Equatable{
  ProductBuyAgain({
    required this.attributes,
    required this.id,
    required this.gCOrderC,
    required this.descriptionC,
    required this.itemIdFormulaC,
    required this.pIMSkuC,
    required this.itemIdC,
    required this.records,
    required this.condtionC,
    required this.isUpdating,
    required this.imageURLC,
    required this.itemPriceC,
    required this.quantityC,
    required this.warrantyPriceC,
    required this.itemSKUC,
    required this.gCOrderR,
  });
  late final Attributes attributes;
  late final String id;
  late bool isUpdating;
  late asm.Records records;
  late final String gCOrderC;
  late final String descriptionC;
  late final String itemIdFormulaC;
  late final String pIMSkuC;
  late final String itemIdC;
  late final String condtionC;
  late final String imageURLC;
  late final double itemPriceC;
  late final int quantityC;
  late final double warrantyPriceC;
  late final String itemSKUC;
  late final GCOrderR gCOrderR;

  ProductBuyAgain.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    id = json['Id'] ?? '';
    isUpdating = false;
    gCOrderC = json['GC_Order__c'] ?? '';
    descriptionC = json['Description__c'] ?? '';
    itemIdFormulaC = json['Item_Id_formula__c'] ?? '';
    pIMSkuC = json['PIM_Sku__c'] ?? '';
    records = asm.Records(childskus: [],quantity: "-1",productId: "null");
    itemIdC = json['Item_Id__c'] ?? '';
    condtionC = json['Condtion__c'] ?? '';
    imageURLC = json['Image_URL__c'] ?? '';
    itemPriceC = json['Item_Price__c'] ?? 0.0;
    quantityC = json['Quantity__c'] ?? 0;
    warrantyPriceC = json['Warranty_price__c'] ?? 0;
    itemSKUC = json['Item_SKU__c'] ?? '';
    gCOrderR = GCOrderR.fromJson(json['GC_Order__r']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Id'] = id;
    data['GC_Order__c'] = gCOrderC;
    data['Description__c'] = descriptionC;
    data['Item_Id_formula__c'] = itemIdFormulaC;
    data['PIM_Sku__c'] = pIMSkuC;
    data['Item_Id__c'] = itemIdC;
    data['Condtion__c'] = condtionC;
    data['Image_URL__c'] = imageURLC;
    data['Item_Price__c'] = itemPriceC;
    data['Quantity__c'] = quantityC;
    data['Warranty_price__c'] = warrantyPriceC;
    data['Item_SKU__c'] = itemSKUC;
    data['GC_Order__r'] = gCOrderR.toJson();
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [attributes,id,gCOrderC,descriptionC,itemIdFormulaC,pIMSkuC,itemIdC,condtionC,imageURLC,
  itemPriceC,quantityC,warrantyPriceC,itemSKUC,isUpdating,gCOrderR,records];

}

class Attributes extends Equatable{
  Attributes({
    required this.type,
    required this.url,
  });
  late final String type;
  late final String url;

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type']??'';
    url = json['url']??'';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['url'] = url;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [type,url];
}

class GCOrderR extends Equatable{
  GCOrderR({
    required this.attributes,
    required this.id,
    required this.siteIdC,
    required this.name,
    required this.customerC,
    required this.customerR,
  });
  late final Attributes attributes;
  late final String id;
  late final String siteIdC;
  late final String name;
  late final String customerC;
  late final CustomerR customerR;

  GCOrderR.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    id = json['Id']??'';
    siteIdC = json['Site_Id__c']??'';
    name = json['Name']??'';
    customerC = json['Customer__c']??'';
    if(json['Customer__r'] != null){
    customerR = CustomerR.fromJson(json['Customer__r']??'');}
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Id'] = id;
    data['Site_Id__c'] = siteIdC;
    data['Name'] = name;
    data['Customer__c'] = customerC;
    data['Customer__r'] = customerR.toJson();
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [attributes,id,siteIdC,name,customerC,customerR];
}

class CustomerR extends Equatable{
  CustomerR({
    required this.attributes,
    required this.id,
    required this.personEmail,
  });
  late final Attributes attributes;
  late final String id;
  late final String personEmail;

  CustomerR.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    id = json['Id']??'';
    personEmail = json['PersonEmail']??'';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Id'] = id;
    data['PersonEmail'] = personEmail;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [attributes,id,personEmail];
}
