import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/order_lookup_bloc/order_lookup_bloc.dart';
import 'package:gc_customer_app/common_widgets/dash_generator.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/order_lookup_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/cart/views/cart_page.dart';
import 'package:gc_customer_app/screens/order_detail/order_detail_page.dart';
import 'package:gc_customer_app/screens/order_lookup/order_lookup_detail_screen.dart';
import 'package:gc_customer_app/screens/order_lookup/widgets.dart';
import 'package:intl/intl.dart';

import '../../utils/routes/cart_page_arguments.dart';

class OrderLookUpScreen extends StatefulWidget {
  CustomerInfoModel? customerInfoModel;
  OrderLookUpScreen({Key? key}) : super(key: key);

  @override
  State<OrderLookUpScreen> createState() => _OrderLookUpScreenState();
}

class _OrderLookUpScreenState extends State<OrderLookUpScreen> {
  late OrderLookUpBloC orderLookUpBloC;
  ScrollController controller = ScrollController();
  TextEditingController tecController = TextEditingController();
  final StreamController<bool> isShowMoveTopSC =
      StreamController<bool>.broadcast()..add(false);

  @override
  void initState() {
    super.initState();
    orderLookUpBloC = context.read<OrderLookUpBloC>();
    controller.addListener(() {
      if (controller.offset >= 170) {
        isShowMoveTopSC.add(true);
      } else {
        isShowMoveTopSC.add(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: StreamBuilder<bool>(
            stream: isShowMoveTopSC.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data != true) return SizedBox.shrink();
              return FloatingActionButton(
                backgroundColor: ColorSystem.white,
                mini: true,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: ColorSystem.black,
                ),
                onPressed: () {
                  controller.animateTo(0,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeInOut);
                },
              );
            }),
        appBar: AppBar(
          toolbarHeight: 90,
          leadingWidth: 45,
          leading: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: BackButton(
              onPressed: () {
                orderLookUpBloC.add(ClearOrderLookUp());
                Navigator.pop(context);
              },
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  'Order Lookup',
                  style: theme.caption?.copyWith(fontSize: 16),
                ),
              ),
              Container(
                height: 40,
                child: TextField(
                  controller: tecController,
                  cursorColor: Theme.of(context).primaryColor,
                  autofocus: true,
                  decoration: InputDecoration(
                    constraints: BoxConstraints(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3, vertical: 2)
                            .copyWith(bottom: 10),
                    hintText: 'Search by order#, phone# or email',
                    hintStyle: TextStyle(
                      color: ColorSystem.secondary,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      EasyDebounce.cancelAll();
                      EasyDebounce.debounce(
                          'search_order_debounce', Duration(seconds: 1),
                          () {
                        orderLookUpBloC.add(SearchOrders(value));
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<OrderLookUpBloC, OrderLookUpState>(
            builder: (context, state) {
          List<OrderLookupModel> orders = [];
          if (state is OrderLookUpProgress) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is OrderLookUpSuccess) {
            orders = state.orders;
            if (orders.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Center(
                  child: NoDataFound(fontSize: 14),
                ),
              );
            }
          }
          return ListView.builder(
            controller: controller,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              bool isOpenOrder = order.orderStatus?.toLowerCase() == 'draft';
              var statusColor = ColorSystem.additionalGreen;
              switch (order.orderStatus) {
                case 'Delivered':
                  statusColor = ColorSystem.lavender3;
                  break;
                case 'Shipped':
                  statusColor = ColorSystem.peach;
                  break;
                case 'Cancelled':
                case 'Returned':
                  statusColor = ColorSystem.pureRed;
                  break;
                case 'Submitted':
                  statusColor = ColorSystem.additionalPurple;
                  break;
                default:
              }
              return InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            OrderLookupDetailScreen(order: order),
                      ));
                },
                child: Row(
                  crossAxisAlignment: index == orders.length - 1
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    SizedBox(width: 14),
                    if (orders.length > 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (index != 0)
                            DashGenerator(numberOfDashes: 16),
                          Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                          ),
                          if (index != orders.length - 1)
                            DashGenerator(numberOfDashes: 16)
                        ],
                      ),
                    Expanded(
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: ColorSystem.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: ColorSystem.black.withOpacity(0.1),
                                  blurRadius: 16,
                                  offset: Offset(5, 5))
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  order.orderNo ?? '',
                                  style: theme.caption?.copyWith(
                                      fontSize: 16,
                                      color: ColorSystem.lavender3),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: \$${order.grandTotal}',
                                  style: theme.caption?.copyWith(fontSize: 16),
                                ),
                                orderStatusWidget(order.orderStatus ?? ''),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order Placed: ${DateFormat('MMM dd, yyyy').format(order.orderDate ?? DateTime.now())}',
                                        style: theme.caption?.copyWith(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text('Brand: ${order.brand}'),
                                      Text('Channel: ${order.entryType}'),
                                    ],
                                  ),
                                ),
                                isOpenOrder
                                    ? TextButton(
                                        onPressed: () => onAddToCart(order),
                                        child: Text('Add to cart'),
                                      )
                                    : SizedBox(width: 10),
                              ],
                            ),
                            if (order.items != null)
                              Container(
                                height: isOpenOrder ? 160 : 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: order.items?.length,
                                  itemBuilder: (context, index) {
                                    var item = order.items![index];
                                    double size = isOpenOrder ? 100 : 60;
                                    return Container(
                                      width: size,
                                      padding: EdgeInsets.only(right: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: item?.imageUrl ?? '',
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: size,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: ColorSystem.black
                                                            .withOpacity(0.2),
                                                        offset: Offset(1, 1),
                                                        blurRadius: 8),
                                                  ],
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.contain)),
                                            ),
                                            placeholder: (context, url) =>
                                                Container(
                                              height: size,
                                              color: Color(0xFFF3F6FA),
                                              alignment: Alignment.center,
                                              child:
                                                  CircularProgressIndicator(
                                                color: ColorSystem.black,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Stack(
                                              children: [
                                                Container(
                                                  height: size,
                                                  color:
                                                      Color(0xFFF3F6FA),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      'Image not found'),
                                                ),
                                                Positioned(
                                                  right: 4,
                                                  top: 4,
                                                  child: orderStatusWidget(
                                                      item?.itemStatus ?? '',
                                                      false),
                                                )
                                              ],
                                            ),
                                          ),
                                          if (isOpenOrder)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item?.itemDesc ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                    '\$${double.parse(item?.unitPrice ?? '0').toStringAsFixed(2)}'),
                                              ],
                                            )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void onAddToCart(OrderLookupModel order) {
    if ((order.items?.length ?? 0) > 0) {
      Navigator.pushNamed(
        context,
        CartPage.routeName,
        arguments: CartArguments(
          email: widget.customerInfoModel?.records![0].accountEmailC != null
              ? widget.customerInfoModel!.records![0].accountEmailC!
              : widget.customerInfoModel?.records![0].emailC != null
                  ? widget.customerInfoModel!.records![0].emailC!
                  : widget.customerInfoModel?.records![0].personEmail != null
                      ? widget.customerInfoModel!.records![0].personEmail!
                      : "",
          phone: widget.customerInfoModel?.records![0].accountPhoneC != null
              ? widget.customerInfoModel!.records![0].accountPhoneC!
              : widget.customerInfoModel?.records![0].phone != null
                  ? widget.customerInfoModel!.records![0].phone!
                  : widget.customerInfoModel?.records![0].phoneC != null
                      ? widget.customerInfoModel!.records![0].phoneC!
                      : "",
          orderId: order.orderId ?? '',
          orderNumber: order.orderNo ?? '',
          orderLineItemId: order.orderNo ?? '',
          orderDate: DateTime.now().toString(),
          customerInfoModel: widget.customerInfoModel ??
              CustomerInfoModel(records: [Records(id: null)]),
          userName: widget.customerInfoModel?.records?[0].name ?? "",
          userId: widget.customerInfoModel?.records?[0].id ?? '',
        ),
      ).then((value) {
        if (value == "isDel") {
          orderLookUpBloC.add(SearchOrders(tecController.text));
        }
      });
    }
  }
}
