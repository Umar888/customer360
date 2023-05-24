import 'package:easy_refresh/easy_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/order_history/open_order_widget.dart';
import 'package:gc_customer_app/common_widgets/order_history/order_history_widget.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/logout_button_web.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_pie_chart_widget.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class OrderHistoryWebScreen extends StatefulWidget {
  final String customerId;
  final CustomerInfoModel customer;
  final LandingScreenState landingScreenState;
  final bool isOnlyShowOrderHistory;
  OrderHistoryWebScreen({
    super.key,
    required this.customerId,
    required this.customer,
    required this.landingScreenState,
    this.isOnlyShowOrderHistory = false,
  });

  @override
  State<OrderHistoryWebScreen> createState() => _OrderHistoryWebScreenState();
}

class _OrderHistoryWebScreenState extends State<OrderHistoryWebScreen> {
  late OrderHistoryBloc orderHistoryBloc;
  ScrollController scrollController = ScrollController();
  bool haveMore = true;

  @override
  void initState() {
    orderHistoryBloc = context.read<OrderHistoryBloc>();
    orderHistoryBloc.add(LoadDataOrderHistory());
    orderHistoryBloc.add(FetchOrderHistory(currentPage: 1));
    int currentPage = 1;
    scrollController.addListener(() {
      if (scrollController.offset ==
              scrollController.position.maxScrollExtent &&
          haveMore) {
        orderHistoryBloc.add(FetchOrderHistory(currentPage: ++currentPage));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth.isMobileWebDevice();
        return Scaffold(
          // drawer: isMobile ? DrawerLandingWidget() : null,
          backgroundColor: ColorSystem.webBackgr,
          appBar: AppBar(
            backgroundColor: ColorSystem.webBackgr,
            centerTitle: true,
            title: Text(
                widget.isOnlyShowOrderHistory ? 'ORDER HISTORY' : 'ORDERS',
                style: TextStyle(
                    fontFamily: kRubik,
                    color: ColorSystem.black,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontSize: 15)),
            actions: [if (!isMobile) LogoutButtonWeb()],
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
                          ?.toStringAsFixed(2) ??
                      '0.0'
                });
                if (state.accessoriesValues != null) {
                  var values = [
                    ...state.accessoriesValues!.values
                  ]..sort((b, a) => double.parse(a).compareTo(double.parse(b)));
                  for (String values in values) {
                    newVal[state.accessoriesValues!.keys.firstWhere((element) =>
                            state.accessoriesValues![element] == values)] =
                        state.accessoriesValues![state.accessoriesValues!.keys
                            .firstWhere((element) =>
                                state.accessoriesValues![element] == values)];
                  }
                }
                haveMore = state.haveMore;
                return ListView(
                  controller: scrollController,
                  children: [
                    // featureButtos(constraints),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: constraints.maxWidth * (isMobile ? 1 : 0.36),
                          padding: EdgeInsets.symmetric(vertical: 24),
                          margin: EdgeInsets.only(left: isMobile ? 0 : 24),
                          decoration: BoxDecoration(
                              color: ColorSystem.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              state.customerOrderInfoModel!.records!.first
                                              .lastTransactionDateC !=
                                          null &&
                                      state
                                          .customerOrderInfoModel!
                                          .records!
                                          .first
                                          .lastTransactionDateC!
                                          .isNotEmpty
                                  ? Column(
                                      children: [
                                        if (!widget.isOnlyShowOrderHistory)
                                          OrderHistoryPieChartWidget(
                                              onTapChart: () {},
                                              isFromLandingPage: false),
                                        if (!widget.isOnlyShowOrderHistory)
                                          _lastPurchase(state),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                              if (isMobile && !widget.isOnlyShowOrderHistory)
                                _openOrder(constraints, isMobile),
                              Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Text(
                                  "Order History",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontFamily: kRubik,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              OrderHistoryWidget(
                                  controller: EasyRefreshController()),
                              if (state.fetchOrderHistory == true &&
                                  state.currentPage > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                  ],
                                )
                            ],
                          ),
                        ),
                        if (!isMobile && !widget.isOnlyShowOrderHistory)
                          _openOrder(constraints, isMobile),
                      ],
                    ),
                  ],
                );
              } else {
                return SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Order detail not found"),
                      ),
                    ));
              }
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
      },
    );
  }

  Widget featureButtos(BoxConstraints constraints) {
    return Container(
      height: 55,
      margin: EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: ColorSystem.greyMild),
            bottom: BorderSide(color: ColorSystem.greyMild)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {},
            child: SizedBox(
              height: 55,
              width: constraints.maxWidth - 180,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.keyboard_arrow_down),
                  ),
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              InkWell(
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(color: ColorSystem.greyMild),
                          right: BorderSide(color: ColorSystem.greyMild))),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    IconSystem.searchIcon,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  width: 55,
                  height: 55,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    IconSystem.filterIcon,
                    width: 20,
                    height: 20,
                  ),
                ),
              )
            ],
          ),
        ],
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ));
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
            showTitle: false,
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
            titleStyle: TextStyle(fontSize: fontSize),
            showTitle: false,
          );
        case 2:
          return PieChartSectionData(
            color: ColorSystem.chartBlue,
            value: accessoriesValue.length < 4
                ? 0
                : double.parse(accessoriesValue[3] ?? "0.0"),
            radius: radius,
            titleStyle: TextStyle(fontSize: fontSize),
            showTitle: false,
          );
        default:
          throw Error();
      }
    });
  }

  Widget _openOrder(BoxConstraints constraints, bool isMobile) {
    return OpenOrderWidget(
      landingScreenState: widget.landingScreenState,
      customerInfoModel: widget.customer,
      customerId: widget.customerId,
      widgetWidth:
          isMobile ? constraints.maxWidth : constraints.maxWidth * 0.6 - 5,
    );
  }

  Widget _lastPurchase(OrderHistoryState state) {
    return Padding(
        padding: EdgeInsets.all(14).copyWith(bottom: 24),
        child: RichText(
            text: TextSpan(
                text: 'Last Purchase'.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: Colors.black87,
                ),
                children: [
              TextSpan(
                text: '  •  ',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: kRubik,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.secondary),
              ),
              TextSpan(
                text: state.customerOrderInfoModel!.records!.first
                    .lastTransactionDateC!
                    .changeToBritishFormat(state.customerOrderInfoModel!
                        .records!.first.lastTransactionDateC!
                        .toString())
                    .toUpperCase(),
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: kRubik,
                    fontWeight: FontWeight.w600,
                    color: ColorSystem.secondary),
              ),
            ])));
  }

  Widget _businessData(Map<String, dynamic> newVal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: SizedBox(
              height: 110,
              child: PieChart(
                PieChartData(
                    sectionsSpace: 0,
                    sections: showingSections(
                      accessoriesValue: newVal.values.toList(),
                    ),
                    centerSpaceColor: ColorSystem.purple.withOpacity(0.1),
                    centerSpaceRadius: 24,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(enabled: false)),
              ),
            )),
        Expanded(
            flex: 3,
            child: SizedBox(
              height: 120,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.7,
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                children: newVal.entries.map((e) {
                  int index = newVal.values.toList().indexOf(e.value);
                  if (index < 4) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 25,
                          width: 5,
                          decoration: BoxDecoration(
                              color: index == 0
                                  ? ColorSystem.chartBlack
                                  : index == 1
                                      ? ColorSystem.chartPink
                                      : index == 2
                                          ? ColorSystem.chartPurple
                                          : ColorSystem.chartBlue,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    r"$",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: index == 0
                                            ? ColorSystem.chartBlack
                                            : index == 1
                                                ? ColorSystem.chartPink
                                                : index == 2
                                                    ? ColorSystem.chartPurple
                                                    : ColorSystem.chartBlue,
                                        fontFamily: kRubik),
                                  ),
                                  double.parse(e.value.toString()) > 999
                                      ? Text(
                                          "${(double.parse(e.value.toString()) / 1000).toStringAsFixed(2)}k",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: index == 0
                                                  ? ColorSystem.chartBlack
                                                  : index == 1
                                                      ? ColorSystem.chartPink
                                                      : index == 2
                                                          ? ColorSystem
                                                              .chartPurple
                                                          : ColorSystem
                                                              .chartBlue,
                                              fontFamily: kRubik))
                                      : Text(
                                          double.parse(e.value.toString())
                                              .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: index == 0
                                                  ? ColorSystem.chartBlack
                                                  : index == 1
                                                      ? ColorSystem.chartPink
                                                      : index == 2
                                                          ? ColorSystem
                                                              .chartPurple
                                                          : ColorSystem
                                                              .chartBlue,
                                              fontFamily: kRubik),
                                        ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                e.key,
                                style: TextStyle(
                                    color: index == 0
                                        ? ColorSystem.chartBlack
                                        : index == 1
                                            ? ColorSystem.chartPink
                                            : index == 2
                                                ? ColorSystem.chartPurple
                                                : ColorSystem.chartBlue,
                                    fontFamily: kRubik,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox(width: 0, height: 0);
                  }
                }).toList(),
              ),
            ))
      ],
    );
  }
}
