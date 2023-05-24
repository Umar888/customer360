import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/cart_model/product_eligibility_model.dart' as pem;
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';

import '../cart_model/cart_warranties_model.dart';

class Records extends Equatable {
  String? zzClass;
  bool? isCartAdding;
  bool? isLoadingProCoverage;
  bool? fetchingEligibility;
  String? quantity;
  String? oliRecId;
  String? totalReviews;
  String? startingAtPrice;
  String? ratingImgUrl;
  String? productTitle;
  Warranties? warranties;
  String? productSeoUrl;
  String? productPrice;
  String? productName;
  String? productImageUrl;
  String? productId;
  String? priceVisibility;
  String? overallRating;
  String? lowPrice;
  String? highPrice;
  bool? hasMultipleStyle;
  bool? hasClearance;
  bool? isUpdating;
  String? enterpriseProductId;
  String? enterprisePIMId;
  Records? records;
  List<Childskus>? childskus;
  List<pem.MoreInfo>? moreInfo;
  List<pem.MainNodeData>? mainNodeData;
  String? brandName;

  Records({
    this.zzClass,
    this.isCartAdding,
    this.fetchingEligibility,
    this.quantity,
    this.mainNodeData,
    this.moreInfo,
    this.warranties,
    this.oliRecId,
    this.totalReviews,
    this.records,
    this.startingAtPrice,
    this.ratingImgUrl,
    this.productTitle,
    this.isUpdating,
    this.isLoadingProCoverage,
    this.productSeoUrl,
    this.productPrice,
    this.productName,
    this.productImageUrl,
    this.productId,
    this.priceVisibility,
    this.overallRating,
    this.lowPrice,
    this.highPrice,
    this.hasMultipleStyle,
    this.hasClearance,
    this.enterpriseProductId,
    this.enterprisePIMId,
    this.childskus,
    this.brandName,
  });

  Records.fromJson(Map<String, dynamic> json) {
    zzClass = json['zz_class'];
    quantity = "0";
    warranties = Warranties(price: 0.0);
    oliRecId = "";
    isCartAdding = false;
    fetchingEligibility = false;
    mainNodeData = [];
    moreInfo = [];
    isUpdating = false;
    isLoadingProCoverage = false;
    records = Records(childskus: [], quantity: "-1", productId: "null");
    totalReviews = json['totalReviews'];
    startingAtPrice = json['startingAtPrice'] ?? "0.00";
    ratingImgUrl = json['ratingImgUrl'];
    productTitle = json['productTitle'];
    productSeoUrl = json['productSeoUrl'];
    productPrice = json['productPrice'].toString();
    productName = json['productName'];
    productImageUrl = json['productImageUrl'];
    productId = json['productId'];

    ///this id
    priceVisibility = json['priceVisibility'];
    overallRating = json['overallRating'];
    lowPrice = json['lowPrice'].toString();
    highPrice = json['highPrice'].toString();
    hasMultipleStyle = json['hasMultipleStyle'];
    hasClearance = json['hasClearance'];
    enterpriseProductId = json['enterpriseProductId'];
    enterprisePIMId = json['enterprisePIMId'];
    if (json['childskus'] != null) {
      childskus = <Childskus>[];
      json['childskus'].forEach((v) {
        childskus!.add(Childskus.fromJson(v));
      });
    }
    brandName = json['brandName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    if (childskus != null) {
      data['childskus'] = childskus!.map((v) => v.toJson()).toList();
    }
    data['brandName'] = brandName;
    return data;
  }

  @override
  List<Object?> get props => [
        zzClass,
        isCartAdding,
        quantity,
        oliRecId,
        fetchingEligibility,
        mainNodeData,
        moreInfo,
        totalReviews,
        startingAtPrice,
        ratingImgUrl,
        productTitle,
        records,
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
        brandName
      ];
}
