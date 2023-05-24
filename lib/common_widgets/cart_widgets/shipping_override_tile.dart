import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:intl/intl.dart' as intl;


import '../../bloc/cart_bloc/cart_bloc.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';
import '../../services/storage/shared_preferences_service.dart';
import '../state_city_picker/dropdown_with_search.dart';

class ShippingOverrideTile extends StatefulWidget {
  String userID;
  String orderID;
  CartBloc cartBloc;
  String orderLineItemID;

  ShippingOverrideTile(
      {Key? key,
      required this.orderID,
      required this.cartBloc,
      required this.userID,
      required this.orderLineItemID})
      : super(key: key);

  @override
  State<ShippingOverrideTile> createState() => _ShippingOverrideTileState();
}

class _ShippingOverrideTileState extends State<ShippingOverrideTile>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  TextEditingController currentOverridePriceController =
      TextEditingController();
  TextEditingController oldOverridePriceController = TextEditingController();
  FocusNode textField = FocusNode();
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  bool readOnly = false;

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  late CartBloc cartBloc;

  @override
  initState() {
    super.initState();
    cartBloc = context.read<CartBloc>();
//    cartBloc.add(GetShippingOverrideReasons());
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(builder: (context, cartStateMain) {
      var shippingAndHandlingPrice = cartStateMain
          .orderDetailModel[0].shippingAndHandling!
          .toStringAsFixed(2);
      bool isApproved =
          cartStateMain.orderDetailModel[0].approvalRequest! == "Approved";
      if (isApproved) {
        shippingAndHandlingPrice =
            (cartStateMain.orderDetailModel[0].shippingAndHandling! -
                    cartStateMain.orderDetailModel[0].shippingAdjustment!)
                .toStringAsFixed(2);
      }
      var requestText = cartStateMain.orderDetailModel[0].approvalRequest;
      return cartStateMain.orderDetailModel[0].shippingAndHandling! > 0
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Shipping and Handling",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: kRubik),
                        ),
                        if (isApproved)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              "(\$${cartStateMain.orderDetailModel[0].shippingAndHandling!.toStringAsFixed(2)})",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.red,
                                fontFamily: kRubik,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      r"$" + "$shippingAndHandlingPrice",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: kRubik),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cartStateMain.smallLoading &&
                            cartStateMain.smallLoadingId == widget.orderID
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: CupertinoActivityIndicator(
                                color: ColorSystem.lavender3),
                          )
                        : Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (cartStateMain.orderDetailModel[0]
                                      .approvalRequest!.isNotEmpty) {
                                    showCupertinoDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 8.0,
                                            sigmaY: 8.0,
                                          ),
                                          child: BlocProvider.value(
                                            value: cartBloc,
                                            child: BlocBuilder<CartBloc,
                                                    CartState>(
                                                builder: (_context, stateCart) {
                                              return CupertinoAlertDialog(
                                                title: Text(
                                                  "Delete Override Price",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: Material(
                                                  color: Colors.transparent,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 10),
                                                      Text(
                                                        "Are you sure, you want to delete override price?",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  CupertinoDialogAction(
                                                      child: Text("OK"),
                                                      onPressed: () async {
                                                        Navigator.of(
                                                                dialogContext)
                                                            .pop();
                                                        var loggedInUserId =
                                                            await SharedPreferenceService()
                                                                .getValue(
                                                                    loggedInAgentId);
                                                        cartBloc.add(
                                                            ResetShippingOverrideReason(
                                                          orderID:
                                                              widget.orderID,
                                                          userID:
                                                              loggedInUserId,
                                                          onException: () =>
                                                              Navigator.pop(
                                                                  dialogContext),
                                                        ));
                                                      }),
                                                  CupertinoDialogAction(
                                                    child: Text("CANCEL"),
                                                    onPressed: () {
                                                      Navigator.of(
                                                              dialogContext)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    setState(() {
                                      oldOverridePriceController.text =
                                          cartStateMain.orderDetailModel[0]
                                              .shippingAndHandling!
                                              .toStringAsFixed(2)
                                              .toString();
                                    });

                                    cartBloc.add(GetShippingOverrideReasons());
                                    showModalBottomSheet(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Scaffold(
                                              backgroundColor: Colors.transparent,
                                              body: Align(
                                              alignment: Alignment.bottomCenter,
                                            child: StatefulBuilder(
                                                builder: (context, bottomState) {
                                              return BlocProvider.value(
                                                value: cartBloc,
                                                child: BlocBuilder<CartBloc,
                                                        CartState>(
                                                    builder:
                                                        (context, cartState) {
                                                  return Padding(
                                                    padding:
                                                        MediaQuery.of(context)
                                                            .viewInsets,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          30.0),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          30.0)),
                                                          color: Colors.white),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(30.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          "S & H Override",
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                                  SizeSystem.size20,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: ColorSystem.primary,
                                                                              fontFamily: kRubik)),
                                                                      SizedBox(
                                                                        height: 3,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                cartStateMain
                                                                        .orderDetailModel[
                                                                            0]
                                                                        .approvalRequest!
                                                                        .isNotEmpty
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showCupertinoDialog(
                                                                            barrierDismissible:
                                                                                true,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext dialogContext) {
                                                                              return BackdropFilter(
                                                                                filter: ImageFilter.blur(
                                                                                  sigmaX: 8.0,
                                                                                  sigmaY: 8.0,
                                                                                ),
                                                                                child: BlocProvider.value(
                                                                                  value: cartBloc,
                                                                                  child: BlocBuilder<CartBloc, CartState>(builder: (_context, stateCart) {
                                                                                    return CupertinoAlertDialog(
                                                                                      title: Text(
                                                                                        "Delete Override Price",
                                                                                        style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                      content: Material(
                                                                                        color: Colors.transparent,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            SizedBox(height: 10),
                                                                                            Text(
                                                                                              "Are you sure, you want to delete override price?",
                                                                                              textAlign: TextAlign.center,
                                                                                              style: TextStyle(
                                                                                                color: Colors.black87,
                                                                                                fontSize: 16,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      actions: [
                                                                                        CupertinoDialogAction(
                                                                                            child: Text("OK"),
                                                                                            onPressed: () async {
                                                                                              Navigator.of(dialogContext).pop();
                                                                                              var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
                                                                                              cartBloc.add(ResetShippingOverrideReason(
                                                                                                orderID: widget.orderID,
                                                                                                userID: loggedInUserId,
                                                                                                onException: () => Navigator.pop(context),
                                                                                              ));
                                                                                            }),
                                                                                        CupertinoDialogAction(
                                                                                          child: Text("CANCEL"),
                                                                                          onPressed: () {
                                                                                            Navigator.of(dialogContext).pop();
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  }),
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            SvgPicture
                                                                                .asset(
                                                                              IconSystem.deleteIcon,
                                                                              package:
                                                                                  'gc_customer_app',
                                                                              color:
                                                                                  ColorSystem.lavender3,
                                                                              width:
                                                                                  16,
                                                                            ),
                                                                            SizedBox(
                                                                              width:
                                                                                  5,
                                                                            ),
                                                                            Text(
                                                                              "Delete",
                                                                              style: TextStyle(
                                                                                  fontSize: SizeSystem.size15,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: ColorSystem.lavender3,
                                                                                  fontFamily: kRubik),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            SizedBox(height: 10),
                                                            cartState
                                                                    .isOverrideLoading
                                                                ? DropdownWithSearch(
                                                                    textEditingController:
                                                                        null,
                                                                    title:
                                                                        "Please wait...",
                                                                    placeHolder:
                                                                        "Search reasons",
                                                                    contentPadding:
                                                                        EdgeInsets.symmetric(
                                                                            vertical:
                                                                                20),
                                                                    selectedItemStyle: TextStyle(
                                                                        fontFamily:
                                                                            kRubik,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            16),
                                                                    labelStyle:
                                                                        TextStyle(
                                                                      color: ColorSystem
                                                                          .greyDark,
                                                                      fontSize:
                                                                          SizeSystem
                                                                              .size18,
                                                                    ),
                                                                    validator:
                                                                        null,
                                                                    dropdownHeadingStyle: TextStyle(
                                                                        fontFamily:
                                                                            kRubik,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20),
                                                                    itemStyle: TextStyle(
                                                                        fontFamily:
                                                                            kRubik,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        fontSize:
                                                                            15),
                                                                    decoration:
                                                                        null,
                                                                    disabledDecoration:
                                                                        null,
                                                                    disabled:
                                                                        true,
                                                                    dialogRadius:
                                                                        20,
                                                                    searchBarRadius:
                                                                        10,
                                                                    label:
                                                                        "Search reasons",
                                                                    items: [],
                                                                    selected:
                                                                        cartState
                                                                            .selectedOverrideReasons,
                                                                    onChanged:
                                                                        (value) {},
                                                                  )
                                                                : DropdownWithSearch(
                                                                    textEditingController:
                                                                        null,
                                                                    title:
                                                                        "Shipping Override",
                                                                    placeHolder:
                                                                        "Search reasons",
                                                                    contentPadding:
                                                                        EdgeInsets.symmetric(
                                                                            vertical:
                                                                                20),
                                                                    selectedItemStyle: TextStyle(
                                                                        fontFamily:
                                                                            kRubik,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            16),
                                                                    labelStyle:
                                                                        TextStyle(
                                                                      color: ColorSystem
                                                                          .greyDark,
                                                                      fontSize:
                                                                          SizeSystem
                                                                              .size18,
                                                                    ),
                                                                    validator:
                                                                        null,
                                                                    dropdownHeadingStyle: TextStyle(
                                                                        fontFamily:
                                                                            kRubik,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20),
                                                                    itemStyle: TextStyle(
                                                                        fontFamily:
                                                                            kRubik,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        fontSize:
                                                                            15),
                                                                    decoration:
                                                                        null,
                                                                    disabledDecoration:
                                                                        null,
                                                                    disabled:
                                                                        cartState.overrideReasons.length ==
                                                                                0
                                                                            ? true
                                                                            : false,
                                                                    dialogRadius:
                                                                        20,
                                                                    searchBarRadius:
                                                                        10,
                                                                    label:
                                                                        "Search reasons",
                                                                    items: cartState
                                                                        .overrideReasons
                                                                        .map((String?
                                                                            dropDownStringItem) {
                                                                      return dropDownStringItem;
                                                                    }).toList(),
                                                                    selected:
                                                                        cartState
                                                                            .selectedOverrideReasons,
                                                                    onChanged:
                                                                        (value) {
                                                                      if (value !=
                                                                          null) {
                                                                        cartBloc.add(ChangeOverrideReason(
                                                                            reason:
                                                                                value ?? ""));
                                                                      }
                                                                    },
                                                                  ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            TextFormField(
                                                              autofocus: false,
                                                              cursorColor: Theme
                                                                      .of(context)
                                                                  .primaryColor,
                                                              focusNode:
                                                                  textField,
                                                              onEditingComplete:
                                                                  textField
                                                                      .unfocus,
                                                              controller:
                                                                  currentOverridePriceController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .numberWithOptions(
                                                                          decimal:
                                                                              true),
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        r'^\d+\.?\d{0,2}')),
                                                              ],
                                                              readOnly: readOnly,
                                                              onTap: () {
                                                                bottomState(() {
                                                                  readOnly =
                                                                      false;
                                                                });
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Enter discount amount',
                                                                constraints:
                                                                    BoxConstraints(),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            0),
                                                                labelStyle:
                                                                    TextStyle(
                                                                  color: ColorSystem
                                                                      .greyDark,
                                                                  fontSize:
                                                                      SizeSystem
                                                                          .size18,
                                                                ),
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: ColorSystem
                                                                        .greyDark,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            TextFormField(
                                                              autofocus: false,
                                                              readOnly: true,
                                                              cursorColor: Theme
                                                                      .of(context)
                                                                  .primaryColor,
                                                              controller:
                                                                  oldOverridePriceController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Actual Shipping Price',
                                                                constraints:
                                                                    BoxConstraints(),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            0),
                                                                labelStyle:
                                                                    TextStyle(
                                                                  color: ColorSystem
                                                                      .greyDark,
                                                                  fontSize:
                                                                      SizeSystem
                                                                          .size18,
                                                                ),
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: ColorSystem
                                                                        .greyDark,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 30,
                                                            ),
                                                            ElevatedButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all(
                                                                          ColorSystem
                                                                              .primaryTextColor),
                                                                  shape: MaterialStateProperty.all<
                                                                          RoundedRectangleBorder>(
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10.0),
                                                                  ))),
                                                              onPressed:
                                                                  () async {
                                                                if (cartState
                                                                    .selectedOverrideReasons
                                                                    .isEmpty) {
                                                                  showMessage(context: context,message:
                                                                      "Please select override reason");
                                                                } else if (currentOverridePriceController
                                                                    .text
                                                                    .isEmpty) {
                                                                  showMessage(context: context,message:
                                                                      "Please enter discount amount");
                                                                }
                                                                // else if (cartStateMain
                                                                //     .orderDetailModel[0]
                                                                //
                                                                //     .approvalRequest! == "Approved" && double.parse(currentOverridePriceController.text) >
                                                                //     cartStateMain
                                                                //         .orderDetailModel[0]
                                                                //         .shippingAdjustment!) {
                                                                //   showMessage(context: context,message:
                                                                //       "Override price cannot be more then actual price");
                                                                // }
                                                                else if (double.parse(
                                                                        currentOverridePriceController
                                                                            .text) >
                                                                    cartStateMain
                                                                        .orderDetailModel[
                                                                            0]
                                                                        .shippingAndHandling!) {
                                                                  showMessage(context: context,message:
                                                                      "Override price cannot be more then actual price");
                                                                } else {
                                                                  var loggedInUserId =
                                                                      await SharedPreferenceService()
                                                                          .getValue(
                                                                              loggedInAgentId);
                                                                  cartBloc.add(
                                                                      SendShippingOverrideReason(
                                                                    orderID: widget
                                                                        .orderID,
                                                                    requestedAmount:
                                                                        double.parse(
                                                                                currentOverridePriceController.text)
                                                                            .toString(),
                                                                    selectedOverrideReasons:
                                                                        cartState
                                                                            .selectedOverrideReasons,
                                                                    userID:
                                                                        loggedInUserId,
                                                                    onCompleted: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                  ));
                                                                }
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            15),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    cartState
                                                                            .isOverrideSubmitting
                                                                        ? CupertinoActivityIndicator(
                                                                            color:
                                                                                Colors.white,
                                                                          )
                                                                        : Text(
                                                                            'Send Request',
                                                                            style:
                                                                                TextStyle(fontSize: 18),
                                                                          ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              );
                                            })),
                                          );
                                        }).whenComplete(() {
                                      currentOverridePriceController.clear();
                                      oldOverridePriceController.clear();
                                      cartBloc.add(
                                          ChangeOverrideReason(reason: ""));
                                      cartBloc.add(ClearOverrideReasonList());
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      IconSystem.overrideReset,
                                      package: 'gc_customer_app',
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      cartStateMain.orderDetailModel[0]
                                              .approvalRequest!.isNotEmpty
                                          ? "Reset"
                                          : "Override",
                                      style: TextStyle(
                                          fontSize: SizeSystem.size15,
                                          fontWeight: FontWeight.w400,
                                          color: ColorSystem.lavender3,
                                          fontFamily: kRubik),
                                    ),
                                  ],
                                ),
                              ),
                              if ((requestText ?? '').isNotEmpty &&
                                  requestText == 'Initiated')
                                InkWell(
                                  onTap: () => cartBloc
                                      .add(RefreshShippingOverrideReason(
                                    orderID: widget.orderID,
                                    onException: () => Navigator.pop(context),
                                  )),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Row(
                                      children: [
                                        // SvgPicture.asset(IconSystem.overrideReset),
                                        Image.asset(
                                          IconSystem.refreshIcon,
                                          package: 'gc_customer_app',
                                          height: 16,
                                          color: ColorSystem.lavender,
                                        ),
                                        // Icon(Icons.refre)
                                        SizedBox(width: 2),
                                        Text(
                                          "Refresh",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size15,
                                              fontWeight: FontWeight.w400,
                                              color: ColorSystem.lavender3,
                                              fontFamily: kRubik),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                    cartStateMain.orderDetailModel[0].approvalRequest!
                                .isNotEmpty &&
                            cartStateMain.orderDetailModel[0].approvalRequest!
                                .contains("Approve")
                        ? Text(
                            "S&H Override Approved",
                            style: TextStyle(
                                fontSize: SizeSystem.size14,
                                fontWeight: FontWeight.w400,
                                color: ColorSystem.additionalGreen,
                                fontFamily: kRubik),
                          )
                        : cartStateMain.orderDetailModel[0].approvalRequest!
                                    .isNotEmpty &&
                                cartStateMain
                                    .orderDetailModel[0].approvalRequest!
                                    .contains("Reject")
                            ? Text(
                                "S&H Override Rejected",
                                style: TextStyle(
                                    fontSize: SizeSystem.size14,
                                    fontWeight: FontWeight.w400,
                                    color: ColorSystem.complimentary,
                                    fontFamily: kRubik),
                              )
                            : cartStateMain.orderDetailModel[0].approvalRequest!
                                    .isNotEmpty
                                ? Text(
                                    "S&H Override ${cartStateMain.orderDetailModel[0].approvalRequest!}",
                                    style: TextStyle(
                                        fontSize: SizeSystem.size14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.orange,
                                        fontFamily: kRubik),
                                  )
                                : SizedBox()
                  ],
                )
              ],
            )
          : SizedBox.shrink();
    });
  }
}
