import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/common_widgets/dash_generator.dart';
import 'package:gc_customer_app/common_widgets/instruments_tile.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/screens/order_detail/order_detail_page.dart';
import 'package:gc_customer_app/screens/order_detail/order_detail_web_page.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/common_widgets.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import '../../models/order_history/order_history_model.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';
import '../no_data_found.dart';

class OrderHistoryWidget extends StatefulWidget {
  final EasyRefreshController controller;
  OrderHistoryWidget({Key? key, required this.controller}) : super(key: key);

  @override
  State<OrderHistoryWidget> createState() => _OrderHistoryWidgetState();
}

class _OrderHistoryWidgetState extends State<OrderHistoryWidget> {
  late OrderHistoryBloc orderHistoryBloc;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (kIsWeb) {
      return BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
        builder: (context, state) {
          if (state.fetchOrderHistory! && state.currentPage == 1) {
            return Center(child: CircularProgressIndicator());
          } else if (state.orderHistory == null ||
              state.orderHistory!.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              height: size.height * 0.2,
              child: Center(child: NoDataFound(fontSize: 16)),
            );
          }
          return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(PaddingSystem.padding20),
              itemCount: state.orderHistory!.length,
              separatorBuilder: (context, index) {
                return Container(
                  color: ColorSystem.secondary.withOpacity(0.3),
                  height: 0.5,
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 20,
                  ),
                );
              },
              itemBuilder: (context, index) {
                return _orderHistoryWidget(index, state,
                    orderDetail: state.orderHistory![index]);
              });
        },
      );
    } else {
      return BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
        builder: (context, state) {
          if (state.searchedOrderHistory?.orderNumber != null) {
            return _orderHistoryWidget(0, state,
                orderHistoryLandingScreen: state.searchedOrderHistory!);
          }
          if (state.fetchOrderHistory! && state.currentPage == 1) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Center(child: CircularProgressIndicator()));
          } else if (state.orderHistory == null ||
              state.orderHistory!.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              height: size.height * 0.2,
              child: Center(child: NoDataFound(fontSize: 16)),
            );
          } else {
            Future.delayed(Duration.zero, () {
              if (state.orderHistory!.isNotEmpty && !state.fetchOrderHistory!) {
                if (mounted) {
                  widget.controller.finishLoad();
                }
              }
            });
            return ListView.separated(
                shrinkWrap: true,
                primary: false,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: PaddingSystem.padding20,
                  left: PaddingSystem.padding20,
                  right: 10,
                ),
                itemCount: state.orderHistory!.length,
                separatorBuilder: (context, index) {
                  if (index == state.orderHistory!.length ||
                      index == state.orderHistory!.length - 1) {
                    return SizedBox.shrink();
                  }
                  return Container(
                    color: ColorSystem.secondary.withOpacity(0.3),
                    height: 0.5,
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 20,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  // if (index == state.orderHistory!.length) {
                  //   return Center(
                  //       child: Padding(
                  //     padding: EdgeInsets.all(15.0),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         Icon(
                  //           Icons.arrow_upward_outlined,
                  //           color: Colors.grey,
                  //         ),
                  //         SizedBox(
                  //           width: 15,
                  //         ),
                  //         Text(
                  //           "Pull up to load more",
                  //           style: TextStyle(color: Colors.grey),
                  //         ),
                  //       ],
                  //     ),
                  //   ));
                  // }
                  return _orderHistoryWidget(index, state,
                      orderDetail: state.orderHistory![index]);
                });
            ;
          }
        },
      );
    }
  }

  @override
  void initState() {
    orderHistoryBloc = context.read<OrderHistoryBloc>();
    // orderHistoryBloc.add(FetchOrderHistory(currentPage: 1)); //This event is called once in landing screen page
    super.initState();
  }

  Widget _orderHistoryWidget(int index, OrderHistoryState state,
      {OrderHistory? orderHistoryLandingScreen, OrderDetail? orderDetail}) {
    var orderStatus = orderHistoryLandingScreen?.orderStatus?.toLowerCase() ??
        orderDetail?.orderStatus?.toLowerCase() ??
        '';
    var orderNumber = orderHistoryLandingScreen?.orderNumber ??
        orderDetail?.orderNumber ??
        '';
    var paymentMethodTotal = (orderHistoryLandingScreen?.paymentMethodTotal ??
        orderDetail?.paymentMethodTotal ??
        0);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            kIsWeb
                ? webPageRoute(
                    MediaQuery.of(context).size.width.isMobileWebDevice()
                        ? OrderDetailPage(order: state.orderHistory![index])
                        : OrderDetailWebPage(order: state.orderHistory![index]))
                : CupertinoPageRoute(
                    builder: (context) =>
                        OrderDetailPage(order: state.orderHistory![index]),
                  ));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          index > 0 && index < state.orderHistory!.length - 1
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DashGenerator(numberOfDashes: 6),
                    orderStatus == "completed"
                        ? Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff35D850),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                          )
                        : orderStatus == "cancelled"
                            ? Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffFF0000),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    border: Border.all(
                                        color: Colors.white, width: 3)),
                              )
                            : Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff8C80F8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    border: Border.all(
                                        color: Colors.white, width: 3)),
                              ),
                    DashGenerator(numberOfDashes: 6)
                  ],
                )
              : index == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                        ),
                        DashGenerator(numberOfDashes: 3),
                        orderStatus == "completed"
                            ? Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff35D850),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    border: Border.all(
                                        color: Colors.white, width: 3)),
                              )
                            : orderStatus == "cancelled"
                                ? Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xffFF0000),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        border: Border.all(
                                            color: Colors.white, width: 3)),
                                  )
                                : Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff8C80F8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        border: Border.all(
                                            color: Colors.white, width: 3)),
                                  ),
                        DashGenerator(numberOfDashes: 6)
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DashGenerator(numberOfDashes: 6),
                        orderStatus == "completed"
                            ? Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff35D850),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    border: Border.all(
                                        color: Colors.white, width: 3)),
                              )
                            : orderStatus == "cancelled"
                                ? Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xffFF0000),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        border: Border.all(
                                            color: Colors.white, width: 3)),
                                  )
                                : Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff8C80F8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        border: Border.all(
                                            color: Colors.white, width: 3)),
                                  ),
                        DashGenerator(
                          numberOfDashes: 6,
                          color: ColorSystem.scaffoldBackgroundColor,
                        )
                      ],
                    ),
          SizedBox(
            width: SizeSystem.size20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderNumber,
                style: TextStyle(
                  color: ColorSystem.primary,
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w400,
                  fontSize: SizeSystem.size12,
                ),
              ),
              SizedBox(
                height: SizeSystem.size4,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    paymentMethodTotal > 0
                        ? '\$' + amountFormatting(paymentMethodTotal)
                        : '\$' +
                            amountFormatting(
                                (orderHistoryLandingScreen?.lineItems?.fold(
                                        0.0,
                                        (previous, current) =>
                                            (previous ?? 0) +
                                            double.parse(
                                                current.purchasedPrice!)) ??
                                    orderDetail?.items?.fold(
                                        0.0,
                                        (previous, current) =>
                                            (previous ?? 0) +
                                            double.parse(
                                                current.purchasedPrice!)) ??
                                    0)),
                    style: TextStyle(
                      color: ColorSystem.primary,
                      fontFamily: kRubik,
                      fontWeight: FontWeight.bold,
                      fontSize: SizeSystem.size16,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeSystem.size4,
              ),
              Text(
                (orderHistoryLandingScreen?.orderDate ?? orderDetail?.orderDate)
                    .toString()
                    .changeToBritishFormat(
                        state.orderHistory![index].orderDate.toString()),
                style: TextStyle(
                  fontFamily: kRubik,
                  fontSize: SizeSystem.size12,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 0,
          ),
          orderStatus == "cancelled"
              ? Container(
                  decoration: BoxDecoration(
                      color: ColorSystem.lightPink,
                      borderRadius: BorderRadius.circular(100)),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: Text(
                    "Cancelled",
                    style: TextStyle(
                        color: ColorSystem.pureRed,
                        fontSize: 14,
                        fontFamily: kRubik),
                  ),
                )
              : orderStatus == "completed"
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(100)),
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      child: Text(
                        "Completed",
                        style: TextStyle(
                            color: Colors.green.shade500,
                            fontSize: 14,
                            fontFamily: kRubik),
                      ),
                    )
                  : orderStatus.isEmpty
                      ? Container()
                      : Container(
                          decoration: BoxDecoration(
                              color: ColorSystem.lavender3.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100)),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          child: Text(
                            orderStatus.toCapitalized(),
                            style: TextStyle(
                                color: ColorSystem.lavender3,
                                fontSize: 14,
                                fontFamily: kRubik),
                          ),
                        ),
          Spacer(),
          InstrumentsTile(
            items: orderHistoryLandingScreen?.lineItems,
            orderDetailItems: orderDetail?.items,
          ),
          SizedBox(
            width: SizeSystem.size16,
          ),
        ],
      ),
    );
  }
}
