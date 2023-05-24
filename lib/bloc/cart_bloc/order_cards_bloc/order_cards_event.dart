part of 'order_cards_bloc.dart';

@immutable
abstract class OrderCardsEvent extends Equatable {
  OrderCardsEvent();
  @override
  List<Object> get props => [];
}

class LoadCardsData extends OrderCardsEvent {
  final String orderId;
  final double totalCartValue;
  final bool isNeedToLoadCOA;
  LoadCardsData(this.orderId, this.totalCartValue,
      {this.isNeedToLoadCOA = true});

  @override
  List<Object> get props => [orderId];
}

class AddNewCard extends OrderCardsEvent {
  final CreditCardModelSave card;
  final double totalCartValue;
  AddNewCard(this.card, this.totalCartValue);

  @override
  List<Object> get props => [];
}

class DeleteCard extends OrderCardsEvent {
  final CreditCardModelSave card;
  DeleteCard(this.card);

  @override
  List<Object> get props => [];
}

class UpdateCard extends OrderCardsEvent {
  final CreditCardModelSave card;
  final int index;
  UpdateCard(this.card, this.index);

  @override
  List<Object> get props => [];
}

class GetGiftCardBalance extends OrderCardsEvent {
  final String cardNumber;
  final String pin;
  GetGiftCardBalance(this.cardNumber, this.pin);

  @override
  List<Object> get props => [cardNumber, pin];
}

class RemoveGiftCardBalance extends OrderCardsEvent {
  RemoveGiftCardBalance();
}

class UpdateCardAddress extends OrderCardsEvent {
  final AddressList address;
  UpdateCardAddress(this.address);
}
