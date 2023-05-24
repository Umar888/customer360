import 'package:equatable/equatable.dart';

class CustomerOrderInfoModel extends Equatable{
  int? totalSize;
  bool? done;
  List<Records>? records;

  CustomerOrderInfoModel({this.totalSize, this.done, this.records});

  CustomerOrderInfoModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['totalSize'];
    done = json['done'];
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalSize'] = this.totalSize;
    data['done'] = this.done;
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [totalSize, done, records];
}

class Records extends Equatable{
  Attributes? attributes;
  String? id;
  String? name;
  String? firstName;
  String? lastName;
  String? lastTransactionDateC;
  double? lifetimeNetSalesAmountC;
  double? lifetimeNetSalesTransactionsC;
  double? lifetimeNetUnitsC;
  String? primaryInstrumentCategoryC;
  double? netSalesAmount12MOC;
  double? orderCount12MOC;

  Records(
      {this.attributes,
        this.id,
        this.name,
        this.firstName,
        this.lastName,
        this.lastTransactionDateC,
        this.lifetimeNetSalesAmountC,
        this.lifetimeNetSalesTransactionsC,
        this.lifetimeNetUnitsC,
        this.primaryInstrumentCategoryC,
        this.netSalesAmount12MOC,
        this.orderCount12MOC});

  Records.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    name = json['Name'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    lastTransactionDateC = json['Last_Transaction_Date__c'];
    lifetimeNetSalesAmountC = json['Lifetime_Net_Sales_Amount__c'];
    lifetimeNetSalesTransactionsC = json['Lifetime_Net_Sales_Transactions__c'];
    lifetimeNetUnitsC = json['Lifetime_Net_Units__c'];
    primaryInstrumentCategoryC = json['Primary_Instrument_Category__c'];
    netSalesAmount12MOC = json['Net_Sales_Amount_12MO__c'];
    orderCount12MOC = json['Order_Count_12MO__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['Last_Transaction_Date__c'] = this.lastTransactionDateC;
    data['Lifetime_Net_Sales_Amount__c'] = this.lifetimeNetSalesAmountC;
    data['Lifetime_Net_Sales_Transactions__c'] =
        this.lifetimeNetSalesTransactionsC;
    data['Lifetime_Net_Units__c'] = this.lifetimeNetUnitsC;
    data['Primary_Instrument_Category__c'] = this.primaryInstrumentCategoryC;
    data['Net_Sales_Amount_12MO__c'] = this.netSalesAmount12MOC;
    data['Order_Count_12MO__c'] = this.orderCount12MOC;
    return data;
  }

  @override
  List<Object?> get props => [
      attributes,
      id,
      name,
      firstName,
      lastName,
      lastTransactionDateC,
      lifetimeNetSalesAmountC,
      lifetimeNetSalesTransactionsC,
      lifetimeNetUnitsC,
      primaryInstrumentCategoryC,
      netSalesAmount12MOC,
      orderCount12MOC,
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
