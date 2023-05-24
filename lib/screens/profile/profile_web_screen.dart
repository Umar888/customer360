import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/credit_balance_bloc/credit_balance_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart'
    as lcb;
import 'package:gc_customer_app/bloc/landing_screen_bloc/tagging_bloc/tagging_bloc.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/payment_cards_bloc/payment_cards_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/profile_screen_bloc.dart';
import 'package:gc_customer_app/common_widgets/slayout.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/data/data_sources/profile_screen/payment_cards_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_history_screen_repository/order_history_repository.dart';
import 'package:gc_customer_app/data/reporsitories/profile/payment_cards_repository.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/logout_button_web.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/channel_metric_pie_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/credit_balance_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/net_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_by_year_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_pie_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/tagging_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/user_information_business_data_widget.dart';
import 'package:gc_customer_app/screens/order_history/order_history_main.dart';
import 'package:gc_customer_app/screens/profile/addresses/addresses.dart';
import 'package:gc_customer_app/screens/profile/business_data.dart';
import 'package:gc_customer_app/screens/profile/customer_information.dart';
import 'package:gc_customer_app/screens/profile/payments/payments.dart';
import 'package:gc_customer_app/screens/profile/purchase_metrics/purchase_metrics.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class ProfileWebScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final Function? onPressed;
  final lcb.LandingScreenState? landingScreenState;
  ProfileWebScreen(
      {super.key,
      this.userProfile,
      required this.onPressed,
      this.landingScreenState});

  @override
  State<ProfileWebScreen> createState() => _ProfileWebScreenState();
}

class _ProfileWebScreenState extends State<ProfileWebScreen> {
  late ProfileScreenBloc profileScreenBloc;

