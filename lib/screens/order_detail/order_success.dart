import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/order_printer_bloc/order_printer_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/confetti/confetti.dart';
import 'package:gc_customer_app/models/printer_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

import '../../primitives/padding_system.dart';
import '../../models/cart_model/tax_model.dart';

class OrderSuccess extends StatefulWidget {
  final String successMsg;
  final String orderId;
  final OrderDetail orderDetail;
  final Map<String, dynamic> proceedOrder;
  final bool isSelectedAgent;
  final bool isFromNotification;
  OrderSuccess(
      {Key? key,
      required this.orderDetail,
      required this.successMsg,
      required this.orderId,
      required this.proceedOrder,
      this.isSelectedAgent = true,
      this.isFromNotification = false})
      : super(key: key);

  @override
  State<OrderSuccess> createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess> {
  StreamSubscription? streamSubscription;
  ConfettiController? _controllerCenter;

  @override
  void initState() {
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'PlaceOrderSuccessScreen');
    _controllerCenter = ConfettiController(duration: Duration(seconds: 1));
    context.read<OrderPrinterBloC>().add(LoadOrderPrinters());
    streamSubscription =
        context.read<OrderPrinterBloC>().stream.listen((event) {
      if (event is OrderPrinterFailure && event.message != null) {
        showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text(event.message?.replaceAll('Exception: ', '') ?? ''),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          },
        );
      } else if (event is OrderPrinterSuccess && event.message != null) {
        showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(event.message ?? ''),
              actions: [
                CupertinoDialogAction(
                  child: Text('Ok'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          },
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    _controllerCenter?.dispose();
    super.dispose();
  }

  Widget getAppBar() {
    return Padding(
      padding: EdgeInsets.only(
          left: PaddingSystem.padding20,
          right: PaddingSystem.padding20,
          top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CloseButton(
            onPressed: () {
              context
                  .read<InventorySearchBloc>()
                  .add(SetCart(itemOfCart: [], records: [], orderId: ''));
              if (widget.isFromNotification) {
                Navigator.pop(context);
                return;
              }
              if (widget.isSelectedAgent) {
                context
                    .read<OrderHistoryBloc>()
                    .add(FetchOrderHistory(currentPage: 1));
                Navigator.of(context).popUntil(
                    (route) => route.settings.name == "CustomerLandingScreen");
              } else {
                Navigator.of(context).popUntil(
                    (route) => route.settings.name == "InventorySearchList");
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controllerCenter?.play();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: ColorSystem.culturedGrey,
          body: BlocBuilder<OrderPrinterBloC, OrderPrinterState>(
              builder: (context, state) {
            List<PrinterModel> zebraPrinters = [];
            LoadingPrinters? loadingPrinters;

            List<PrinterModel> epsonPrinters = [];
            if (state is OrderPrinterSuccess) {
              zebraPrinters = state.zebraPrinters;
              epsonPrinters = state.epsonPrinters;
              loadingPrinters = state.loadingPrinters;
            }
            if (state is OrderPrinterProgress) {
              zebraPrinters = state.zebraPrinters ?? [];
              epsonPrinters = state.epsonPrinters ?? [];
              loadingPrinters = state.loadingPrinters;
            }
            if (state is OrderPrinterFailure) {
              zebraPrinters = state.zebraPrinters ?? [];
              epsonPrinters = state.epsonPrinters ?? [];
              loadingPrinters = state.loadingPrinters;
            }
            return Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 180),
                    child: ConfettiWidget(
                      confettiController: _controllerCenter!,
                      blastDirectionality: BlastDirectionality
                          .explosive, // don't specify a direction, blast randomly
                      shouldLoop:
                          false, // start again as soon as the animation is finished
                      colors: [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple
                      ], // manually specify the colors to be used
                      // createParticlePath: drawStar, // define a custom shape/path.
                      maxBlastForce: 10, // set a lower max blast force
                      minBlastForce: 8, // set a lower min blast force
                      emissionFrequency: 1,
                      numberOfParticles: 8, // a lot of particles at once
                    ),
                  ),
                ),
                SafeArea(
                    left: true,
                    top: true,
                    right: true,
                    bottom: false,
                    child: ListView(
                      children: [
                        getAppBar(),
                        SvgPicture.asset(
                          IconSystem.orderSuccess,
                          package: 'gc_customer_app',
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Order Placed Successfully!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: kRubik,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: 8),
                        RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: 'Order ID: ',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor),
                                children: [
                                  TextSpan(
                                      text:
                                          '${widget.successMsg.split(' ').last}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: kRubik,
                                          fontWeight: FontWeight.w500,
                                          color: ColorSystem.lavender3))
                                ])),
                        Divider(
                          height: 14,
                          indent: 8,
                          endIndent: 8,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                        if (loadingPrinters == null ||
                            loadingPrinters == LoadingPrinters.loading)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Center(child: CircularProgressIndicator()),
                          ),

                        if ((loadingPrinters != null &&
                                loadingPrinters ==
                                    LoadingPrinters.notLoading) &&
                            (zebraPrinters.isNotEmpty ||
                                epsonPrinters.isNotEmpty))
                          Text(
                            'Print Receipt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        if ((loadingPrinters != null &&
                                loadingPrinters ==
                                    LoadingPrinters.notLoading) &&
                            (zebraPrinters.isNotEmpty))
                          Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(left: 14),
                            child: Text(
                              'Zebra Printers',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        Wrap(
                          children: zebraPrinters
                              .map<Widget>((p) => InkWell(
                                    onTap: () {
                                      context.read<OrderPrinterBloC>().add(
                                          PrintOrder(p.value!, widget.orderId));
                                    },
                                    child: Container(
                                      width:
                                          (MediaQuery.of(context).size.width /
                                                  2) -
                                              10,
                                      margin: EdgeInsets.all(4),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      child: Column(children: [
                                        Text(
                                          '${p.key ?? ''}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 4),
                                        Icon(Icons.print)
                                      ]),
                                    ),
                                  ))
                              .toList(),
                        ),

                        if ((loadingPrinters != null &&
                                loadingPrinters ==
                                    LoadingPrinters.notLoading) &&
                            (epsonPrinters.isNotEmpty))
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(left: 14, top: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Epson Printers',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        Wrap(
                          children: epsonPrinters
                              .map<Widget>((p) => InkWell(
                                    onTap: () {
                                      context.read<OrderPrinterBloC>().add(
                                          FetchStoreAddress(
                                              p.value!,
                                              widget.orderId,
                                              widget.proceedOrder,
                                              widget.orderDetail));
                                    },
                                    child: Container(
                                      width:
                                          (MediaQuery.of(context).size.width /
                                                  2) -
                                              10,
                                      margin: EdgeInsets.all(4),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      child: Column(children: [
                                        Text(
                                          '${p.key ?? ''}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 4),
                                        Icon(Icons.print)
                                      ]),
                                    ),
                                  ))
                              .toList(),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.all(20.0),
                        //   child: ElevatedButton(
                        //     style: ButtonStyle(
                        //         backgroundColor: MaterialStateProperty.all(
                        //             Theme.of(context).primaryColor),
                        //         shape:
                        //             MaterialStateProperty.all<RoundedRectangleBorder>(
                        //                 RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10.0),
                        //         ))),
                        //     onPressed: () {},
                        //     child: Padding(
                        //       padding: EdgeInsets.symmetric(vertical: 15),
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Text(
                        //             'Proceed to Feedback',
                        //             style: TextStyle(fontSize: 18),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 50),
                      ],
                    )),
                // if (state is OrderPrinterProgress)
                //    Center(child: CircularProgressIndicator())
              ],
            );
          })),
    );
  }
}
