import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;

class ProductCartBrowseItemsModel extends Equatable {
  ProductCartBrowseItemsModel({
    required this.productCart,
    required this.message,
  });

  late final List<ProductCart> productCart;
  late final String message;

  ProductCartBrowseItemsModel.fromJson(Map<String, dynamic> json) {
    if (json['productCart'] != null && json['productCart'].isNotEmpty) {
      productCart = List.from(json['productCart'])
          .map((e) => ProductCart.fromJson(e))
          .toList();
    } else {
      productCart = [];
    }

    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['productCart'] = productCart.map((e) => e.toJson()).toList();
    data['message'] = message;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [productCart, message];
}

class ProductCart extends Equatable {
  ProductCart({
    required this.wrapperinstance,
    required this.faceLst,
  });
  late final Wrapperinstance wrapperinstance;
  late final List<dynamic> faceLst;

  ProductCart.fromJson(Map<String, dynamic> json) {
    wrapperinstance = Wrapperinstance.fromJson(json['wrapperinstance']);
    faceLst = List.castFrom<dynamic, dynamic>(json['faceLst']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['wrapperinstance'] = wrapperinstance.toJson();
    data['faceLst'] = faceLst;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [wrapperinstance, faceLst];
}

class Wrapperinstance extends Equatable {
  Wrapperinstance({
    required this.records,
    required this.navContent,
    this.facet,
  });
  late final List<Records> records;
  late final NavContent navContent;
  late final dynamic facet;

  Wrapperinstance.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null && json['records'].isNotEmpty) {
      records =
          List.from(json['records']).map((e) => Records.fromJson(e)).toList();
    } else {
      records = [];
    }

    navContent = NavContent.fromJson(json['navContent']);
    facet = json['facet'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['records'] = records.map((e) => e.toJson()).toList();
    data['navContent'] = navContent.toJson();
    data['facet'] = facet;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [records, navContent, facet];
}

class Records extends Equatable {
  Records({
    this.zzClass,
    this.totalReviews,
    this.startingAtPrice,
    required this.ratingImgUrl,
    this.productTitle,
    this.productSeoUrl,
    required this.productPrice,
    required this.productName,
    required this.productImageUrl,
    required this.productId,
    this.priceVisibility,
    this.overallRating,
    required this.lowPrice,
    required this.highPrice,
    required this.hasMultipleStyle,
    required this.hasClearance,
    required this.enterpriseProductId,
    required this.enterprisePIMId,
    required this.childskus,
    required this.brandName,
  });
  late final dynamic zzClass;
  late final dynamic totalReviews;
  late final dynamic startingAtPrice;
  late bool isUpdating;
  late asm.Records records;
  late bool? isItemOnline;
  late bool? isItemOutOfStock;
  late final String ratingImgUrl;
  late final dynamic productTitle;
  late final dynamic productSeoUrl;
  late final String productPrice;
  late final String productName;
  late final String productImageUrl;
  late final String productId;
  late final dynamic priceVisibility;
  late final dynamic overallRating;
  late final dynamic lowPrice;
  late final String highPrice;
  late final bool hasMultipleStyle;
  late final bool hasClearance;
  late final String enterpriseProductId;
  late final String enterprisePIMId;
  late final List<Childskus> childskus;
  late final String brandName;

  @override
  // TODO: implement props
  List<Object?> get props => [
        zzClass,
        isUpdating,
        isItemOnline,
        isItemOutOfStock,
        records,
        totalReviews,
        startingAtPrice,
        ratingImgUrl,
        productTitle,
        productSeoUrl,
        productPrice,
        productName,
        productImageUrl,
        productId,
        priceVisibility,
        overallRating,
        lowPrice,
        highPrice,
        hasMultipleStyle,
        hasClearance,
        enterpriseProductId,
        enterprisePIMId,
        childskus,
        brandName,
      ];

  Records.fromJson(Map<String, dynamic> json) {
    zzClass = json['zz_class'] ?? '';
    isUpdating = false;
    isItemOnline = false;
    isItemOutOfStock = false;
    records = asm.Records(childskus: [], quantity: "-1", productId: "null");
    totalReviews = json['totalReviews'] ?? '';
    startingAtPrice = json['startingAtPrice'] ?? '';
    ratingImgUrl = json['ratingImgUrl'] ?? '';
    productTitle = json['productTitle'] ?? '';
    productSeoUrl = json['productSeoUrl'] ?? '';
    productPrice = json['productPrice'].toString();
    productName = json['productName'] ?? '';
    productImageUrl = json['productImageUrl'] ?? '';
    productId = json['productId'] ?? '';
    priceVisibility = json['priceVisibility'] ?? '';
    overallRating = json['overallRating'] ?? '';
    lowPrice = json['lowPrice'].toString();
    highPrice = json['highPrice'].toString();
    hasMultipleStyle = json['hasMultipleStyle'] ?? false;
    hasClearance = json['hasClearance'] ?? false;
    enterpriseProductId = json['enterpriseProductId'] ?? '';
    enterprisePIMId = json['enterprisePIMId'] ?? '';
    if (json['childskus'] != null && json['childskus'].isNotEmpty) {
      childskus = List.from(json['childskus'])
          .map((e) => Childskus.fromJson(e))
          .toList();
    } else {
      childskus = [];
    }

    brandName = json['brandName'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['zz_class'] = zzClass;
    data['totalReviews'] = totalReviews;
    data['startingAtPrice'] = startingAtPrice;
    data['ratingImgUrl'] = ratingImgUrl;
    data['productTitle'] = productTitle;
    data['productSeoUrl'] = productSeoUrl;
    data['productPrice'] = productPrice;
    data['productName'] = productName;
    data['productImageUrl'] = productImageUrl;
    data['productId'] = productId;
    data['priceVisibility'] = priceVisibility;
    data['overallRating'] = overallRating;
    data['lowPrice'] = lowPrice;
    data['highPrice'] = highPrice;
    data['hasMultipleStyle'] = hasMultipleStyle;
    data['hasClearance'] = hasClearance;
    data['enterpriseProductId'] = enterpriseProductId;
    data['enterprisePIMId'] = enterprisePIMId;
    data['childskus'] = childskus.map((e) => e.toJson()).toList();
    data['brandName'] = brandName;
    return data;
  }
}

class Childskus extends Equatable {
  Childskus({
    this.zzClass,
    this.weight,
    this.upcCode,
    this.twoDayShippingSourceStatus,
    this.skuShortName,
    this.skuSeoUrl,
    this.skuPriceVisibility,
    required this.skuPrice,
    required this.skuPIMId,
    this.skuItem,
    required this.skuImageUrl,
    required this.skuImageId,
    required this.skuId,
    required this.skuENTId,
    required this.skuDisplayName,
    this.skuConditionInd,
    required this.skuCondition,
    this.serialSkus,
    this.serialNumbers,
    this.serialNumber,
    this.regularPrice,
    required this.pimStatus,
    this.onSale,
    this.lessonsEnabled,
    this.kitCarouselSkuIds,
    this.inventoryStatus,
    this.graphicalStickerRank,
    this.graphicalStickerId,
    required this.gcItemNumber,
    required this.availableInDC,
    this.availableDate,
  });
  late final dynamic zzClass;
  late final dynamic weight;
  late final dynamic upcCode;
  late final dynamic twoDayShippingSourceStatus;
  late final dynamic skuShortName;
  late final dynamic skuSeoUrl;
  late final dynamic skuPriceVisibility;
  late final String skuPrice;
  late final String skuPIMId;
  late final dynamic skuItem;
  late final String skuImageUrl;
  late final String skuImageId;
  late final String skuId;
  late final String skuENTId;
  late final String skuDisplayName;
  late final dynamic skuConditionInd;
  late final String skuCondition;
  late final dynamic serialSkus;
  late final dynamic serialNumbers;
  late final dynamic serialNumber;
  late final dynamic regularPrice;
  late final String pimStatus;
  late final dynamic onSale;
  late final dynamic lessonsEnabled;
  late final dynamic kitCarouselSkuIds;
  late final dynamic inventoryStatus;
  late final dynamic graphicalStickerRank;
  late final dynamic graphicalStickerId;
  late final String gcItemNumber;
  late final bool availableInDC;
  late final dynamic availableDate;

  Childskus.fromJson(Map<String, dynamic> json) {
    zzClass = json['zz_class'] ?? '';
    weight = json['weight'] ?? '';
    upcCode = json['upcCode'] ?? '';
    twoDayShippingSourceStatus = json[''] ?? '';
    skuShortName = json['skuShortName'] ?? '';
    skuSeoUrl = json['skuSeoUrl'] ?? '';
    skuPriceVisibility = json['skuPriceVisibility'] ?? '';
    skuPrice = json['skuPrice'].toString();
    skuPIMId = json['skuPIMId'] ?? '';
    skuItem = json['skuItem'] ?? '';
    skuImageUrl = json['skuImageUrl'] ?? '';
    skuImageId = json['skuImageId'] ?? '';
    skuId = json['skuId'] ?? '';
    skuENTId = json['skuENTId'] ?? '';
    skuDisplayName = json['skuDisplayName'] ?? '';
    skuConditionInd = json['skuConditionInd'] ?? '';
    skuCondition = json['skuCondition'] ?? '';
    serialSkus = json['serialSkus'] ?? '';
    serialNumbers = json['serialNumbers'] ?? [];
    serialNumber = json['serialNumber'] ?? '';
    regularPrice = json['regularPrice'] ?? '';
    pimStatus = json['pimStatus'] ?? '';
    onSale = json['onSale'] ?? '';
    lessonsEnabled = json['lessonsEnabled'] ?? '';
    kitCarouselSkuIds = json['kitCarouselSkuIds'] ?? '';
    inventoryStatus = json['inventoryStatus'] ?? '';
    graphicalStickerRank = json['graphicalStickerRank'] ?? '';
    graphicalStickerId = json['graphicalStickerId'] ?? '';
    gcItemNumber = json['gcItemNumber'] ?? '';
    availableInDC = json['availableInDC'] ?? false;
    availableDate = json['availableDate'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['zz_class'] = zzClass;
    data['weight'] = weight;
    data['upcCode'] = upcCode;
    data['twoDayShippingSourceStatus'] = twoDayShippingSourceStatus;
    data['skuShortName'] = skuShortName;
    data['skuSeoUrl'] = skuSeoUrl;
    data['skuPriceVisibility'] = skuPriceVisibility;
    data['skuPrice'] = skuPrice;
    data['skuPIMId'] = skuPIMId;
    data['skuItem'] = skuItem;
    data['skuImageUrl'] = skuImageUrl;
    data['skuImageId'] = skuImageId;
    data['skuId'] = skuId;
    data['skuENTId'] = skuENTId;
    data['skuDisplayName'] = skuDisplayName;
    data['skuConditionInd'] = skuConditionInd;
    data['skuCondition'] = skuCondition;
    data['serialSkus'] = serialSkus;
    data['serialNumbers'] = serialNumbers;
    data['serialNumber'] = serialNumber;
    data['regularPrice'] = regularPrice;
    data['pimStatus'] = pimStatus;
    data['onSale'] = onSale;
    data['lessonsEnabled'] = lessonsEnabled;
    data['kitCarouselSkuIds'] = kitCarouselSkuIds;
    data['inventoryStatus'] = inventoryStatus;
    data['graphicalStickerRank'] = graphicalStickerRank;
    data['graphicalStickerId'] = graphicalStickerId;
    data['gcItemNumber'] = gcItemNumber;
    data['availableInDC'] = availableInDC;
    data['availableDate'] = availableDate;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        zzClass,
        weight,
        upcCode,
        twoDayShippingSourceStatus,
        skuShortName,
        skuSeoUrl,
        skuPriceVisibility,
        skuPrice,
        skuPIMId,
        skuItem,
        skuImageUrl,
        skuImageId,
        skuId,
        skuENTId,
        skuDisplayName,
        skuConditionInd,
        skuCondition,
        serialSkus,
        serialNumbers,
        serialNumber,
        regularPrice,
        pimStatus,
        onSale,
        lessonsEnabled,
        kitCarouselSkuIds,
        inventoryStatus,
        graphicalStickerRank,
        graphicalStickerId,
        gcItemNumber,
        availableInDC,
        availableDate
      ];
}

class NavContent extends Equatable {
  NavContent({
    required this.totalERecsNum,
  });
  late final int totalERecsNum;

  NavContent.fromJson(Map<String, dynamic> json) {
    totalERecsNum = json['totalERecsNum'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalERecsNum'] = totalERecsNum;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [totalERecsNum];
}
