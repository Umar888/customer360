import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/auth_bloc.dart/auth_bloc.dart';
import 'package:gc_customer_app/bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/credit_balance_bloc/credit_balance_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/customer_reminder_bloc/customer_reminder_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/recommended_landing_bloc/recommended_landing_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/smart_trigger_bloc/smart_trigger_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/tagging_bloc/tagging_bloc.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/browser_history/recommendation_browse_history_bloc.dart';
import 'package:gc_customer_app/common_widgets/activity_button.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/activity_widget.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/agent_widget.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/favorite_brand_widget.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/landing_offers_widget.dart';
import 'package:gc_customer_app/common_widgets/other_tile_widget.dart';
import 'package:gc_customer_app/common_widgets/slayout.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/data/reporsitories/customer_look_up_repository/customer_lookup_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_history_screen_repository/order_history_repository.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/logout_button_web.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/customer_look_up/customer_lookup_widget.dart';
import 'package:gc_customer_app/screens/favourite_brand_screen/favourite_brand_web_screen.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_page.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/channel_metric_pie_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/credit_balance_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/net_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_by_year_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_pie_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/profile_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/recommended_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/smart_trigger_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/tagging_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/user_information_business_data_widget.dart';
import 'package:gc_customer_app/screens/offers_screen/offers_screen_main.dart';
import 'package:gc_customer_app/screens/order_history/order_history_main.dart';
import 'package:gc_customer_app/screens/profile/profile_screen_main.dart';
import 'package:gc_customer_app/screens/promotions/promotions_screen_main.dart';
import 'package:gc_customer_app/screens/recommendation_screen/browse_history_web_page.dart';
import 'package:gc_customer_app/screens/recommendation_screen/recommendation_screen_main.dart';
import 'package:gc_customer_app/screens/reminder/customer_remider_web_page.dart';
import 'package:gc_customer_app/screens/settings_screen/settings_screen_main.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/app_theme.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:gc_customer_app/utils/enums/music_instrument_enum.dart';
import 'package:intl/intl.dart';

class LandingScreenWebPage extends StatefulWidget {
  final UserProfile? userProfile;
  LandingScreenWebPage({super.key, this.userProfile});

  @override
  State<LandingScreenWebPage> createState() => _LandingScreenWebPageState();
}

class _LandingScreenWebPageState extends State<LandingScreenWebPage> {
  // final StreamController<int> selectedIndexController =
  //     StreamController<int>.broadcast()..add(0);
  late NavigatorWebBloC _navigatorBloC = context.read<NavigatorWebBloC>();

  late LandingScreenBloc landingScreenBloc;

  late List<Widget> _views;

