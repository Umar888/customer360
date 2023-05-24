import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/order_cards_bloc/order_cards_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

class PaymentPanelWidget extends StatelessWidget {
  final bool isPaymentExpand;
  final Function onTapEdit;
  PaymentPanelWidget(
      {Key? key, required this.isPaymentExpand, required this.onTapEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 295,
      alignment: Alignment.topCenter,
      width: double.infinity,
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(26, 45, 49, 66),
                blurRadius: 30,
                offset: Offset(0, -5))
          ]),
      child: BlocBuilder<OrderCardsBloc, OrderCardsState>(
          builder: (context, state) {
        var cards = state.orderCardsModel ?? [];
        cards.removeWhere((c) =>
            double.parse(c.availableAmount?.replaceAll(',', '') ?? '0.0') == 0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  margin: EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                      color: ColorSystem.greyMild,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Image.asset(
                      IconSystem.creditCard,
                      package: 'gc_customer_app',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                    child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                              text: TextSpan(
                                  text: 'Payment ',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: kRubik,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500),
                                  children: [
                                TextSpan(
                                  text: '(${cards.length})',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: kRubik,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ])),
                          InkWell(
                            onTap: () {
                              onTapEdit();
                              context
                                  .read<CartBloc>()
                                  .add(UpdateActiveStep(value: 2));
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 3),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: ColorSystem.lavender,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: ColorSystem.lavender),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                      if (!isPaymentExpand)
                        ...cards
                            .map<Widget>((c) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    c.cardType == PaymentMethodType.cOA
                                        ? Text(
                                            'COA Balance',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontFamily: kRubik),
                                          )
                                        : Text(
                                            '**** **** **** ${c.cardNumber.substring(c.cardNumber.length - 4, c.cardNumber.length)}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontFamily: kRubik),
                                          ),
                                    Text(
                                      "\$${c.availableAmount}",
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Theme.of(context).primaryColor,
                                          fontFamily: kRubik),
                                    ),
                                  ],
                                ))
                            .toList(),
                    ],
                  ),
                )),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            if (isPaymentExpand) SizedBox(height: 14),
            if (isPaymentExpand)
              Container(
                height: 220,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          height: 115,
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 45)
                              .copyWith(top: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: ColorSystem.lavender3,
                              image: DecorationImage(
                                  image: AssetImage(
                                    // "assets/icons/credit_card_background.png"),
                                    'assets/images/card_background_4.png',
                                    package: 'gc_customer_app',
                                  ),
                                  fit: BoxFit.fitWidth)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 25),
                                  Text(
                                    cards[index].cardType ==
                                            PaymentMethodType.cOA
                                        ? 'COA'
                                        : '**** **** **** ${cards[index].cardNumber.substring(cards[index].cardNumber.length - 4, cards[index].cardNumber.length)}',
                                    style: TextStyle(
                                        color: ColorSystem.white,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: kRubik,
                                        fontSize: 16,
                                        letterSpacing: 1.6),
                                  ),
                                  SizedBox(height: 10),
                                  if (cards[index].cardType !=
                                      PaymentMethodType.cOA)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'EXP ${cards[index].expiryMonth}.${cards[index].expiryYear.length == 4 ? cards[index].expiryYear.substring(2, 4) : cards[index].expiryYear}',
                                              style: TextStyle(
                                                  color: ColorSystem.white,
                                                  letterSpacing: 1.13,
                                                  fontSize: 12,
                                                  fontFamily: kRubik,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            Text(
                                              cards[index]
                                                  .cardHolderName
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  color: ColorSystem.white,
                                                  letterSpacing: 1.3,
                                                  fontFamily: kRubik,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                ]),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: 24,
                            width: 100,
                            margin: EdgeInsets.only(right: 30),
                            decoration: BoxDecoration(
                                color: ColorSystem.black,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                      color: ColorSystem.black.withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: Offset(2, 5)),
                                ]),
                            child: Center(
                              child: Text(
                                '\$${double.parse(cards[index].availableAmount ?? '0.0').toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: ColorSystem.white,
                                  fontFamily: kRubik,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}
