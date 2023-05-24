import 'package:equatable/equatable.dart';

class CustomerInfoModel extends Equatable {
  int? totalSize;
  bool? done;
  List<Records>? records;

  CustomerInfoModel({this.totalSize, this.done, this.records});

  CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['totalSize'];
    done = json['done'];
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    } else {
      records = <Records>[Records(id: null)];
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

class Records extends Equatable {
  Attributes? attributes;
  String? id;
  String? name;
  String? firstName;
  String? lastName;
  String? accountEmailC;
  String? brandCodeC;
  String? accountPhoneC;
  String? personEmail;
  String? emailC;
  String? phoneC;
  String? phone;
  bool? premiumPurchaserC;
  String? lastTransactionDateC;
  double? lifetimeNetSalesAmountC;
  double? lifetimeNetSalesTransactionsC;
  double? lifetimeNetUnitsC;
  String? primaryInstrumentCategoryC;
  double? netSalesAmount12MOC;
  double? orderCount12MOC;
  GCOrdersR? gCOrdersR;
  String? epsilonCustomerBrandKeyC;
  bool? lessonsCustomerC;
  bool? openBoxPurchaserC;
  bool? loyaltyCustomerC;
  bool? usedPurchaserC;
  bool? synchronyCustomerC;
  bool? vintagePurchaserC;

  Records({
    this.attributes,
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.accountEmailC,
    this.brandCodeC,
    this.accountPhoneC,
    this.personEmail,
    this.emailC,
    this.phoneC,
    this.phone,
    this.premiumPurchaserC,
    this.lastTransactionDateC,
    this.lifetimeNetSalesAmountC,
    this.lifetimeNetSalesTransactionsC,
    this.lifetimeNetUnitsC,
    this.primaryInstrumentCategoryC,
    this.netSalesAmount12MOC,
    this.orderCount12MOC,
    this.gCOrdersR,
    this.epsilonCustomerBrandKeyC,
    this.lessonsCustomerC,
    this.openBoxPurchaserC,
    this.loyaltyCustomerC,
    this.usedPurchaserC,
    this.synchronyCustomerC,
    this.vintagePurchaserC,
  });

  Records.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null ? new Attributes.fromJson(json['attributes']) : null;
    id = json['Id'];
    name = json['Name'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    accountEmailC = json['accountEmail__c'];
    brandCodeC = json['Brand_Code__c'];
    accountPhoneC = json['accountPhone__c'];
    personEmail = json['PersonEmail'];
    emailC = json['Email__c'];
    phoneC = json['Phone__c'];
    phone = json['Phone'];
    premiumPurchaserC = json['Premium_Purchaser__c'];
    lastTransactionDateC = json['Last_Transaction_Date__c'];
    lifetimeNetSalesAmountC = json['Lifetime_Net_Sales_Amount__c'];
    lifetimeNetSalesTransactionsC = json['Lifetime_Net_Sales_Transactions__c'];
    lifetimeNetUnitsC = json['Lifetime_Net_Units__c'];
    primaryInstrumentCategoryC = json['Primary_Instrument_Category__c'];
    netSalesAmount12MOC = json['Net_Sales_Amount_12MO__c'];
    orderCount12MOC = json['Order_Count_12MO__c'];
    gCOrdersR = json['GC_Orders__r'] != null ? new GCOrdersR.fromJson(json['GC_Orders__r']) : null;
    epsilonCustomerBrandKeyC = json['Epsilon_Customer_Brand_Key__c'];
    lessonsCustomerC = json['Lessons_Customer__c'];
    openBoxPurchaserC = json['Open_Box_Purchaser__c'];
    loyaltyCustomerC = json['Loyalty_Customer__c'];
    usedPurchaserC = json['Used_Purchaser__c'];
    synchronyCustomerC = json['Synchrony_Customer__c'];
    vintagePurchaserC = json['Vintage_Purchaser__c'];
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
    data['accountEmail__c'] = this.accountEmailC;
    data['Brand_Code__c'] = this.brandCodeC;
    data['accountPhone__c'] = this.accountPhoneC;
    data['PersonEmail'] = this.personEmail;
    data['Email__c'] = this.emailC;
    data['Phone__c'] = this.phoneC;
    data['Phone'] = this.phone;
    data['Premium_Purchaser__c'] = this.premiumPurchaserC;
    data['Last_Transaction_Date__c'] = this.lastTransactionDateC;
    data['Lifetime_Net_Sales_Amount__c'] = this.lifetimeNetSalesAmountC;
    data['Lifetime_Net_Sales_Transactions__c'] = this.lifetimeNetSalesTransactionsC;
    data['Lifetime_Net_Units__c'] = this.lifetimeNetUnitsC;
    data['Primary_Instrument_Category__c'] = this.primaryInstrumentCategoryC;
    data['Net_Sales_Amount_12MO__c'] = this.netSalesAmount12MOC;
    data['Order_Count_12MO__c'] = this.orderCount12MOC;
    if (this.gCOrdersR != null) {
      data['GC_Orders__r'] = this.gCOrdersR!.toJson();
    }
    data['Epsilon_Customer_Brand_Key__c'] = this.epsilonCustomerBrandKeyC;
    data['Lessons_Customer__c'] = this.lessonsCustomerC;
    data['Open_Box_Purchaser__c'] = this.openBoxPurchaserC;
    data['Loyalty_Customer__c'] = this.loyaltyCustomerC;
    data['Used_Purchaser__c'] = this.usedPurchaserC;
    data['Synchrony_Customer__c'] = this.synchronyCustomerC;
    data['Vintage_Purchaser__c'] = this.vintagePurchaserC;
    return data;
  }

  @override
  List<Object?> get props => [
        attributes,
        id,
        name,
        firstName,
        lastName,
        accountEmailC,
        brandCodeC,
        accountPhoneC,
        personEmail,
        emailC,
        phoneC,
        phone,
        premiumPurchaserC,
        lastTransactionDateC,
        lifetimeNetSalesAmountC,
        lifetimeNetSalesTransactionsC,
        lifetimeNetUnitsC,
        primaryInstrumentCategoryC,
        netSalesAmount12MOC,
        orderCount12MOC,
        gCOrdersR,
        epsilonCustomerBrandKeyC,
        lessonsCustomerC,
        openBoxPurchaserC,
        loyaltyCustomerC,
        usedPurchaserC,
        synchronyCustomerC,
        vintagePurchaserC,
      ];
}

class Attributes extends Equatable {
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

class GCOrders extends Equatable {
  GCOrdersR? gCOrdersR;

  GCOrders({this.gCOrdersR});

  GCOrders.fromJson(Map<String, dynamic> json) {
    gCOrdersR = json['GC_Orders__r'] != null ? new GCOrdersR.fromJson(json['GC_Orders__r']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.gCOrdersR != null) {
      data['GC_Orders__r'] = this.gCOrdersR!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [gCOrdersR];
}

class GCOrdersR extends Equatable {
  int? totalSize;
  bool? done;
  List<GCRecords>? records;

  GCOrdersR({this.totalSize, this.done, this.records});

  GCOrdersR.fromJson(Map<String, dynamic> json) {
    totalSize = json['totalSize'];
    done = json['done'];
    if (json['records'] != null) {
      records = <GCRecords>[];
      json['records'].forEach((v) {
        records!.add(new GCRecords.fromJson(v));
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

class GCRecords extends Equatable {
  Attributes? attributes;
  double? totalAmountC;

  GCRecords({this.attributes, this.totalAmountC});

  GCRecords.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null ? new Attributes.fromJson(json['attributes']) : null;
    totalAmountC = json['Total_Amount__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Total_Amount__c'] = this.totalAmountC;
    return data;
  }

  @override
  List<Object?> get props => [attributes, totalAmountC];
}
