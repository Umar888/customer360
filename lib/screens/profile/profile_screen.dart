import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/payment_cards_bloc/payment_cards_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/profile_screen_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/data/data_sources/profile_screen/payment_cards_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_history_screen_repository/order_history_repository.dart';
import 'package:gc_customer_app/data/reporsitories/profile/payment_cards_repository.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/profile/addresses/addresses.dart';
import 'package:gc_customer_app/screens/profile/business_data.dart';
import 'package:gc_customer_app/screens/profile/customer_information.dart';
import 'package:gc_customer_app/screens/profile/payments/payments.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/utils_functions.dart';

import 'purchase_metrics/purchase_metrics.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;
  ProfileScreen({super.key, this.userProfile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileScreenBloc profileScreenBloc;

  @override
  void initState() {
    super.initState();
    profileScreenBloc = context.read<ProfileScreenBloc>();
    profileScreenBloc.add(LoadData());
    // if (!kIsWeb)
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'ProfileScreen');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: AppBarWidget(
            paddingFromleftLeading: constraints.maxWidth * 0.034,
            paddingFromRightActions: constraints.maxWidth * 0.034,
            leadingWidget: Icon(
              Icons.navigate_before_rounded,
              color: ColorSystem.black,
              size: 40,
            ),
            textThem: Theme.of(context).textTheme,
            onPressedLeading: () => Navigator.of(context).pop(),
            titletxt: 'PROFILE',
            actionsWidget: SizedBox.shrink(),
            actionOnPress: () => () {},
          ),
        ),
        body: BlocBuilder<ProfileScreenBloc, ProfileScreenState>(
            builder: (context, state) {
          if (state is ProfileScreenSuccess) {
            var userProfile = state.userProfile;
            return ListView(
              padding:
                  EdgeInsets.only(left: constraints.maxWidth / 20, bottom: 100),
              children: [
                _userInfor(constraints, userProfile),
                BlocProvider<OrderHistoryBloc>(
                  create: (context) => OrderHistoryBloc(
                      orderHistoryRepository: OrderHistoryRepository(),
                      landingScreenRepository: LandingScreenRepository()),
                  child: BusinessData(constraints, userProfile),
                ),
                SizedBox(height: 24),
                CustomerInformation(userProfile),
                PurchaseMetrics(),
                Addresses(
                  constraints,
                  userProfile: widget.userProfile,
                ),
                BlocProvider<PaymentCardsBloc>(
                  create: (context) => PaymentCardsBloc(
                      PaymentCardsRepository(PaymentCardsDataSource())),
                  child: Payments(constraints),
                ),
              ],
            );
          }
          return SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ));
        }),
      );
    });
  }

  Widget _userInfor(BoxConstraints constraints, UserProfile? userProfile) {
    var textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: constraints.maxWidth / 3.75,
            width: constraints.maxWidth / 3.75,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage(
                'assets/images/profileBackground.png',
                package: 'gc_customer_app',
              ),
              fit: BoxFit.contain,
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/guitar.svg',
                  package: 'gc_customer_app',
                ),
                Text(
                  guitaristtxt,
                  style: textTheme.headline4,
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(userProfile!.name! + " • ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                      Text(userProfile.brandCodeC!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 16,
                          )),
                    ],
                  ),
                ),
                (userProfile.accountPhoneC ?? '').isEmpty &&
                        (userProfile.phone ?? '').isEmpty &&
                        (userProfile.phoneC ?? '').isEmpty
                    ? SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          makephoneCall(userProfile.accountPhoneC != null
                              ? userProfile.accountPhoneC!.toMobileFormat()
                              : userProfile.accountPhoneC == null &&
                                      userProfile.phoneC != null
                                  ? userProfile.phoneC!.toMobileFormat()
                                  : userProfile.accountPhoneC == null &&
                                          userProfile.phoneC == null &&
                                          userProfile.phone != null
                                      ? userProfile.phone!.toMobileFormat()
                                      : "");
                        },
                        child: Text(
                            userProfile.accountPhoneC != null
                                ? userProfile.accountPhoneC!.toMobileFormat()
                                : userProfile.accountPhoneC == null &&
                                        userProfile.phoneC != null
                                    ? userProfile.phoneC!.toMobileFormat()
                                    : userProfile.accountPhoneC == null &&
                                            userProfile.phoneC == null &&
                                            userProfile.phone != null
                                        ? userProfile.phone!.toMobileFormat()
                                        : "",
                            style: textTheme.headline3?.copyWith(
                                color: ColorSystem.lavender3,
                                fontWeight: FontWeight.w500)),
                      ),
                Text(
                  (userProfile.accountEmailC ?? '').isEmpty &&
                          (userProfile.emailC ?? '').isEmpty &&
                          (userProfile.personEmail ?? '').isEmpty
                      ? noCustomerEmailFoundtxt
                      : userProfile.accountEmailC != null
                          ? userProfile.accountEmailC!
                          : userProfile.emailC != null
                              ? userProfile.emailC!
                              : userProfile.personEmail != null
                                  ? userProfile.personEmail!
                                  : "",
                  style: textTheme.headline3,
                  maxLines: 2,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(IconSystem.badgeIcon,
                        package: 'gc_customer_app',
                        height: 18,
                        color: getCustomerLevelColor(getCustomerLevel(
                            userProfile.lifetimeNetSalesAmountC ?? 0))),
                    SizedBox(width: 3),
                    Text(
                      getCustomerLevel(
                          userProfile.lifetimeNetSalesAmountC ?? 0),
                      style: TextStyle(
                        fontFamily: kRubik,
                        fontWeight: FontWeight.w600,
                        color: getCustomerLevelColor(getCustomerLevel(
                            userProfile.lifetimeNetSalesAmountC ?? 0)),
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
