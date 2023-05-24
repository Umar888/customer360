import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/common_widgets/order_history/order_history_widget.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/inventory_search/inventory_search_page.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_pie_chart_widget.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';

import '../../common_widgets/app_bar_widget.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../common_widgets/order_history/open_order_widget.dart';
import '../../primitives/size_system.dart';
import '../../primitives/color_system.dart';

class OrderHistoryScreen extends StatefulWidget {
  String customerId;
  CustomerInfoModel customer;
  LandingScreenState landingScreenState;
  List<OrderHistoryLandingScreen> orderHistoryLandingScreen;
  bool isOtherUser;
  bool isOnlyShowOrderHistory;

  OrderHistoryScreen({
    super.key,
    required this.landingScreenState,
    required this.customerId,
    required this.orderHistoryLandingScreen,
    required this.customer,
    this.isOtherUser = false,
    this.isOnlyShowOrderHistory = false,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late OrderHistoryBloc orderHistoryBloc;
  late isb.InventorySearchBloc inventorySearchBloc;
  late ProductDetailBloc productDetailBloc;
  late ZipStoreListBloc zipStoreListBloc;
  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  ScrollController scrollController = ScrollController();
  final StreamController<String> showingTitleSC =
      StreamController<String>.broadcast();
  StreamSubscription? streamSubscription;
  TextEditingController orderHistorySearchTEC = TextEditingController();

  late bool? newArrived;
  @override
  void initState() {
    orderHistoryBloc = context.read<OrderHistoryBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    productDetailBloc = context.read<ProductDetailBloc>();
    zipStoreListBloc = context.read<ZipStoreListBloc>();

    orderHistoryBloc.add(LoadDataOrderHistory());
    orderHistoryBloc.add(SearchOrderHistory(''));
    newArrived = false;
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'OrderHistoryScreen');

    int? openOrderLenght;
    streamSubscription = orderHistoryBloc.stream.listen((event) {
      openOrderLenght = event.openOrderModel?.openOrders?.length;
    });
    if (!widget.isOnlyShowOrderHistory) {
      showingTitleSC.add('ORDERS');
      scrollController.addListener(() {
        if (scrollController.offset < 180) {
          showingTitleSC.add('ORDERS');
        }
        if (scrollController.offset > 180) {
          showingTitleSC.add('OPEN ORDERS');
        }
        if (openOrderLenght != null) {
          double openOrderOffset = (200 + openOrderLenght! * 250);
          if (scrollController.offset > openOrderOffset) {
            showingTitleSC.add('ORDER HISTORY');
          }
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    streamSubscription?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: ColorSystem.scaffoldBackgroundColor,
        bottomNavigationBar: AppBottomNavBar(widget.customer, null, null,
            inventorySearchBloc, productDetailBloc, zipStoreListBloc),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: StreamBuilder<String>(
              stream: showingTitleSC.stream,
              builder: (context, snapshot) {
                return AppBarWidget(
                  paddingFromleftLeading: widthOfScreen * 0.034,
                  paddingFromRightActions: widthOfScreen * 0.034,
                  textThem: textThem,
                  leadingWidget: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 30,
                  ),
                  onPressedLeading: () => Navigator.of(context).pop(),
                  titletxt: snapshot.data ??
                      (widget.isOnlyShowOrderHistory
                          ? 'ORDER HISTORY'
                          : 'ORDERS'),
                  actionsWidget: SizedBox.shrink(),
                  actionOnPress: () {
                    if (!widget.isOtherUser) {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => InventorySearchPage(
                                customerID: widget.customerId,
                                customer: widget.customer),
                          ));
                    }
                  },
                );
              }),
        ),
        body: BlocConsumer<OrderHistoryBloc, OrderHistoryState>(
            listener: (context, state) {
          if (state.message != null &&
              state.message!.isNotEmpty &&
              state.message != "done") {
            Future.delayed(Duration.zero, () {
              setState(() {});
              ScaffoldMessenger.of(context)
                  .showSnackBar(snackBar(state.message ?? ""));
            });
          }
          orderHistoryBloc.add(EmptyMessage());
        }, builder: (context, state) {
          if (state.orderHistoryStatus == OrderHistoryStatus.success) {
            if (state.customerOrderInfoModel != null &&
                state.customerOrderInfoModel!.records!.isNotEmpty) {
              Map<String, dynamic> newVal = {};
              newVal.addAll({
                "LTV": state.customerOrderInfoModel!.records!.first
                    .lifetimeNetSalesAmountC
                    .toString()
              });
              var values;
              if (state.accessoriesValues != null) {
                values = [...state.accessoriesValues!.values]
                  ..sort((b, a) => double.parse(a).compareTo(double.parse(b)));

                for (String values in values) {
                  newVal[state.accessoriesValues!.keys.firstWhere((element) =>
                          state.accessoriesValues![element] == values)] =
                      state.accessoriesValues![state.accessoriesValues!.keys
                          .firstWhere((element) =>
                              state.accessoriesValues![element] == values)];
                }
              }

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  controller: scrollController,
                  // physics: physics,
                  // primary: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (!widget.isOnlyShowOrderHistory)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OrderHistoryPieChartWidget(
                                onTapChart: () {}, isFromLandingPage: false),
                            state.customerOrderInfoModel!.records!.first
                                            .lastTransactionDateC !=
                                        null &&
                                    state.customerOrderInfoModel!.records!.first
                                        .lastTransactionDateC!.isNotEmpty
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Last Purchase".toUpperCase(),
                                          style: TextStyle(
                                              fontSize: SizeSystem.size17,
                                              fontFamily: kRubik,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.1,
                                              color: Colors.black87),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "•",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size20,
                                              fontFamily: kRubik,
                                              fontWeight: FontWeight.bold,
                                              color: ColorSystem.secondary),
                                        ),
                                        SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            state
                                                    .customerOrderInfoModel!
                                                    .records!
                                                    .first
                                                    .lastTransactionDateC
                                                    ?.changeToBritishFormat(state
                                                        .customerOrderInfoModel!
                                                        .records!
                                                        .first
                                                        .lastTransactionDateC!
                                                        .toString())
                                                    .toUpperCase() ??
                                                '',
                                            style: TextStyle(
                                                fontSize: SizeSystem.size17,
                                                fontFamily: kRubik,
                                                fontWeight: FontWeight.w600,
                                                color: ColorSystem.secondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                            state.customerOrderInfoModel!.records!.first
                                            .lastTransactionDateC !=
                                        null &&
                                    state.customerOrderInfoModel!.records!.first
                                        .lastTransactionDateC!.isNotEmpty
                                ? SizedBox(height: heightOfScreen * 0.02)
                                : SizedBox.shrink(),
                            Divider(height: 1),
                            if ((state.fetchingOpenOrders ?? true) ||
                                (state.openOrderModel?.openOrders ?? [])
                                    .isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: heightOfScreen * 0.015),
                                  BlocProvider.value(
                                      value: orderHistoryBloc,
                                      child: OpenOrderWidget(
                                        landingScreenState:
                                            widget.landingScreenState,
                                        customerInfoModel: widget.customer,
                                        customerId: widget.customerId,
                                      )),
                                  SizedBox(height: heightOfScreen * 0.01),
                                ],
                              ),
                          ],
                        ),
                      if ((state.fetchOrderHistory ?? true) ||
                          (state.orderHistory ?? []).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                "Order History",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: SizeSystem.size16,
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18)
                                  .copyWith(top: 12),
                              child: TextField(
                                controller: orderHistorySearchTEC,
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                    constraints: BoxConstraints(),
                                    contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2)
                                        .copyWith(bottom: 10),
                                    hintText: 'Search by order#',
                                    hintStyle: TextStyle(
                                      color: ColorSystem.secondary,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                        color: Colors.black,
                                        onPressed: () {
                                          orderHistorySearchTEC.clear();
                                          orderHistoryBloc
                                              .add(SearchOrderHistory(''));
                                        },
                                        icon: Icon(Icons.close))),
                                onChanged: (value) {
                                  if (value.trim().isNotEmpty) {
                                    EasyDebounce.cancelAll();
                                    EasyDebounce.debounce(
                                        'search_order_debounce',
                                        Duration(seconds: 1), () {
                                      orderHistoryBloc.add(
                                          SearchOrderHistory(value.trim()));
                                    });
                                  } else {
                                    orderHistoryBloc
                                        .add(SearchOrderHistory(''));
                                  }
                                },
                              ),
                            ),
                            OrderHistoryWidget(controller: _controller),
                          ],
                        ),
                      SizedBox(height: heightOfScreen * 0.025),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox(
                  height: heightOfScreen,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ));
            }
          } else {
            return SizedBox(
                height: heightOfScreen,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ));
          }
        }));
  }

  List<PieChartSectionData> showingSections(
      {required List<dynamic> accessoriesValue}) {
    return List.generate(3, (i) {
      const fontSize = 0.0;
      const radius = 26.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: ColorSystem.chartPink,
            value: accessoriesValue.length < 2
                ? 0
                : double.parse(accessoriesValue[1] ?? "0.0"),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: ColorSystem.chartPurple,
            value: accessoriesValue.length < 3
                ? 0
                : double.parse(accessoriesValue[2] ?? "0.0"),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: ColorSystem.chartBlue,
            value: accessoriesValue.length < 4
                ? 0
                : double.parse(accessoriesValue[3] ?? "0.0"),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  void doNothing(BuildContext context) {}
}
