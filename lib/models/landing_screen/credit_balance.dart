import 'package:equatable/equatable.dart';

class CreditBalance extends Equatable {
  CreditBalance({
    this.omsCustomerId = '0',
    this.omsCustomerEmailId = '',
    this.currentBalance = '0.0',
    this.availableAmount = '0.0',
  });

  String omsCustomerId;
  String? omsCustomerEmailId;
  String currentBalance;
  String availableAmount;

  factory CreditBalance.fromJson(Map<String, dynamic> json) => CreditBalance(
        omsCustomerId: json["OMSCustomerID"],
        omsCustomerEmailId: json["OMSCustomerEmailID"],
        currentBalance: json["CurrentBalance"],
        availableAmount: json["AvailableAmount"],
      );

  Map<String, dynamic> toJson() => {
        "OMSCustomerID": omsCustomerId,
        "OMSCustomerEmailID": omsCustomerEmailId,
        "CurrentBalance": currentBalance,
        "AvailableAmount": availableAmount,
      };

  @override
  List<Object?> get props =>
      [omsCustomerId, omsCustomerEmailId, currentBalance, availableAmount];
}
