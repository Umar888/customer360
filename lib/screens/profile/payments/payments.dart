import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/payment_cards_bloc/payment_cards_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';

import 'package:gc_customer_app/screens/profile/payments/card_widget.dart';

class Payments extends StatefulWidget {
  final BoxConstraints constraints;
  Payments(this.constraints, {Key? key}) : super(key: key);

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  late final PaymentCardsBloc paymentCardsBloc;
  var cardBackgrounds = [
    'assets/images/card_background_1.png',
    'assets/images/card_background_2.png',
    // 'assets/images/card_background_3.png',
    'assets/images/card_background_4.png',
    // 'assets/images/card_background_5.png',
    // 'assets/images/card_background_6.png',
  ];

  @override
  void initState() {
    paymentCardsBloc = context.read<PaymentCardsBloc>();
    paymentCardsBloc.add(LoadCardsData());
    cardBackgrounds.shuffle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(left: 12),
      child: BlocBuilder<PaymentCardsBloc, PaymentCardsState>(
          builder: (context, state) {
        List<PaymentCardModel> cards = [];
        if (state is PaymentCardsSuccess &&
            (state.paymentCardsModel ?? []).isNotEmpty) {
          cards = state.paymentCardsModel!;
        }
        // if (cards.isEmpty) return SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paymentstxt,
              style: textTheme.headline2?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 118,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.only(right: 12),
                  //   child: InkWell(
                  //     onTap: () => showModalBottomSheet(
                  //       context: context,
                  //       backgroundColor: Colors.transparent,
                  //       barrierColor: Color.fromARGB(25, 92, 106, 196),
                  //       isScrollControlled: true,
                  //       builder: (context) {
                  //         return AddCardPaymentBottomSheet();
                  //       },
                  //     ),
                  //     child: DottedBorder(
                  //       dashPattern: [5, 5],
                  //       borderType: BorderType.RRect,
                  //       color: ColorSystem.black,
                  //       radius: Radius.circular(15),
                  //       child: Container(
                  //         height: widgetHeight,
                  //         width: addressWidth / 2.76,
                  //         alignment: Alignment.center,
                  //         child: Icon(Icons.add),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  if (cards.isNotEmpty)
                    ...cards.asMap().entries.map<Widget>((ca) {
                      //Get background sequentially.
                      var background = cardBackgrounds[ca.key % 3];
                      return Container(
                        height: 118,
                        width: 182,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                          background,
                          package: 'gc_customer_app',
                        ))),
                        child: CardWidget(
                          cardModel: ca.value,
                          isDefault: ca.hashCode == cards.first.hashCode,
                        ),
                      );
                    }).toList()
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
