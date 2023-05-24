import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CartPopupMenu extends Equatable{
  String? name;
  Widget? icon;

  CartPopupMenu({this.icon, this.name});

  @override
  List<Object?> get props => [name];

}