import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/approval_process_bloc/approval_process_bloc.dart';
import 'package:gc_customer_app/bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/credit_balance_bloc/credit_balance_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/recommended_landing_bloc/recommended_landing_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/smart_trigger_bloc/smart_trigger_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/tagging_bloc/tagging_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as plb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlb;
import 'package:gc_customer_app/common_widgets/landing_screen/landing_offers_widget.dart';
import 'package:gc_customer_app/common_widgets/user_data_found.dart';
import 'package:gc_customer_app/data/reporsitories/customer_look_up_repository/customer_lookup_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_history_screen_repository/order_history_repository.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/repositories/auth/repository/authentication_repository.dart';
import 'package:gc_customer_app/screens/customer_look_up/customer_lookup_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/channel_metric_pie_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/credit_balance_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/customer_reminder_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/net_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_by_year_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_pie_chart_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/recommended_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/smart_trigger_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/tagging_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/user_information_business_data_widget.dart';
import 'package:gc_customer_app/screens/my_customer/my_customer_screen.dart';
import 'package:gc_customer_app/screens/promotions/promotions_screen_main.dart';
import 'package:gc_customer_app/screens/recommendation_screen/recommendation_screen_main.dart';
import 'package:gc_customer_app/screens/settings_screen/settings_screen_main.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/landing_screen/agent_widget.dart';
import '../../common_widgets/landing_screen/favorite_brand_widget.dart';
import '../../constants/colors.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../repositories/auth/bloc/authentication_bloc.dart';
import '../../utils/enums/music_instrument_enum.dart';
import '../../utils/utils_functions.dart';
import '../order_history/order_history_main.dart';
import '../profile/profile_screen_main.dart';

import '../../bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import '../../common_widgets/activity_button.dart';
import '../../common_widgets/landing_screen/activity_widget.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../common_widgets/other_tile_widget.dart';
import '../../constants/text_strings.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';
import '../reminder/reminder_button.dart';
import 'landing_screen_main.dart';

class CustomerLandingScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final String appName;
  CustomerLandingScreen(
      {super.key, this.userProfile, this.appName = "Customer 360"});

  @override
  State<CustomerLandingScreen> createState() => _CustomerLandingScreenState();
}

