import 'package:equatable/equatable.dart';

class PaymentCardModel extends Equatable {
  PaymentCardModel({
    this.paymentType,
    this.isExpired,
    this.id,
    this.expYear,
    this.expMonth,
    this.cardType,
    this.cardNumberDecrypted,
    this.cardNumber,
    this.address,
  });

  String? paymentType;
  bool? isExpired;
  String? id;
  String? expYear;
  String? expMonth;
  String? cardType;
  String? cardNumberDecrypted;
  String? cardNumber;
  Address? address;

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) =>
      PaymentCardModel(
        paymentType: json["paymentType"],
        isExpired: json["isExpired"] ?? false,
        id: json["id"],
        expYear: json["expYear"],
        expMonth: json["expMonth"],
        cardType: json["cardType"],
        cardNumberDecrypted: json["cardNumberDecrypted"],
        cardNumber: json["cardNumber"],
        address: Address.fromJson(json["address"]),
      );

  Map<String, dynamic> toJson() => {
        "paymentType": paymentType,
        "isExpired": isExpired,
        "id": id,
        "expYear": expYear,
        "expMonth": expMonth,
        "cardType": cardType,
        "cardNumberDecrypted": cardNumberDecrypted,
        "cardNumber": cardNumber,
        "address": address?.toJson(),
      };

  @override
  List<Object?> get props => [cardNumber, id, expMonth, expYear, paymentType];
}

class Address {
  Address({
    this.zipCode,
    this.street2,
    this.street1,
    this.state,
    this.phone,
    this.lastName,
    this.firstName,
    this.country,
    this.companyName,
    this.city,
  });

  String? zipCode;
  String? street2;
  String? street1;
  String? state;
  Phone? phone;
  String? lastName;
  String? firstName;
  String? country;
  String? companyName;
  String? city;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        zipCode: json["zipCode"],
        street2: json["street2"],
        street1: json["street1"],
        state: json["state"],
        phone: Phone.fromJson(json["phone"]),
        lastName: json["lastName"],
        firstName: json["firstName"],
        country: json["country"],
        companyName: json["companyName"],
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {
        "zipCode": zipCode,
        "street2": street2,
        "street1": street1,
        "state": state,
        "phone": phone?.toJson(),
        "lastName": lastName,
        "firstName": firstName,
        "country": country,
        "companyName": companyName,
        "city": city,
      };
}

class Phone {
  Phone({
    this.value,
    this.type,
    this.isPrimary,
  });

  String? value;
  String? type;
  bool? isPrimary;

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
        value: json["value"],
        type: json["type"],
        isPrimary: json["isPrimary"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "type": type,
        "isPrimary": isPrimary,
      };
}
