import 'package:equatable/equatable.dart';

class ProductEligibility {
  bool? outOfStock;
  String? otherStoreList;
  String? otherNodeData;
  bool? noInfo;
  List<MoreInfo>? moreInfo;
  String? message;
  List<MainNodeData>? mainNodeData;
  bool? inStore;

  ProductEligibility(
      {this.outOfStock,
        this.otherStoreList,
        this.otherNodeData,
        this.noInfo,
        this.moreInfo,
        this.message,
        this.mainNodeData,
        this.inStore});

  ProductEligibility.fromJson(Map<String, dynamic> json) {
    outOfStock = json['outOfStock'];
    otherStoreList = json['otherStoreList'];
    otherNodeData = json['otherNodeData'];
    noInfo = json['noInfo'];
    if (json['moreInfo'] != null) {
      moreInfo = <MoreInfo>[];
      json['moreInfo'].forEach((v) {
        moreInfo!.add(new MoreInfo.fromJson(v));
      });
    }
    message = json['message'];
    if (json['mainNodeData'] != null) {
      mainNodeData = <MainNodeData>[];
      json['mainNodeData'].forEach((v) {
        mainNodeData!.add(new MainNodeData.fromJson(v));
      });
    }
    inStore = json['inStore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['outOfStock'] = this.outOfStock;
    data['otherStoreList'] = this.otherStoreList;
    data['otherNodeData'] = this.otherNodeData;
    data['noInfo'] = this.noInfo;
    if (this.moreInfo != null) {
      data['moreInfo'] = this.moreInfo!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    if (this.mainNodeData != null) {
      data['mainNodeData'] = this.mainNodeData!.map((v) => v.toJson()).toList();
    }
    data['inStore'] = this.inStore;
    return data;
  }
}

class MoreInfo extends Equatable{
  Attributes? attributes;
  String? id;
  String? vendorNameC;
  double? mSRPC;
  double? averageCostC;
  double? standardUnitCostC;
  bool? isBackorderableC;
  bool? isClearanceItemC;
  String? partC;
  double? billableWeightC;
  bool? isTruckShipC;
  bool? isReturnableC;
  bool? isPickupAllowedC;
  bool? isPlatinumItemC;
  bool? is914EligibleC;
  String? enterpriseIdC;
  String? dAXIdC;
  String? leadTimeC;

  MoreInfo(
      {this.attributes,
        this.id,
        this.vendorNameC,
        this.mSRPC,
        this.averageCostC,
        this.standardUnitCostC,
        this.isBackorderableC,
        this.isClearanceItemC,
        this.partC,
        this.billableWeightC,
        this.isTruckShipC,
        this.isReturnableC,
        this.isPickupAllowedC,
        this.isPlatinumItemC,
        this.is914EligibleC,
        this.enterpriseIdC,
        this.dAXIdC,
        this.leadTimeC,});

  MoreInfo.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    vendorNameC = json['Vendor_Name__c'];
    mSRPC = json['MSRP__c'];
    averageCostC = json['AverageCost__c'];
    standardUnitCostC = json['Standard_Unit_Cost__c'];
    isBackorderableC = json['Is_Backorderable__c'];
    isClearanceItemC = json['Is_Clearance_Item__c'];
    partC = json['Part__c'];
    billableWeightC = json['Billable_Weight__c'];
    isTruckShipC = json['Is_Truck_Ship__c'];
    isReturnableC = json['IsReturnable__c'];
    isPickupAllowedC = json['Is_Pickup_Allowed__c'];
    isPlatinumItemC = json['Is_Platinum_Item__c'];
    is914EligibleC = json['Is_914_Eligible__c'];
    enterpriseIdC = json['Enterprise_Id__c'];
    dAXIdC = json['DAX_Id__c'];
    leadTimeC = json['Lead_Time__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Vendor_Name__c'] = this.vendorNameC;
    data['MSRP__c'] = this.mSRPC;
    data['AverageCost__c'] = this.averageCostC;
    data['Standard_Unit_Cost__c'] = this.standardUnitCostC;
    data['Is_Backorderable__c'] = this.isBackorderableC;
    data['Is_Clearance_Item__c'] = this.isClearanceItemC;
    data['Part__c'] = this.partC;
    data['Billable_Weight__c'] = this.billableWeightC;
    data['Is_Truck_Ship__c'] = this.isTruckShipC;
    data['IsReturnable__c'] = this.isReturnableC;
    data['Is_Pickup_Allowed__c'] = this.isPickupAllowedC;
    data['Is_Platinum_Item__c'] = this.isPlatinumItemC;
    data['Is_914_Eligible__c'] = this.is914EligibleC;
    data['Enterprise_Id__c'] = this.enterpriseIdC;
    data['DAX_Id__c'] = this.dAXIdC;
    data['Lead_Time__c'] = this.leadTimeC;
    return data;
  }

  @override
  List<Object?> get props => [
    attributes,
    id,
    vendorNameC,
    mSRPC,
    averageCostC,
    standardUnitCostC,
    isBackorderableC,
    isClearanceItemC,
    partC,
    billableWeightC,
    isTruckShipC,
    isReturnableC,
    isPickupAllowedC,
    isPlatinumItemC,
    is914EligibleC,
    enterpriseIdC,
    dAXIdC,
    leadTimeC,
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

class MainNodeData {
  String? nodeStock;
  String? nodeName;
  String? nodeCity;

  MainNodeData({this.nodeStock, this.nodeName, this.nodeCity});

  MainNodeData.fromJson(Map<String, dynamic> json) {
    nodeStock = json['NodeStock'];
    nodeName = json['NodeName'];
    nodeCity = json['NodeCity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NodeStock'] = this.nodeStock;
    data['NodeName'] = this.nodeName;
    data['NodeCity'] = this.nodeCity;
    return data;
  }
}