  @override
  void initState() {
    super.initState();
    profileScreenBloc = context.read<ProfileScreenBloc>();
    profileScreenBloc.add(LoadData());
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth.isMobileWebDevice();
    return BlocBuilder<ProfileScreenBloc, ProfileScreenState>(
        builder: (context, state) {
      if (state is ProfileScreenSuccess) {
        var userProfile = state.userProfile;
        return Scaffold(
          // drawer:
          //     screenWidth.isMobileWebDevice() ? DrawerLandingWidget() : null,
          appBar: AppBar(
            centerTitle: true,
            title: Text('PROFILE',
                style: TextStyle(
                    fontFamily: kRubik,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontSize: 15)),
            actions: [if (!screenWidth.isMobileWebDevice()) LogoutButtonWeb()],
          ),
          backgroundColor: isMobile ? ColorSystem.white : null,
          body: ListView(
            padding: EdgeInsets.only(left: 34, top: 24),
            children: [
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _userInfor(userProfile),
                        GestureDetector(
                          onTap: () => widget.onPressed!(),
                          child: Container(
                            height: 200,
                            width: 350,
                            padding: EdgeInsets.only(top: 18, bottom: 14),
                            decoration: BoxDecoration(
                                color: ColorSystem.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: BlocProvider<OrderHistoryBloc>(
                              create: (context) => OrderHistoryBloc(
                                  orderHistoryRepository:
                                      OrderHistoryRepository(),
                                  landingScreenRepository:
                                      LandingScreenRepository()),
                              child: Center(
                                child: BusinessData(
                                    BoxConstraints(maxWidth: 350), userProfile),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 200,
                          width: 300,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                              color: ColorSystem.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: CustomerInformation(userProfile),
                        ),
                      ],
                    )
                  : Container(
                      // margin: EdgeInsets.symmetric(vertical: 20),
                      height: 240,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        children: [
                          GestureDetector(
                            onTap: () => widget.onPressed!(),
                            child: Container(
                              height: 200,
                              width: 350,
                              padding: EdgeInsets.only(left: 24, top: 18),
                              decoration: BoxDecoration(
                                  color: ColorSystem.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: ShadowSystem.webWidgetShadow),
                              child: BlocProvider<OrderHistoryBloc>(
                                create: (context) => OrderHistoryBloc(
                                    orderHistoryRepository:
                                        OrderHistoryRepository(),
                                    landingScreenRepository:
                                        LandingScreenRepository()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BusinessData(BoxConstraints(maxWidth: 350),
                                        userProfile),
                                    // SizedBox(height: 24),
                                    BlocProvider(
                                      create: (context) => CreditBalanceBloc(),
                                      child: CreditBalanceWidget(
                                          isHaveBackground: false,
                                          isHaveEmail:
                                              (userProfile?.accountEmailC ?? '')
                                                  .isNotEmpty),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            width: 300,
                            margin: EdgeInsets.only(left: 24),
                            padding: EdgeInsets.all(24).copyWith(right: 8),
                            decoration: BoxDecoration(
                                color: ColorSystem.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: ShadowSystem.webWidgetShadow),
                            child: CustomerInformation(userProfile),
                          ),
                        ],
                      ),
                    ),
              Container(
                height: 240,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  children: [
                    BlocProvider(
                        create: (context) => OrderHistoryBloc(
                              orderHistoryRepository: OrderHistoryRepository(),
                              landingScreenRepository: context
                                  .read<lcb.LandingScreenBloc>()
                                  .landingScreenRepository,
                            ),
                        child: Container(
                          width: 380,
                          child: OrderHistoryPieChartWidget(onTapChart: () {
                            context.read<NavigatorWebBloC>().selectedTabIndex =
                                3;
                          }),
                        )),
                    SizedBox(
                      width: 380,
                      child: ChannelMetricPieChartWidget(onTapChart: () {
                        context.read<NavigatorWebBloC>().selectedTabIndex = 3;
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 380,
                child: NetChartWidget(
                  customerInfoModel:
                      widget.landingScreenState!.customerInfoModel!,
                ),
              ),
              if (!isMobile)
                Column(
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.only(bottom: 12),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       BlocProvider(
                    //         create: (context) => CreditBalanceBloc(),
                    //         child: CreditBalanceWidget(
                    //             isHaveEmail: (userProfile?.accountEmailC ?? '')
                    //                 .isNotEmpty),
                    //       ),
                    //       SizedBox(width: 8),
                    //     ],
                    //   ),
                    // ),
                    if (screenWidth.isMobileWebDevice() || screenWidth <= 1000)
                      BlocProvider<OrderHistoryBloc>(
                        create: (context) => OrderHistoryBloc(
                            orderHistoryRepository: OrderHistoryRepository(),
                            landingScreenRepository: context
                                .read<lcb.LandingScreenBloc>()
                                .landingScreenRepository),
                        child: OrderHistoryByYearChartWidget(),
                      ),
                    SizedBox(height: 14),
                    if (!screenWidth.isMobileWebDevice() && screenWidth > 1000)
                      Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!screenWidth.isMobileWebDevice())
                              Expanded(
                                child: BlocProvider<OrderHistoryBloc>(
                                  create: (context) => OrderHistoryBloc(
                                      orderHistoryRepository:
                                          OrderHistoryRepository(),
                                      landingScreenRepository: context
                                          .read<lcb.LandingScreenBloc>()
                                          .landingScreenRepository),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 300),
                                    child: OrderHistoryByYearChartWidget(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (screenWidth.isMobileWebDevice() || screenWidth <= 1000)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 380),
                            child: BlocProvider(
                                create: (context) => OrderHistoryBloc(
                                      orderHistoryRepository:
                                          OrderHistoryRepository(),
                                      landingScreenRepository: context
                                          .read<lcb.LandingScreenBloc>()
                                          .landingScreenRepository,
                                    ),
                                child: OrderHistoryPieChartWidget(
                                    onTapChart: () {})),
                          ),
                          SizedBox(height: 14),
                          Container(
                            constraints: BoxConstraints(maxWidth: 380),
                            child:
                                ChannelMetricPieChartWidget(onTapChart: () {}),
                          ),
                          SizedBox(height: 14),
                        ],
                      ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     if (!screenWidth.isMobileWebDevice() &&
                    //         screenWidth > 1000)
                    //       SizedBox(
                    //         width: 380,
                    //         child:
                    //             ChannelMetricPieChartWidget(onTapChart: () {}),
                    //       ),
                    //   ],
                    // ),
                    SizedBox(height: 14),
                    BlocProvider(
                      create: (context) => TaggingBloc(),
                      child: TaggingWidget(),
                    ),
                  ],
                ),
              PurchaseMetrics(),
              Addresses(
                BoxConstraints(maxWidth: 350),
                userProfile: widget.userProfile,
              ),
              BlocProvider<PaymentCardsBloc>(
                create: (context) => PaymentCardsBloc(
                    PaymentCardsRepository(PaymentCardsDataSource())),
                child: Payments(BoxConstraints()),
              ),
              SizedBox(height: 100)
            ],
          ),
        );
      }
      return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ));
    });
  }

  Widget _userInfor(UserProfile? userProfile) {
    var textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.width / 3.75,
            width: MediaQuery.of(context).size.width / 3.75,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/profileBackground.png'),
              fit: BoxFit.contain,
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/guitar.svg'),
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
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
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
                            style: textTheme.headline3),
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
                        fontSize: 14,
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
}
