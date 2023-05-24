// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'recommendation_cart_bloc.dart';

abstract class RecommendationCartState extends Equatable {
  RecommendationCartState();

  @override
  List<Object?> get props => [];
}

class CartLoadInitial extends RecommendationCartState {}

class CartLoadFailure extends RecommendationCartState {}

class CartLoadProgress extends RecommendationCartState {}

class LoadCartItemsSuccess extends RecommendationCartState {
  final ProductCartBrowseItemsModel? productCartBrowseItemsModel;
  final ProductCartFrequentlyBaughtItemsModel? productCartFrequentlyBaughtItemsModel;
  final asm.Records? product;
  final String message;

  LoadCartItemsSuccess({
    this.product,
    this.message = "",
    required this.productCartBrowseItemsModel,
    required this.productCartFrequentlyBaughtItemsModel,
  });

  @override
  List<Object?> get props => [productCartBrowseItemsModel, message, product, productCartFrequentlyBaughtItemsModel];
}
