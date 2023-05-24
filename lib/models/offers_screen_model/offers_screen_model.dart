class OffersScreenModel {
  OffersScreenModel({
    required this.offers,
    required this.message,
  });
  late final List<Offers> offers;
  late final String message;

  OffersScreenModel.fromJson(Map<String, dynamic> json) {
    if (json['offers'] != null && json['offers'].isNotEmpty) {
      offers =
          List.from(json['offers']).map((e) => Offers.fromJson(e)).toList();
    } else {
      offers = [];
    }

    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['offers'] = offers.map((e) => e.toJson()).toList();
    data['message'] = message;
    return data;
  }
}

class Offers {
  Offers({
    required this.flashDeal,
  });
  late final FlashDeal flashDeal;

  Offers.fromJson(Map<String, dynamic> json) {
    flashDeal = FlashDeal.fromJson(json['flashDeal']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['flashDeal'] = flashDeal.toJson();
    return data;
  }
}

class FlashDeal {
  FlashDeal({
    required this.todaysPrice,
    required this.skuSeoUrl,
    required this.savingsPercentRounded,
    required this.savings,
    required this.salePrice,
    required this.promoEndDate,
    required this.productId,
    required this.productDisplayName,
    required this.msrpPrice,
    this.message,
    required this.listPrice,
    required this.enterpriseSkuId,
    required this.enterprisePIMId,
    required this.brandName,
    required this.brandId,
    required this.assetPath,
  });
  late final double todaysPrice;
  late final String skuSeoUrl;
  late final double savingsPercentRounded;
  late final double savings;
  late final double salePrice;
  late final String promoEndDate;
  late final String productId;
  late final String productDisplayName;
  late final double msrpPrice;
  late final dynamic message;
  late final String listPrice;
  late final String enterpriseSkuId;
  late final String enterprisePIMId;
  late final String brandName;
  late final String brandId;
  late final String assetPath;

  FlashDeal.fromJson(Map<String, dynamic> json) {
    todaysPrice = json['todaysPrice'] ?? 0.0;
    skuSeoUrl = json['skuSeoUrl'] ?? '';
    savingsPercentRounded = json['savingsPercentRounded'] ?? 0.0;
    savings = json['savings'] ?? '';
    salePrice = json['salePrice'] ?? '';
    promoEndDate = json['promoEndDate'] ?? '';
    productId = json['productId'] ?? '';
    productDisplayName = json['productDisplayName'] ?? '';
    msrpPrice = json['msrpPrice'] ?? '';
    message = json['message'] ?? '';
    listPrice = json['listPrice'] ?? '';
    enterpriseSkuId = json['enterpriseSkuId'] ?? '';
    enterprisePIMId = json['enterprisePIMId'] ?? '';
    brandName = json['brandName'] ?? '';
    brandId = json['brandId'] ?? '';
    assetPath = json['assetPath'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['todaysPrice'] = todaysPrice;
    data['skuSeoUrl'] = skuSeoUrl;
    data['savingsPercentRounded'] = savingsPercentRounded;
    data['savings'] = savings;
    data['salePrice'] = salePrice;
    data['promoEndDate'] = promoEndDate;
    data['productId'] = productId;
    data['productDisplayName'] = productDisplayName;
    data['msrpPrice'] = msrpPrice;
    data['message'] = message;
    data['listPrice'] = listPrice;
    data['enterpriseSkuId'] = enterpriseSkuId;
    data['enterprisePIMId'] = enterprisePIMId;
    data['brandName'] = brandName;
    data['brandId'] = brandId;
    data['assetPath'] = assetPath;
    return data;
  }
}
