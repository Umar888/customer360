import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';
import '../../utils/enums/music_instrument_enum.dart';

class CustomerPopup extends StatelessWidget {
  final String customerId;
  final String clientName;
  final String? clientType;
  final String? primaryInstrument;
  final double? lastPurchaseValue;
  final double? ltv;
  final double? netTransactions;
  final String? lastVisitDate;
  final bool? lessons;
  final bool? openBox;
  final bool? loyalty;
  final bool? used;
  final bool? synchrony;
  final bool? vintage;

  CustomerPopup(
      {Key? key,
      required this.clientName,
        required this.customerId,
      this.clientType,
      required this.primaryInstrument,
      required this.lastPurchaseValue,
      required this.ltv,
      required this.netTransactions,
      required this.lastVisitDate,
      required this.lessons,
      required this.loyalty,
      required this.openBox,
      required this.synchrony,
      required this.used,
      required this.vintage})
      : super(key: key);

  String dateFormatter(String date) {
    var dateTime = DateTime.parse(date);
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          margin: EdgeInsets.symmetric(
            horizontal: PaddingSystem.padding16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              SizeSystem.size16,
            ),
            color: ColorSystem.culturedGrey,
          ),
          padding: EdgeInsets.symmetric(
            vertical: PaddingSystem.padding16,
            horizontal: PaddingSystem.padding16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: kRubik,
                        ),
                        children: [
                          TextSpan(
                            text: '$clientName ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: SizeSystem.size16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text: '• GC',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: SizeSystem.size16,
                              color: ColorSystem.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  if (ltv != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          IconSystem.badge,
                          height: 15,
                          width: 15,
                          color: getCustomerLevelColor(getCustomerLevel(ltv!)),
                        ),
                        SizedBox(
                          width: SizeSystem.size4,
                        ),
                        Text(
                          getCustomerLevel(ltv!),
                          style: TextStyle(
                            fontFamily: kRubik,
                            fontWeight: FontWeight.w600,
                            color:
                                getCustomerLevelColor(getCustomerLevel(ltv!)),
                            fontSize: SizeSystem.size12,
                          ),
                        ),
                      ],
                    )
                ],
              ),
              SizedBox(
                height: SizeSystem.size12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  primaryInstrument != null
                      ? SvgPicture.asset(MusicInstrument.getInstrumentIcon(
                          MusicInstrument.getMusicInstrumentFromString(
                              primaryInstrument!)))
                      : Text('--',
                          style: TextStyle(
                            fontSize: SizeSystem.size12,
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik,
                          )),
                  SizedBox(
                    width: SizeSystem.size10,
                  ),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: kRubik,
                        ),
                        children: [
                          TextSpan(
                            text: '${primaryInstrument ?? '--'} ',
                            style: TextStyle(
                              fontSize: SizeSystem.size12,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik,
                            ),
                          ),
                          if (vintage!)
                            TextSpan(
                              text: '| Vintage ',
                              style: TextStyle(
                                fontSize: SizeSystem.size12,
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik,
                              ),
                            ),
                          if (openBox!)
                            TextSpan(
                              text: '| Open-box ',
                              style: TextStyle(
                                fontSize: SizeSystem.size12,
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik,
                              ),
                            ),
                          if (used!)
                            TextSpan(
                              text: '| Used ',
                              style: TextStyle(
                                fontSize: SizeSystem.size12,
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik,
                              ),
                            ),
                          if (lessons!)
                            TextSpan(
                              text: '| Lessons ',
                              style: TextStyle(
                                fontSize: SizeSystem.size12,
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik,
                              ),
                            ),
                          if (loyalty!)
                            TextSpan(
                              text: '| Loyalty ',
                              style: TextStyle(
                                fontSize: SizeSystem.size12,
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik,
                              ),
                            ),
                          if (synchrony!)
                            TextSpan(
                              text: '| Synchrony ',
                              style: TextStyle(
                                fontSize: SizeSystem.size12,
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeSystem.size10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "L. PURCHASE",
                          style: TextStyle(
                            fontFamily: kRubik,
                            color: ColorSystem.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeSystem.size10,
                          ),
                        ),
                        SizedBox(
                          height: SizeSystem.size4,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: kRubik,
                            ),
                            children: [
                              TextSpan(
                                text: lastPurchaseValue != null
                                    ? '\$${amountFormatting(double.parse(formattedNumber(lastPurchaseValue!)))}'
                                    : '0.0',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: SizeSystem.size18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeSystem.size50,
                    child: VerticalDivider(
                      color: Color.fromRGBO(0, 0, 0, 0.04),
                      thickness: 1,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LTV",
                          style: TextStyle(
                            fontFamily: kRubik,
                            color: ColorSystem.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeSystem.size10,
                          ),
                        ),
                        SizedBox(
                          height: SizeSystem.size4,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: kRubik,
                            ),
                            children: [
                              TextSpan(
                                text: ltv != null
                                    ? '\$${amountFormatting(double.parse(formattedNumber(ltv!)))}'
                                    : '--',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeSystem.size18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeSystem.size50,
                    child: VerticalDivider(
                      color: Color.fromRGBO(0, 0, 0, 0.04),
                      thickness: 1,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AOV",
                          style: TextStyle(
                            fontFamily: kRubik,
                            color: ColorSystem.secondary,
                            fontWeight: FontWeight.w500,
                            fontSize: SizeSystem.size10,
                          ),
                        ),
                        SizedBox(
                          height: SizeSystem.size4,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: kRubik,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '\$${amountFormatting(double.parse(formattedNumber(aovCalculator(ltv, netTransactions))))}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: SizeSystem.size18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                lastVisitDate != null ? dateFormatter(lastVisitDate!) : '--',
                style: TextStyle(
                  fontFamily: kRubik,
                  color: Theme.of(context).primaryColor,
                  fontSize: SizeSystem.size12,
                ),
              ),
              SizedBox(
                height: SizeSystem.size10,
              ),
              Container(
                color: ColorSystem.secondary.withOpacity(0.6),
                height: SizeSystem.size1,
              ),
              SizedBox(
                height: SizeSystem.size16,
              ),
              Material(
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () async {
                    try {
                      await launchUrlString(
                          'salesforce1://sObject/$customerId/view');
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Center(
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: ColorSystem.lavender3,
                        fontSize: SizeSystem.size14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: SizeSystem.size4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
