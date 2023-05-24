import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/profile/profile_screen_main.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/enums/music_instrument_enum.dart';
import 'package:intl/intl.dart';

class ProfileLandingWidget extends StatelessWidget {
  final LandingScreenState landingScreenState;
  final Function onPressed;
  ProfileLandingWidget(
      {Key? key, required this.landingScreenState, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = kIsWeb ? 350 : MediaQuery.of(context).size.width;
    var textThem = Theme.of(context).textTheme;
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () => onPressed(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: widthOfScreen * 0.3,
            width: widthOfScreen * 0.3,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/images/profileBackground.png',
                      package: 'gc_customer_app',
                    ),
                    fit: BoxFit.contain)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                landingScreenState.customerInfoModel!.records!.first
                            .primaryInstrumentCategoryC !=
                        null
                    ? SvgPicture.asset(
                        MusicInstrument.getInstrumentIcon(
                            MusicInstrument.getMusicInstrumentFromString(
                                landingScreenState.customerInfoModel!.records!
                                    .first.primaryInstrumentCategoryC!)),
                        package: 'gc_customer_app',
                        width: 50,
                        fit: BoxFit.cover)
                    : SvgPicture.asset(
                        'assets/icons/guitar.svg',
                        package: 'gc_customer_app',
                      ),
                SizedBox(height: 2),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontFamily: kRubik),
                    children: [
                      TextSpan(
                        text:
                            '${landingScreenState.customerInfoModel!.records!.first.primaryInstrumentCategoryC ?? '--'} ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontFamily: kRubik,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontFamily: kRubik,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: widthOfScreen * 0.05),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((landingScreenState
                            .customerInfoModel?.records?.first.name ??
                        '')
                    .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          landingScreenState
                              .customerInfoModel!.records!.first.name!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                      SizedBox(height: 5),
                    ],
                  ),
                (landingScreenState
                                    .customerInfoModel!.records!.first.accountPhoneC ??
                                '')
                            .isEmpty &&
                        (landingScreenState
                                    .customerInfoModel!.records!.first.phone ??
                                '')
                            .isEmpty &&
                        (landingScreenState
                                    .customerInfoModel!.records!.first.phoneC ??
                                '')
                            .isEmpty
                    ? SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              landingScreenState.customerInfoModel!.records!.first
                                          .accountPhoneC !=
                                      null
                                  ? landingScreenState
                                      .customerInfoModel!.records!.first.accountPhoneC!
                                      .toMobileFormat()
                                  : landingScreenState.customerInfoModel!
                                              .records!.first.phoneC !=
                                          null
                                      ? landingScreenState.customerInfoModel!
                                          .records!.first.phoneC!
                                          .toMobileFormat()
                                      : landingScreenState.customerInfoModel!
                                                  .records!.first.phone !=
                                              null
                                          ? landingScreenState
                                              .customerInfoModel!
                                              .records!
                                              .first
                                              .phone!
                                              .toMobileFormat()
                                          : "",
                              style: textThem.headline3?.copyWith(
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(height: 5),
                        ],
                      ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        (landingScreenState.customerInfoModel!.records!.first.accountEmailC ?? '').isEmpty &&
                                (landingScreenState.customerInfoModel!.records!
                                            .first.emailC ??
                                        '')
                                    .isEmpty &&
                                (landingScreenState.customerInfoModel!.records!
                                            .first.personEmail ??
                                        '')
                                    .isEmpty
                            ? noCustomerEmailFoundtxt
                            : landingScreenState.customerInfoModel!.records![0]
                                        .accountEmailC !=
                                    null
                                ? landingScreenState.customerInfoModel!
                                    .records![0].accountEmailC!
                                : landingScreenState.customerInfoModel!
                                            .records![0].emailC !=
                                        null
                                    ? landingScreenState
                                        .customerInfoModel!.records![0].emailC!
                                    : landingScreenState.customerInfoModel!
                                                .records![0].personEmail !=
                                            null
                                        ? landingScreenState.customerInfoModel!
                                            .records![0].personEmail!
                                        : "",
                        style: textThem.headline5
                            ?.copyWith(color: Theme.of(context).primaryColor)),
                    SizedBox(height: 5),
                  ],
                ),
                if ((landingScreenState.customerInfoModel?.records?.first
                            .lastTransactionDateC ??
                        '')
                    .isNotEmpty)
                  Text(
                    'Last Purchased : ${formatDate(landingScreenState.customerInfoModel!.records!.first.lastTransactionDateC!)}',
                    style: TextStyle(
                      fontSize: SizeSystem.size14,
                      fontFamily: kRubik,
                      color: ColorSystem.secondary,
                    ),
                  ),
                SizedBox(height: 5),
                Row(
                  children: [
                    if (kIsWeb)
                      Text(
                        'LTV Band: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: kRubik,
                          color: ColorSystem.secondary,
                        ),
                      ),
                    SvgPicture.asset(IconSystem.badgeIcon,
                        package: 'gc_customer_app',
                        height: 18,
                        color: getCustomerLevelColor(getCustomerLevel(
                            landingScreenState.customerInfoModel?.records?.first
                                    .lifetimeNetSalesAmountC ??
                                0.0))),
                    SizedBox(width: 3),
                    Text(
                      getCustomerLevel(landingScreenState.customerInfoModel
                              ?.records?.first.lifetimeNetSalesAmountC ??
                          0),
                      style: TextStyle(
                        fontFamily: kRubik,
                        fontWeight: FontWeight.w600,
                        color: getCustomerLevelColor(getCustomerLevel(
                            landingScreenState.customerInfoModel?.records?.first
                                    .lifetimeNetSalesAmountC ??
                                0)),
                        fontSize: SizeSystem.size14,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  String formatDate(String date) {
    return DateFormat('MM-dd-yyyy').format(DateTime.parse(date));
  }

  Color getCustomerLevelColor(String level) {
    switch (level) {
      case 'LOW':
        return ColorSystem.purple;
      case 'MEDIUM':
        return ColorSystem.darkOchre;
      case 'HIGH':
        return ColorSystem.complimentary;
      default:
        return ColorSystem.complimentary;
    }
  }

  String getCustomerLevel(double ltv) {
    if (ltv <= 500) {
      return 'LOW';
    } else if (ltv > 500 && ltv <= 1000) {
      return 'MEDIUM';
    } else {
      return 'HIGH';
    }
  }
}
