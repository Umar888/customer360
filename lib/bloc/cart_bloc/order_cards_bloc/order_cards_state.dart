part of 'order_cards_bloc.dart';

enum OrderCardsStatus { initState, loadState, successState, failedState }

class OrderCardsState extends Equatable {
  List<CreditCardModelSave>? orderCardsModel;
  final OrderCardsStatus orderCardsStatus;
  final bool isAddedNewCard;
  final bool isUpdatedCard;
  final bool isAddedNewCardFail;
  final String giftCardAvailable;
  final List<FinancialTypeModel>? essentialFinance;
  final List<FinancialTypeModel>? gearFinance;
  final String giftCardAvailableBalance;
  final CreditBalance? coaCreditBalance;
  final List<PaymentCardModel>? existingCards;

  OrderCardsState({
    this.orderCardsModel,
    this.orderCardsStatus = OrderCardsStatus.initState,
    this.isAddedNewCard = false,
    this.isUpdatedCard = false,
    this.giftCardAvailable = '0.0',
    this.essentialFinance,
    this.gearFinance,
    this.giftCardAvailableBalance = '0.0',
    this.isAddedNewCardFail = false,
    this.coaCreditBalance,
    this.existingCards,
  });

  OrderCardsState copyWith({
    OrderCardsStatus? orderCardsStatus,
    List<CreditCardModelSave>? orderCardsModel,
    bool? isAddedNewCard,
    bool? isAddedNewCardFail,
    bool? isUpdatedCard,
    String? giftCardAvailable,
    String? coaCurrentBalance,
    String? coaAvailableAmount,
    List<FinancialTypeModel>? essentialFinance,
    List<FinancialTypeModel>? gearFinance,
    String? giftCardAvailableBalance,
    CreditBalance? coaCreditBalance,
    List<PaymentCardModel>? existingCards,
  }) {
    return OrderCardsState(
      orderCardsModel: orderCardsModel ?? this.orderCardsModel,
      orderCardsStatus: orderCardsStatus ?? this.orderCardsStatus,
      isAddedNewCard: isAddedNewCard ?? false,
      isUpdatedCard: isUpdatedCard ?? false,
      giftCardAvailable: giftCardAvailable ?? this.giftCardAvailable,
      essentialFinance: essentialFinance ?? this.essentialFinance,
      gearFinance: gearFinance ?? this.gearFinance,
      giftCardAvailableBalance:
          giftCardAvailableBalance ?? this.giftCardAvailableBalance,
      isAddedNewCardFail: isAddedNewCardFail ?? this.isAddedNewCardFail,
      coaCreditBalance: coaCreditBalance ?? this.coaCreditBalance,
      existingCards: existingCards ?? this.existingCards,
    );
  }

  @override
  List<Object?> get props => [
        orderCardsModel,
        orderCardsStatus,
        isAddedNewCard,
        isUpdatedCard,
        giftCardAvailable,
        essentialFinance,
        gearFinance,
        giftCardAvailableBalance,
        isAddedNewCardFail,
        coaCreditBalance,
        existingCards,
      ];
}

// class OrderCardsInitial extends OrderCardsState {
//   OrderCardsInitial(super.orderCardsModel);
// }

// class OrderCardsProgress extends OrderCardsState {
//   OrderCardsProgress(super.orderCardsModel);

//   @override
//   List<Object?> get props => [orderCardsModel];
// }

// class OrderCardsFailure extends OrderCardsState {
//   OrderCardsFailure(super.orderCardsModel);

//   @override
//   List<Object?> get props => [orderCardsModel];
// }

// class OrderCardsSuccess extends OrderCardsState {
//   final List<CreditCardModelSave>? orderCardsModel;
//   OrderCardsSuccess({this.orderCardsModel}) : super(null);

//   @override
//   List<Object?> get props => [orderCardsModel];
// }

// class AddCardsSuccess extends OrderCardsState {
//   final List<CreditCardModelSave>? orderCardsModel;
//   AddCardsSuccess({this.orderCardsModel}) : super(null);

//   @override
//   List<Object?> get props => [orderCardsModel];
// }
