import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/views/flutter_credit_card.dart';
import 'package:gc_customer_app/models/cart_model/financial_type_model.dart';

enum PaymentMethodType { credit, gcEssentials, gcGear, gcGift, cOA }

class CreditCardModelSave extends Equatable {
  CreditCardModelSave({
    required this.cardNumber,
    this.expiryMonth = '',
    this.expiryYear = '',
    this.cardType = PaymentMethodType.credit,
    this.cardHolderName = '',
    required this.cvvCode,
    this.paymentMethod,
    this.isCvvFocused = false,
    this.availableAmount,
    this.financialTypeModel,
    this.maxAmount = '0',
    this.isUseFullBalance,
    this.isSameAsShippingAddress = true,
    this.firstName = '',
    this.lastName = '',
    this.isExistingCard = false,
  });

  String cardNumber = '';
  String expiryMonth;
  // String cardType = '';
  String expiryYear;
  String cardHolderName;
  String firstName;
  String lastName;
  PaymentMethod? paymentMethod;
  String cvvCode = '';
  bool isCvvFocused;
  PaymentMethodType cardType;
  String? availableAmount;
  FinancialTypeModel? financialTypeModel;
  //For gift card
  String? maxAmount;
  bool? isUseFullBalance;
  bool isSameAsShippingAddress;
  bool isExistingCard;

  Map<String, dynamic> toJson() {
    String _paymentMethod = 'Credit Card';
    switch (cardType) {
      case PaymentMethodType.cOA:
        _paymentMethod = 'COA';
        break;
      case PaymentMethodType.gcEssentials:
        _paymentMethod = 'Guitar Center Essentials Card';
        break;
      case PaymentMethodType.gcGear:
        _paymentMethod = 'Guitar Center Gear Card';
        break;
      case PaymentMethodType.gcGift:
        _paymentMethod = 'Gift Card';
        break;
      default:
    }
    String _creditType = '';
    switch (detectCCType(cardNumber)) {
      case CardType.americanExpress:
        _creditType = 'COA';
        break;
      case CardType.discover:
        _creditType = 'Discover';
        break;
      case CardType.mastercard:
        _creditType = 'Mastercard';
        break;
      case CardType.visa:
        _creditType = 'VISA';
        break;
      default:
    }
    paymentMethod?.paymentMethodType = _paymentMethod;
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Card_Number'] = cardNumber;
    data['Expiry_Month'] = expiryMonth;
    data['Expiry_Year'] =
        expiryYear.length == 2 ? '20${expiryYear}' : expiryYear;
    data['Password'] = "";
    data['Last_digit'] = cardNumber.length > 4
        ? cardNumber.substring(cardNumber.length - 4)
        : cardNumber;
    data['Security_Code'] = cvvCode;
    data['planCode'] = financialTypeModel?.planCode ?? '';
    data['planDescription'] = financialTypeModel?.promoDescription ?? '';
    data['cardType'] = _creditType;
    data['redeemtionId'] = "";
    data['loyaltypoints'] = "";
    data['isSpecialFinancing'] = financialTypeModel?.isSpecialFinancing;
    data['CopyAddress'] = true;
    data['Index'] = 1;
    data['PaymentMethod'] = paymentMethod?.toJson();
    return data;
  }

  @override
  List<Object?> get props => [
        cardNumber,
        expiryMonth,
        cardType,
        expiryYear,
        cardHolderName,
        paymentMethod,
        cvvCode,
        isCvvFocused
      ];

  Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
  };

  CardType detectCCType(String cardNumber) {
    //Default card type is other
    CardType cardType = CardType.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    cardNumPatterns.forEach(
      (CardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          String ccPatternStr =
              cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }
}

class PaymentMethod extends Equatable {
  String amount;
  String country;
  String address;
  String address2;
  String state;
  String zipCode;
  String heading = '';
  String city;
  String orderID;
  String email;
  String firstName;
  String lastName;
  String phone;
  String paymentMethodType;

  PaymentMethod({
    this.amount = "",
    this.country = "",
    this.address = "",
    this.address2 = "",
    this.heading = "",
    this.state = "",
    this.zipCode = "",
    this.city = "",
    this.orderID = "",
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.phone = "",
    this.paymentMethodType = "CreditCard",
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Payment_Method__c'] = paymentMethodType;
    data['Amount__c'] = amount;
    data['Country__c'] = country;
    data['Address__c'] = address;
    data['Address_2__c'] = address2;
    data['State__c'] = state;
    data['Zip_Code__c'] = zipCode;
    data['City__c'] = city;
    data['Order__c'] = orderID;
    data['Email__c'] = email;
    data['First_Name__c'] = firstName;
    data['Last_Name__c'] = lastName;
    data['Phone__c'] = phone;
    return data;
  }

  @override
  List<Object?> get props => [
        amount,
        country,
        address,
        address2,
        heading,
        state,
        zipCode,
        city,
        orderID,
        email,
        firstName,
        lastName,
        phone
      ];
}
