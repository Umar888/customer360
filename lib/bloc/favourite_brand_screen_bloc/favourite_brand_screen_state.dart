// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'favourite_brand_screen_bloc.dart';

abstract class FavouriteBrandScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavouriteBrandScreenInitial extends FavouriteBrandScreenState {}

class FavouriteBrandScreenProgress extends FavouriteBrandScreenState {}

class FavouriteBrandScreenFailure extends FavouriteBrandScreenState {}

class FavouriteBrandScreenSuccess extends FavouriteBrandScreenState {
  final FavoriteBrandDetailModel? favoriteItems;
  final List<BrandItems>? brandItems;
  final asm.Records? product;
  final String? message;

  FavouriteBrandScreenSuccess({
    required this.favoriteItems,
    required this.brandItems,
    required this.product,
    required this.message,
  });
  @override
  List<Object?> get props => [favoriteItems,message,product,brandItems];
}