class _CustomerLandingScreenState extends State<CustomerLandingScreen> {
  late LandingScreenBloc landingScreenBloc;
  late InventorySearchBloc inventorySearchBloc;
  late plb.ProductDetailBloc productDetailBloc;
  late zlb.ZipStoreListBloc zipStoreListBloc;
  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: false,
  );
  late AppBottomNavBar bottomBar;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    landingScreenBloc = context.read<LandingScreenBloc>();
    inventorySearchBloc = context.read<InventorySearchBloc>();
    productDetailBloc = context.read<plb.ProductDetailBloc>();
    zipStoreListBloc = context.read<zlb.ZipStoreListBloc>();

    landingScreenBloc.add(LoadData(appName: widget.appName));
  }

  final spaceBtwWidgets = SizedBox(height: 25);

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;

    return BlocConsumer<LandingScreenBloc, LandingScreenState>(
        listener: (context, landingScreenState) {
      if (landingScreenState.customerInfoModel != null) {}
    }, builder: (context, landingScreenState) {
      CustomerInfoModel? customerInfoModel;
      bottomBar = AppBottomNavBar(landingScreenState.customerInfoModel, null,
          null, inventorySearchBloc, productDetailBloc, zipStoreListBloc);
      if (landingScreenState.landingScreenStatus ==
          LandingScreenStatus.failure) {
        return Scaffold(body: Center(child: UserDataFound(fontSize: 20)));
      } else if (landingScreenState.landingScreenStatus ==
          LandingScreenStatus.success) {
        if (landingScreenState.message!.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            ScaffoldMessenger.of(context)
                .showSnackBar(snackBar(landingScreenState.message ?? ""));
            //   Navigator.pop(context);
          });
          landingScreenBloc.add(ClearMessage());
        }
        if (landingScreenState.customerInfoModel != null &&
            landingScreenState.customerInfoModel != null) {
          customerInfoModel = landingScreenState.customerInfoModel;
          if (landingScreenState.customerInfoModel!.records != null &&
              landingScreenState.customerInfoModel!.records!.isNotEmpty) {
            if (!kIsWeb) {
            FirebaseAnalytics.instance
                  .setCurrentScreen(screenName: 'LandingScreen');
            // FirebaseAnalytics.instance.setUserProperty(
            //       value: customerInfoModel!.records!.first.accountEmailC,
            //       name: "CustomerEmail");
            // FirebaseAnalytics.instance.setUserProperty(
            //       value: customerInfoModel.records!.first.accountPhoneC,
            //       name: "CustomerPhoneNumber");
            }
            return Scaffold(
                appBar: AppBar(
                  leadingWidth: 0,
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
//                      SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          SharedPreferenceService()
                              .setKey(key: agentId, value: '');
                          SharedPreferenceService()
                              .setKey(key: agentPhone, value: '');
                          SharedPreferenceService()
                              .setKey(key: agentEmail, value: '');
                          SharedPreferenceService()
                              .setKey(key: savedAgentName, value: '');
                          landingScreenBloc.add(RemoveCustomer());
                          Navigator.of(context).pushAndRemoveUntil<void>(
                            LandingScreenMain.route(AuthenticationRepository(),
                                AuthenticationStatus.authenticated),
                            (route) => false,
                          );

                          // Navigator.of(context).popUntil((route) => route.settings.name == "LandingScreenMain");
                        },
                        icon: SvgPicture.asset(
                          IconSystem.leaveIcon,
                          package: 'gc_customer_app',
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                  elevation: 0,
                  actions: [
                    if (widget.userProfile == null)
                      BlocProvider.value(
                          value: landingScreenBloc,
                          child: ReminderButton(
                            landingScreenBloc: landingScreenBloc,
                          )),
                    // if (widget.userProfile == null) NotificationBottonWidget()
                  ],
                ),
                bottomNavigationBar: kIsWeb
                    ? null
                    : BlocProvider.value(
                        value: landingScreenBloc, child: bottomBar),
                body: (landingScreenState.landingScreenStatus ==
                        LandingScreenStatus.success)
                    ? (customerInfoModel?.records ?? []).isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: widthOfScreen * 0.05,
                            ),
                            child: EasyRefresh.builder(
                              header: BezierHeader(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white),
                              noMoreLoad: true,
                              onLoad: null,
                              onRefresh: () async {
                                await Future.delayed(Duration(seconds: 2));
                                _controller.finishRefresh();
                                landingScreenBloc
                                    .add(LoadData(appName: widget.appName));
                              },
                              childBuilder: (context, physics) {
                                return SingleChildScrollView(
                                  physics: physics,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileScreenMain()));
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: widthOfScreen * 0.3,
                                              width: widthOfScreen * 0.3,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                        'assets/images/profileBackground.png',
                                                        package:
                                                            'gc_customer_app',
                                                      ),
                                                      fit: BoxFit.contain)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  landingScreenState
                                                                  .customerInfoModel!
                                                                  .records!
                                                                  .first
                                                                  .primaryInstrumentCategoryC !=
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
                                                              .primaryInstrumentCategoryC!
                                                              .split(",")[0])),
                                                          package:
                                                              'gc_customer_app',
                                                          width: widthOfScreen *
                                                              0.17,
                                                          fit: BoxFit.contain)
                                                      : SvgPicture.asset('assets/icons/guitar.svg',
                                                          package: 'gc_customer_app',
                                                          width: widthOfScreen * 0.17,
                                                          fit: BoxFit.contain),
                                                  SizedBox(height: 5),
                                                  RichText(
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        fontFamily: kRubik,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${(landingScreenState.customerInfoModel!.records!.first.primaryInstrumentCategoryC ?? 'Guitar').split(",")[0]} ',
                                                          style: TextStyle(
                                                            fontSize: 2 *
                                                                (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.0095),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: ColorSystem
                                                                .primary,
                                                            fontFamily: kRubik,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: ' ',
                                                          style: TextStyle(
                                                            fontSize: 2 *
                                                                (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.0095),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: ColorSystem
                                                                .primary,
                                                            fontFamily: kRubik,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                width: widthOfScreen * 0.05),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: heightOfScreen * 0.01),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                              landingScreenState
                                                                      .customerInfoModel!
                                                                      .records!
                                                                      .first
                                                                      .name ??
                                                                  "",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              )),
                                                          Text(" • ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              )),
                                                          Text(
                                                              landingScreenState
                                                                      .customerInfoModel!
                                                                      .records!
                                                                      .first
                                                                      .brandCodeC ??
                                                                  "",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 16,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    (landingScreenState
                                                                        .customerInfoModel!
                                                                        .records!
                                                                        .first
                                                                        .accountPhoneC ??
                                                                    '')
                                                                .isEmpty &&
                                                            (landingScreenState
                                                                        .customerInfoModel!
                                                                        .records!
                                                                        .first
                                                                        .phone ??
                                                                    '')
                                                                .isEmpty &&
                                                            (landingScreenState
                                                                        .customerInfoModel!
                                                                        .records!
                                                                        .first
                                                                        .phoneC ??
                                                                    '')
                                                                .isEmpty
                                                        ? SizedBox.shrink()
                                                        : Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 5),
                                                            child: InkWell(
                                                              onTap: () {
                                                                makephoneCall(landingScreenState
                                                                            .customerInfoModel!
                                                                            .records!
                                                                            .first
                                                                            .accountPhoneC !=
                                                                        null
                                                                    ? landingScreenState
                                                                        .customerInfoModel!
                                                                        .records!
                                                                        .first
                                                                        .accountPhoneC!
                                                                        .toMobileFormat()
                                                                    : landingScreenState.customerInfoModel!.records!.first.accountPhoneC ==
                                                                                null &&
                                                                            landingScreenState.customerInfoModel!.records!.first.phoneC !=
                                                                                null
                                                                        ? landingScreenState
                                                                            .customerInfoModel!
                                                                            .records!
                                                                            .first
                                                                            .phoneC!
                                                                            .toMobileFormat()
                                                                        : landingScreenState.customerInfoModel!.records!.first.accountPhoneC == null &&
                                                                                landingScreenState.customerInfoModel!.records!.first.phoneC == null &&
                                                                                landingScreenState.customerInfoModel!.records!.first.phone != null
                                                                            ? landingScreenState.customerInfoModel!.records!.first.phone!.toMobileFormat()
                                                                            : "");
                                                              },
                                                              child: Text(
                                                                  landingScreenState
                                                                              .customerInfoModel!
                                                                              .records!
                                                                              .first
                                                                              .accountPhoneC !=
                                                                          null
                                                                      ? landingScreenState
                                                                          .customerInfoModel!
                                                                          .records!
                                                                          .first
                                                                          .accountPhoneC!
                                                                          .toMobileFormat()
                                                                      : landingScreenState.customerInfoModel!.records!.first.accountPhoneC == null &&
                                                                              landingScreenState.customerInfoModel!.records!.first.phoneC !=
                                                                                  null
                                                                          ? landingScreenState
                                                                              .customerInfoModel!
                                                                              .records!
                                                                              .first
                                                                              .phoneC!
                                                                              .toMobileFormat()
                                                                          : landingScreenState.customerInfoModel!.records!.first.accountPhoneC == null &&
                                                                                  landingScreenState.customerInfoModel!.records!.first.phoneC ==
                                                                                      null &&
                                                                                  landingScreenState.customerInfoModel!.records!.first.phone !=
                                                                                      null
                                                                              ? landingScreenState.customerInfoModel!.records!.first.phone!
                                                                                  .toMobileFormat()
                                                                              : "",
                                                                  style: textThem
                                                                      .headline3
                                                                      ?.copyWith(
                                                                          color: ColorSystem.lavender3,
                                                                          fontWeight: FontWeight.w500)),
                                                            ),
                                                          ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                        (landingScreenState
                                                                            .customerInfoModel!
                                                                            .records!
                                                                            .first
                                                                            .accountEmailC ??
                                                                        '')
                                                                    .isEmpty &&
                                                                (landingScreenState
                                                                            .customerInfoModel!
                                                                            .records!
                                                                            .first
                                                                            .emailC ??
                                                                        '')
                                                                    .isEmpty &&
                                                                (landingScreenState
                                                                            .customerInfoModel!
                                                                            .records!
                                                                            .first
                                                                            .personEmail ??
                                                                        '')
                                                                    .isEmpty
                                                            ? noCustomerEmailFoundtxt
                                                            : landingScreenState
                                                                        .customerInfoModel!
                                                                        .records![
                                                                            0]
                                                                        .accountEmailC !=
                                                                    null
                                                                ? landingScreenState
                                                                    .customerInfoModel!
                                                                    .records![0]
                                                                    .accountEmailC!
                                                                : landingScreenState
                                                                            .customerInfoModel!
                                                                            .records![
                                                                                0]
                                                                            .emailC !=
                                                                        null
                                                                    ? landingScreenState
                                                                        .customerInfoModel!
                                                                        .records![
                                                                            0]
                                                                        .emailC!
                                                                    : landingScreenState.customerInfoModel!.records![0].personEmail !=
                                                                            null
                                                                        ? landingScreenState
                                                                            .customerInfoModel!
                                                                            .records![
                                                                                0]
                                                                            .personEmail!
                                                                        : "",
                                                        style:
                                                            textThem.headline5),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Last Purchased : ${formatDate(landingScreenState.customerInfoModel?.records?.first.lastTransactionDateC ?? '')}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size14,
                                                        fontFamily: kRubik,
                                                        color: ColorSystem
                                                            .secondary,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'LTV Band: ',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily: kRubik,
                                                            color: ColorSystem
                                                                .secondary,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        SvgPicture.asset(
                                                            IconSystem
                                                                .badgeIcon,
                                                            package:
                                                                'gc_customer_app',
                                                            height: 18,
                                                            color: getCustomerLevelColor(getCustomerLevel(
                                                                landingScreenState
                                                                        .customerInfoModel
                                                                        ?.records
                                                                        ?.first
                                                                        .lifetimeNetSalesAmountC ??
                                                                    0))),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          getCustomerLevel(
                                                              landingScreenState
                                                                      .customerInfoModel
                                                                      ?.records
                                                                      ?.first
                                                                      .lifetimeNetSalesAmountC ??
                                                                  0),
                                                          style: TextStyle(
                                                            fontFamily: kRubik,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: getCustomerLevelColor(getCustomerLevel(
                                                                landingScreenState
                                                                        .customerInfoModel
                                                                        ?.records
                                                                        ?.first
                                                                        .lifetimeNetSalesAmountC ??
                                                                    0)),
                                                            fontSize: SizeSystem
                                                                .size14,
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
                                                  isHaveEmail: (landingScreenState
                                                                  .customerInfoModel!
                                                                  .records!
                                                                  .first
                                                                  .accountEmailC ??
                                                              '')
                                                          .isNotEmpty ||
                                                      (landingScreenState
                                                                  .customerInfoModel!
                                                                  .records!
                                                                  .first
                                                                  .emailC ??
                                                              '')
                                                          .isNotEmpty ||
                                                      (landingScreenState
                                                                  .customerInfoModel!
                                                                  .records!
                                                                  .first
                                                                  .personEmail ??
                                                              '')
                                                          .isNotEmpty)),
                                          SizedBox(width: 8),
                                          UserInformationBusinessWidget(
                                            userProfile: UserProfile.fromJson(
                                                landingScreenState
                                                    .customerInfoModel!
                                                    .records!
                                                    .first
                                                    .toJson()),
                                          ),
                                        ],
                                      ),

                                      OrderHistoryByYearChartWidget(),
                                      SizedBox(height: 14),
                                      BlocProvider(
                                          create: (context) => OrderHistoryBloc(
                                                orderHistoryRepository:
                                                    OrderHistoryRepository(),
                                                landingScreenRepository:
                                                    landingScreenBloc
                                                        .landingScreenRepository,
                                              ),
                                          child: OrderHistoryPieChartWidget(
                                              onTapChart: () {
                                            Navigator.of(context).push(CupertinoPageRoute(
                                                builder: (context) => OrderHistoryMain(
                                                    landingScreenState:
                                                        landingScreenState,
                                                    customer: landingScreenState
                                                        .customerInfoModel!,
                                                    orderHistoryLandingScreen:
                                                        landingScreenState
                                                                .orderHistoryLandingScreen ??
                                                            [],
                                                    customerId:
                                                        landingScreenState
                                                            .customerInfoModel!
                                                            .records![0]
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
                                                      customer: landingScreenState
                                                          .customerInfoModel!,
                                                      orderHistoryLandingScreen:
                                                          landingScreenState
                                                                  .orderHistoryLandingScreen ??
                                                              [],
                                                      customerId:
                                                          landingScreenState
                                                              .customerInfoModel!
                                                              .records![0]
                                                              .id!,
                                                      isOtherUser:
                                                          widget.userProfile !=
                                                              null,
                                                      isOnlyShowOrderHistory:
                                                          true,
                                                    )));
                                      }),
                                      NetChartWidget(
                                        customerInfoModel: landingScreenState
                                            .customerInfoModel!,
                                      ),
                                      SizedBox(height: 24),
                                      BlocProvider(
                                        create: (context) => TaggingBloc(),
                                        child: TaggingWidget(),
                                      ),
                                      if (!kIsWeb) CustomerReminderWidget(),
                                      // spaceBtwWidgets,
                                      if (!kIsWeb)
                                        BlocProvider(
                                          create: (context) =>
                                              SmartTriggerBloc(),
                                          child: SmartTriggerWidget(
                                              landingScreenState:
                                                  landingScreenState),
                                        ),
                                      landingScreenState
                                                  .landingScreenRecommendationModel !=
                                              null
                                          ? BlocProvider(
                                              create: (context) =>
                                                  RecommendedLandingBloc(),
                                              child: RecommendedWidget(
                                                landingScreenState:
                                                    landingScreenState,
                                                landingScreenRecommendationModel:
                                                    landingScreenState
                                                        .landingScreenRecommendationModel!,
                                              ),
                                            )
                                          : SizedBox(
                                              height: MediaQuery.of(context)
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
                                          customerInfoModel: landingScreenState
                                              .customerInfoModel!),
                                      spaceBtwWidgets,
                                      Text(activitytxt,
                                          style: TextStyle(
                                              color: ColorSystem.blueGrey,
                                              fontFamily: kRubik,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      SizedBox(height: 20),
                                      BlocProvider.value(
                                          value: landingScreenBloc,
                                          child: ActivityWidget()),
                                      SizedBox(height: heightOfScreen * 0.03),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: widthOfScreen * 0.07),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ActivityButton(
                                              heightOfScreen: heightOfScreen,
                                              isLoading: landingScreenState
                                                  .gettingFavorites!,
                                              onTap:
                                                  landingScreenState
                                                          .gettingFavorites!
                                                      ? () {}
                                                      : () {
                                                          Navigator.of(context).push(
                                                              CupertinoPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          OrderHistoryMain(
                                                                            landingScreenState:
                                                                                landingScreenState,
                                                                            customer:
                                                                                landingScreenState.customerInfoModel!,
                                                                            orderHistoryLandingScreen:
                                                                                landingScreenState.orderHistoryLandingScreen ?? [],
                                                                            customerId:
                                                                                landingScreenState.customerInfoModel!.records![0].id!,
                                                                            isOtherUser:
                                                                                widget.userProfile != null,
                                                                          )));
                                                        },
                                              widthOfScreen: kIsWeb
                                                  ? widthOfScreen
                                                  : widthOfScreen / 2,
                                              buttonColor: AppColors.pinkHex,
                                              iconImage: SvgPicture.asset(
                                                IconSystem.shoppingBag,
                                                package: 'gc_customer_app',
                                              ),
                                              text: 'ORDERS',
                                            ),
                                            if (!kIsWeb) SizedBox(width: 12),
                                            if (!kIsWeb)
                                              ActivityButton(
                                                heightOfScreen: heightOfScreen,
                                                onTap: () {
                                                  bottomBar.showInventoryLookup(
                                                      context);
                                                },
                                                widthOfScreen:
                                                    widthOfScreen / 2,
                                                buttonColor:
                                                    ColorSystem.lavender,
                                                iconImage: Image.asset(
                                                  IconSystem.newOrder,
                                                  package: 'gc_customer_app',
                                                ),
                                                text: 'CREATE ORDER',
                                                isLoading: false,
                                              ),
                                          ],
                                        ),
                                      ),
                                      spaceBtwWidgets,
                                      Text(othertxt,
                                          style: TextStyle(
                                              color: ColorSystem.blueGrey,
                                              fontFamily: kRubik,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      SizedBox(height: 15),
                                      if (widget.userProfile == null)
                                        OtherTilesWidget(
                                          widthOfScreen: widthOfScreen,
                                          textThem: textThem,
                                          nameOfAssociate: 'Custom',
                                          subtitleOftile: 'Recommendations',
                                          iconpath:
                                              IconSystem.treeStructureThinIcons,
                                          isWidget: false,
                                          ontapList: () =>
                                              Navigator.of(context).push(
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
                                        widthOfScreen: widthOfScreen,
                                        textThem: textThem,
                                        nameOfAssociate: 'Email',
                                        subtitleOftile: 'Promotions',
                                        iconpath: IconSystem.emailSettingIcon,
                                        isWidget: false,
                                        ontapList: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PromotionsScreenMain(),
                                            ),
                                          );
                                        },
                                      ),
                                      if (widget.userProfile == null)
                                        OtherTilesWidget(
                                          widthOfScreen: widthOfScreen,
                                          textThem: textThem,
                                          nameOfAssociate: 'Settings',
                                          subtitleOftile: 'Opt-Out/ Opt-In',
                                          iconpath: IconSystem.runIcon,
                                          isWidget: false,
                                          ontapList: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SettingsScreenMain(),
                                              ),
                                            );
                                          },
                                        ),
                                      spaceBtwWidgets,
                                      if (widget.userProfile == null)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                      spaceBtwWidgets
                                    ],
                                  ),
                                );
                              },
                            ))
                        : SizedBox(
                            height: heightOfScreen,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("User detail not found"),
                              ),
                            ))
                    : SizedBox(
                        height: heightOfScreen,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )));
          } else {
            return _handleNoCustomerData();
          }
        } else {
          return Scaffold(body: Center(child: UserDataFound(fontSize: 20)));
        }
      } else {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    });
  }

  Widget _handleNoCustomerData() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SafeArea(
              child: Text(
                'Version 1.1.1',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline3?.copyWith(
                    color: AppColors.redTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Initiate',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline3?.copyWith(
                  color: AppColors.redTextColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Text(
              'Customer\nLookup',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline3?.copyWith(
                  color: AppColors.redTextColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'OR',
              style:
                  Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Inventory\nLookup',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline3?.copyWith(
                  color: AppColors.redTextColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocProvider.value(
        value: landingScreenBloc,
        child: AppBottomNavBar(
            CustomerInfoModel(records: [Records(id: null)]),
            null,
            null,
            inventorySearchBloc,
            productDetailBloc,
            zipStoreListBloc),
      ),
    );
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
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  String formatDate(String date) {
    try {
      return DateFormat('MM-dd-yyyy').format(DateTime.parse(date));
    } on FormatException {
      return date;
    } catch (e) {
      return date;
    }
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
