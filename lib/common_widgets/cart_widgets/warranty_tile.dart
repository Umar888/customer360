import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/services/extensions/list_sorting.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:intl/intl.dart' as intl;

import '../../bloc/cart_bloc/cart_bloc.dart';
import '../../bloc/inventory_search_bloc/inventory_search_bloc.dart' as isb;
import '../../models/cart_model/cart_warranties_model.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';
import '../../services/storage/shared_preferences_service.dart';

class WarrantyTile extends StatefulWidget {
  Items items;
  int index;
  String userID;
  String orderID;
  CartBloc cartBloc;
  String orderLineItemID;
  String orderSkUID;
  CartState cartStateMain;

  WarrantyTile(
      {Key? key,
      required this.orderID,
      required this.orderSkUID,
      required this.index,
      required this.cartBloc,
      required this.items,
      required this.cartStateMain,
      required this.userID,
      required this.orderLineItemID})
      : super(key: key);

  @override
  State<WarrantyTile> createState() => _WarrantyTileState();
}

class _WarrantyTileState extends State<WarrantyTile>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  TextEditingController currentOverridePriceController =
      TextEditingController();
  TextEditingController oldOverridePriceController = TextEditingController();

  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
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

  @override
  initState() {
    super.initState();
    cartBloc = context.read<CartBloc>();
//    cartBloc.add(GetWarranties(skuEntId: widget.orderSkUID, index: widget.index));
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartBloc
        .add(GetWarranties(skuEntId: widget.orderSkUID, index: widget.index));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pro Coverage",
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontFamily: kRubik),
        ),
        SizedBox(height: 3),
        BlocConsumer<CartBloc, CartState>(listener: (context, cartState) {
          ///  cartBloc.add(GetWarranties(skuEntId: widget.orderSkUID, index: widget.index));
        }, builder: (context, cartState) {
          return widget.items.isUpdatingCoverage!
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Updating",
                      style: TextStyle(
                          fontSize: SizeSystem.size17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          fontFamily: kRubik),
                    ),
                  ],
                )
              : widget.items.isWarrantiesLoading!
                  ? Text(
                      "Please wait...",
                      style: TextStyle(
                          fontSize: SizeSystem.size17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          fontFamily: kRubik),
                    )
                  : widget.items.warranties!.isEmpty
                      ? Text(
                          "No Coverage Plans",
                          style: TextStyle(
                              fontSize: SizeSystem.size17,
                              fontWeight: FontWeight.w400,
                              color: ColorSystem.lavender3,
                              fontFamily: kRubik),
                        )
                      : InkWell(
                          onTap: () async {
                            // var recordID = await SharedPreferenceService().getValue(agentId);
                            // if(recordID.isEmpty){
                            //   showMessage(context: context,message:"Please select a customer");
                            // }
                            // else{
                            showCupertinoDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8.0,
                                    sigmaY: 8.0,
                                  ),
                                  child: CupertinoAlertDialog(
                                    actions: [
                                      Material(
                                        color: Colors.white30,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20.0),
                                                child: Text(
                                                  "Pro Coverage",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black54,
                                                height: 1,
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: widget
                                                    .items.warranties!
                                                    .sortedBy((it) => it.price!)
                                                    .map((Warranties value) {
                                                  int index = widget
                                                      .items.warranties!
                                                      .sortedBy(
                                                          (it) => it.price!)
                                                      .toList()
                                                      .indexOf(value);
                                                  return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            // var recordID = await SharedPreferenceService().getValue(agentId);
                                                            // if(recordID.isEmpty){
                                                            //   showMessage(context: context,message:"Please select a customer");
                                                            // }
                                                            // else{
                                                            Navigator.pop(
                                                                dialogContext);
                                                            if (value
                                                                .styleDescription1!
                                                                .isNotEmpty) {
                                                              cartBloc.add(ChangeWarranties(
                                                                  warrantyName:
                                                                      value
                                                                          .styleDescription1!,
                                                                  inventorySearchBloc:
                                                                      context.read<
                                                                          isb
                                                                              .InventorySearchBloc>(),
                                                                  warrantyPrice:
                                                                      value
                                                                          .price!
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  warrantyId:
                                                                      value.id!,
                                                                  index: widget
                                                                      .index,
                                                                  warranties:
                                                                      value,
                                                                  orderItem: widget
                                                                      .orderLineItemID,
                                                                  orderID: widget
                                                                      .orderID));
                                                            } else {
                                                              cartBloc.add(RemoveWarranties(
                                                                  warrantyName:
                                                                      value
                                                                          .styleDescription1!,
                                                                  inventorySearchBloc:
                                                                      context.read<
                                                                          isb
                                                                              .InventorySearchBloc>(),
                                                                  warrantyPrice:
                                                                      value
                                                                          .price!
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  warrantyId:
                                                                      value.id!,
                                                                  index: widget
                                                                      .index,
                                                                  warranties:
                                                                      value,
                                                                  orderItem: widget
                                                                      .orderLineItemID,
                                                                  orderID: widget
                                                                      .orderID));
                                                            }
                                                            //}
                                                          },
                                                          child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          15.0),
                                                              child:
                                                                  value.price ==
                                                                          0.0
                                                                      ? Text(
                                                                          "${value.displayName}",
                                                                          style: TextStyle(
                                                                              fontSize: SizeSystem.size18,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: widget.items.warrantyDisplayName == value.displayName ? Colors.blue : Colors.black87,
                                                                              fontFamily: kRubik),
                                                                        )
                                                                      : Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              "${value.styleDescription1!.replaceAll("-", "")}: ",
                                                                              style: TextStyle(fontSize: SizeSystem.size18, fontWeight: FontWeight.w400, color: widget.items.warrantyId == value.id ? Colors.blue : Colors.black87, fontFamily: kRubik),
                                                                            ),
                                                                            Text(
                                                                              "\$" + amountFormatting(value.price!),
                                                                              style: TextStyle(fontSize: SizeSystem.size18, fontWeight: FontWeight.w400, color: widget.items.warrantyId == value.id ? Colors.blue : Colors.black87, fontFamily: kRubik),
                                                                            ),
                                                                          ],
                                                                        )),
                                                        ),
                                                        index ==
                                                                widget.items
                                                                        .warranties!
                                                                        .sortedBy((it) =>
                                                                            it.price!)
                                                                        .toList()
                                                                        .length -
                                                                    1
                                                            ? SizedBox.shrink()
                                                            : Divider(
                                                                color: Colors
                                                                    .black54,
                                                                height: 1,
                                                              ),
                                                      ]);
                                                }).toList(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            //}
                          },
                          child: Row(
                            children: [
                              widget.items.warrantyId!.isEmpty &&
                                      widget.items.warrantyDisplayName!.isEmpty
                                  ? Text(
                                      "+ Add Pro Coverage",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: ColorSystem.lavender3,
                                          fontFamily: kRubik),
                                    )
                                  : widget.items.warrantyId!.isEmpty &&
                                          widget.items.warrantyDisplayName!
                                              .isNotEmpty
                                      ? Text(
                                          "${widget.items.warrantyDisplayName!}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: ColorSystem.lavender3,
                                              fontFamily: kRubik),
                                        )
                                      : Row(
                                          children: [
                                            Text(
                                              "${widget.items.warrantyStyleDesc!.replaceAll("ONTH", "")}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorSystem.lavender3,
                                                  fontFamily: kRubik),
                                            ),
                                            Text(
                                              " @ \$${widget.items.warrantyPrice}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorSystem.lavender3,
                                                  fontFamily: kRubik),
                                            ),
                                          ],
                                        ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.expand_more_outlined,
                                  color: Theme.of(context).primaryColor)
                            ],
                            // icon: Icon(Icons.expand_more_outlined,color: Theme.of(context).primaryColor),
                            // hint:  widget.items.warrantyId!.isEmpty?
                            // Text(
                            //   "Select Plan",
                            //   style: TextStyle(
                            //       fontSize:
                            //       SizeSystem.size17,
                            //       fontWeight: FontWeight.w500,
                            //       color: Colors.black,
                            //       fontFamily: kRubik),
                            // ):
                            // Row(
                            //   children: [
                            //     Text(
                            //       "${widget.items.warrantyStyleDesc!.replaceAll("ONTH", "")}",
                            //       style: TextStyle(
                            //           fontSize:
                            //           SizeSystem.size17,
                            //           fontWeight: FontWeight.w500,
                            //           color: Colors.blue,
                            //           fontFamily: kRubik),
                            //     ),
                            //     Text(
                            //       " @ ${widget.items.warrantyPrice}",
                            //       style: TextStyle(
                            //           fontSize:
                            //           SizeSystem.size17,
                            //           fontWeight: FontWeight.w500,
                            //           color: Colors.black,
                            //           fontFamily: kRubik),
                            //     ),
                            //   ],
                            // ),
                            // underline: Container(),
                            // isExpanded: true,
                            // isDense: true,
                            // items: widget.items.warranties!.sortedBy((it) => it.price!).map((Warranties value) {
                            //   return DropdownMenuItem<Warranties>(
                            //
                            //     value: value,
                            //     child: value.styleDescription1!.isNotEmpty?
                            //     Row(
                            //       children: [
                            //         Flexible(
                            //           child: Text(
                            //             "${value.styleDescription1??""}",
                            //             style: TextStyle(
                            //                 fontSize:
                            //                 SizeSystem.size17,
                            //                 fontWeight: FontWeight.w500,
                            //                 color: Colors.blue,
                            //                 fontFamily: kRubik),
                            //           ),
                            //         ),
                            //         Text(
                            //           " @ ${value.price}",
                            //           style: TextStyle(
                            //               fontSize:
                            //               SizeSystem.size17,
                            //               fontWeight: FontWeight.w500,
                            //               color: Colors.black,
                            //               fontFamily: kRubik),
                            //         ),
                            //       ],
                            //     ):
                            //     Text(
                            //       "${value.displayName??""}",
                            //       style: TextStyle(
                            //           fontSize:
                            //           SizeSystem.size17,
                            //           fontWeight: FontWeight.w500,
                            //           color: Colors.black,
                            //           fontFamily: kRubik),
                            //     ),
                            //   );
                            // }).toList(),
                            // onChanged: (_) async{
                            //   if(_!.styleDescription1!.isNotEmpty){
                            //     cartBloc.add(ChangeWarranties(warrantyName: _.styleDescription1! ,warrantyPrice: _.price!.toStringAsFixed(2),warrantyId: _.id!,index: widget.index,warranties: _,orderItem: widget.orderLineItemID,orderID: widget.orderID));
                            //   }
                            //   else{
                            //   cartBloc.add(RemoveWarranties(warrantyName: _.styleDescription1! ,warrantyPrice: _.price!.toStringAsFixed(2),warrantyId: _.id!,index: widget.index,warranties: _,orderItem: widget.orderLineItemID,orderID: widget.orderID));
                            // }},
                          ),
                        );
        }),
      ],
    );
  }
}
