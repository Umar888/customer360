import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:intl/intl.dart' as intl;


import '../../bloc/cart_bloc/cart_bloc.dart';
import '../../bloc/inventory_search_bloc/inventory_search_bloc.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';
import '../../services/storage/shared_preferences_service.dart';
import '../state_city_picker/dropdown_with_search.dart';
import 'custom_switch.dart';

class OverrideTile extends StatefulWidget {
  Items items;
  String userID;
  String orderID;
  CartBloc cartBloc;
  String orderLineItemID;

  OverrideTile(
      {Key? key,
      required this.orderID,
      required this.cartBloc,
      required this.items,
      required this.userID,
      required this.orderLineItemID})
      : super(key: key);

  @override
  State<OverrideTile> createState() => _OverrideTileState();
}

class _OverrideTileState extends State<OverrideTile>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  String discountedMargin = "";
  String discountedMarginPercentage = "";
  late Animation<double> _iconTurns;
  TextEditingController currentOverridePriceController =
      TextEditingController();
  TextEditingController oldOverridePriceController = TextEditingController();
  TextEditingController initialOverridePriceController =
      TextEditingController();
  FocusNode textField = FocusNode();

  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  late CartBloc cartBloc;

  double calculateMarginValues(
      String cost, String overridePrice, String originalMarginValue) {
    double discountedMarginValue =
        double.parse(overridePrice) - double.parse(cost);
    return discountedMarginValue;
  }

  double calculateMarginPercentageValues(String overridePrice, String cost) {
    double discountedMarginPercentageValue =
        ((double.parse(overridePrice) - double.parse(cost)) /
                double.parse(overridePrice)) *
            100;
    print("cost $cost");
    print("overridePrice $overridePrice");
    print("discountedMarginPercentageValue ${discountedMarginPercentageValue}");
    return discountedMarginPercentageValue;
  }

  @override
  initState() {
    super.initState();
    cartBloc = context.read<CartBloc>();
//    cartBloc.add(GetOverrideReasons());
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(builder: (context, cartStateMain) {
      var overridePricePercent = (100 -
          ((widget.items.overridePrice! / widget.items.unitPrice!.toDouble()) *
              100));
      return InkWell(
        onTap: (cartStateMain.orderDetailModel[0].items!
                        .firstWhere(
                            (element) => element.itemId == widget.items.itemId)
                        .overridePriceApproval !=
                    null &&
                cartStateMain.orderDetailModel[0].items!
                    .firstWhere(
                        (element) => element.itemId == widget.items.itemId)
                    .overridePriceApproval!
                    .isNotEmpty)
            ? () async {
                // var recordID = await SharedPreferenceService().getValue(agentId);
                // if(recordID.isEmpty){
                //   showMessage(context: context,message:"Please select a customer");
                // }
                // else{
                cartBloc.add(ChangeIsExpanded(
                    value: cartStateMain.orderDetailModel[0].items!
                            .firstWhere((element) =>
                                element.itemId == widget.items.itemId)
                            .isExpanded!
                        ? false
                        : true,
                    item: cartStateMain.orderDetailModel[0].items!.firstWhere(
                        (element) => element.itemId == widget.items.itemId)));
                setState(() {});
                //      }
              }
            : () async {
                // var recordID = await SharedPreferenceService().getValue(agentId);
                // if(recordID.isEmpty){
                //   showMessage(context: context,message:"Please select a customer");
                // }
                // else{
                initialOverridePriceController.text = r"$" +
                    cartStateMain.orderDetailModel[0].items!
                        .firstWhere(
                            (element) => element.itemId == widget.items.itemId)
                        .unitPrice!
                        .toStringAsFixed(2)
                        .toString();
                cartBloc.add(GetOverrideReasons());
                showModalBottomSheet(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Align(
                          alignment: Alignment.bottomCenter,
                          child: StatefulBuilder(builder: (context, bottomState) {
                              return BlocProvider.value(
                                value: cartBloc,
                                child: BlocBuilder<CartBloc, CartState>(
                                    builder: (context, cartState) {
                                  return Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(30.0),
                                              topLeft: Radius.circular(30.0)),
                                          color: Colors.white),
                                      child:  Padding(
                                          padding: EdgeInsets.all(30.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Override Price",
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    SizeSystem.size20,
                                                                overflow: TextOverflow
                                                                    .ellipsis,
                                                                fontWeight:
                                                                    FontWeight.w500,
                                                                color: Theme.of(context)
                                                                    .primaryColor,
                                                                fontFamily: kRubik)),
                                                        SizedBox(
                                                          height: 3,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text("Margin: ",
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    fontSize: SizeSystem
                                                                        .size18,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    color: ColorSystem
                                                                        .primary,
                                                                    fontFamily:
                                                                        kRubik)),
                                                            Text(
                                                                "${widget.items.cost != null ? "${widget.items.marginValue.toString().contains("-") ? "-\$" + widget.items.marginValue!.toStringAsFixed(2).toString().replaceAll("-", "") : "\$" + widget.items.marginValue!.toStringAsFixed(2).toString()}" : "N/A"}",
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    fontSize: SizeSystem
                                                                        .size18,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    color: ColorSystem
                                                                        .primary,
                                                                    fontFamily:
                                                                        kRubik)),
                                                            Text(
                                                                ", ${widget.items.cost != null ? widget.items.margin.toString() + "%" : "0.0%"}",
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    fontSize: SizeSystem
                                                                        .size18,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    color: ColorSystem
                                                                        .primary,
                                                                    fontFamily:
                                                                        kRubik)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  CustomSwitch(
                                                    value: cartStateMain
                                                        .orderDetailModel[0].items!
                                                        .firstWhere((element) =>
                                                            element.itemId ==
                                                            widget.items.itemId)
                                                        .isOverridden!,
                                                    onChanged: (v) {
                                                      cartBloc.add(ChangeIsOverridden(
                                                          value: v,
                                                          item: cartStateMain
                                                              .orderDetailModel[0]
                                                              .items!
                                                              .firstWhere((element) =>
                                                                  element.itemId ==
                                                                  widget
                                                                      .items.itemId)));
                                                      bottomState(() {});
                                                    },
                                                    activeText: Icon(
                                                      Icons.attach_money,
                                                      color: Colors.white,
                                                    ),
                                                    activeColor:
                                                        Theme.of(context).primaryColor,
                                                    inactiveColor:
                                                        Theme.of(context).primaryColor,
                                                    inactiveText: Icon(
                                                      Icons.percent_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Row(
                                                children: [
                                                  Text("Disc Margin: ",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: SizeSystem.size16,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                          fontWeight: FontWeight.w500,
                                                          color: Theme.of(context)
                                                              .primaryColor,
                                                          fontFamily: kRubik)),
                                                  Text(
                                                      "${currentOverridePriceController.text.isNotEmpty && widget.items.cost != null ? calculateMarginValues((widget.items.cost ?? 0.0).toString(), widget.items.isOverridden! ? currentOverridePriceController.text : (widget.items.unitPrice! * ((100 - double.parse(currentOverridePriceController.text)) / 100)).toString(), widget.items.marginValue.toString()).toString().contains("-") ? "-\$${calculateMarginValues((widget.items.cost ?? 0.0).toString(), widget.items.isOverridden! ? currentOverridePriceController.text : (widget.items.unitPrice! * ((100 - double.parse(currentOverridePriceController.text)) / 100)).toString(), widget.items.marginValue.toString()).toStringAsFixed(2).replaceAll("-", "")}" : "\$${calculateMarginValues((widget.items.cost ?? 0.0).toString(), widget.items.isOverridden! ? currentOverridePriceController.text : (widget.items.unitPrice! * ((100 - double.parse(currentOverridePriceController.text)) / 100)).toString(), widget.items.marginValue.toString()).toStringAsFixed(2)}" : (cartStateMain.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePriceApproval != null && cartStateMain.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePriceApproval!.isNotEmpty) && widget.items.cost != null ? "${widget.items.discountedMarginValue.toString().contains("-") ? "-\$" + widget.items.discountedMarginValue!.toStringAsFixed(2).toString().replaceAll("-", "") : "\$" + widget.items.discountedMarginValue!.toStringAsFixed(2).toString()}" : "N/A"}",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: SizeSystem.size18,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                          fontWeight: FontWeight.w500,
                                                          color: Theme.of(context)
                                                              .primaryColor,
                                                          fontFamily: kRubik)),
                                                  Text(
                                                      currentOverridePriceController
                                                                  .text.isNotEmpty &&
                                                              widget.items.cost != null
                                                          ? ", " +
                                                              calculateMarginPercentageValues(
                                                                      widget.items
                                                                              .isOverridden!
                                                                          ? currentOverridePriceController
                                                                              .text
                                                                          : (widget.items
                                                                                      .unitPrice! *
                                                                                  ((100 - double.parse(currentOverridePriceController.text)) /
                                                                                      100))
                                                                              .toString(),
                                                                      widget.items.cost
                                                                          .toString())
                                                                  .toStringAsFixed(2) +
                                                              " %"
                                                          : ", ${(cartStateMain.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePriceApproval != null && cartStateMain.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePriceApproval!.isNotEmpty) && widget.items.cost != 0.0 ? widget.items.discountedMargin!.toStringAsFixed(2).toString() + "%" : "0.0%"}",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: SizeSystem.size18,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                          fontWeight: FontWeight.w500,
                                                          color: Theme.of(context)
                                                              .primaryColor,
                                                          fontFamily: kRubik)),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              cartState.isOverrideLoading
                                                  ? DropdownWithSearch(
                                                      textEditingController: null,
                                                      title: "Please wait...",
                                                      placeHolder: "Search reasons",
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 20),
                                                      selectedItemStyle: TextStyle(
                                                          fontFamily: kRubik,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16),
                                                      labelStyle: TextStyle(
                                                        color: ColorSystem.greyDark,
                                                        fontSize: SizeSystem.size18,
                                                      ),
                                                      validator: null,
                                                      dropdownHeadingStyle: TextStyle(
                                                          fontFamily: kRubik,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20),
                                                      itemStyle: TextStyle(
                                                          fontFamily: kRubik,
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 15),
                                                      decoration: null,
                                                      disabledDecoration: null,
                                                      disabled: true,
                                                      dialogRadius: 20,
                                                      searchBarRadius: 10,
                                                      label: "Search reasons",
                                                      items: [],
                                                      selected: cartState
                                                          .selectedOverrideReasons,
                                                      onChanged: (value) {},
                                                    )
                                                  : DropdownWithSearch(
                                                      textEditingController: null,
                                                      title: "Override Reason",
                                                      placeHolder: "Search reasons",
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 20),
                                                      selectedItemStyle: TextStyle(
                                                          fontFamily: kRubik,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16),
                                                      labelStyle: TextStyle(
                                                        color: ColorSystem.greyDark,
                                                        fontSize: SizeSystem.size18,
                                                      ),
                                                      validator: null,
                                                      dropdownHeadingStyle: TextStyle(
                                                          fontFamily: kRubik,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20),
                                                      itemStyle: TextStyle(
                                                          fontFamily: kRubik,
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 15),
                                                      decoration: null,
                                                      disabledDecoration: null,
                                                      disabled: cartState
                                                                  .overrideReasons
                                                                  .length ==
                                                              0
                                                          ? true
                                                          : false,
                                                      dialogRadius: 20,
                                                      searchBarRadius: 10,
                                                      label: "Search reasons",
                                                      items: cartState.overrideReasons
                                                          .map((String?
                                                              dropDownStringItem) {
                                                        return dropDownStringItem;
                                                      }).toList(),
                                                      selected: cartState
                                                          .selectedOverrideReasons,
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          cartBloc.add(
                                                              ChangeOverrideReason(
                                                                  reason: value ?? ""));
                                                        }
                                                      },
                                                    ),

/*                                      InputDecorator(
                                                      decoration: InputDecoration(
                                                          labelText:
                                                              'Select Override Reason',
                                                          hintText: 'Reason',
                                                          constraints: BoxConstraints(),
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                  vertical: 10,
                                                                  horizontal: 0),
                                                          labelStyle: TextStyle(
                                                            color: ColorSystem.greyDark,
                                                            fontSize: SizeSystem.size18,
                                                          ),
                                                          helperStyle: TextStyle(
                                                            color: ColorSystem.greyDark,
                                                            fontSize: SizeSystem.size18,
                                                          ),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  ColorSystem.greyDark,
                                                              width: 1,
                                                            ),
                                                          )),
                                                      isEmpty: cartState
                                                          .selectedOverrideReasons
                                                          .isEmpty,
                                                      child: DropdownButton<String>(
                                                        hint: Text(
                                                            cartState
                                                                .selectedOverrideReasons,
                                                            style: TextStyle(
                                                                color: ColorSystem
                                                                    .primary)),
                                                        icon: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10.0),
                                                          child: Icon(
                                                              Icons
                                                                  .expand_more_outlined,
                                                              color: ColorSystem
                                                                  .primaryTextColor),
                                                        ),
                                                        underline: Container(),
                                                        isExpanded: true,
                                                        isDense: true,
                                                        items: cartState.overrideReasons
                                                            .map((String value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: TextStyle(
                                                                  color: ColorSystem
                                                                      .primary),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (_) async {
                                                          cartBloc.add(ChangeOverrideReason(reason: _ ?? ""));
                                                        },
                                                      ),
                                                    ),*/
                                              SizedBox(
                                                height: 15,
                                              ),
                                              TextFormField(
                                                autofocus: false,
                                                cursorColor:
                                                    Theme.of(context).primaryColor,
                                                focusNode: textField,
                                                onEditingComplete: textField.unfocus,
                                                controller:
                                                    currentOverridePriceController,
                                                keyboardType:
                                                    TextInputType.numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                      RegExp(r'^\d+\.?\d{0,2}')),
                                                ],
/*
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                    try {
                                                      final text = newValue.text;
                                                      if (text.isNotEmpty) double.parse(text);
                                                      return newValue;
                                                    } catch (e) {}
                                                    return oldValue;
                                                  }),
                                                ],
*/
                                                onChanged: (value) {
                                                  bottomState(() {});
                                                  setState(() {});
                                                },
                                                decoration: InputDecoration(
                                                  labelText: cartStateMain
                                                          .orderDetailModel[0].items!
                                                          .firstWhere((element) =>
                                                              element.itemId ==
                                                              widget.items.itemId)
                                                          .isOverridden!
                                                      ? 'Enter New Price for Item'
                                                      : "Enter discount Percentage",
                                                  constraints: BoxConstraints(),
                                                  contentPadding: EdgeInsets.symmetric(
                                                      vertical: 10, horizontal: 0),
                                                  labelStyle: TextStyle(
                                                    color: ColorSystem.greyDark,
                                                    fontSize: SizeSystem.size18,
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: ColorSystem.greyDark,
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
                                                cursorColor:
                                                    Theme.of(context).primaryColor,
                                                controller:
                                                    initialOverridePriceController,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter.allow(
                                                      RegExp(r"[0-9.]")),
                                                  TextInputFormatter.withFunction(
                                                      (oldValue, newValue) {
                                                    try {
                                                      final text = newValue.text;
                                                      if (text.isNotEmpty)
                                                        double.parse(text);
                                                      return newValue;
                                                    } catch (e) {}
                                                    return oldValue;
                                                  }),
                                                ],
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Initial Price',
                                                  constraints: BoxConstraints(),
                                                  contentPadding: EdgeInsets.symmetric(
                                                      vertical: 10, horizontal: 0),
                                                  labelStyle: TextStyle(
                                                    color: ColorSystem.greyDark,
                                                    fontSize: SizeSystem.size18,
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: ColorSystem.greyDark,
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
                                                          BorderRadius.circular(10.0),
                                                    ))),
                                                onPressed: () async {
                                                  if (cartState.selectedOverrideReasons
                                                      .isEmpty) {
                                                    showMessage(context: context,message:
                                                        "Please select override reason");
                                                  } else if (currentOverridePriceController
                                                      .text.isEmpty) {
                                                    showMessage(context: context,message:
                                                        "Please enter override price");
                                                  } else if (cartStateMain
                                                          .orderDetailModel[0].items!
                                                          .firstWhere((element) =>
                                                              element.itemId ==
                                                              widget.items.itemId)
                                                          .isOverridden! &&
                                                      double.parse(
                                                              currentOverridePriceController
                                                                  .text) >
                                                          widget.items.unitPrice!) {
                                                    showMessage(context: context,message:
                                                        "Override price cannot be more then actual price");
                                                  } else if (!cartStateMain
                                                          .orderDetailModel[0].items!
                                                          .firstWhere((element) =>
                                                              element.itemId ==
                                                              widget.items.itemId)
                                                          .isOverridden! &&
                                                      double.parse(
                                                              currentOverridePriceController
                                                                  .text) >
                                                          100) {
                                                    showMessage(context: context,message:
                                                        "Override price cannot be more then actual price");
                                                  } else {
                                                    var loggedInUserId =
                                                        await SharedPreferenceService()
                                                            .getValue(loggedInAgentId);
                                                    print(
                                                        "loggedInAgentId $loggedInAgentId");
                                                    cartBloc.add(SendOverrideReason(
                                                      item: widget.items,
                                                      orderID: widget.orderID,
                                                      inventorySearchBloc: context
                                                          .read<InventorySearchBloc>(),
                                                      orderLineItemID:
                                                          widget.items.itemId!,
                                                      requestedAmount: widget
                                                              .items.isOverridden!
                                                          ? currentOverridePriceController
                                                              .text
                                                          : (widget.items.unitPrice! *
                                                                  ((100 -
                                                                          double.parse(
                                                                              currentOverridePriceController
                                                                                  .text)) /
                                                                      100))
                                                              .toString(),
                                                      selectedOverrideReasons: cartState
                                                          .selectedOverrideReasons,
                                                      userID: loggedInUserId,
                                                      onCompleted: () =>
                                                          Navigator.pop(context),
                                                    ));
                                                  }
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      cartState.isOverrideSubmitting
                                                          ? CupertinoActivityIndicator(
                                                              color: Colors.white,
                                                            )
                                                          : Text(
                                                              'Send Request',
                                                              style: TextStyle(
                                                                  fontSize: 18),
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
                            }),
                        ),
                      );
                    }).whenComplete(() {
                  currentOverridePriceController.clear();
                  oldOverridePriceController.clear();
                  initialOverridePriceController.clear();
                  cartBloc.add(ChangeOverrideReason(reason: ""));
                  cartBloc.add(ClearOverrideReasonList());
                });
                //    }
              },
        child: cartStateMain.orderDetailModel[0].items!
                .firstWhere((element) => element.itemId == widget.items.itemId)
                .isExpanded!
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Override Price",
                        style: TextStyle(
                            fontSize: SizeSystem.size17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF222222),
                            fontFamily: kRubik),
                      ),
                      RotationTransition(
                        turns: _iconTurns,
                        child: Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Override Reason",
                            style: TextStyle(
                                fontSize: SizeSystem.size17,
                                fontWeight: FontWeight.w400,
                                color: ColorSystem.greyDark,
                                fontFamily: kRubik),
                          ),
