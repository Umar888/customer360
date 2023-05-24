import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/product_detail_model/other_store_model.dart';

class GetZipCodeList extends Equatable{
  bool? outOfStock;
  List<OtherNodeData>? otherNodeData;
  List<OtherStoreModel>? otherStores;
  bool? noInfo;
  String? message;
  List<MainNodeData>? mainNodeData;
  bool? inStore;
  List<String>? sourcingReason;

  GetZipCodeList({
    this.outOfStock,
    this.otherNodeData,
    this.noInfo,
    this.message,
    this.mainNodeData,
    this.inStore,
    this.otherStores,
    this.sourcingReason,
  });

  GetZipCodeList.fromJson(Map<String, dynamic> json) {
    outOfStock = json['outOfStock'];
    if (json['otherNodeData'] != null) {
      otherNodeData = <OtherNodeData>[];
      json['otherNodeData'].forEach((v) {
        otherNodeData!.add(new OtherNodeData.fromJson(v));
      });
    }
    if (json['otherStoreList'] != null) {
      otherStores = <OtherStoreModel>[];
      json['otherStoreList'].forEach((v) {
        otherStores!.add(new OtherStoreModel.fromJson(v));
      });
    }
    noInfo = json['noInfo'];
    message = json['message'];
    if (json['mainNodeData'] != null) {
      mainNodeData = <MainNodeData>[];
      json['mainNodeData'].forEach((v) {
        mainNodeData!.add(new MainNodeData.fromJson(v));
      });
    }
    inStore = json['inStore'];
    sourcingReason = json["SourcingReason"] == null
        ? []
        : List<String>.from(json["SourcingReason"]!.map((x) => x));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['outOfStock'] = this.outOfStock;
    if (this.otherNodeData != null) {
      data['otherNodeData'] =
          this.otherNodeData!.map((v) => v.toJson()).toList();
    }
    if (this.otherStores != null) {
      data['otherStoreList'] =
          this.otherStores!.map((v) => v.toJson()).toList();
    }
    data['noInfo'] = this.noInfo;
    data['message'] = this.message;
    if (this.mainNodeData != null) {
      data['mainNodeData'] = this.mainNodeData!.map((v) => v.toJson()).toList();
    }
    data['inStore'] = this.inStore;
    data["SourcingReason"] = this.sourcingReason == null
        ? []
        : List<dynamic>.from(sourcingReason!.map((x) => x));
    return data;
  }

  @override
  List<Object?> get props => [
    outOfStock,
    otherNodeData,
    noInfo,
    message,
    mainNodeData,
    inStore,
    otherStores,
    sourcingReason,
  ];
}

class OtherNodeData extends Equatable {
  String? value;
  String? stockLevel;
  String? nodeZip;
  String? nodeState;
  String? nodeID;
  String? nodeCity;
  String? label;
  bool? inventorySelection;
  String? selectedReason;

  OtherNodeData({
    this.value,
    this.stockLevel,
    this.nodeZip,
    this.nodeState,
    this.nodeID,
    this.nodeCity,
    this.label,
    this.inventorySelection = false,
    this.selectedReason,
  });

  OtherNodeData.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    stockLevel = json['StockLevel'];
    nodeZip = json['NodeZip'];
    nodeState = json['NodeState'];
    nodeID = json['NodeID'];
    nodeCity = json['NodeCity'];
    label = json['label'];
    inventorySelection = json['InventorySelection'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['StockLevel'] = this.stockLevel;
    data['NodeZip'] = this.nodeZip;
    data['NodeState'] = this.nodeState;
    data['NodeID'] = this.nodeID;
    data['NodeCity'] = this.nodeCity;
    data['label'] = this.label;
    data['InventorySelection'] = this.inventorySelection;
    return data;
  }

  @override
  List<Object?> get props => [nodeID];
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
