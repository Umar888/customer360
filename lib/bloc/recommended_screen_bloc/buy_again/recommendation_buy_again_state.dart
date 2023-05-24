// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'recommendation_buy_again_bloc.dart';

abstract class RecommendationBuyAgainState extends Equatable {
  RecommendationBuyAgainState();

  @override
  List<Object?> get props => [];
}

class BuyAgainInitial extends RecommendationBuyAgainState {}

class BuyAgainPageProgress extends RecommendationBuyAgainState {}

class BuyAgainFailure extends RecommendationBuyAgainState {}

class LoadBuyAgainItemsSuccess extends RecommendationBuyAgainState {
  final BuyAgainModel? buyAgainModel;
  final Records? product;
  final String? message;

  LoadBuyAgainItemsSuccess({required this.buyAgainModel, this.product, this.message = ""});

  @override
  List<Object?> get props => [buyAgainModel, message!, product];
}
