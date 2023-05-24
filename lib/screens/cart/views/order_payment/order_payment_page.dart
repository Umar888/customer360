import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/order_cards_bloc/order_cards_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/views/flutter_credit_card.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/cart/views/order_payment/add_payment_method_widget.dart';
import 'package:gc_customer_app/screens/cart/views/order_payment/empty_card_widget.dart';

class OrderPaymentPage extends StatefulWidget {
  final CartState cartState;
  final Function onScroll;
  final String orderId;
  final String userId;
  final String email;
  final String phone;
  OrderPaymentPage(
      {Key? key,
      required this.cartState,
      required this.onScroll,
      required this.orderId,
      required this.userId,
      required this.email,
      required this.phone})
      : super(key: key);

  @override
  State<OrderPaymentPage> createState() => _OrderPaymentPageState();
}

class _OrderPaymentPageState extends State<OrderPaymentPage> {
  late CartBloc cartBloc;
  late OrderCardsBloc cardsBloc;

  @override
  void initState() {
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'OrderCardsScreen');
    cartBloc = context.read<CartBloc>();
    cardsBloc = context.read<OrderCardsBloc>();
    // cardsBloc.add(LoadCardsData(widget.orderId, widget.cartState.total));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var orderTotal = widget.cartState.orderDetailModel[0].total;

