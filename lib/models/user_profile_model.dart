import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  UserProfile({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.accountEmailC,
    this.personEmail,
    this.emailC,
    this.brandCodeC,
    this.accountPhoneC,
    this.phoneC,
    this.phone,
    this.premiumPurchaserC,
    this.personMailingStreet,
    this.personMailingStreet2,
    this.personMailingCity,
    this.personMailingState,
    this.personMailingPostalCode,
    this.personMailingCountry,
    this.zipLast4C,
    this.lastTransactionDateC,
    this.lifetimeNetSalesAmountC,
    this.lifetimeNetSalesTransactionsC,
    this.lifetimeNetUnitsC,
    this.primaryInstrumentCategoryC,
    this.netSalesAmount12MoC,
    this.orderCount12MoC,
    this.isSelected,
    this.gcOrdersR,
    this.epsilonCustomerBrandKeyC,
    this.lessonsCustomerC,
    this.openBoxPurchaserC,
    this.loyaltyCustomerC,
    this.usedPurchaserC,
    this.synchronyCustomerC,
    this.vintagePurchaserC,
    this.persionMailing,
  });

  String? id;
  String? name;
  String? firstName;
  String? lastName;
  String? accountEmailC;
  String? personEmail;
  String? emailC;
  bool? isSelected;
  String? brandCodeC;
  String? accountPhoneC;
  String? phoneC;
  String? phone;
  bool? premiumPurchaserC;
  String? personMailingStreet;
  String? personMailingStreet2;
  String? personMailingCity;
  String? personMailingState;
  String? personMailingPostalCode;
  String? personMailingCountry;
  String? zipLast4C;
  DateTime? lastTransactionDateC;
  double? lifetimeNetSalesAmountC;
  double? lifetimeNetSalesTransactionsC;
  double? lifetimeNetUnitsC;
  String? primaryInstrumentCategoryC;
  double? netSalesAmount12MoC;
  double? orderCount12MoC;
  GcOrdersR? gcOrdersR;
  String? epsilonCustomerBrandKeyC;
  bool? lessonsCustomerC;
  bool? openBoxPurchaserC;
  bool? loyaltyCustomerC;
  bool? usedPurchaserC;
  bool? synchronyCustomerC;
  bool? vintagePurchaserC;
  String? persionMailing;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
      id: json["Id"],
      isSelected: false,
      name: json["Name"],
      firstName: json["FirstName"],
      lastName: json["LastName"],
      accountEmailC: json["accountEmail__c"],
      emailC: json["mail__c"],
      personEmail: json["PersonEmail"],
      brandCodeC: json["Brand_Code__c"],
      accountPhoneC: json["accountPhone__c"],
      phoneC: json["Phone__c"],
      phone: json["Phone"],
      premiumPurchaserC: json["Premium_Purchaser__c"],
      personMailingStreet: json["PersonMailingStreet"],
      personMailingCity: json["PersonMailingCity"],
      personMailingState: json["PersonMailingState"],
      personMailingPostalCode: json["PersonMailingPostalCode"],
      personMailingCountry: json["PersonMailingCountry"],
      zipLast4C: json["Zip_Last_4__c"],
      lastTransactionDateC: json["Last_Transaction_Date__c"] == null ? null: DateTime.parse(json["Last_Transaction_Date__c"]),
      lifetimeNetSalesAmountC: json["Lifetime_Net_Sales_Amount__c"]?.toDouble(),
      lifetimeNetSalesTransactionsC: json["Lifetime_Net_Sales_Transactions__c"]?.toDouble(),
      lifetimeNetUnitsC: json["Lifetime_Net_Units__c"],
      primaryInstrumentCategoryC: json["Primary_Instrument_Category__c"],
      netSalesAmount12MoC: json["Net_Sales_Amount_12MO__c"]?.toDouble(),
      orderCount12MoC: json["Order_Count_12MO__c"],
      gcOrdersR: json["GC_Orders__r"] == null
          ? null
          : GcOrdersR.fromJson(json["GC_Orders__r"]),
      epsilonCustomerBrandKeyC: json["Epsilon_Customer_Brand_Key__c"],
      lessonsCustomerC: json["Lessons_Customer__c"],
      openBoxPurchaserC: json["Open_Box_Purchaser__c"],
      loyaltyCustomerC: json["Loyalty_Customer__c"],
      usedPurchaserC: json["Used_Purchaser__c"],
      synchronyCustomerC: json["Synchrony_Customer__c"],
      vintagePurchaserC: json["Vintage_Purchaser__c"],
      persionMailing: '${json["PersonMailingStreet"] ?? ""} ${json["Address_2__c"] ?? ""},\n${json["PersonMailingCity"] ?? ""}, ${json["PersonMailingState"] ?? ""}, ${json["PersonMailingPostalCode"] ?? ""}');

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "FirstName": firstName,
        "LastName": lastName,
        "accountEmail__c": accountEmailC,
        "mail__c": emailC,
        "PersonEmail": personEmail,
        "Brand_Code__c": brandCodeC,
        "accountPhone__c": accountPhoneC,
        "Phone__c": phoneC,
        "Phone": phone,
        "Premium_Purchaser__c": premiumPurchaserC,
        "PersonMailingStreet": personMailingStreet,
        "PersonMailingCity": personMailingCity,
        "PersonMailingState": personMailingState,
        "PersonMailingPostalCode": personMailingPostalCode,
        "PersonMailingCountry": personMailingCountry,
        "Zip_Last_4__c": zipLast4C,
        "Last_Transaction_Date__c":
            "${lastTransactionDateC?.year.toString().padLeft(4, '0')}-${lastTransactionDateC?.month.toString().padLeft(2, '0')}-${lastTransactionDateC?.day.toString().padLeft(2, '0')}",
        "Lifetime_Net_Sales_Amount__c": lifetimeNetSalesAmountC,
        "Lifetime_Net_Sales_Transactions__c": lifetimeNetSalesTransactionsC,
        "Lifetime_Net_Units__c": lifetimeNetUnitsC,
        "Primary_Instrument_Category__c": primaryInstrumentCategoryC,
        "Net_Sales_Amount_12MO__c": netSalesAmount12MoC,
        "Order_Count_12MO__c": orderCount12MoC,
        "GC_Orders__r": gcOrdersR?.toJson(),
        "Epsilon_Customer_Brand_Key__c": epsilonCustomerBrandKeyC,
        "Lessons_Customer__c": lessonsCustomerC,
        "Open_Box_Purchaser__c": openBoxPurchaserC,
        "Loyalty_Customer__c": loyaltyCustomerC,
        "Used_Purchaser__c": usedPurchaserC,
        "Synchrony_Customer__c": synchronyCustomerC,
        "Vintage_Purchaser__c": vintagePurchaserC,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        firstName,
        lastName,
        accountEmailC,
        brandCodeC,
        accountPhoneC,
        premiumPurchaserC,
        personMailingStreet,
        personMailingCity,
        personMailingState,
        personMailingPostalCode,
        personMailingCountry,
        zipLast4C,
        "${lastTransactionDateC?.year.toString().padLeft(4, '0')}-${lastTransactionDateC?.month.toString().padLeft(2, '0')}-${lastTransactionDateC?.day.toString().padLeft(2, '0')}",
        lifetimeNetSalesAmountC,
        lifetimeNetSalesTransactionsC,
        lifetimeNetUnitsC,
        primaryInstrumentCategoryC,
        netSalesAmount12MoC,
        orderCount12MoC,
        gcOrdersR?.toJson(),
        epsilonCustomerBrandKeyC,
        lessonsCustomerC,
        openBoxPurchaserC,
        loyaltyCustomerC,
        usedPurchaserC,
        synchronyCustomerC,
        vintagePurchaserC,
      ];
}

class GcOrdersR {
  GcOrdersR({
    this.totalSize,
    this.done,
    this.records,
  });

  int? totalSize;
  bool? done;
  List<Record>? records;

  factory GcOrdersR.fromJson(Map<String, dynamic> json) => GcOrdersR(
        totalSize: json["totalSize"],
        done: json["done"],
        records:
            List<Record>.from(json["records"].map((x) => Record.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalSize": totalSize,
        "done": done,
        "records": (records?.isEmpty ?? true)
            ? []
            : List<dynamic>.from(records!.map((x) => x.toJson())),
      };
}

class Record {
  Record({
    this.totalAmountC,
  });

  double? totalAmountC;

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        totalAmountC: json["Total_Amount__c"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Total_Amount__c": totalAmountC,
      };
}
