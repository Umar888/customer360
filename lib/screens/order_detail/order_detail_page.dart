import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/models/order_history/order_history_model.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';
import '../../services/networking/endpoints.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderDetail order;

  OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  // late Future<void> _futureOrderDetail;
  // List<CartDetailModel> orderDetailModel = [];
  StreamSubscription? navigatorListener;

  // Future<void> getOrders() async {
  //   var response = await HttpService()
  //       .doGet(path: Endpoints.getPastOrderDetail(widget.orderId));
  //   log(jsonEncode(response.data));
  //   try {
  //     orderDetailModel.add(CartDetailModel.fromJson(response.data));
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  String dateFormatter(String? orderDate) {
    if ((orderDate ?? '').isEmpty) {
      return '--';
    } else {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate!));
    }
  }

  String calculateProCoverage(List<Items> items) {
    double? proCoverageAmount = 0.00;
    if (items.isNotEmpty) {
      for (var i = 0; i < items.length; i++) {
        proCoverageAmount = (proCoverageAmount! +
            (items[i].warrantyPrice! * items[i].quantity!));
      }
      return proCoverageAmount!.toStringAsFixed(2);
    }
    return proCoverageAmount.toStringAsFixed(2);
  }

  @override
  initState() {
    super.initState();
    if (!kIsWeb) {
      // FirebaseAnalytics.instance
      //     .setCurrentScreen(screenName: 'CompletedOrderDetailScreen');
    } else {
      context.read<NavigatorWebBloC>().selectedTabIndex = 3;
      navigatorListener =
          context.read<NavigatorWebBloC>().selectedTab.listen((event) {
        if (event != 3 && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    scrollableController.addListener(() {});
  }

  @override
  void dispose() {
    navigatorListener?.cancel();
    super.dispose();
  }

  static double minExtent = 0.35;
  static double maxExtent = 0.82;

  DraggableScrollableController scrollableController =
      DraggableScrollableController();
  bool isExpanded = false;
  double initialExtent = minExtent;
  late BuildContext draggableSheetContext;

  Widget getAppBar() {
    return Padding(
      padding: EdgeInsets.only(
          left: PaddingSystem.padding20,
          right: PaddingSystem.padding20,
          top: PaddingSystem.padding20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    IconSystem.back,
                    package: 'gc_customer_app',
                    height: SizeSystem.size28,
                    width: SizeSystem.size28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.order.orderNumber ?? '',
                style: TextStyle(
                    fontSize: SizeSystem.size15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                    fontFamily: kRubik),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                dateFormatter(widget.order.orderDate),
                style: TextStyle(
                    fontSize: SizeSystem.size17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                    letterSpacing: 2,
                    fontFamily: kRubik),
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Flexible(
                //   child: SvgPicture.asset(IconSystem.percentage, color: Colors.black)
                // ),
                // Flexible(
                //   child: SvgPicture.asset(IconSystem.checkoutMoreOptions, color: Theme.of(context).primaryColor)
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _draggableScrollableSheetBuilder(
      BuildContext context, ScrollController scrollController) {
    draggableSheetContext = context;
    bool haveShipTo = widget.order.shippingAddress!.isNotEmpty ||
        widget.order.shippingCity!.isNotEmpty ||
        widget.order.shippingState!.isNotEmpty ||
        widget.order.shippingCountry!.isNotEmpty;
    bool haveBillTo = (widget.order.billingAddress ?? '').isNotEmpty;
    return Container(
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(26, 45, 49, 66),
                blurRadius: 30,
                offset: Offset(0, -5))
          ]),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: isExpanded
              ? Column(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      child: AnimatedRotation(
                        turns: isExpanded ? 0 : 0.5,
                        duration: Duration(milliseconds: 500),
                        child: IconButton(
                            onPressed: () {},
                            constraints: BoxConstraints(),
                            icon: SvgPicture.asset(
                              IconSystem.expansion,
                              package: 'gc_customer_app',
                              width: 24,
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: ColorSystem.greyLight,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: EdgeInsets.all(13.0),
                                    child: SvgPicture.asset(
                                      IconSystem.shipping,
                                      package: 'gc_customer_app',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Shipping & Billing Details",
                                      style: TextStyle(
                                          fontSize: SizeSystem.size18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF222222),
                                          fontFamily: kRubik),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              if (haveShipTo)
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.order.shippingMethod ==
                                                'Pick From Store'
                                            ? 'Pick-up'
                                            : "Ship to:",
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF222222),
                                            fontFamily: kRubik),
                                      ),
                                      Text(
                                        "${widget.order.shippingAddress! + '${widget.order.shippingAddress2!.isNotEmpty ? ', ${widget.order.shippingAddress2}' : ''}'}, ${widget.order.shippingCity!}, ${widget.order.shippingState!}, ${widget.order.shippingZipcode!}\n${widget.order.phone != null ? widget.order.phone!.toMobileFormat() : ''}",
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF222222),
                                            fontFamily: kRubik),
                                      )
                                    ],
                                  ),
                                ),
                              SizedBox(
                                width: 30,
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 1, child: SizedBox()),
                        haveBillTo
                            ? Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Bill to:",
                                            style: TextStyle(
                                                fontSize: SizeSystem.size15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF222222),
                                                fontFamily: kRubik),
                                          ),
                                          Text(
                                            "${widget.order.billingAddress! + '${widget.order.billingAddress2!.isNotEmpty ? ', ${widget.order.billingAddress2}' : ''}'}, ${widget.order.billingCity!}, ${widget.order.billingState!}, ${widget.order.billingZipcode!}\n${widget.order.billingPhone != null ? widget.order.billingPhone!.toMobileFormat() : ''}",
                                            style: TextStyle(
                                                fontSize: SizeSystem.size15,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF222222),
                                                fontFamily: kRubik),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(
                      height: 1.5,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pro Coverages:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: ColorSystem.primary,
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"$" + calculateProCoverage(widget.order.items ?? []),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: ColorSystem.primary,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        double.parse(calculateProCoverage(
                                    widget.order.items ?? [])) ==
                                0
                            ? Text(
                                "Subtotal:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              )
                            : Text(
                                "Subtotal\n(incl. pro-coverages):",
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                        Text(
                          r"$" + amountFormatting(widget.order.subtotal ?? 0),
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Shipping & Handling:",
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                        Text(
                          "\$${amountFormatting(widget.order.shippingAndHandling ?? 0)}",
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Taxes:",
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"$" + amountFormatting(widget.order.tax ?? 0),
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    (widget.order.shippingFee ?? 0) > 0
                        ? SizedBox(height: 15)
                        : SizedBox.shrink(),
                    (widget.order.shippingFee ?? 0) > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CO Delivery Fee:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    widget.order.shippingFee!
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    (widget.order.shippingTax ?? 0) > 0
                        ? SizedBox(height: 15)
                        : SizedBox.shrink(),
                    (widget.order.shippingTax ?? 0) > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CO Delivery Fee Tax:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    widget.order.shippingTax!
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discounts:",
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"-$" +
                              amountFormatting(widget.order.totalDiscount ?? 0),
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                          color: ColorSystem.greyLight,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    amountFormatting(widget.order.total ?? 0),
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.order.paymentMethods?.length,
                              itemBuilder: (context, index) {
                                var paymentMethod =
                                    widget.order.paymentMethods![index];
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          paymentMethod.paymentMethod_C ==
                                                  'Guitar Center Essentials Card'
                                              ? "Paid By Ess. Card_${paymentMethod.lastCardNumber_C}:"
                                              : paymentMethod.paymentMethod_C ==
                                                      'Guitar Center Gear Card'
                                                  ? "Paid By Gear Card_${paymentMethod.lastCardNumber_C}:"
                                                  : paymentMethod
                                                              .paymentMethod_C ==
                                                          'Credit Card'
                                                      ? "Paid By CC_${paymentMethod.lastCardNumber_C}:"
                                                      : paymentMethod
                                                                  .paymentMethod_C ==
                                                              'Gift Card'
                                                          ? "Paid By Gift Card_${paymentMethod.lastCardNumber_C}:"
                                                          : paymentMethod
                                                                      .paymentMethod_C ==
                                                                  'COA'
                                                              ? "Paid By COA${paymentMethod.lastCardNumber_C}:"
                                                              : '',
                                          style: TextStyle(
                                              fontSize: SizeSystem.size16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF222222),
                                              fontFamily: kRubik),
                                        ),
                                        Text(
                                          r"$" +
                                              amountFormatting(
                                                  paymentMethod.amount_C ?? 0),
                                          style: TextStyle(
                                              fontSize: SizeSystem.size16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF222222),
                                              fontFamily: kRubik),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                );
                                // : SizedBox.shrink();
                              }),
                        ],
                      ),
                    ),
                  ],
                )
              : !MediaQuery.of(context).size.width.isMobileWebDevice()
                  ? _webDetail(haveBillTo)
                  : Column(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          child: AnimatedRotation(
                            turns: isExpanded ? 0 : 0.5,
                            duration: Duration(milliseconds: 500),
                            child: IconButton(
                                onPressed: () {},
                                constraints: BoxConstraints(),
                                icon: SvgPicture.asset(
                                  IconSystem.expansion,
                                  package: 'gc_customer_app',
                                  width: 24,
                                )),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                          color: ColorSystem.greyLight,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: EdgeInsets.all(18.0),
                                        child: SvgPicture.asset(
                                          IconSystem.shipping,
                                          package: 'gc_customer_app',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    if (haveShipTo)
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.order.shippingMethod ==
                                                      'Pick From Store'
                                                  ? 'Pick-up'
                                                  : "Ship to:",
                                              style: TextStyle(
                                                  fontSize: SizeSystem.size15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF222222),
                                                  fontFamily: kRubik),
                                            ),
                                            Text(
                                              "${widget.order.shippingAddress!}",
                                              style: TextStyle(
                                                  fontSize: SizeSystem.size15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF222222),
                                                  fontFamily: kRubik),
                                            )
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    haveBillTo
                                        ? Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Bill to:",
                                                        style: TextStyle(
                                                            fontSize: SizeSystem
                                                                .size15,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xFF222222),
                                                            fontFamily: kRubik),
                                                      ),
                                                      Text(
                                                        "${widget.order.billingAddress}",
                                                        style: TextStyle(
                                                            fontSize: SizeSystem
                                                                .size15,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xFF222222),
                                                            fontFamily: kRubik),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1.5,
                        ),
                        SizedBox(height: 15),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    amountFormatting(widget.order.total ?? 0),
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.order.paymentMethods?.length,
                            itemBuilder: (context, index) {
                              var paymentMethod =
                                  widget.order.paymentMethods![index];
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        paymentMethod.paymentMethod_C ==
                                                'Guitar Center Essentials Card'
                                            ? "Paid By Ess. Card_${paymentMethod.lastCardNumber_C}:"
                                            : paymentMethod.paymentMethod_C ==
                                                    'Guitar Center Gear Card'
                                                ? "Paid By Gear Card_${paymentMethod.lastCardNumber_C}:"
                                                : paymentMethod
                                                            .paymentMethod_C ==
                                                        'Credit Card'
                                                    ? "Paid By CC_${paymentMethod.lastCardNumber_C}:"
                                                    : paymentMethod
                                                                .paymentMethod_C ==
                                                            'Gift Card'
                                                        ? "Paid By Gift Card_${paymentMethod.lastCardNumber_C}"
                                                        : paymentMethod
                                                                    .paymentMethod_C ==
                                                                'COA'
                                                            ? "Paid By COA:"
                                                            : '',
                                        style: TextStyle(
                                            fontSize: SizeSystem.size16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF222222),
                                            fontFamily: kRubik),
                                      ),
                                      Text(
                                        r"$" +
                                            amountFormatting(
                                                paymentMethod.amount_C ?? 0),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF222222),
                                            fontFamily: kRubik),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                ],
                              );
                              // : SizedBox.shrink();
                            }),
                      ],
                    ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          leading: BackButton(),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.order.orderNumber ?? '',
                style: TextStyle(
                    fontSize: SizeSystem.size15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                    fontFamily: kRubik),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                dateFormatter(widget.order.orderDate),
                style: TextStyle(
                    fontSize: SizeSystem.size17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                    letterSpacing: 2,
                    fontFamily: kRubik),
              ),
            ],
          ),
        ),
        body: SlidingUpPanel(
          body: ListView(children: [
            Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.order.items?.map((e) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                  child: Container(
                                      padding: EdgeInsets.only(
                                          bottom: 15, left: 15, right: 15),
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF4F6FA),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Image(
                                        image: CachedNetworkImageProvider(
                                            e.imageUrl ?? ''),
                                        width: 80,
                                      )),
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "SKU #: ",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size13,
                                              fontWeight: FontWeight.w500,
                                              color: ColorSystem.greyDark,
                                              fontFamily: kRubik),
                                        ),
                                        Text(
                                          e.sKU ?? '',
                                          style: TextStyle(
                                              fontSize: SizeSystem.size13,
                                              fontWeight: FontWeight.w400,
                                              color: ColorSystem.greyDark,
                                              fontFamily: kRubik),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                        (e.itemDesc ?? '').isEmpty
                                            ? e.title!
                                            : e.itemDesc!,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: SizeSystem.size17,
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff222222),
                                            fontFamily: kRubik)),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Qty: ",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size14,
                                              fontWeight: FontWeight.w500,
                                              color: ColorSystem.greyDark,
                                              fontFamily: kRubik),
                                        ),
                                        Text(
                                          e.quantity?.toInt().toString() ?? '0',
                                          style: TextStyle(
                                              fontSize: SizeSystem.size16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF222222),
                                              fontFamily: kRubik),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Price: ",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size14,
                                              fontWeight: FontWeight.w500,
                                              color: ColorSystem.greyDark,
                                              fontFamily: kRubik),
                                        ),
                                        Text(
                                          "\$${e.overridePrice != null && e.overridePriceApproval == 'Approved' ? amountFormatting(e.overridePrice!) : amountFormatting(e.unitPrice!)}",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF222222),
                                              fontFamily: kRubik),
                                        ),
                                        if (e.overridePrice != null &&
                                            e.overridePriceApproval ==
                                                'Approved')
                                          Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(
                                              '(\$${amountFormatting(e.unitPrice!)})',
                                              style: TextStyle(
                                                fontSize: SizeSystem.size16,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    ColorSystem.complimentary,
                                                fontFamily: kRubik,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Divider(
                              color: Colors.grey.shade400,
                              height: 1.5,
                            ),
                          )
                        ],
                      );
                    }).toList() ??
                    []),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.275,
            )
          ]),
          onPanelOpened: () => setState(() {
            isExpanded = true;
          }),
          onPanelClosed: () => setState(() {
            isExpanded = false;
          }),
          minHeight: MediaQuery.of(context).size.height * 0.3,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(26, 45, 49, 66),
                blurRadius: 30,
                offset: Offset(0, -5))
          ],
          panel: _draggableScrollableSheetBuilder(context, ScrollController()),
        ));
  }

  _webDetail(bool haveBillTo) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Ship to:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                        Text(
                          "${widget.order.shippingAddress! + '${widget.order.shippingAddress2!.isNotEmpty ? ', ${widget.order.shippingAddress2}' : ''}'}, ${widget.order.shippingCity!}, ${widget.order.shippingState!}, ${widget.order.shippingZipcode!}\n ${widget.order.phone != null ? widget.order.phone!.toMobileFormat() : ''}",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                if ((widget.order.billingAddress ?? '').isNotEmpty)
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bill to:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                        Text(
                          "${widget.order.billingAddress! + '${widget.order.billingAddress2!.isNotEmpty ? ', ${widget.order.billingAddress2}' : ''}'}, ${widget.order.billingCity!}, ${widget.order.billingState!}, ${widget.order.billingZipcode!}\n ${widget.order.billingPhone != null ? widget.order.billingPhone!.toMobileFormat() : ''}",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pro Coverages:",
                      style: TextStyle(
                          fontSize: SizeSystem.size15,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor,
                          fontFamily: kRubik),
                    ),
                    Text(
                      r"$" + calculateProCoverage(widget.order.items ?? []),
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor,
                          fontFamily: kRubik),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    double.parse(calculateProCoverage(
                                widget.order.items ?? [])) ==
                            0
                        ? Text(
                            "Subtotal:",
                            style: TextStyle(
                                fontSize: SizeSystem.size16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF222222),
                                fontFamily: kRubik),
                          )
                        : Text(
                            "Subtotal\n(incl. pro-coverages):",
                            style: TextStyle(
                                fontSize: SizeSystem.size16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF222222),
                                fontFamily: kRubik),
                          ),
                    Text(
                      r"$" + amountFormatting(widget.order.subtotal!),
                      style: TextStyle(
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF222222),
                          fontFamily: kRubik),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shipping & Handling:",
                      style: TextStyle(
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF222222),
                          fontFamily: kRubik),
                    ),
                    Text(
                      "\$${amountFormatting(widget.order.shippingAndHandling!)}",
                      style: TextStyle(
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF222222),
                          fontFamily: kRubik),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Taxes:",
                      style: TextStyle(
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF222222),
                          fontFamily: kRubik),
                    ),
                    Text(
                      r"$" + amountFormatting(widget.order.tax ?? 0),
                      style: TextStyle(
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF222222),
                          fontFamily: kRubik),
                    ),
                  ],
                ),
                (widget.order.shippingFee ?? 0) > 0
                    ? SizedBox(height: 4)
                    : SizedBox.shrink(),
                (widget.order.shippingFee ?? 0) > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "CO Delivery Fee:",
                            style: TextStyle(
                                fontSize: SizeSystem.size16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF222222),
                                fontFamily: kRubik),
                          ),
                          Text(
                            r"$" + widget.order.shippingFee!.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: SizeSystem.size16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF222222),
                                fontFamily: kRubik),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                (widget.order.shippingTax ?? 0) > 0
                    ? SizedBox(height: 4)
                    : SizedBox.shrink(),
                (widget.order.shippingTax ?? 0) > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "CO Delivery Fee Tax:",
                            style: TextStyle(
                                fontSize: SizeSystem.size16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF222222),
                                fontFamily: kRubik),
                          ),
                          Text(
                            r"$" + widget.order.shippingTax!.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: SizeSystem.size16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF222222),
                                fontFamily: kRubik),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discounts:",
                      style: TextStyle(
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF222222),
                          fontFamily: kRubik),
                    ),
                    Text(
                      r"-$" + amountFormatting(widget.order.totalDiscount ?? 0),
                      style: TextStyle(
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w400,
                          color: Colors.red,
                          fontFamily: kRubik),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total:",
                        style: TextStyle(
                            fontSize: SizeSystem.size16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                            fontFamily: kRubik),
                      ),
                      Text(
                        r"$" + amountFormatting(widget.order.total ?? 0),
                        style: TextStyle(
                            fontSize: SizeSystem.size16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                            fontFamily: kRubik),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.order.paymentMethods?.length,
                    itemBuilder: (context, index) {
                      var paymentMethod = widget.order.paymentMethods![index];
                      return haveBillTo
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      paymentMethod.paymentMethod_C ==
                                              'Guitar Center Essentials Card'
                                          ? "Paid By Ess. Card_${paymentMethod.lastCardNumber_C}:"
                                          : paymentMethod.paymentMethod_C ==
                                                  'Guitar Center Gear Card'
                                              ? "Paid By Gear Card_${paymentMethod.lastCardNumber_C}:"
                                              : paymentMethod.paymentMethod_C ==
                                                      'Credit Card'
                                                  ? "Paid By CC_${paymentMethod.lastCardNumber_C}:"
                                                  : paymentMethod
                                                              .paymentMethod_C ==
                                                          'Gift Card'
                                                      ? "Paid By Gift Card_${paymentMethod.lastCardNumber_C}"
                                                      : paymentMethod
                                                                  .paymentMethod_C ==
                                                              'COA'
                                                          ? "Paid By COA:"
                                                          : '',
                                      style: TextStyle(
                                          fontSize: SizeSystem.size16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF222222),
                                          fontFamily: kRubik),
                                    ),
                                    Text(
                                      r"$" +
                                          amountFormatting(
                                              paymentMethod.amount_C ?? 0),
                                      style: TextStyle(
                                          fontSize: SizeSystem.size16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF222222),
                                          fontFamily: kRubik),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                              ],
                            )
                          : SizedBox.shrink();
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
