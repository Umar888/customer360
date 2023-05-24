import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/cart/views/cart_page.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:gc_customer_app/utils/routes/cart_page_arguments.dart';

import '../../bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import '../../models/order_history/open_order_model.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';
import '../no_data_found.dart';
import 'order_history_item.dart';

class OpenOrderWidget extends StatefulWidget {
  LandingScreenState landingScreenState;
  CustomerInfoModel customerInfoModel;
  String customerId;
  double? widgetWidth;
  bool isOnlyShowOpenOrder;

  OpenOrderWidget({
    Key? key,
    required this.landingScreenState,
    required this.customerId,
    required this.customerInfoModel,
    this.widgetWidth,
    this.isOnlyShowOpenOrder = false,
  }) : super(key: key);

  @override
  State<OpenOrderWidget> createState() => _OpenOrderWidgetState();
}

class _OpenOrderWidgetState extends State<OpenOrderWidget> {
  late OrderHistoryBloc orderHistoryBloc;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
//      buildWhen: (previous, current) => previous.openOrderModel != current.openOrderModel,
        builder: (context, state) {
      if (!(state.fetchingOpenOrders ?? true)) {
        if (state.openOrderModel != null &&
            state.openOrderModel!.openOrders != null &&
            state.openOrderModel!.openOrders!.isNotEmpty) {
          return Padding(
            padding: EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isOnlyShowOpenOrder)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Open Orders",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: SizeSystem.size16,
                          fontFamily: kRubik,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ...state.openOrderModel?.openOrders?.map<Widget>((e) {
                      OpenOrders openOrders = e;
                      return Container(
                        width: widget.widgetWidth ?? double.infinity,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: kIsWeb &&
                                    !MediaQuery.of(context)
                                        .size
                                        .width
                                        .isMobileWebDevice()
                                ? ColorSystem.white
                                : ColorSystem.culturedGrey,
                            borderRadius: BorderRadius.circular(20)),
                        child: InkWell(
                          onTap: kIsWeb
                              ? null
                              : () {
                                  if ((e.gCOrderLineItemsR?.totalSize ?? 0) >
                                      0) {
                                    Navigator.pushNamed(
                                      context,
                                      CartPage.routeName,
                                      arguments: CartArguments(
                                        email: widget
                                                    .customerInfoModel
                                                    .records![0]
                                                    .accountEmailC !=
                                                null
                                            ? widget.customerInfoModel
                                                .records![0].accountEmailC!
                                            : widget.customerInfoModel
                                                        .records![0].emailC !=
                                                    null
                                                ? widget.customerInfoModel
                                                    .records![0].emailC!
                                                : widget
                                                            .customerInfoModel
                                                            .records![0]
                                                            .personEmail !=
                                                        null
                                                    ? widget
                                                        .customerInfoModel
                                                        .records![0]
                                                        .personEmail!
                                                    : "",
                                        phone: widget
                                                    .customerInfoModel
                                                    .records![0]
                                                    .accountPhoneC !=
                                                null
                                            ? widget.customerInfoModel
                                                .records![0].accountPhoneC!
                                            : widget.customerInfoModel
                                                        .records![0].phone !=
                                                    null
                                                ? widget.customerInfoModel
                                                    .records![0].phone!
                                                : widget
                                                            .customerInfoModel
                                                            .records![0]
                                                            .phoneC !=
                                                        null
                                                    ? widget.customerInfoModel
                                                        .records![0].phoneC!
                                                    : "",
                                        orderId: openOrders.id!,
                                        orderNumber: openOrders.orderNumberC!,
                                        orderLineItemId:
                                            openOrders.orderNumberC!,
                                        orderDate: openOrders.createdDate!,
                                        customerInfoModel:
                                            widget.customerInfoModel,
                                        userName: widget.customerInfoModel
                                            .records!.first.name!,
                                        userId: widget.customerId,
                                      ),
                                    ).then((value) {
                                      if (value == "isDel") {
                                        orderHistoryBloc.add(GetOpenOrders());
                                      }
                                    });
                                  }
                                },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/calories.svg",
                                    package: 'gc_customer_app',
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${openOrders.gCOrderLineItemsR!.records!.length} Items",
                                        style: TextStyle(
                                            fontFamily: kRubik,
                                            fontSize: SizeSystem.size16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        r"$"
                                        "${openOrders.totalLineAmountC?.toStringAsFixed(2) ?? openOrders.totalC?.toStringAsFixed(2) ?? '0'}",
                                        // "${openOrders.gCOrderLineItemsR!.records!.fold(0, (previous, current) => previous + double.parse((current.itemPriceC! * current.quantityC!).toString()).toInt()) > 999 ? "${(openOrders.gCOrderLineItemsR!.records!.fold(0.0, (previous, current) => previous + double.parse((current.itemPriceC! * current.quantityC!).toString())) / 1000).toStringAsFixed(2)}k" : (openOrders.gCOrderLineItemsR!.records!.fold(0.0, (previous, current) => previous + (current.itemPriceC! * current.quantityC!))).toStringAsFixed(2)}",
                                        style: TextStyle(
                                            fontFamily: kRubik,
                                            fontSize: SizeSystem.size13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          openOrders.createdDate!
                                              .changeToBritishFormat(
                                                  openOrders.createdDate!),
                                          style: TextStyle(
                                              fontFamily: kRubik,
                                              fontSize: SizeSystem.size15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          openOrders.orderNumberC!,
                                          style: TextStyle(
                                              fontFamily: kRubik,
                                              fontSize: SizeSystem.size13,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Divider(),
                              SizedBox(height: 10),
                              SizedBox(
                                height: 240,
                                width: widget.widgetWidth,
                                child: openOrders
                                        .gCOrderLineItemsR!.records!.isNotEmpty
                                    ? ListView.separated(
                                        shrinkWrap: true,
                                        separatorBuilder: (context, index) {
                                          return SizedBox(width: 20);
                                        },
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.all(10),
                                        itemCount: openOrders
                                            .gCOrderLineItemsR!.records!.length,
                                        itemBuilder: (context, i) {
                                          return AspectRatio(
                                            aspectRatio: 0.65,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                  child: OrderHistoryItem(
                                                    orderId: openOrders.id!,
                                                    records: openOrders
                                                        .gCOrderLineItemsR!
                                                        .records![i],
                                                    skuId: openOrders
                                                        .gCOrderLineItemsR!
                                                        .records![i]
                                                        .itemSKUC!,
                                                    recordIndex: i,
                                                    onTap: () {
                                                      // Navigator.push(
                                                      //     context,
                                                      //     CupertinoPageRoute(
                                                      //       builder: (context) => ProductDetailPage(
                                                      //         customerID:widget.customerId,
                                                      //         customer: widget.customerInfoModel,
                                                      //         orderLineItemId: openOrders.id,
                                                      //         orderId: openOrders.id!,
                                                      //         skUiD: openOrders.gCOrderLineItemsR!.records![i].itemSKUC!,
                                                      //       ),
                                                      //     ));
                                                      print("ok");
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                MouseRegion(
                                                  onHover: (event) {
                                                    print(openOrders
                                                        .gCOrderLineItemsR!
                                                        .records![i]
                                                        .descriptionC);
                                                  },
                                                  child: Tooltip(
                                                    message: openOrders
                                                        .gCOrderLineItemsR!
                                                        .records![i]
                                                        .descriptionC,
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Text(
                                                          openOrders
                                                              .gCOrderLineItemsR!
                                                              .records![i]
                                                              .descriptionC!,
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  kRubik,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontSize:
                                                                  SizeSystem
                                                                      .size14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  r"$" +
                                                      openOrders
                                                          .gCOrderLineItemsR!
                                                          .records![i]
                                                          .itemPriceC!
                                                          .toStringAsFixed(2),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontFamily: kRubik,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize:
                                                          SizeSystem.size20,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                    : Center(
                                        child: Text("No products in order"),
                                      ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    }).toList() ??
                    []
              ],
            ),
          );
        } else {
          return Container(
            width: widget.widgetWidth ?? double.infinity,
            padding: EdgeInsets.all(10),
            height: size.height * 0.7,
            child: Center(child: NoDataFound(fontSize: 16)),
          );
        }
      } else {
        return Container(
          width: widget.widgetWidth ?? double.infinity,
          padding: EdgeInsets.all(10),
          height: size.height * 0.7,
          child: Center(child: CircularProgressIndicator()),
        );
      }
    });
  }

  @override
  void initState() {
    orderHistoryBloc = context.read<OrderHistoryBloc>();
    orderHistoryBloc.add(GetOpenOrders());
    super.initState();
  }
}
