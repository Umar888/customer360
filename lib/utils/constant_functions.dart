import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:intl/intl.dart';
import "dart:math";

Color getCustomerLevelColor(String level) {
  switch (level) {
    case 'LOW':
      return ColorSystem.purple;
    case 'MEDIUM':
      return ColorSystem.darkOchre;
    case 'HIGH':
      return ColorSystem.complimentary;
    default:
      return ColorSystem.complimentary;
  }
}

String getCustomerLevel(double ltv) {
  if (ltv <= 500) {
    return 'LOW';
  } else if (ltv > 500 && ltv <= 1000) {
    return 'MEDIUM';
  } else {
    return 'HIGH';
  }
}

double aovCalculator(double? ltv, double? lnt) {
  if (ltv != null && lnt != null) {
    return ltv / lnt;
  } else {
    return 0;
  }
}

String formattedNumber(double value) {
  var f = NumberFormat.compact(locale: "en_US");
  return f.format(value);
}

String dp(double val, int places){
  if(val.toString().split(".").length == 1 || val.toString().split(".")[1].length == 1){
    return val.toStringAsFixed(places);
  }
  else {
  num mod = pow(10.0, places);
  return (double.parse(((val * mod).toStringAsFixed(places))).round().toDouble() / mod).toString();
  }
}

String amountFormatting(double amount){
  return dp(amount,2);
   //  int lengthAfterDecimal;
   //  String firstpart='';
   //  String secondPart='';
   // firstpart= amount.toString().split('.')[0];
   // secondPart= amount.toString().split('.')[1];
   //
   //  lengthAfterDecimal=   amount.toString().split('.')[1].length;
   //    if (lengthAfterDecimal>=2) {
   //      return amount.toStringAsFixed(2);
   //    }else{
   //      secondPart='0'+secondPart;
   //    }
   //  return firstpart+'.'+secondPart;
  }
