import 'package:equatable/equatable.dart';

class MyCustomerModel extends Equatable {
  MyCustomerModel({
    this.record,
    this.priority,
    this.accountId,
    this.purchased,
    this.contacted,
  });

  MyCustomerRecord? record;
  String? priority;
  String? accountId;
  String? purchased;
  String? contacted;

  factory MyCustomerModel.fromJson(Map<String, dynamic> json) => MyCustomerModel(
        record: json["Record"] == null ? null : MyCustomerRecord.fromJson(json["Record"]),
        priority: json["Priority"],
        accountId: json["AccountId"],
        purchased: json["Purchased"],
        contacted: json["Contacted"],
      );

  Map<String, dynamic> toJson() => {
        "Record": record?.toJson(),
        "Priority": priority,
        "AccountId": accountId,
        "Purchased": purchased,
        "Contacted": contacted,
      };

  @override
  List<Object?> get props => [
        record,
        priority,
        accountId,
        purchased,
        contacted,
      ];
}

class MyCustomerRecord {
  MyCustomerRecord({
    this.id,
    this.name,
    this.lifetimeNetSalesAmountC,
    this.lastTransactionDateC,
    this.attributes,
    this.phone,
  });

  String? id;
  String? name;
  double? lifetimeNetSalesAmountC;
  DateTime? lastTransactionDateC;
  MyCustomerAttributes? attributes;
  String? phone;

  factory MyCustomerRecord.fromJson(Map<String, dynamic> json) => MyCustomerRecord(
        attributes: json["attributes"] == null ? null : MyCustomerAttributes.fromJson(json["attributes"]),
        id: json["Id"],
        name: json["Name"],
        lifetimeNetSalesAmountC: json["Lifetime_Net_Sales_Amount__c"],
        lastTransactionDateC: json["Last_Transaction_Date__c"] == null ? null : DateTime.parse(json["Last_Transaction_Date__c"]),
        phone: json["accountPhone__c"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Lifetime_Net_Sales_Amount__c": lifetimeNetSalesAmountC,
        "Last_Transaction_Date__c": lastTransactionDateC == null
            ? ''
            : "${lastTransactionDateC!.year.toString().padLeft(4, '0')}-${lastTransactionDateC!.month.toString().padLeft(2, '0')}-${lastTransactionDateC!.day.toString().padLeft(2, '0')}",
        "accountPhone__c": phone
      };
}

class MyCustomerAttributes {
  MyCustomerAttributes({
    this.type,
    this.url,
  });

  String? type;
  String? url;

  factory MyCustomerAttributes.fromJson(Map<String, dynamic> json) => MyCustomerAttributes(
        type: json["type"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "url": url,
      };
}

class ListClientResponse {
  ListClientResponse({
    this.clients,
    this.mediumCount,
    this.lowCount,
    this.highCount,
  });

  List<MyCustomerModel>? clients;
  int? mediumCount;
  int? lowCount;
  int? highCount;

  factory ListClientResponse.fromJson(Map<String, dynamic> json) {
    return ListClientResponse(
      clients: json["resp"] == null ? [] : json["resp"]!.map<MyCustomerModel>((x) => MyCustomerModel.fromJson(x)).toList(),
      mediumCount: json["MediumCount"],
      lowCount: json["LowCount"],
      highCount: json["HighCount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "resp": clients == null ? [] : List<dynamic>.from(clients!.map((x) => x.toJson())),
        "MediumCount": mediumCount,
        "LowCount": lowCount,
        "HighCount": highCount,
      };
}

class ListContactedResponse {
  ListContactedResponse({
    this.contacteds,
    this.notContactedCount,
    this.contactedCount,
  });

  List<MyCustomerModel>? contacteds;
  int? notContactedCount;
  int? contactedCount;

  factory ListContactedResponse.fromJson(Map<String, dynamic> json) {
    return ListContactedResponse(
      contacteds: json["resp"] == null ? [] : json["resp"]!.map<MyCustomerModel>((x) => MyCustomerModel.fromJson(x)).toList(),
      notContactedCount: json["NotContactedCount"],
      contactedCount: json["ContactedCount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "resp": contacteds == null ? [] : List<dynamic>.from(contacteds!.map((x) => x.toJson())),
        "NotContactedCount": notContactedCount,
        "ContactedCount": contactedCount,
      };
}

class ListPurchasedResponse {
  ListPurchasedResponse({
    this.purchaseds,
    this.notPurchasedCount,
    this.purchasedCount,
  });

  List<MyCustomerModel>? purchaseds;
  int? notPurchasedCount;
  int? purchasedCount;

  factory ListPurchasedResponse.fromJson(Map<String, dynamic> json) {
    return ListPurchasedResponse(
      purchaseds: json["resp"] == null ? [] : json["resp"]!.map<MyCustomerModel>((x) => MyCustomerModel.fromJson(x)).toList(),
      notPurchasedCount: json["NotPurchasedCount"],
      purchasedCount: json["PurchasedCount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "resp": purchaseds == null ? [] : List<dynamic>.from(purchaseds!.map((x) => x.toJson())),
        "NotPurchasedCount": notPurchasedCount,
        "PurchasedCount": purchasedCount,
      };
}
