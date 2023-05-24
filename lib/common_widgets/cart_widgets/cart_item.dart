import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as pdb;
import 'package:gc_customer_app/common_widgets/cart_widgets/warranty_tile.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/screens/google_map/get_address_from_map.dart';
import 'package:gc_customer_app/screens/product_detail/product_detail_page.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:gc_customer_app/utils/get_user_location.dart';
import 'package:intl/intl.dart' as intl;

import '../../bloc/cart_bloc/cart_bloc.dart';
import '../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';
import 'override_tile.dart';

class CartItem extends StatefulWidget {
  Items items;
  String userID;
  CustomerInfoModel customerInfoModel;
  String orderID;
  String orderLineItemID;
  CartBloc cartBloc;

  CartItem(
      {Key? key,
      required this.orderLineItemID,
      required this.customerInfoModel,
      required this.orderID,
      required this.cartBloc,
      required this.items,
      required this.userID})
      : super(key: key);

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  TextEditingController itemQuantity = TextEditingController();

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  late CartBloc cartBloc;
  late isb.InventorySearchBloc inventorySearchBloc;

  CachedNetworkImage _imageContainer(String imageUrl, double width) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(0),
            color: Colors.transparent,
          ),
          child: Image(
            image: imageProvider,
          ),
        );
      },
    );
  }

  final SwipeActionController controller = SwipeActionController();

  @override
  initState() {
    super.initState();
    cartBloc = context.read<CartBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    setState(() {
      itemQuantity.text = widget.items.quantity!.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocConsumer<CartBloc, CartState>(listener: (context, cartState) {
        itemQuantity.text = widget.items.quantity!.toInt().toString();
      }, builder: (context, cartState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          // var recordID = await SharedPreferenceService().getValue(agentId);
                          // if(recordID.isEmpty){
                          //   showMessage(context: context,message:"Please select a customer");
                          // }
                          // else{
                          Navigator.push(
                                  context,
                                  CupertinoPageRoute<List<asm.Records>>(
                                      builder: (context) => ProductDetailPage(
                                            customerID: widget.userID,
                                            warranties:
                                                widget.items
                                                                .warranties ==
                                                            null ||
                                                        widget.items.warranties!
                                                            .isEmpty ||
                                                        widget.items
                                                                .warrantyId ==
                                                            null ||
                                                        widget.items.warrantyId!
                                                            .isEmpty
                                                    ? Warranties()
                                                    : widget
                                                        .items.warranties!
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            widget.items
                                                                .warrantyId),
                                            customer: widget.customerInfoModel,
                                            previousPage: "cart",
                                            orderLineItemId:
                                                widget.items.itemId!,
                                            warrantyId: widget.items.warrantyId,
                                            orderId: widget.orderID,
                                            productsInCart: inventorySearchBloc
                                                .state.productsInCart,
                                            cartItemInfor: widget.items,
                                            skUID:
                                                widget.items.itemNumber ?? "",
                                          ),
                                      settings:
                                          RouteSettings(name: "/detail_page")))
                              .then((value) {
                            cartBloc.add(ReloadCart(
                                orderID: widget.orderID,
                                inventorySearchBloc: inventorySearchBloc));
                          });
                          //}
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Column(
                            children: [
                              Card(
                                  color: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: _imageContainer(
                                        widget.items.imageUrl!, 95),
                                  )),
                              TextButton(
                                  onPressed: () async {
                                    context.read<pdb.ProductDetailBloc>().add(
                                        pdb.GetAddressProduct(
                                            skuENTId:
                                                widget.items.itemNumber ?? ""));
                                    var currentLocation =
                                        await getUserLocation(context);
                                    if (currentLocation?.latitude == 0) return;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GetAddressFromMap(
                                            latitude: currentLocation?.latitude
                                                .toString(),
                                            longitude: currentLocation
                                                ?.longitude
                                                .toString(),
                                            markers: {},
                                            zoom: 10,
                                            radius: double.parse('50'),
                                            isFullScreen: true,
                                            skuENTId:
                                                widget.items.itemNumber ?? "",
                                            productName: widget.items.itemDesc,
                                            orderId: widget.orderID,
                                            cartItemInfor: widget.items,
                                          ),
                                        ));
                                  },
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero)),
                                  child: Text(
                                    'View inventory',
                                    style:
                                        TextStyle(color: ColorSystem.lavender3),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  "SKU #: ${widget.items.itemNumber}",
                                  style: TextStyle(
                                      fontSize: SizeSystem.size13,
                                      fontWeight: FontWeight.w500,
                                      color: ColorSystem.greyDark,
                                      fontFamily: kRubik),
                                ),
                              ),
                              SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  cartBloc.add(GetProductEligibility(
                                      itemSKUId:
                                          widget.items.itemNumber ?? ""));
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
                                          child:
                                              BlocBuilder<CartBloc, CartState>(
                                                  builder: (context,
                                                      cartEligibilityState) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white70,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0))),
                                              insetPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              actions: [
                                                Material(
                                                  color: Colors.transparent,
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child:
                                                        cartEligibilityState
                                                                .fetchMoreInfo
                                                            ? Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    3,
                                                                child: Center(
                                                                    child:
                                                                        CircularProgressIndicator()),
                                                              )
                                                            : Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.8,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 15.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            IconButton(
                                                                              icon: Icon(Icons.close),
                                                                              constraints: BoxConstraints(),
                                                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                                                              onPressed: null,
                                                                              disabledColor: Colors.transparent,
                                                                            ),
                                                                            Text(
                                                                              "More Information",
                                                                              style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.bold),
                                                                            ),
                                                                            IconButton(
                                                                              icon: Icon(Icons.close),
                                                                              constraints: BoxConstraints(),
                                                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                                                              onPressed: () {
                                                                                Navigator.pop(dialogContext);
                                                                              },
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Flexible(
                                                                              child: InkWell(
                                                                                onTap: () async {
                                                                                  await Clipboard.setData(ClipboardData(text: widget.items.posSkuId ?? ''));
                                                                                  showMessage(context: context, message: 'Copied POS Sku - ${widget.items.posSkuId ?? ''}');
                                                                                },
                                                                                child: Container(
                                                                                  color: Colors.transparent,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text("POS Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                      SizedBox(height: 4),
                                                                                      Text(widget.items.posSkuId ?? '',
                                                                                          // state.records.first.childskus?.first.gcItemNumber ?? '',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(
                                                                                            color: Colors.black87,
                                                                                            fontSize: 16,
                                                                                          )),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: InkWell(
                                                                                onTap: () async {
                                                                                  await Clipboard.setData(ClipboardData(text: widget.items.pimSkuId ?? ''));
                                                                                  showMessage(context: context, message: 'Copied PIM Sku - ${widget.items.pimSkuId ?? ''}');
                                                                                },
                                                                                child: Container(
                                                                                  color: Colors.transparent,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text("PIM Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                      SizedBox(height: 4),
                                                                                      Text(widget.items.pimSkuId ?? '',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(
                                                                                            color: Colors.black87,
                                                                                            fontSize: 16,
                                                                                          )),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: InkWell(
                                                                                onTap: () async {
                                                                                  await Clipboard.setData(ClipboardData(text: widget.items.itemNumber ?? ''));
                                                                                  showMessage(context: context, message: 'Copied Sku - ${widget.items.itemNumber ?? ''}');
                                                                                },
                                                                                child: Container(
                                                                                  color: Colors.transparent,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text("Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                      SizedBox(height: 4),
                                                                                      Text(widget.items.itemNumber ?? '',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(
                                                                                            color: Colors.black87,
                                                                                            fontSize: 16,
                                                                                          )),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Text("Cost", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                SizedBox(height: 4),
                                                                                Text(widget.items.cost == null ? "N/A" : r"$" + widget.items.cost!.toStringAsFixed(2),
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      color: Colors.black87,
                                                                                      fontSize: 16,
                                                                                    )),
                                                                              ],
                                                                            ),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Text("Margin", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                SizedBox(height: 4),
                                                                                Text(widget.items.cost == null ? "N/A (0.00%)" : "${widget.items.marginValue.toString().contains("-") ? "-\$" + widget.items.marginValue!.toStringAsFixed(2).replaceAll("-", "") : "\$" + widget.items.marginValue!.toStringAsFixed(2)}" + " (" + widget.items.margin!.toStringAsFixed(2) + "%)",
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      color: Colors.black87,
                                                                                      fontSize: 16,
                                                                                    )),
                                                                              ],
                                                                            ),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Text("D Margin", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                SizedBox(height: 4),
                                                                                Text((cartState.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePriceApproval != null && cartState.orderDetailModel[0].items!.firstWhere((element) => element.itemId == widget.items.itemId).overridePriceApproval!.isNotEmpty) && widget.items.cost != null ? "${widget.items.discountedMarginValue.toString().contains("-") ? "-\$" + widget.items.discountedMarginValue!.toStringAsFixed(2).replaceAll("-", "") : "\$" + widget.items.discountedMarginValue!.toStringAsFixed(2)}" + " (" + widget.items.discountedMargin!.toStringAsFixed(2) + "%)" : "N/A (0.00%)",
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      color: Colors.black87,
                                                                                      fontSize: 16,
                                                                                    )),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("KCDC", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.mainNodeData.firstWhere((element) => element.nodeName == "KCDC").nodeStock!,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("Store", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.mainNodeData.firstWhere((element) => element.nodeName == "Store").nodeStock!,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("Global", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.mainNodeData.firstWhere((element) => element.nodeName == "Global").nodeStock!,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("WCDC", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.mainNodeData.firstWhere((element) => element.nodeName == "WCDC").nodeStock!,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("Average Cost", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.moreInfo.isNotEmpty ? (cartEligibilityState.moreInfo[0].averageCostC ?? 0.00).toStringAsFixed(2) : "0.00",
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("Lead Time", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].leadTimeC!.isNotEmpty ? (cartEligibilityState.moreInfo[0].leadTimeC ?? "N/A") : "N/A",
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("Part Number", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].partC!.isNotEmpty ? (cartEligibilityState.moreInfo[0].partC ?? "N/A") : "N/A",
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("Vendor Name", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].vendorNameC != null && cartEligibilityState.moreInfo[0].vendorNameC!.isNotEmpty ? (cartEligibilityState.moreInfo[0].vendorNameC ?? "N/A") : "N/A",
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("MSRP", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.moreInfo.isNotEmpty ? (cartEligibilityState.moreInfo[0].mSRPC ?? 0.00).toStringAsFixed(2) : "0.00",
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text("Billable Weight", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(height: 4),
                                                                                  Text(cartEligibilityState.moreInfo.isNotEmpty ? (cartEligibilityState.moreInfo[0].billableWeightC ?? 0.00).toStringAsFixed(2) : "0.00",
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        color: Colors.black87,
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      ListTile(
                                                                        dense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                2,
                                                                            horizontal:
                                                                                5),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.returnableIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Returnable",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                            Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                              child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isReturnableC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isReturnableC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      ListTile(
                                                                        dense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                5),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.pickupIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Pickup",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                            Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                              child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPickupAllowedC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPickupAllowedC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      ListTile(
                                                                        dense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                5),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.truckshipIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Truckship",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                            Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                              child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isTruckShipC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isTruckShipC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      ListTile(
                                                                        dense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                5),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.platinumIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Platinum",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                            Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                              child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPlatinumItemC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPlatinumItemC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      ListTile(
                                                                        dense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                5),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.nine14Icon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - 914",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                            Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                              child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].is914EligibleC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].is914EligibleC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      ListTile(
                                                                        dense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                5),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.backorderableIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Back Orderable",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                            Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                              child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isBackorderableC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isBackorderableC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black38,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      ListTile(
                                                                        dense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                5),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.clearenceIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Clearance",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                            Spacer(),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                              child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isClearanceItemC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isClearanceItemC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  "More Info",
                                  style: TextStyle(
                                      fontSize: SizeSystem.size15,
                                      fontWeight: FontWeight.bold,
                                      color: ColorSystem.lavender3,
                                      fontFamily: kRubik),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(widget.items.itemDesc!,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: SizeSystem.size18,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff222222),
                                  fontFamily: kRubik)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              cartState.updateID == widget.items.itemId &&
                                      cartState.isUpdating
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Card(
                                          elevation: 2,
                                          color: Theme.of(context).primaryColor,
                                          shape: CircleBorder(),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CupertinoActivityIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Card(
                                          elevation: 2,
                                          color: Colors.red,
                                          shape: CircleBorder(),
                                          child: InkWell(
                                            onTap: () {
                                              if (cartState.updateID !=
                                                      widget.items.itemId &&
                                                  cartState.isUpdating) {
                                                showMessage(
                                                    context: context,
                                                    message:
                                                        "Please wait until previous item update");
                                              } else {
                                                cartBloc.add(RemoveFromCart(
                                                    records: widget.items,
                                                    inventorySearchBloc:
                                                        inventorySearchBloc,
                                                    customerID: widget.userID,
                                                    orderID: widget.orderID));
                                                if (inventorySearchBloc
                                                    .state.productsInCart
                                                    .where((element) =>
                                                        element.childskus!.first
                                                            .skuENTId ==
                                                        widget.items.itemNumber)
                                                    .isNotEmpty) {
                                                  inventorySearchBloc.add(isb.RemoveFromCart(
                                                      favouriteBrandScreenBloc:
                                                          context.read<
                                                              FavouriteBrandScreenBloc>(),
                                                      records: inventorySearchBloc
                                                          .state.productsInCart
                                                          .firstWhere((element) =>
                                                              element
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId ==
                                                              widget.items
                                                                  .itemNumber),
                                                      customerID: widget.userID,
                                                      quantity: -1,
                                                      productId: widget
                                                          .items.productId!,
                                                      orderID: widget.orderID));
                                                }
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Text(
                                                "-",
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size30,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontFamily: kRubik),
                                              ),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Container(
                                            width: 35,
                                            child: TextFormField(
                                              autofocus: false,
                                              cursorColor: Theme.of(context)
                                                  .primaryColor,
                                              maxLength: 3,
                                              controller: itemQuantity,
                                              textAlign: TextAlign.center,
                                              onFieldSubmitted: (value) {
                                                if (cartState.updateID !=
                                                        widget.items.itemId &&
                                                    cartState.isUpdating) {
                                                  showMessage(
                                                      context: context,
                                                      message:
                                                          "Please wait until previous item update");
                                                } else if (itemQuantity
                                                        .text.isEmpty ||
                                                    itemQuantity.text == "0" ||
                                                    int.parse(
                                                            itemQuantity.text) <
                                                        0) {
                                                  showMessage(
                                                      context: context,
                                                      message:
                                                          "Please enter valid quantity");
                                                } else {
                                                  if (double.parse(
                                                          itemQuantity.text) <
                                                      widget.items.quantity!) {
                                                    cartBloc.add(RemoveFromCart(
                                                        records: widget.items,
                                                        inventorySearchBloc:
                                                            inventorySearchBloc,
                                                        customerID:
                                                            widget.userID,
                                                        orderID: widget.orderID,
                                                        quantity: int.parse(
                                                            itemQuantity
                                                                .text)));
                                                    if (inventorySearchBloc
                                                        .state.productsInCart
                                                        .where((element) =>
                                                            element
                                                                .childskus!
                                                                .first
                                                                .skuENTId ==
                                                            widget.items
                                                                .itemNumber)
                                                        .isNotEmpty) {
                                                      inventorySearchBloc.add(isb.RemoveFromCart(
                                                          favouriteBrandScreenBloc:
                                                              context.read<
                                                                  FavouriteBrandScreenBloc>(),
                                                          records: inventorySearchBloc
                                                              .state
                                                              .productsInCart
                                                              .firstWhere((element) =>
                                                                  element
                                                                      .childskus!
                                                                      .first
                                                                      .skuENTId ==
                                                                  widget.items
                                                                      .itemNumber),
                                                          customerID:
                                                              widget.userID,
                                                          quantity: int.parse(
                                                              itemQuantity.text),
                                                          productId: widget.items.productId!,
                                                          orderID: widget.orderID));
                                                    }
                                                  } else {
                                                    cartBloc.add(AddToCart(
                                                        records: widget.items,
                                                        inventorySearchBloc:
                                                            inventorySearchBloc,
                                                        customerID:
                                                            widget.userID,
                                                        orderID: widget.orderID,
                                                        quantity: int.parse(
                                                            itemQuantity
                                                                .text)));
                                                    // if (inventorySearchBloc
                                                    //     .state.productsInCart
                                                    //     .where((element) =>
                                                    //         element
                                                    //             .childskus!
                                                    //             .first
                                                    //             .skuENTId ==
                                                    //         widget.items
                                                    //             .itemNumber)
                                                    //     .isNotEmpty) {
                                                    //   inventorySearchBloc.add(isb.AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    //       context: context,
                                                    //       records: inventorySearchBloc
                                                    //           .state
                                                    //           .productsInCart
                                                    //           .firstWhere((element) =>
                                                    //               element
                                                    //                   .childskus!
                                                    //                   .first
                                                    //                   .skuENTId ==
                                                    //               widget.items
                                                    //                   .itemNumber),
                                                    //       customerID:
                                                    //           widget.userID,
                                                    //       productId: widget
                                                    //           .items.productId!,
                                                    //       quantity: int.parse(
                                                    //           itemQuantity
                                                    //               .text),
                                                    //       ifWarranties: false,
                                                    //       orderItem: "",
                                                    //       warranties: Warranties(),
                                                    //       orderID: widget.orderID));
                                                    // }
                                                  }
                                                }
                                              },
                                              textInputAction:
                                                  TextInputAction.done,
                                              style: TextStyle(
                                                  fontSize: SizeSystem.size20,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF222222),
                                                  fontFamily: kRubik),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true,
                                                      decimal: false),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              // Only numbers can be entered
                                              decoration: InputDecoration(
                                                constraints: BoxConstraints(),
                                                counter: SizedBox.shrink(),
                                                contentPadding: EdgeInsets.zero,
                                                isDense: true,
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: ColorSystem.greyDark,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // InkWell(
                                        //   onTap: (){
                                        //
                                        //     showModalBottomSheet(
                                        //         clipBehavior: Clip.antiAliasWithSaveLayer,
                                        //         backgroundColor: Colors.transparent,
                                        //         isScrollControlled : true,
                                        //         context: context,
                                        //         builder: (BuildContext context) {
                                        //           return StatefulBuilder(
                                        //               builder: (context,bottomState) {
                                        //                 return BlocProvider.value(
                                        //                   value: cartBloc,
                                        //                   child:BlocBuilder<CartBloc, CartState>(
                                        //                       builder: (context,cartState) {
                                        //                         return Padding(
                                        //                           padding: MediaQuery.of(context).viewInsets,
                                        //                           child: Container(
                                        //                             decoration:BoxDecoration(
                                        //                                 borderRadius: BorderRadius.only(
                                        //                                     topRight: Radius.circular(30.0),
                                        //                                     topLeft: Radius.circular(30.0)),
                                        //                                 color: Colors.white),
                                        //                             child: Padding(
                                        //                               padding: EdgeInsets.all(30.0),
                                        //                               child: Column(
                                        //                                 mainAxisSize: MainAxisSize.min,
                                        //                                 children: [
                                        //                                   Row(
                                        //                                     crossAxisAlignment: CrossAxisAlignment.start,
                                        //                                     children: [
                                        //                                       Expanded(
                                        //                                         child: Column(
                                        //                                           crossAxisAlignment: CrossAxisAlignment.start,
                                        //                                           children: [
                                        //                                             Text( widget.items.itemDesc!,
                                        //                                                 maxLines: 3,
                                        //
                                        //                                                 style: TextStyle(
                                        //                                                     fontSize: SizeSystem.size20,
                                        //                                                     overflow: TextOverflow.ellipsis,
                                        //                                                     fontWeight: FontWeight.w500,
                                        //                                                     color: Theme.of(context).primaryColor,
                                        //                                                     fontFamily: kRubik)
                                        //                                             ),
                                        //                                             SizedBox(height: 3,),
                                        //                                           ],
                                        //                                         ),
                                        //                                       ),
                                        //                                     ],
                                        //                                   ),
                                        //
                                        //                                   SizedBox(height: 15,),
                                        //                                   TextFormField(
                                        //                                     autofocus: false,
                                        //                                     cursorColor: Theme.of(context).primaryColor,
                                        //                                     controller: itemQuantity,
                                        //                                     keyboardType: TextInputType.number,
                                        //                                     inputFormatters: <TextInputFormatter>[
                                        //                                       FilteringTextInputFormatter.digitsOnly
                                        //                                     ], // Only numbers can be entered
                                        //                                     decoration:   InputDecoration(
                                        //                                       labelText: "Item Quantity",
                                        //                                       constraints: BoxConstraints(),
                                        //                                       contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 0),
                                        //                                       labelStyle: TextStyle(
                                        //                                         color: ColorSystem.greyDark,
                                        //                                         fontSize: SizeSystem.size18,
                                        //                                       ),
                                        //                                       focusedBorder: UnderlineInputBorder(
                                        //                                         borderSide: BorderSide(
                                        //                                           color: ColorSystem.greyDark,
                                        //                                           width: 1,
                                        //                                         ),
                                        //                                       ),
                                        //                                     ),
                                        //                                   ),
                                        //                                   SizedBox(height: 30,),
                                        //                                   ElevatedButton(
                                        //                                     style: ButtonStyle(
                                        //                                         backgroundColor: MaterialStateProperty.all(
                                        //                                             Theme.of(context).primaryColor),
                                        //                                         shape: MaterialStateProperty.all<
                                        //                                             RoundedRectangleBorder>(
                                        //                                             RoundedRectangleBorder(
                                        //                                               borderRadius: BorderRadius.circular(10.0),
                                        //                                             ))),
                                        //                                     onPressed: () async {
                                        //                                       if(itemQuantity.text.isEmpty || itemQuantity.text == "0"){
                                        //                                         showMessage(context: context,message:"Please enter valid quantity");
                                        //                                       }
                                        //                                       else{
                                        //                                         if(double.parse(itemQuantity.text) < widget.items.quantity!){
                                        //                                           Navigator.pop(context);
                                        //                                             cartBloc.add(RemoveFromCart(records: widget.items, customerID: widget.userID, orderID: widget.orderID,quantity: int.parse(itemQuantity.text)));
                                        //                                             if(inventorySearchBloc.state.productsInCart.where((element) => element.childskus!.first.skuENTId == widget.items.itemNumber).isNotEmpty){
                                        //                                             inventorySearchBloc.add(isb.RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                        //                                             records: inventorySearchBloc.state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == widget.items.itemNumber),
                                        //                                             customerID:widget.userID,
                                        //                                                 quantity: int.parse(itemQuantity.text),
                                        //                                             productId: widget.items.productId!,
                                        //                                             orderID: widget.orderID));}
                                        //                                         }
                                        //                                         else{
                                        //                                           Navigator.pop(context);
                                        //                                             cartBloc.add(AddToCart(records: widget.items, customerID: widget.userID, orderID: widget.orderID,quantity: int.parse(itemQuantity.text)));
                                        //                                             if(inventorySearchBloc.state.productsInCart.where((element) => element.childskus!.first.skuENTId == widget.items.itemNumber).isNotEmpty){
                                        //                                             inventorySearchBloc.add(isb.AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                        //                                             records: inventorySearchBloc.state.productsInCart.
                                        //                                             firstWhere((element) => element.childskus!.first.skuENTId == widget.items.itemNumber),
                                        //                                             customerID:widget.userID,
                                        //                                             productId: widget.items.productId!,
                                        //                                             quantity: int.parse(itemQuantity.text),
                                        //                                             ifWarranties: false,
                                        //                                             orderItem: "",
                                        //                                             warranties: Warranties(),
                                        //                                             orderID: widget.orderID));}
                                        //                                         }
                                        //                                       }
                                        //                                     },
                                        //                                     child: Padding(
                                        //                                       padding: EdgeInsets.symmetric(vertical: 15),
                                        //                                       child: Row(
                                        //                                         mainAxisAlignment: MainAxisAlignment.center,
                                        //                                         children:  [
                                        //                                           Text(
                                        //                                             'Update',
                                        //                                             style: TextStyle(fontSize: 18),
                                        //                                           ),
                                        //                                         ],
                                        //                                       ),
                                        //                                     ),
                                        //                                   ),
                                        //                                   SizedBox(height: 10),                                    ],
                                        //                               ),
                                        //                             ),
                                        //                           ),
                                        //                         );
                                        //                       }
                                        //                   ),
                                        //                 );
                                        //               }
                                        //           );
                                        //         }).whenComplete(() {
                                        //       itemQuantity.clear();
                                        //     });
                                        //   },
                                        //   child: Padding(
                                        //     padding: EdgeInsets.symmetric(horizontal: 10.0),
                                        //     child: Text(
                                        //       widget.items.quantity!.toInt().toString(),
                                        //       style: TextStyle(fontSize: SizeSystem.size24, fontWeight: FontWeight.w500, color: Color(0xFF222222), fontFamily: kRubik),
                                        //     ),
                                        //   ),
                                        // ),
                                        Card(
                                          elevation: 2,
                                          color: Theme.of(context).primaryColor,
                                          shape: CircleBorder(),
                                          child: InkWell(
                                            onTap: () {
                                              if (cartState.updateID !=
                                                      widget.items.itemId &&
                                                  cartState.isUpdating) {
                                                showMessage(
                                                    context: context,
                                                    message:
                                                        "Please wait until previous item update");
                                              } else {
                                                cartBloc.add(AddToCart(
                                                  records: widget.items,
                                                  inventorySearchBloc:
                                                      inventorySearchBloc,
                                                  customerID: widget.userID,
                                                  orderID: widget.orderID,
                                                ));
                                                // if (inventorySearchBloc
                                                //     .state.productsInCart
                                                //     .where((element) =>
                                                //         element.childskus!.first
                                                //             .skuENTId ==
                                                //         widget.items.itemNumber)
                                                //     .isNotEmpty) {
                                                //   inventorySearchBloc.add(isb.AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                //       context: context,
                                                //       records: inventorySearchBloc
                                                //           .state.productsInCart
                                                //           .firstWhere((element) =>
                                                //               element
                                                //                   .childskus!
                                                //                   .first
                                                //                   .skuENTId ==
                                                //               widget.items
                                                //                   .itemNumber),
                                                //       customerID: widget.userID,
                                                //       productId: widget
                                                //           .items.productId!,
                                                //       ifWarranties: false,
                                                //       orderItem: "",
                                                //       warranties: Warranties(),
                                                //       orderID: widget.orderID));
                                                // }
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Text(
                                                "+",
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size30,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontFamily: kRubik),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                            ],
                          ),
                        ],
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  Divider(height: 1.5),
                  SizedBox(height: 5),
                  BlocProvider.value(
                    value: cartBloc,
                    child: OverrideTile(
                        items: widget.items,
                        cartBloc: cartBloc,
                        userID: widget.userID,
                        orderID: widget.orderID,
                        orderLineItemID: widget.orderLineItemID),
                  ),
                  SizedBox(height: 5),
                  Divider(height: 1.5),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: BlocProvider.value(
                          value: cartBloc,
                          child: WarrantyTile(
                              cartBloc: cartBloc,
                              userID: widget.userID,
                              orderID: widget.orderID,
                              orderLineItemID: widget.items.itemId!,
                              orderSkUID: widget.items.pimSkuId!,
                              cartStateMain: cartState,
                              index: cartState.orderDetailModel[0].items!
                                  .indexOf(widget.items),
                              items: widget.items),
                        ),
                      ),
                      SizedBox(width: 0),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Text(
                            //   r"   $"
                            //   "${widget.items.overridePrice.toString() == "0.0"?widget.items.unitPrice:widget.items.overridePrice!.toStringAsFixed(2)}",
                            //   style: TextStyle(
                            //       fontSize:
                            //       SizeSystem.size26,
                            //       fontWeight: FontWeight.w500,
                            //       color: Colors.black,
                            //       fontFamily: kRubik),
                            // ),
                            RichText(
                                text: TextSpan(
                                    text: '\$',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontFamily: kRubik,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    children: [
                                  TextSpan(
                                    text:
                                        "${widget.items.overridePriceApproval != "Approved" ? widget.items.unitPrice!.toStringAsFixed(2) : widget.items.overridePrice!.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontFamily: kRubik,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 24,
                                    ),
                                  )
                                ])),
                            widget.items.overridePriceApproval == "Approved"
                                ? SizedBox(height: 2)
                                : SizedBox.shrink(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                widget.items.overridePriceApproval == "Approved"
                                    ? Text(
                                        r"$"
                                        "${widget.items.unitPrice?.toStringAsFixed(2)}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.red,
                                            fontFamily: kRubik),
                                      )
                                    : SizedBox.shrink(),
                                widget.items.overridePriceApproval == "Approved"
                                    ? Text(
                                        " (${(100 - ((widget.items.overridePrice! / widget.items.unitPrice!.toDouble()) * 100)).toDouble().toShortPercent()}%)",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontFamily: kRubik),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
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
      }),
    );
  }
}
