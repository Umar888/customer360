import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/widgets/credit_card_widget.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/utils/custom_card_type_icon.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

class CardWidget extends StatefulWidget {
  final PaymentCardModel cardModel;
  final bool isDefault;
  final List<CustomCardTypeIcon> customCardTypeIcons;
  CardWidget({
    super.key,
    required this.cardModel,
    this.isDefault = false,
    this.customCardTypeIcons = const <CustomCardTypeIcon>[],
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isAmex = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var cardYear = widget.cardModel.expYear;
    if (cardYear?.length == 4) {
      cardYear = cardYear?.substring(2, 4);
    }

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    widget.isDefault ? Color(0xFFFF7643) : Colors.transparent),
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
                            overflow: TextOverflow.ellipsis)
                        .copyWith(
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: widget.cardModel.cardNumber?.substring(
                            (widget.cardModel.cardNumber?.length ?? 4) - 4,
                            widget.cardModel.cardNumber?.length ?? 0),
                        style: TextStyle(
                                color: ColorSystem.cardTextColor,
                                fontSize: SizeSystem.size12,
                                fontWeight: FontWeight.w300,
                                fontFamily: kRubik,
                                overflow: TextOverflow.ellipsis)
                            .copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      )
                    ]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXP ${widget.cardModel.expMonth}.$cardYear',
                    style: TextStyle(
                            color: ColorSystem.cardTextColor,
                            fontSize: SizeSystem.size12,
                            fontWeight: FontWeight.w300,
                            fontFamily: kRubik,
                            overflow: TextOverflow.ellipsis)
                        .copyWith(
                            color: ColorSystem.white,
                            fontSize: 11.26,
                            letterSpacing: 1.13),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${widget.cardModel.address?.firstName ?? ''} ${widget.cardModel.address?.lastName ?? ''}'
                        .toUpperCase(),
                    style: TextStyle(
                            color: ColorSystem.cardTextColor,
                            fontSize: SizeSystem.size12,
                            fontWeight: FontWeight.w300,
                            fontFamily: kRubik,
                            overflow: TextOverflow.ellipsis)
                        .copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            letterSpacing: 1.2),
                  )
                ],
              )
            ],
          ),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: EdgeInsets.only(right: 8, top: 22),
                child: getCardTypeIcon(widget.cardModel.cardNumber ?? ''))),
      ],
    );
  }

  /// Credit Card prefix patterns as of March 2019
  /// A [List<String>] represents a range.
  /// i.e. ['51', '55'] represents the range of cards starting with '51' to those starting with '55'
  Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
  };

  /// This function determines the Credit Card type based on the cardPatterns
  /// and returns it.
  CardType detectCCType(String cardNumber) {
    //Default card type is other
    CardType cardType = CardType.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    cardNumPatterns.forEach(
      (CardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          String ccPatternStr =
              cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }

  List<CustomCardTypeIcon> getCustomCardTypeIcon(CardType currentCardType) =>
      widget.customCardTypeIcons
          .where((CustomCardTypeIcon element) =>
              element.cardType == currentCardType)
          .toList();

  Widget getCardTypeIcon(String cardNumber) {
    Widget icon;
    final CardType ccType = detectCCType(cardNumber);
    final List<CustomCardTypeIcon> customCardTypeIcon =
        getCustomCardTypeIcon(ccType);
    if (customCardTypeIcon.isNotEmpty) {
      icon = customCardTypeIcon.first.cardImage;
      isAmex = ccType == CardType.americanExpress;
    } else {
      switch (ccType) {
        case CardType.visa:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            package: 'gc_customer_app',
            height: 48,
            width: 48,
          );
          isAmex = false;
          break;

        case CardType.americanExpress:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            package: 'gc_customer_app',
            height: 48,
            width: 48,
          );
          isAmex = true;
          break;

        case CardType.mastercard:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            package: 'gc_customer_app',
            height: 48,
            width: 48,
          );
          isAmex = false;
          break;

        case CardType.discover:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            package: 'gc_customer_app',
            height: 48,
            width: 48,
          );
          isAmex = false;
          break;

        default:
          icon = Container(
            height: 48,
            width: 48,
          );
          isAmex = false;
          break;
      }
    }

    return icon;
  }
}
