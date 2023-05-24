// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class OffersList extends Equatable{
  String? offPercentage;
  String? backAmount;
  String? numberOfProducts;
  OffersList({
    this.offPercentage,
    this.backAmount,
    this.numberOfProducts,
  });
  @override
  List<Object?> get props => [offPercentage,backAmount,numberOfProducts];

}
