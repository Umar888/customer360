part of 'payment_cards_bloc.dart';

@immutable
abstract class PaymentCardsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentCardsInitial extends PaymentCardsState {}

class PaymentCardsProgress extends PaymentCardsState {}

class PaymentCardsFailure extends PaymentCardsState {}

class PaymentCardsSuccess extends PaymentCardsState {
  final List<PaymentCardModel>? paymentCardsModel;

  PaymentCardsSuccess({this.paymentCardsModel});

  @override
  List<Object?> get props => [paymentCardsModel];
}