/*                          InkWell(
                            onTap: () {
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
                                      child: BlocBuilder<CartBloc, CartState>(
                                          builder: (context, stateCart) {
                                        return CupertinoAlertDialog(
                                          title: Text(
                                            "Delete Override Price",
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: Material(
                                            color: Colors.transparent,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Text(
                                                  "Are you sure, you want to delete this override price?",
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
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  cartBloc
                                                      .add(ResetOverrideReason(
                                                    item: widget.items,
                                                    orderID: widget.orderID,
                                                    context: context,
                                                    orderLineItemID:
                                                        widget.items.itemId!,
                                                    requestedAmount: cartStateMain
                                                        .orderDetailModel[0]
                                                        .
                                                        .items!
                                                        .firstWhere((element) =>
                                                            element.itemId ==
                                                            widget.items.itemId)
                                                        .overridePrice!
                                                        .toStringAsFixed(2),
                                                    selectedOverrideReasons:
                                                        widget.items
                                                            .overridePriceReason!,
                                                    userID: widget.userID,
                                                  ));
                                                }),
                                            CupertinoDialogAction(
                                              child: Text("CANCEL"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
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
                            child: SvgPicture.asset(
                              IconSystem.deleteIcon,
                              color: ColorSystem.lavender3,
                              width: 16,
                            ),
                          ),*/
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    fontSize: SizeSystem.size17,
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    color: ColorSystem.greyDark,
                                    fontFamily: kRubik),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          "${widget.items.overridePriceReason!} : "),
                                  TextSpan(
                                      text: r"$"
                                          "${cartStateMain.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePrice!.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: SizeSystem.size17,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context).primaryColor,
                                          fontFamily: kRubik)),
                                  TextSpan(
                                      text:
                                          ", ${(100 - ((widget.items.overridePrice! / widget.items.unitPrice!.toDouble()) * 100)).toStringAsFixed(2)}%",
                                      style: TextStyle(
                                          fontSize: SizeSystem.size17,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context).primaryColor,
                                          fontFamily: kRubik)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Request ${widget.items.overridePriceApproval}",
                                style: TextStyle(
                                    fontSize: SizeSystem.size17,
                                    fontWeight: FontWeight.w400,
                                    color: widget.items.overridePriceApproval!
                                            .toLowerCase()
                                            .contains("approve")
                                        ? Colors.green
                                        : widget.items.overridePriceApproval!
                                                .toLowerCase()
                                                .contains("reject")
                                            ? Colors.red
                                            : Colors.orange,
                                    fontFamily: kRubik),
                              ),
                              !cartStateMain.smallLoading &&
                                      widget.items.overridePriceApproval!
                                          .toLowerCase()
                                          .contains("initiated")
                                  ? InkWell(
                                      onTap: () {
                                        if (cartStateMain.smallLoading &&
                                            cartStateMain.smallLoadingId !=
                                                widget.items.productId!) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar(
                                                  "Please wait, cart reloading is already is progress"));
                                        } else {
                                          cartBloc.add(ReloadCart(
                                              orderID: widget.orderID,
                                              inventorySearchBloc: context
                                                  .read<InventorySearchBloc>(),
                                              smallLoading: true,
                                              smallLoadingId:
                                                  widget.items.productId!));
                                          setState(() {});
                                        }
                                      },
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
                                  : cartStateMain.smallLoading &&
                                          cartStateMain.smallLoadingId ==
                                              widget.items.productId!
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: CupertinoActivityIndicator(
                                              color: ColorSystem.lavender3),
                                        )
                                      : SizedBox.shrink(),
                            ],
                          ),
                          InkWell(
                            onTap: () {
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
                                      child: BlocBuilder<CartBloc, CartState>(
                                          builder: (_context, stateCart) {
                                        return CupertinoAlertDialog(
                                          title: Text(
                                            "Delete Override Price",
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: Material(
                                            color: Colors.transparent,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Text(
                                                  "Are you sure, you want to delete this override price?",
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
                                                onPressed: () {
                                                  Navigator.of(_context).pop();
                                                  cartBloc
                                                      .add(ResetOverrideReason(
                                                    item: widget.items,
                                                    orderID: widget.orderID,
                                                    inventorySearchBloc:
                                                        context.read<InventorySearchBloc>(),
                                                    orderLineItemID:
                                                        widget.items.itemId!,
                                                    requestedAmount: cartStateMain
                                                        .orderDetailModel[0]
                                                        .items!
                                                        .firstWhere((element) =>
                                                            element.itemId ==
                                                            widget.items.itemId)
                                                        .overridePrice!
                                                        .toStringAsFixed(2),
                                                    selectedOverrideReasons:
                                                        widget.items
                                                            .overridePriceReason!,
                                                    userID: widget.userID,
                                                  ));
                                                }),
                                            CupertinoDialogAction(
                                              child: Text("CANCEL"),
                                              onPressed: () {
                                                Navigator.of(_context).pop();
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  IconSystem.overrideReset,
                                  package: 'gc_customer_app',
                                  width: 16,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Reset",
                                  style: TextStyle(
                                      fontSize: SizeSystem.size17,
                                      fontWeight: FontWeight.w500,
                                      color: ColorSystem.lavender3,
                                      fontFamily: kRubik),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (cartStateMain.orderDetailModel[0].items!
                                  .firstWhere((element) =>
                                      element.itemId == widget.items.itemId)
                                  .overridePriceApproval !=
                              null &&
                          cartStateMain.orderDetailModel[0].items!
                              .firstWhere((element) =>
                                  element.itemId == widget.items.itemId)
                              .overridePriceApproval!
                              .isNotEmpty)
                      ? Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Override Price : ",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF222222),
                                    fontFamily: kRubik),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(
                                  r"$" "${cartStateMain.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePrice!.toStringAsFixed(2)}, " +
                                      "${overridePricePercent.toShortPercent()}% - ${widget.items.overridePriceApproval ?? ""}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: widget.items.overridePriceApproval!
                                              .toLowerCase()
                                              .contains("approve")
                                          ? Colors.green
                                          : widget.items.overridePriceApproval!
                                                  .toLowerCase()
                                                  .contains("reject")
                                              ? Colors.red
                                              : Colors.orange,
                                      fontFamily: kRubik),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          "Override Price",
                          style: TextStyle(
                              fontSize: SizeSystem.size17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                        ),
                  Icon(Icons.keyboard_arrow_right)
                ],
              ),
      );
    });
  }

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.075,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }
}
