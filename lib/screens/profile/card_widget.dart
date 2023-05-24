import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

class CardWidget extends StatelessWidget {
  final PaymentCardModel cardModel;
  final bool isDefault;
  CardWidget(
      {super.key, required this.cardModel, this.isDefault = false});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDefault ? Color(0xFFFF7643) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
                text: 'Ending with ',
                style: TextStyle(
                    color: ColorSystem.cardTextColor,
                    fontSize: SizeSystem.size12,
                    fontWeight: FontWeight.w300,
                    fontFamily: kRubik,
                    overflow: TextOverflow.ellipsis),
                children: [
                  TextSpan(
                    text: cardModel.cardNumber,
                    style: TextStyle(
                        color: ColorSystem.cardTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: kRubik,
                        overflow: TextOverflow.ellipsis),
                  )
                ]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXP ${cardModel.expMonth}',
                style: TextStyle(
                    color: ColorSystem.white,
                    fontSize: SizeSystem.size12,
                    fontWeight: FontWeight.w300,
                    fontFamily: kRubik,
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(height: 2),
              Text(
                '${cardModel.address?.firstName ?? ''} ${cardModel.address?.lastName ?? ''}',
                style: TextStyle(
                    color: ColorSystem.cardTextColor,
                    fontSize: SizeSystem.size12,
                    fontWeight: FontWeight.w500,
                    fontFamily: kRubik,
                    overflow: TextOverflow.ellipsis),
              )
            ],
          )
        ],
      ),
    );
  }
}
