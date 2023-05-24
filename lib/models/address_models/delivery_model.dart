import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DeliveryModel extends Equatable {
  String? type;
  String? price;
  String? time;
  bool? isSelected;
  String? address;
  String? pickupAddress;
  bool? isPickup;
  String? pickupDistance;
  String? name;

  DeliveryModel(
      {this.address,
      this.type,
      this.price,
      this.isSelected,
      this.time,
      this.isPickup,
      this.pickupDistance,
      this.pickupAddress,this.name,});

  @override
  List<Object?> get props => [type, price, time, isSelected, address];
}
