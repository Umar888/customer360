part of 'promotion_bloc.dart';

@immutable
abstract class PromotionScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PromotionScreenInitial extends PromotionScreenState {}

class PromotionScreenProgress extends PromotionScreenState {}

class PromotionScreenFailure extends PromotionScreenState {}

class PromotionScreenSuccess extends PromotionScreenState {
  final PromotionModel? topPromotion;
  final List<PromotionModel>? activePromotions;
  PromotionScreenSuccess({this.topPromotion, this.activePromotions});

  @override
  List<Object?> get props => [topPromotion, activePromotions];
}
