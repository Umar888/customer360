part of 'payment_cards_bloc.dart';

@immutable
abstract class PaymentCardsEvent extends Equatable {
  PaymentCardsEvent();
  @override
  List<Object> get props => [];
}

class LoadCardsData extends PaymentCardsEvent {
  LoadCardsData();

  @override
  List<Object> get props => [];
}
