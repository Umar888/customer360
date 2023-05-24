import 'package:equatable/equatable.dart';

class Childskus extends Equatable{
  String? zzClass;
  String? weight;
  String? upcCode;
  String? twoDayShippingSourceStatus;
  String? skuShortName;
  String? skuSeoUrl;
  String? skuPriceVisibility;
  String? skuPrice;
  String? skuPIMId;
  String? skuItem;
  String? skuImageUrl;
  String? skuImageId;
  String? skuId;
  String? skuENTId;
  String? skuDisplayName;
  String? skuConditionInd;
  String? skuCondition;
  String? serialSkus;
  String? serialNumber;
  String? regularPrice;
  String? pimStatus;
  String? onSale;
  String? lessonsEnabled;
  String? kitCarouselSkuIds;
  String? inventoryStatus;
  String? graphicalStickerRank;
  String? graphicalStickerId;
  String? gcItemNumber;
  bool? availableInDC;
  String? availableDate;

  Childskus(
      {this.zzClass,
        this.weight,
        this.upcCode,
        this.twoDayShippingSourceStatus,
        this.skuShortName,
        this.skuSeoUrl,
        this.skuPriceVisibility,
        this.skuPrice,
        this.skuPIMId,
        this.skuItem,
        this.skuImageUrl,
        this.skuImageId,
        this.skuId,
        this.skuENTId,
        this.skuDisplayName,
        this.skuConditionInd,
        this.skuCondition,
        this.serialSkus,
        this.serialNumber,
        this.regularPrice,
        this.pimStatus,
        this.onSale,
        this.lessonsEnabled,
        this.kitCarouselSkuIds,
        this.inventoryStatus,
        this.graphicalStickerRank,
        this.graphicalStickerId,
        this.gcItemNumber,
        this.availableInDC,
        this.availableDate});

  Childskus.fromJson(Map<String, dynamic> json) {
    zzClass = json['zz_class'];
    weight = json['weight'];
    upcCode = json['upcCode'];
    twoDayShippingSourceStatus = json['twoDayShippingSourceStatus'];
    skuShortName = json['skuShortName'];
    skuSeoUrl = json['skuSeoUrl'];
    skuPriceVisibility = json['skuPriceVisibility'];
    skuPrice = json['skuPrice'].toString();
    skuPIMId = json['skuPIMId']??"";
    skuItem = json['skuItem'];
    skuImageUrl = json['skuImageUrl'];
    skuImageId = json['skuImageId'];
    skuId = json['skuId'];
    skuENTId = json['skuENTId']??"";
    skuDisplayName = json['skuDisplayName'];
    skuConditionInd = json['skuConditionInd'];
    skuCondition = json['skuCondition'];
    serialSkus = json['serialSkus'];
    serialNumber = json['serialNumber'];
    regularPrice = json['regularPrice'];
    pimStatus = json['pimStatus'];
    onSale = json['onSale'];
    lessonsEnabled = json['lessonsEnabled'];
    kitCarouselSkuIds = json['kitCarouselSkuIds'];
    inventoryStatus = json['inventoryStatus'];
    graphicalStickerRank = json['graphicalStickerRank'];
    graphicalStickerId = json['graphicalStickerId'];
    gcItemNumber = json['gcItemNumber'];
    availableInDC = json['availableInDC'];
    availableDate = json['availableDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['zz_class'] = this.zzClass;
    data['weight'] = this.weight;
    data['upcCode'] = this.upcCode;
    data['twoDayShippingSourceStatus'] = this.twoDayShippingSourceStatus;
    data['skuShortName'] = this.skuShortName;
    data['skuSeoUrl'] = this.skuSeoUrl;
    data['skuPriceVisibility'] = this.skuPriceVisibility;
    data['skuPrice'] = this.skuPrice;
    data['skuPIMId'] = this.skuPIMId;
    data['skuItem'] = this.skuItem;
    data['skuImageUrl'] = this.skuImageUrl;
    data['skuImageId'] = this.skuImageId;
    data['skuId'] = this.skuId;
    data['skuENTId'] = this.skuENTId;
    data['skuDisplayName'] = this.skuDisplayName;
    data['skuConditionInd'] = this.skuConditionInd;
    data['skuCondition'] = this.skuCondition;
    data['serialSkus'] = this.serialSkus;
    data['serialNumber'] = this.serialNumber;
    data['regularPrice'] = this.regularPrice;
    data['pimStatus'] = this.pimStatus;
    data['onSale'] = this.onSale;
    data['lessonsEnabled'] = this.lessonsEnabled;
    data['kitCarouselSkuIds'] = this.kitCarouselSkuIds;
    data['inventoryStatus'] = this.inventoryStatus;
    data['graphicalStickerRank'] = this.graphicalStickerRank;
    data['graphicalStickerId'] = this.graphicalStickerId;
    data['gcItemNumber'] = this.gcItemNumber;
    data['availableInDC'] = this.availableInDC;
    data['availableDate'] = this.availableDate;
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
