import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;

class LandingScreenOffersModel extends Equatable{
  List<Offers>? offers;
  String? message;

  LandingScreenOffersModel({this.offers, this.message});

  LandingScreenOffersModel.fromJson(Map<String, dynamic> json) {
    if (json['offers'] != null) {
      offers = <Offers>[];
      json['offers'].forEach((v) {
        offers!.add(Offers.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (offers != null) {
      data['offers'] = offers!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }

  @override
  List<Object?> get props => [offers,message];
}

class Offers extends Equatable{
  FlashDeal? flashDeal;

  Offers({this.flashDeal});

  Offers.fromJson(Map<String, dynamic> json) {
    flashDeal = json['flashDeal'] != null
        ? FlashDeal.fromJson(json['flashDeal'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (flashDeal != null) {
      data['flashDeal'] = flashDeal!.toJson();
    }
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [flashDeal];
}

class FlashDeal extends Equatable {
  asm.Records? records;
  bool? isUpdating;
  double? todaysPrice;
  String? skuSeoUrl;
  double? savingsPercentRounded;
  double? savings;
  double? salePrice;
  String? promoEndDate;
  String? productId;
  String? productDisplayName;
  double? msrpPrice;
  String? message;
  String? listPrice;
  String? enterpriseSkuId;
  String? enterprisePIMId;
  String? brandName;
  String? brandId;
  String? assetPath;

  FlashDeal(
      {this.todaysPrice,
        this.skuSeoUrl,
        this.isUpdating,
        this.records,
        this.savingsPercentRounded,
        this.savings,
        this.salePrice,
        this.promoEndDate,
        this.productId,
        this.productDisplayName,
        this.msrpPrice,
        this.message,
        this.listPrice,
        this.enterpriseSkuId,
        this.enterprisePIMId,
        this.brandName,
        this.brandId,
        this.assetPath});

  FlashDeal.fromJson(Map<String, dynamic> json) {
    todaysPrice = json['todaysPrice']??0.00;
    skuSeoUrl = json['skuSeoUrl'];
    savingsPercentRounded = json['savingsPercentRounded'];
    savings = json['savings'];
    salePrice = json['salePrice'];
    promoEndDate = json['promoEndDate'];
    isUpdating = false;
    records = asm.Records(childskus: [],quantity: "-1",productId: "null");
    productId = json['productId'];
    productDisplayName = json['productDisplayName'];
    msrpPrice = json['msrpPrice']??0.00;
    message = json['message'];
    listPrice = json['listPrice'];
    enterpriseSkuId = json['enterpriseSkuId'];
    enterprisePIMId = json['enterprisePIMId'];
    brandName = json['brandName'];
    brandId = json['brandId'];
    assetPath = json['assetPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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

  @override
  // TODO: implement props
  List<Object?> get props => [todaysPrice,
    skuSeoUrl,
    savingsPercentRounded,
    savings,
    salePrice,
    promoEndDate,
    productId,
    productDisplayName,
    msrpPrice,
    message,
    listPrice,
    enterpriseSkuId,
    enterprisePIMId,
    isUpdating,
    records,
    brandName,
    brandId,
    assetPath
  ];
}