  @override
  void initState() {
    super.initState();
    landingScreenBloc = context.read<LandingScreenBloc>();
    landingScreenBloc.add(LoadData());

    _views = [ProfileScreenMain(userProfile: widget.userProfile)];
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return BlocBuilder<LandingScreenBloc, LandingScreenState>(
        builder: (context, landingScreenState) {
      CustomerInfoModel? customerInfoModel;
      if (landingScreenState.landingScreenStatus ==
              LandingScreenStatus.failure ||
          ((landingScreenState.customerInfoModel?.records ?? []).isEmpty ||
              landingScreenState.customerInfoModel?.records?.first.id ==
                  null)) {
        return _handleNoCustomerData();
      }

      Records? userInfo;
      if (landingScreenState.landingScreenStatus ==
          LandingScreenStatus.success) {
        if (landingScreenState.message!.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            ScaffoldMessenger.of(context)
                .showSnackBar(snackBar(landingScreenState.message ?? ""));
            Navigator.pop(context);
          });
          landingScreenBloc.add(ClearMessage());
        }
        if (landingScreenState.customerInfoModel != null &&
            landingScreenState.customerInfoModel != null &&
            landingScreenState.customerInfoModel!.records != null &&
            landingScreenState.customerInfoModel!.records!.isNotEmpty) {
          customerInfoModel = landingScreenState.customerInfoModel;
          userInfo = customerInfoModel!.records!.first;
          _views = [
            BlocProvider.value(
              value: landingScreenBloc,
              child: ProfileScreenMain(
                onPressed: () => selectTab(5),
                landingScreenState: landingScreenState,
              ),
            ),
            BlocProvider<RecommendationBrowseHistoryBloc>(
                create: (context) => RecommendationBrowseHistoryBloc(
                    recommendationScreenRepository:
                        RecommendationScreenRepository()),
                child: Scaffold(
                  appBar: AppBar(
                    title: Text('Browsing History',
                        style: TextStyle(
                            fontFamily: kRubik,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            fontSize: 15)),
                    centerTitle: true,
                  ),
                  body: BrowseHistoryWebPage(
                      customerInfoModel: customerInfoModel),
                )),
            BlocProvider.value(
              value: landingScreenBloc,
              child: FavouriteBrandsWebScreen(
                customerInfoModel: customerInfoModel,
              ),
            ),
            // OffersScreenMain(
            //   customerInfoModel: customerInfoModel,
            //   offers: landingScreenState.landingScreenOffersModel?.offers ?? [],
            // ),
            // BlocProvider(
            //   create: (context) => SmartTriggerBloc(),
            //   child: SmartTriggerWidget(landingScreenState: landingScreenState),
            // ),
            // BlocProvider(
            //     create: (context) => CustomerReminderBloc(
            //         landingScreenBloc.landingScreenRepository),
            //     child: CustomerReminderWebPage()),
            OrderHistoryMain(
              landingScreenState: landingScreenState,
              customer: landingScreenState.customerInfoModel!,
              customerId: landingScreenState.customerInfoModel!.records![0].id!,
              orderHistoryLandingScreen:
                  landingScreenState.orderHistoryLandingScreen ?? [],
            ),
            SizedBox.shrink(),
            RecommendationScreenMain(customerInfoModel: customerInfoModel),
            PromotionsScreenMain(),
            SettingsScreenMain(),
          ];
        }
      }
      return StreamBuilder<int>(
          stream: _navigatorBloC.selectedTab,
          initialData: 0,
          builder: (context, snapshot) {
            var index = snapshot.data ?? 0;
            return (landingScreenState.landingScreenStatus ==
                    LandingScreenStatus.success)
                ? userInfo != null
                    ? SLayout(
                        desktop: (context, constraints) => Scaffold(
                          body: Row(
                            children: [
                              Container(
                                width: constraints.maxWidth / 4,
                                constraints: BoxConstraints(minWidth: 300),
                                child: ListView(
                                  padding: EdgeInsets.only(bottom: 100),
                                  children: [
                                    _header(theme, landingScreenState,
                                        userInfo!, index),
                                    _profileTabs(theme, userInfo, index),
                                    _ordersButtons(landingScreenState, index),
                                    _otherTabs(
                                        theme, landingScreenState, index),
                                    _gearAdvisor(landingScreenState),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: MaterialApp(
                                  debugShowCheckedModeBanner: false,
                                  title: 'GC Customer',
                                  theme: AppTheme.themeData,
                                  home: Scaffold(
                                    body: Container(
                                      color: ColorSystem.webBackgr,
                                      width: constraints.maxWidth * 3 / 4,
                                      child: _views[index],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // mobile: (context, constraints) => MaterialApp(
                        //   debugShowCheckedModeBanner: false,
                        //   title: 'GC Customer',
                        //   theme: AppTheme.themeData,
                        //   home: Scaffold(
                        //     drawer: DrawerLandingWidget(),
                        //     body: Container(
                        //       color: ColorSystem.webBackgr,
                        //       // width: constraints.maxWidth * 3 / 4,
                        //       child: _views[index],
                        //     ),
                        //   ),
                        // ),
                        mobile: (context, constraints) {
                          var widthOfScreen = constraints.maxWidth;
                          var heightOfScreen = constraints.maxHeight;
                          var textThem = Theme.of(context).textTheme;
                          final spaceBtwWidgets = SizedBox(height: 25);
                          return Scaffold(
                              appBar: AppBar(
                                leadingWidth: 0,
                                centerTitle: false,
                                automaticallyImplyLeading: false,
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        SharedPreferenceService()
                                            .setKey(key: agentId, value: '');
                                        SharedPreferenceService()
                                            .setKey(key: agentEmail, value: '');
                                        SharedPreferenceService().setKey(
                                            key: savedAgentName, value: '');
                                        landingScreenBloc.add(RemoveCustomer());
                                      },
                                      icon: SvgPicture.asset(
                                          IconSystem.leaveIcon),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 0),
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                                actions: [LogoutButtonWeb()],
                                elevation: 0,
                              ),
                              body:
                                  (landingScreenState.landingScreenStatus ==
                                          LandingScreenStatus.success)
                                      ? (customerInfoModel?.records ?? [])
                                              .isNotEmpty
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                left: widthOfScreen * 0.05,
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProfileScreenMain(
                                                                          userProfile:
                                                                              widget.userProfile,
                                                                          landingScreenState:
                                                                              landingScreenState,
                                                                        )));
                                                      },
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height:
                                                                widthOfScreen *
                                                                    0.3,
                                                            width:
                                                                widthOfScreen *
                                                                    0.3,
                                                            decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                    image: AssetImage(
                                                                      'assets/images/profileBackground.png',
                                                                    ),
                                                                    fit: BoxFit.contain)),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                landingScreenState.customerInfoModel!.records!.first.primaryInstrumentCategoryC !=
                                                                            null &&
                                                                        landingScreenState
                                                                            .customerInfoModel!
                                                                            .records!
                                                                            .first
                                                                            .primaryInstrumentCategoryC!
                                                                            .isNotEmpty
                                                                    ? SvgPicture.asset(
                                                                        MusicInstrument.getInstrumentIcon(MusicInstrument.getMusicInstrumentFromString(landingScreenState
                                                                            .customerInfoModel!
                                                                            .records!
                                                                            .first
                                                                            .primaryInstrumentCategoryC!)),
                                                                        width: widthOfScreen *
                                                                            0.17,
                                                                        fit: BoxFit
                                                                            .contain)
                                                                    : SvgPicture.asset(
                                                                        'assets/icons/guitar.svg',
                                                                        width: widthOfScreen *
                                                                            0.17,
                                                                        fit: BoxFit
                                                                            .contain),
                                                                SizedBox(
                                                                    height: 5),
                                                                RichText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  text:
                                                                      TextSpan(
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          kRubik,
                                                                    ),
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            '${landingScreenState.customerInfoModel!.records!.first.primaryInstrumentCategoryC ?? 'Guitar'} ',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              2 * (MediaQuery.of(context).size.height * 0.0095),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Theme.of(context).primaryColor,
                                                                          fontFamily:
                                                                              kRubik,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            ' ',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              2 * (MediaQuery.of(context).size.height * 0.0095),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Theme.of(context).primaryColor,
                                                                          fontFamily:
                                                                              kRubik,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  widthOfScreen *
                                                                      0.05),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: heightOfScreen *
                                                                          0.01),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                            landingScreenState.customerInfoModel!.records!.first.name ??
                                                                                "",
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                            )),
                                                                        Text(
                                                                            " • ",
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                            )),
                                                                        Text(
                                                                            landingScreenState.customerInfoModel!.records!.first.brandCodeC ??
                                                                                "",
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.grey,
                                                                              fontSize: 16,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  (landingScreenState.customerInfoModel!.records!.first.accountPhoneC ?? '').isEmpty &&
                                                                          (landingScreenState.customerInfoModel!.records!.first.phone ?? '')
                                                                              .isEmpty &&
                                                                          (landingScreenState.customerInfoModel!.records!.first.phoneC ?? '')
                                                                              .isEmpty
                                                                      ? SizedBox
                                                                          .shrink()
                                                                      : Padding(
                                                                          padding:
                                                                              EdgeInsets.only(top: 5),
                                                                          child: Text(
                                                                              landingScreenState.customerInfoModel!.records!.first.accountPhoneC != null
                                                                                  ? landingScreenState.customerInfoModel!.records!.first.accountPhoneC!.toMobileFormat()
                                                                                  : landingScreenState.customerInfoModel!.records!.first.accountPhoneC == null && landingScreenState.customerInfoModel!.records!.first.phoneC != null
                                                                                      ? landingScreenState.customerInfoModel!.records!.first.phoneC!.toMobileFormat()
                                                                                      : landingScreenState.customerInfoModel!.records!.first.accountPhoneC == null && landingScreenState.customerInfoModel!.records!.first.phoneC == null && landingScreenState.customerInfoModel!.records!.first.phone != null
                                                                                          ? landingScreenState.customerInfoModel!.records!.first.phone!.toMobileFormat()
                                                                                          : "",
                                                                              style: textThem.headline3),
                                                                        ),
                                                                  SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                      (landingScreenState.customerInfoModel!.records!.first.accountEmailC ?? '').isEmpty &&
                                                                              (landingScreenState.customerInfoModel!.records!.first.emailC ?? '').isEmpty &&
                                                                              (landingScreenState.customerInfoModel!.records!.first.personEmail ?? '').isEmpty
                                                                          ? noCustomerEmailFoundtxt
                                                                          : landingScreenState.customerInfoModel!.records![0].accountEmailC != null
                                                                              ? landingScreenState.customerInfoModel!.records![0].accountEmailC!
                                                                              : landingScreenState.customerInfoModel!.records![0].emailC != null
                                                                                  ? landingScreenState.customerInfoModel!.records![0].emailC!
                                                                                  : landingScreenState.customerInfoModel!.records![0].personEmail != null
                                                                                      ? landingScreenState.customerInfoModel!.records![0].personEmail!
                                                                                      : "",
                                                                      style: textThem.headline5),
                                                                  SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                    'Last Purchased : ${DateFormat('MM-dd-yyyy').format(DateTime.parse(landingScreenState.customerInfoModel?.records?.first.lastTransactionDateC ?? ''))}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          kRubik,
                                                                      color: ColorSystem
                                                                          .secondary,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          5),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'LTV Band: ',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily:
                                                                              kRubik,
                                                                          color:
                                                                              ColorSystem.secondary,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              4),
                                                                      SvgPicture.asset(
                                                                          IconSystem
                                                                              .badgeIcon,
                                                                          height:
                                                                              18,
                                                                          color:
                                                                              getCustomerLevelColor(getCustomerLevel(landingScreenState.customerInfoModel?.records?.first.lifetimeNetSalesAmountC ?? 0))),
                                                                      SizedBox(
                                                                          width:
                                                                              3),
                                                                      Text(
                                                                        getCustomerLevel(
                                                                            landingScreenState.customerInfoModel?.records?.first.lifetimeNetSalesAmountC ??
                                                                                0),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              kRubik,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              getCustomerLevelColor(getCustomerLevel(landingScreenState.customerInfoModel?.records?.first.lifetimeNetSalesAmountC ?? 0)),
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        BlocProvider(
                                                            create: (context) =>
                                                                CreditBalanceBloc(),
                                                            child: CreditBalanceWidget(
                                                                isHaveEmail: (landingScreenState.customerInfoModel!.records!.first.accountEmailC ?? '').isNotEmpty ||
                                                                    (landingScreenState.customerInfoModel!.records!.first.emailC ??
                                                                            '')
                                                                        .isNotEmpty ||
                                                                    (landingScreenState.customerInfoModel!.records!.first.personEmail ??
                                                                            '')
                                                                        .isNotEmpty)),
                                                        SizedBox(width: 8),
                                                        UserInformationBusinessWidget(
                                                          userProfile: UserProfile
                                                              .fromJson(
                                                                  landingScreenState
                                                                      .customerInfoModel!
                                                                      .records!
                                                                      .first
                                                                      .toJson()),
                                                        ),
                                                      ],
                                                    ),
                                                    BlocProvider<
                                                        OrderHistoryBloc>(
                                                      create: (context) => OrderHistoryBloc(
                                                          orderHistoryRepository:
                                                              OrderHistoryRepository(),
                                                          landingScreenRepository:
                                                              landingScreenBloc
                                                                  .landingScreenRepository),
                                                      child:
                                                          OrderHistoryByYearChartWidget(),
                                                    ),
                                                    SizedBox(height: 14),
                                                    BlocProvider(
                                                        create: (context) =>
                                                            OrderHistoryBloc(
                                                              orderHistoryRepository:
                                                                  OrderHistoryRepository(),
                                                              landingScreenRepository:
                                                                  landingScreenBloc
                                                                      .landingScreenRepository,
                                                            ),
                                                        child:
                                                            OrderHistoryPieChartWidget(
                                                                onTapChart: () {
                                                          Navigator.of(context).push(CupertinoPageRoute(
                                                              builder: (context) => OrderHistoryMain(
                                                                  landingScreenState:
                                                                      landingScreenState,
                                                                  customer:
                                                                      landingScreenState
                                                                          .customerInfoModel!,
                                                                  orderHistoryLandingScreen:
                                                                      landingScreenState.orderHistoryLandingScreen ??
                                                                          [],
                                                                  customerId: landingScreenState
                                                                      .customerInfoModel!
                                                                      .records![
                                                                          0]
                                                                      .id!,
                                                                  isOtherUser:
                                                                      widget.userProfile !=
                                                                          null,
                                                                  isOnlyShowOrderHistory:
                                                                      true)));
                                                        })),
                                                    ChannelMetricPieChartWidget(
                                                        onTapChart: () {
                                                      Navigator.of(context).push(
                                                          CupertinoPageRoute(
                                                              builder: (context) =>
                                                                  OrderHistoryMain(
                                                                    landingScreenState:
                                                                        landingScreenState,
                                                                    customer:
                                                                        landingScreenState
                                                                            .customerInfoModel!,
                                                                    orderHistoryLandingScreen:
                                                                        landingScreenState.orderHistoryLandingScreen ??
                                                                            [],
                                                                    customerId: landingScreenState
                                                                        .customerInfoModel!
                                                                        .records![
                                                                            0]
                                                                        .id!,
                                                                    isOtherUser:
                                                                        widget.userProfile !=
                                                                            null,
                                                                    isOnlyShowOrderHistory:
                                                                        true,
                                                                  )));
                                                    }),
                                                    NetChartWidget(
                                                      customerInfoModel:
                                                          landingScreenState
                                                              .customerInfoModel!,
                                                    ),
                                                    SizedBox(height: 24),
                                                    BlocProvider(
                                                      create: (context) =>
                                                          TaggingBloc(),
                                                      child: TaggingWidget(),
                                                    ),
                                                    landingScreenState
                                                                .landingScreenRecommendationModel !=
                                                            null
                                                        ? BlocProvider(
                                                            create: (context) =>
                                                                RecommendedLandingBloc(),
                                                            child: RecommendedWidget(
                                                                landingScreenRecommendationModel:
                                                                    landingScreenState
                                                                        .landingScreenRecommendationModel!,
                                                                landingScreenState:
                                                                    landingScreenState),
                                                          )
                                                        : SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.2,
                                                            child: Center(
                                                                child:
                                                                    CircularProgressIndicator())),
                                                    BlocProvider.value(
                                                      value: landingScreenBloc,
                                                      child: FavoriteBrand(
                                                        landingScreenState:
                                                            landingScreenState,
                                                      ),
                                                    ),
                                                    LandingOffersWidget(
                                                        customerInfoModel:
                                                            landingScreenState
                                                                .customerInfoModel!),
                                                    spaceBtwWidgets,
                                                    Text(activitytxt,
                                                        style: TextStyle(
                                                            color: ColorSystem
                                                                .blueGrey,
                                                            fontFamily: kRubik,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16)),
                                                    SizedBox(height: 20),
                                                    BlocProvider.value(
                                                        value:
                                                            landingScreenBloc,
                                                        child:
                                                            ActivityWidget()),
                                                    SizedBox(
                                                        height: heightOfScreen *
                                                            0.03),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: widthOfScreen *
                                                              0.07),
                                                      child: Row(
                                                        children: [
                                                          ActivityButton(
                                                            heightOfScreen:
                                                                heightOfScreen,
                                                            isLoading:
                                                                landingScreenState
                                                                    .gettingFavorites!,
                                                            onTap: landingScreenState
                                                                    .gettingFavorites!
                                                                ? () {}
                                                                : () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(CupertinoPageRoute(
                                                                            builder: (context) => OrderHistoryMain(
                                                                                  landingScreenState: landingScreenState,
                                                                                  customer: landingScreenState.customerInfoModel!,
                                                                                  orderHistoryLandingScreen: landingScreenState.orderHistoryLandingScreen ?? [],
                                                                                  customerId: landingScreenState.customerInfoModel!.records![0].id!,
                                                                                  isOtherUser: widget.userProfile != null,
                                                                                )));
                                                                  },
                                                            widthOfScreen:
                                                                widthOfScreen,
                                                            buttonColor:
                                                                AppColors
                                                                    .pinkHex,
                                                            iconImage: SvgPicture
                                                                .asset(IconSystem
                                                                    .shoppingBag),
                                                            text: 'ORDERS',
                                                          ),
                                                          //                          SizedBox(width: widthOfScreen * 0.04),
                                                          // ActivityButton(
                                                          //   heightOfScreen: heightOfScreen,
                                                          //   onTap:(){
                                                          //     Navigator.of(context).push(
                                                          //         CupertinoPageRoute(
                                                          //             builder: (context) => CaseHistoryScreenMain()));
                                                          //   },
                                                          //   widthOfScreen: widthOfScreen,
                                                          //   buttonColor: AppColors.lightPurpleHex,
                                                          //   iconImage: IconSystem.fileIcon,
                                                          //   text: 'CASES',
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    spaceBtwWidgets,
                                                    Text(othertxt,
                                                        style: TextStyle(
                                                            color: ColorSystem
                                                                .blueGrey,
                                                            fontFamily: kRubik,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16)),
                                                    SizedBox(height: 15),
                                                    if (widget.userProfile ==
                                                        null)
                                                      OtherTilesWidget(
                                                        widthOfScreen:
                                                            widthOfScreen,
                                                        textThem: textThem,
                                                        nameOfAssociate:
                                                            'Custom',
                                                        subtitleOftile:
                                                            'Recommendations',
                                                        iconpath: IconSystem
                                                            .treeStructureThinIcons,
                                                        isWidget: false,
                                                        ontapList: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RecommendationScreenMain(
                                                                    customerInfoModel:
                                                                        landingScreenState
                                                                            .customerInfoModel!),
                                                          ),
                                                        ),
                                                      ),
                                                    OtherTilesWidget(
                                                      widthOfScreen:
                                                          widthOfScreen,
                                                      textThem: textThem,
                                                      nameOfAssociate: 'Email',
                                                      subtitleOftile:
                                                          'Promotions',
                                                      iconpath: IconSystem
                                                          .emailSettingIcon,
                                                      isWidget: false,
                                                      ontapList: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PromotionsScreenMain(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    if (widget.userProfile ==
                                                        null)
                                                      OtherTilesWidget(
                                                        widthOfScreen:
                                                            widthOfScreen,
                                                        textThem: textThem,
                                                        nameOfAssociate:
                                                            'Settings',
                                                        subtitleOftile:
                                                            'Opt-Out/ Opt-In',
                                                        iconpath:
                                                            IconSystem.runIcon,
                                                        isWidget: false,
                                                        ontapList: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SettingsScreenMain(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    spaceBtwWidgets,
                                                    if (widget.userProfile ==
                                                        null)
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(gearAdvisor,
                                                              style: TextStyle(
                                                                  color: ColorSystem
                                                                      .blueGrey,
                                                                  fontFamily:
                                                                      kRubik,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      16)),
                                                          SizedBox(height: 10),
                                                          BlocProvider.value(
                                                            value:
                                                                landingScreenBloc,
                                                            child:
                                                                AgentWidget(),
                                                          ),
                                                        ],
                                                      ),
                                                    spaceBtwWidgets
                                                  ],
                                                ),
                                              ))
                                          : SizedBox(
                                              height: heightOfScreen,
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: Text(
                                                      "User detail not found"),
                                                ),
                                              ))
                                      : SizedBox(
                                          height: heightOfScreen,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )));
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("User detail not found"),
                        ),
                      )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
          });
    });
  }

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        backgroundColor: ColorSystem.lavender3,
        behavior: SnackBarBehavior.floating,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  Widget _header(TextTheme theme, LandingScreenState landingScreenState,
          Records userInfo, int index) =>
      Container(
        width: 350,
        height: 250,
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      index = 0;
                      SharedPreferenceService().setKey(key: agentId, value: '');
                      SharedPreferenceService()
                          .setKey(key: agentEmail, value: '');
                      _navigatorBloC.selectedTabIndex = 0;
                      landingScreenBloc.add(LoadData());
                    },
                    icon: SvgPicture.asset(IconSystem.leaveIcon)),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${userInfo.firstName ?? ''}',
                      maxLines: 2,
                      style: theme.caption?.copyWith(fontSize: 32),
                    ),
                    Text(
                      DateFormat('E, MMM dd').format(DateTime.now()),
                      maxLines: 2,
                      style: theme.caption?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.67),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            ProfileLandingWidget(
              landingScreenState: landingScreenState,
              onPressed: () => selectTab(0),
            )
          ],
        ),
      );

  Widget _profileTabs(TextTheme theme, Records userInfo, int index) {
    var divider = Divider(
      height: 4,
      color: ColorSystem.black.withOpacity(0.04),
    );
    return Container(
      padding: EdgeInsets.only(left: 14),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: ShadowSystem.webWidgetShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14, top: 31, bottom: 27),
            child: Text(
              '${userInfo.firstName?.toUpperCase()} PROFILE',
              style: theme.bodyText1
                  ?.copyWith(color: ColorSystem.lavender2, letterSpacing: 2.33),
            ),
          ),
          divider,
          ListTile(
            title: Text(
              recommendedtxt,
              style: theme.bodyText2?.copyWith(
                  fontWeight: index == 1 ? FontWeight.w600 : FontWeight.w400),
            ),
            onTap: (() => selectTab(1)),
            trailing: index == 1 ? selectedWidget() : SizedBox.shrink(),
            contentPadding: EdgeInsets.only(left: 16),
          ),
          divider,
          ListTile(
            title: Text(
              favoriteBrandtxt,
              style: theme.bodyText2?.copyWith(
                  fontWeight: index == 2 ? FontWeight.w600 : FontWeight.w400),
            ),
            onTap: (() => selectTab(2)),
            trailing: index == 2 ? selectedWidget() : SizedBox.shrink(),
            contentPadding: EdgeInsets.only(left: 16),
          ),
          // divider,
          // ListTile(
          //   title: Text(
          //     smartTriggerTasks,
          //     style: theme.bodyText2?.copyWith(
          //         fontWeight: index == 3 ? FontWeight.w600 : FontWeight.w400),
          //   ),
          //   onTap: (() => selectTab(3)),
          //   trailing: index == 3 ? selectedWidget() : SizedBox.shrink(),
          //   contentPadding: EdgeInsets.only(left: 16),
          // ),
          // divider,
          // ListTile(
          //   title: Text(
          //     customerRemindertxt,
          //     style: theme.bodyText2?.copyWith(
          //         fontWeight: index == 4 ? FontWeight.w600 : FontWeight.w400),
          //   ),
          //   onTap: (() => selectTab(4)),
          //   trailing: index == 4 ? selectedWidget() : SizedBox.shrink(),
          //   contentPadding: EdgeInsets.only(left: 16),
          // ),
          SizedBox(height: 8)
        ],
      ),
    );
  }

  Widget _ordersButtons(LandingScreenState landingScreenState, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActivityButton(
            onTap: () => selectTab(3),
            widthOfScreen: MediaQuery.of(context).size.width,
            heightOfScreen: MediaQuery.of(context).size.height,
            buttonColor: AppColors.pinkHex,
            iconImage: SvgPicture.asset(IconSystem.shoppingBag),
            text: 'ORDERS',
            isSelected: index == 3,
            isLoading: false,
          ),
        ],
      ),
    );
  }

  Widget _otherTabs(
      TextTheme theme, LandingScreenState landingScreenState, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(othertxt,
              style: TextStyle(
                  color: ColorSystem.blueGrey,
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ),
        SizedBox(height: 15),
        OtherTilesWidget(
          widthOfScreen: MediaQuery.of(context).size.width,
          textThem: theme,
          nameOfAssociate: 'Custom',
          subtitleOftile: 'Recommendations',
          iconpath: IconSystem.treeStructureThinIcons,
          isWidget: false,
          ontapList: () => selectTab(5),
          isSelected: index == 5,
        ),
        OtherTilesWidget(
          widthOfScreen: MediaQuery.of(context).size.width,
          textThem: theme,
          nameOfAssociate: 'Email',
          subtitleOftile: 'Promotions',
          iconpath: IconSystem.emailSettingIcon,
          isWidget: false,
          ontapList: () => selectTab(6),
          isSelected: index == 6,
        ),
        OtherTilesWidget(
          widthOfScreen: MediaQuery.of(context).size.width,
          textThem: theme,
          nameOfAssociate: 'Settings',
          subtitleOftile: 'Opt-Out/ Opt-In',
          iconpath: IconSystem.runIcon,
          isWidget: false,
          ontapList: () => selectTab(7),
          isSelected: index == 7,
        ),
      ],
    );
  }

  Widget _gearAdvisor(LandingScreenState landingScreenState) {
    return Padding(
      padding: EdgeInsets.only(top: 24, left: 14, right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(gearAdvisor,
              style: TextStyle(
                  color: ColorSystem.blueGrey,
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          SizedBox(height: 10),
          BlocProvider.value(
            value: landingScreenBloc,
            child: AgentWidget(),
          ),
        ],
      ),
    );
  }

  Widget _handleNoCustomerData() {
    return Scaffold(
      body: BlocBuilder<AuthBloC, AuthState>(builder: (context, state) {
        var token = '';
        if (state is AuthSuccess) {
          token = state.token ?? '';
        }
        return Stack(
          children: [
            Center(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.75,
                child: BlocProvider<CustomerLookUpBloc>(
                  create: (context) =>
                      CustomerLookUpBloc(CustomerLookUpRepository()),
                  child: CustomerLookUpWidget(isNoUser: true),
                ),
              ),
            ),
            if (token.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: LogoutButtonWeb(),
              ),
            if (token.isEmpty)
              Container(
                height: double.infinity,
                width: double.infinity,
                color: ColorSystem.white.withOpacity(0.8),
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 4),
                child: Center(
                  child: InkWell(
                      onTap: (() {
                        context.read<AuthBloC>().add(Authentication());
                      }),
                      child: Container(
                        height: 60,
                        width: 180,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(100, 76, 76, 76),
                                blurRadius: 10,
                                offset: Offset(4, 8),
                              )
                            ]),
                        alignment: Alignment.center,
                        child: Text(
                          'Click here to Sign In',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                      )),
                ),
              )
          ],
        );
      }),
    );
  }

  Widget selectedWidget() => Container(
        height: 60,
        width: 5,
        decoration: BoxDecoration(
            color: ColorSystem.lavender3,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(55),
              bottomLeft: Radius.circular(55),
            )),
      );

  void selectTab(int index) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    _navigatorBloC.selectedTabIndex = index;
  }
}
