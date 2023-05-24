import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension doubleExt on double {
  String toHumanRead() {
    if (this > 10000) {
      return '${(this / 1000).toStringAsFixed(2)} k';
    } else if (this > 1000) {
      return toStringAsFixed(1);
    } else {
      return toStringAsFixed(2);
    }
  }

  String toSmallerHumanRead() {
    if (this >= 1000000) {
      if (this % 1000000 == 0) {
        return '${(this / 1000).toStringAsFixed(0)} m';
      } else if (this % 100000 == 0)
        return '${(this / 1000).toStringAsFixed(1)} m';
    } else if (this > 1000) {
      if (this % 1000 == 0) {
        return '${(this / 1000).toStringAsFixed(0)} k';
      } else if (this % 100 == 0)
        return '${(this / 1000).toStringAsFixed(1)} k';
      return '${(this / 1000).toStringAsFixed(2)} k';
    } else {
      if (this % 1 == 0) {
        return toStringAsFixed(0);
      }
    }
    return toStringAsFixed(2);
  }

  bool isMobileWebDevice() {
    return this <= 600 ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String toShortPercent() {
    var value = double.parse(this.toStringAsFixed(2));
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
