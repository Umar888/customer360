// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ActivityClass extends Equatable{
  String? typeOfOrder;
  String? numberOfOrders;
  String? valueOfOrder;
  String? dateoforder;
  String? itemsOfOrder;
  ActivityClass({
    this.typeOfOrder,
    this.numberOfOrders,
    this.valueOfOrder,
    this.dateoforder,
    this.itemsOfOrder,
  });
  @override
  List<Object?> get props => [typeOfOrder,numberOfOrders,valueOfOrder,dateoforder,itemsOfOrder];

}
