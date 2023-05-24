part of 'promotion_bloc.dart';

abstract class PromotionEvent extends Equatable {
  PromotionEvent();
}

class LoadPromotions extends PromotionEvent {
  LoadPromotions();

  @override
  List<Object?> get props => [];
}