    return Expanded(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  widget.onScroll();
                } else if (scrollNotification is ScrollUpdateNotification) {
                  widget.onScroll();
                } else if (scrollNotification is ScrollEndNotification) {
                  widget.onScroll();
                }
                return true;
              },
              child: SingleChildScrollView(
                child: BlocBuilder<OrderCardsBloc, OrderCardsState>(
                    builder: (context, state) {
                  if (state.orderCardsStatus == OrderCardsStatus.loadState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var creditCardModelSave = state.orderCardsModel ?? [];
                  widget.cartState.creditCardModelSave = creditCardModelSave;
                  return Column(
                    children: [
                      creditCardModelSave.isEmpty
                          ? EmptyCardWidget()
                          : Column(
                              children: creditCardModelSave
                                  .asMap()
                                  .entries
                                  .map<Widget>((e) {
                                return _cardItemWidget(
                                    e, creditCardModelSave.length - 1, state);
                              }).toList(),
                            ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30)
                            .copyWith(bottom: 300),
                        child: InkWell(
                          onTap: () {
                            double defaultInputAmount = orderTotal ?? 0;
                            for (var i = 0;
                                i < (state.orderCardsModel?.length ?? 0);
                                i++) {
                              defaultInputAmount -= double.parse(state
                                      .orderCardsModel![i].availableAmount
                                      ?.replaceAll('\$', '')
                                      .replaceAll(',', '') ??
                                  '0.0');
                            }
                            if (defaultInputAmount < 0) defaultInputAmount = 0;
                            _addNewPaymentMethod(
                                defaultInputAmount: defaultInputAmount,
                                state: state);
                          },
                          child: DottedBorder(
                            color: Colors.black,
                            strokeWidth: 1,
                            dashPattern: [10, 2],
                            radius: Radius.circular(12),
                            borderType: BorderType.RRect,
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.9,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  " + Add Payment Method",
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Theme.of(context).primaryColor,
                                      fontFamily: kRubik),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> _addNewPaymentMethod({
    CreditCardModelSave? card,
    double defaultInputAmount = 0,
    OrderCardsState? state,
    int? index,
  }) async {
    String existingCards = (state?.existingCards ?? []).isEmpty
        ? ''
        : '(${state!.existingCards!.length})';
    bool isCOAAvailable = (state?.orderCardsModel ?? [])
            .where((c) => c.cardType == PaymentMethodType.cOA)
            .isEmpty &&
        state?.coaCreditBalance?.availableAmount != null;
    bool isSelectedExistingCard = false;
    var type = card?.cardType ??
        await showDialog<PaymentMethodType?>(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Payment Method'),
              actions: [
                CupertinoDialogAction(
                  child: Text(
                    'Credit/Debit Card $existingCards',
                    style: TextStyle(fontSize: 17, color: ColorSystem.black),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, PaymentMethodType.credit),
                ),
                CupertinoDialogAction(
                  child: Text(
                    'Guitar Center Essentials Card',
                    style: TextStyle(fontSize: 17, color: ColorSystem.black),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, PaymentMethodType.gcEssentials),
                ),
                CupertinoDialogAction(
                  child: Text(
                    'Guitar Center Gear Card',
                    style: TextStyle(fontSize: 17, color: ColorSystem.black),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, PaymentMethodType.gcGear),
                ),
                CupertinoDialogAction(
                  child: Text(
                    'Guitar Center Gift Card',
                    style: TextStyle(fontSize: 17, color: ColorSystem.black),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, PaymentMethodType.gcGift),
                ),
                CupertinoDialogAction(
                  child: Text(
                    isCOAAvailable
                        ? 'COA (Available - \$${state?.coaCreditBalance?.availableAmount})'
                        : 'COA (Unavailable)',
                    style: TextStyle(fontSize: 17, color: ColorSystem.black),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, PaymentMethodType.cOA),
                ),
              ],
            );
          },
        );

    if (type == PaymentMethodType.credit && existingCards.isNotEmpty) {
      ///dialog select type card
      var selectedCreditCard = await showDialog<PaymentCardModel?>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Credit Card'),
            actions: [
              ...state!.existingCards!
                  .map<Widget>(
                    (c) => CupertinoDialogAction(
                      child: Text(
                        '${c.cardType} **** **** **** ${c.cardNumber!.substring(c.cardNumber!.length - 4, c.cardNumber!.length)}',
                        style:
                            TextStyle(fontSize: 17, color: ColorSystem.black),
                      ),
                      onPressed: () => Navigator.pop(context, c),
                    ),
                  )
                  .toList(),
              CupertinoDialogAction(
                child: Text(
                  'Manual Input',
                  style: TextStyle(fontSize: 17, color: ColorSystem.black),
                ),
                onPressed: () => Navigator.pop(context, null),
              ),
            ],
          );
        },
      );
      if (selectedCreditCard != null) {
        isSelectedExistingCard = true;
        var cardNumber = '';
        selectedCreditCard.cardNumber =
            selectedCreditCard.cardNumber!.replaceAll(' ', '');
        cardNumber = selectedCreditCard.cardNumber!;
        card = CreditCardModelSave(
            cardNumber: cardNumber,
            cvvCode: '',
            cardHolderName:
                '${selectedCreditCard.address?.firstName ?? ''} ${selectedCreditCard.address?.lastName ?? ''}',
            expiryMonth: selectedCreditCard.expMonth ?? '',
            expiryYear: (selectedCreditCard.expYear ?? '').length == 4
                ? selectedCreditCard.expYear!.substring(2, 4)
                : selectedCreditCard.expYear ?? '',
            cardType: PaymentMethodType.credit,
            availableAmount: defaultInputAmount.toStringAsFixed(2),
            paymentMethod: PaymentMethod(
              amount: '0.0',
              country: selectedCreditCard.address?.country ?? '',
              address: selectedCreditCard.address?.street1 ?? '',
              heading: '',
              state: selectedCreditCard.address?.state ?? '',
              zipCode: selectedCreditCard.address?.zipCode ?? '',
              city: selectedCreditCard.address?.city ?? '',
              orderID: '',
              email: '',
              firstName: selectedCreditCard.address?.firstName ?? '',
              lastName: selectedCreditCard.address?.lastName ?? '',
              phone: selectedCreditCard.address?.phone?.value ?? '',
            ));
      }
    }

    if (type == PaymentMethodType.cOA &&
        (state?.orderCardsModel
                ?.any((c) => c.cardType == PaymentMethodType.cOA) ??
            false)) if (type != null) {
      showMessage(context: context, message: 'You have already added COA');
      return;
    }

    if (type == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: BlocProvider.value(
            value: cardsBloc,
            child: BlocProvider.value(
              value: cartBloc,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom / 2),
                child: AddPaymentMethodWidget(
                  cartState: widget.cartState,
                  type: type,
                  cardEdit: card,
                  defaultInputAmount: defaultInputAmount,
                  orderId: widget.orderId,
                  isSelectedExistingCard: isSelectedExistingCard,
                  cardIndex: index,
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      cardsBloc.add(RemoveGiftCardBalance());
    });
  }

  Widget _cardItemWidget(MapEntry<int, CreditCardModelSave> e,
      int savedCardLength, OrderCardsState state) {
    var index = e.key;
    var card = e.value;
    return Container(
      margin: EdgeInsets.only(bottom: 25, left: 14, right: 14),
      child: GestureDetector(
        onTap: () => _addNewPaymentMethod(card: card, index: index),
        child: CreditCardWidget(
          isCOACard: card.cardType == PaymentMethodType.cOA,
          coaCreditBalance: state.coaCreditBalance,
          obscureCardNumber: true,
          showAmount: true,
          showChip: true,
          isAmountEditable: card.cardType != PaymentMethodType.cOA &&
              card.cardType != PaymentMethodType.gcGift,
          amount: card.availableAmount ?? '',
          obscureCardCvv: false,
          isHolderNameVisible: card.cardType == PaymentMethodType.credit ||
              card.cardType == PaymentMethodType.gcEssentials ||
              card.cardType == PaymentMethodType.gcGear,
          isCardMonthYearVisible: card.cardType == PaymentMethodType.credit,
          isSwipeGestureEnabled: false,
          height: card.cardType == PaymentMethodType.cOA
              ? MediaQuery.of(context).size.width / 2.2
              : MediaQuery.of(context).size.width / 2,
          width: MediaQuery.of(context).size.width,
          backgroundImage: "assets/icons/credit_card_background.png",
          glassmorphismConfig: null,
          cardHolderName: card.cardHolderName,
          expiryMonth: card.expiryMonth,
          expiryYear: card.expiryYear,
          cardNumber: card.cardNumber,
          cvvCode: card.cvvCode,
          showBackView: card.isCvvFocused,
          onCreditCardWidgetChange: (CreditCardBrand) {},
          onSubmitNewAmount: (p0) {
            cardsBloc.add(UpdateCard(card..availableAmount = p0, index));
          },
          paymentMethodType: card.cardType,
          financialTypeModel: card.financialTypeModel,
        ),
      ),
    );
  }
}
