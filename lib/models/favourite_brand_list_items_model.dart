// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class FavouriteBrandListItems extends Equatable{
  String? brandName;
  String? brandImageUrl;
  String? brandNoUpdates;
  FavouriteBrandListItems({
    this.brandName,
    this.brandImageUrl,
    this.brandNoUpdates,
  });
  @override
  List<Object?> get props => [brandName,brandImageUrl,brandNoUpdates];

}
