import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as pdb;
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart'
    as cm;
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/google_map/get_address_from_map.dart';
import 'package:gc_customer_app/screens/product_detail/product_detail_page.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:gc_customer_app/utils/get_user_location.dart';
import 'package:intl/intl.dart' as intl;


import '../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';

class ListItem extends StatefulWidget {
  Records items;
  int index;
  cm.CustomerInfoModel customerInfoModel;

  ListItem(
      {Key? key,
      required this.customerInfoModel,
      required this.items,
      required this.index})
      : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  TextEditingController itemQuantity = TextEditingController();
  StreamController<String> selectedSkuENTId = StreamController.broadcast();

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  late Records e;
  late InventorySearchBloc inventorySearchBloc;

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
    inventorySearchBloc = context.read<InventorySearchBloc>();
    setState(() {
      e = widget.items;
      if (double.parse(widget.items.quantity ?? "0").toInt() > 0) {
        itemQuantity.text =
            double.parse(widget.items.quantity ?? "0").toInt().toString();
      } else {
        itemQuantity.clear();
      }
    });
  }

  @override
  void dispose() {
    selectedSkuENTId.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocConsumer<InventorySearchBloc, InventorySearchState>(
          listener: (context, state) {
        if (double.parse(widget.items.quantity ?? "0").toInt() > 0) {
          itemQuantity.text =
              double.parse(widget.items.quantity ?? "0").toInt().toString();
        } else {
          itemQuantity.clear();
        }
      }, builder: (context, state) {
        return SwipeActionCell(
          controller: controller,
          key: ObjectKey(e.productId),
          closeWhenScrolling: true,
          leadingActions: [
            SwipeAction(
                performsFirstActionWithFullSwipe: false,
                widthSpace: MediaQuery.of(context).size.width * 0.3,
                closeOnTap: true,
                // title: "View inventory",
                content: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                      IconSystem.mapBackground,
                      package: 'gc_customer_app',
                    )),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    height: 30,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'View inventory',
                      style: TextStyle(
                          fontSize: SizeSystem.size12,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: kRubik),
                    ),
                  ),
                ),
                color: Colors.transparent,
                // style: TextStyle(
                //     fontSize: SizeSystem.size12,
                //     overflow: TextOverflow.ellipsis,
                //     fontWeight: FontWeight.w500,
                //     color: Colors.white,
                //     fontFamily: kRubik),
                // icon: SvgPicture.asset(
                //   IconSystem.mapLable,
                //   color: ColorSystem.white,
                // ),
                onTap: (_) async {
                  context.read<pdb.ProductDetailBloc>().add(
                      pdb.GetAddressProduct(
                          skuENTId: e.childskus?.first.skuENTId ?? ''));
                  var currentLocation = await getUserLocation(context);
                  if (currentLocation?.latitude == 0) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GetAddressFromMap(
                          latitude: currentLocation?.latitude.toString(),
                          longitude: currentLocation?.longitude.toString(),
                          markers: {},
                          zoom: 10,
                          radius: double.parse('50'),
                          isFullScreen: true,
                          skuENTId: e.childskus?.first.skuENTId ?? '',
                          productName: e.childskus?.first.skuDisplayName,
                        ),
                      ));
                }),
          ],
          trailingActions: double.parse(e.quantity!) > 0
              ? <SwipeAction>[
                  SwipeAction(
                      performsFirstActionWithFullSwipe: false,
                      widthSpace: MediaQuery.of(context).size.width * 0.3,
                      closeOnTap: true,
                      title: "Remove from cart",
                      style: TextStyle(
                          fontSize: SizeSystem.size12,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: kRubik),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      onTap: state.isUpdating
                          ? (CompletionHandler handler) async {
                              controller.closeAllOpenCell();
                            }
                          : state.productsInCart.isEmpty
                              ? (CompletionHandler handler) async {
                                  controller.closeAllOpenCell();
                                }
                              : state.productsInCart.isNotEmpty &&
                                      state.productsInCart
                                          .where((element) =>
                                              element.productId == e.productId)
                                          .isEmpty
                                  ? (CompletionHandler handler) async {
                                      controller.closeAllOpenCell();
                                    }
                                  : (CompletionHandler handler) async {
                                      controller.closeAllOpenCell();
                                      if ((state.isUpdating &&
                                              state.updateID != e.productId!) ||
                                          (state.fetchWarranties &&
                                              state.updateID !=
                                                  e.childskus!.first
                                                      .skuPIMId!)) {
                                        showMessage(context: context,message:
                                            "Please wait until previous item update");
                                      } else {
                                        inventorySearchBloc.add(RemoveFromCart(
                                            favouriteBrandScreenBloc:
                                                context.read<
                                                    FavouriteBrandScreenBloc>(),
                                            records: e,
                                            quantity: 0,
                                            customerID: widget.customerInfoModel
                                                    .records!.first.id ??
                                                "",
                                            orderID: state.orderId,
                                            productId: e.productId!));
                                      }
                                    }),
                ]
              : [],
          child: InkWell(
            onTap: () {
              if (state.isUpdating || state.fetchWarranties) {
                showMessage(context: context,message:"Please wait until cart update");
              } else {
                openProductDetail(
                    customerID:
                        widget.customerInfoModel.records!.first.id ?? "",
                    customer: widget.customerInfoModel,
                    orderID: state.orderId,
                    productsInCart: state.productsInCart,
                    records: e,
                    orderLineItemId: state.orderLineItemId);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 15, left: 15, right: 15),
                                  child:
                                      _imageContainer(e.productImageUrl!, 60.0),
                                ),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    context.read<pdb.ProductDetailBloc>().add(
                                        pdb.GetAddressProduct(
                                            skuENTId:
                                                e.childskus?.first.skuENTId ??
                                                    ''));
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
                                                e.childskus?.first.skuENTId ??
                                                    '',
                                            productName: e.childskus?.first
                                                .skuDisplayName,
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
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            e.childskus?.first.skuDisplayName ??
                                                '',
                                            maxLines: 4,
                                            style: TextStyle(
                                                fontSize: SizeSystem.size15,
                                                overflow: TextOverflow.ellipsis,
                                                // fontWeight: FontWeight.w600,
                                                color: Color(0xff222222),
                                                fontFamily: kRubik)),
                                        SizedBox(height: 5),
                                        Text(e.brandName ?? "",
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: SizeSystem.size12,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w500,
                                                color: ColorSystem.greyDark,
                                                fontFamily: kRubik)),
                                        SizedBox(height: 5),
                                        if (e.childskus?.first.skuCondition !=
                                            null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _conditionWidget(e.childskus!
                                                  .first.skuCondition!),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                        e.highPrice
                                                        .toString()
                                                        .replaceAll(
                                                            "Starting at ", "")
                                                        .replaceAll("\$", "") !=
                                                    "0.00" &&
                                                e.highPrice
                                                        .toString()
                                                        .replaceAll(
                                                            "Starting at ", "")
                                                        .replaceAll("\$", "") !=
                                                    (e.childskus!.first
                                                                .skuPrice ??
                                                            "0.00")
                                                        .replaceAll("\$", "")
                                                        .replaceAll(
                                                            "Starting at ", "")
                                            ? Text(
                                                r"$" +
                                                    double.parse((e.highPrice ??
                                                                "0.00")
                                                            .replaceAll(
                                                                "\$", "")
                                                            .replaceAll(
                                                                "Starting at ",
                                                                ""))
                                                        .toStringAsFixed(2)
                                                        .replaceAll(
                                                            "Starting at ", "")
                                                        .replaceAll("\$", ""),
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontSize: SizeSystem.size13,
                                                    fontWeight: FontWeight.w400,
                                                    color: ColorSystem
                                                        .complimentary,
                                                    fontFamily: kRubik),
                                              )
                                            : SizedBox.shrink(),
                                        Text(
                                          r"$" +
                                              amountFormatting(double.parse((e
                                                          .childskus!
                                                          .first
                                                          .skuPrice ??
                                                      "0.00")
                                                  .replaceAll("\$", "")
                                                  .replaceAll(
                                                      "Starting at ", ""))),
                                          style: TextStyle(
                                              fontSize: SizeSystem.size18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF222222),
                                              fontFamily: kRubik),
                                        ),
                                      ],
                                    )),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              inventorySearchBloc.add(
                                                  FetchEligibility(
                                                      index: widget.index));
                                              showCupertinoDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (BuildContext
                                                    dialogContext) {
                                                  return BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                      sigmaX: 8.0,
                                                      sigmaY: 8.0,
                                                    ),
                                                    child: BlocProvider.value(
                                                      value:
                                                          inventorySearchBloc,
                                                      child: BlocBuilder<
                                                              InventorySearchBloc,
                                                              InventorySearchState>(
                                                          builder: (context,
                                                              cartEligibilityState) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors.white70,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          15.0))),
                                                          insetPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20),
                                                          actions: [
                                                            Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: e.fetchingEligibility!
                                                                    ? Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                3,
                                                                        child: Center(
                                                                            child:
                                                                                CircularProgressIndicator()),
                                                                      )
                                                                    : SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 15.0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: InkWell(
                                                                                      onTap: () async {
                                                                                        await Clipboard.setData(ClipboardData(text: e.childskus?.first.gcItemNumber ?? ''));
                                                                                        showMessage(context: context,message:'Copied POS Sku - ${e.childskus?.first.gcItemNumber ?? ''}');
                                                                                      },
                                                                                      child: Container(
                                                                                        color: Colors.transparent,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Text("POS Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                            SizedBox(height: 4),
                                                                                            Text(e.childskus?.first.gcItemNumber ?? '',
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
                                                                                        await Clipboard.setData(ClipboardData(text: e.childskus?.first.skuPIMId ?? ''));
                                                                                        showMessage(context: context,message:'Copied PIM Sku - ${e.childskus?.first.skuPIMId ?? ''}');
                                                                                      },
                                                                                      child: Container(
                                                                                        color: Colors.transparent,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Text("PIM Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                            SizedBox(height: 4),
                                                                                            Text(e.childskus?.first.skuPIMId ?? '',
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
                                                                                        await Clipboard.setData(ClipboardData(text: e.childskus?.first.skuENTId ?? ''));
                                                                                        showMessage(context: context,message:'Copied Sku - ${e.childskus?.first.skuENTId ?? ''}');
                                                                                      },
                                                                                      child: Container(
                                                                                        color: Colors.transparent,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Text("Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                            SizedBox(height: 4),
                                                                                            Text(e.childskus?.first.skuENTId ?? '',
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
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Text("KCDC", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                        SizedBox(height: 4),
                                                                                        Text(e.mainNodeData!.firstWhere((element) => element.nodeName == "KCDC").nodeStock!,
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
                                                                                        Text(e.mainNodeData!.firstWhere((element) => element.nodeName == "Store").nodeStock!,
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
                                                                                        Text(e.mainNodeData!.firstWhere((element) => element.nodeName == "Global").nodeStock!,
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
                                                                                        Text(e.mainNodeData!.firstWhere((element) => element.nodeName == "WCDC").nodeStock!,
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
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Text("Average Cost", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                        SizedBox(height: 4),
                                                                                        Text(e.moreInfo!.isNotEmpty ? (e.moreInfo![0].averageCostC ?? 0.00).toStringAsFixed(2) : "0.00",
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
                                                                                        Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].leadTimeC!.isNotEmpty ? (e.moreInfo![0].leadTimeC ?? "N/A") : "N/A",
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
                                                                                        Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].partC!.isNotEmpty ? (e.moreInfo![0].partC ?? "N/A") : "N/A",
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
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Text("Vendor Name", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                        SizedBox(height: 4),
                                                                                        Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].vendorNameC != null && e.moreInfo![0].vendorNameC!.isNotEmpty ? (e.moreInfo![0].vendorNameC ?? "N/A") : "N/A",
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
                                                                                        Text(e.moreInfo!.isNotEmpty ? (e.moreInfo![0].mSRPC ?? 0.00).toStringAsFixed(2) : "0.00",
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
                                                                                        Text(e.moreInfo!.isNotEmpty ? (e.moreInfo![0].billableWeightC ?? 0.00).toStringAsFixed(2) : "0.00",
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
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                                                              dense: true,
                                                                              title: Row(
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    IconSystem.returnableIcon,
                                                                                    package: 'gc_customer_app',
                                                                                  ),
                                                                                  Text(" - Returnable", style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                                  Spacer(),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                                    child: Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].isReturnableC! ? "Yes" : "No", style: TextStyle(color: e.moreInfo!.isNotEmpty && e.moreInfo![0].isReturnableC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                                                              dense: true,
                                                                              title: Row(
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    IconSystem.pickupIcon,
                                                                                    package: 'gc_customer_app',
                                                                                  ),
                                                                                  Text(" - Pickup", style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                                  Spacer(),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                                    child: Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].isPickupAllowedC! ? "Yes" : "No", style: TextStyle(color: e.moreInfo!.isNotEmpty && e.moreInfo![0].isPickupAllowedC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                                                              dense: true,
                                                                              title: Row(
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    IconSystem.truckshipIcon,
                                                                                    package: 'gc_customer_app',
                                                                                  ),
                                                                                  Text(" - Truckship", style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                                  Spacer(),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                                    child: Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].isTruckShipC! ? "Yes" : "No", style: TextStyle(color: e.moreInfo!.isNotEmpty && e.moreInfo![0].isTruckShipC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                                                              dense: true,
                                                                              title: Row(
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    IconSystem.platinumIcon,
                                                                                    package: 'gc_customer_app',
                                                                                  ),
                                                                                  Text(" - Platinum", style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                                  Spacer(),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                                    child: Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].isPlatinumItemC! ? "Yes" : "No", style: TextStyle(color: e.moreInfo!.isNotEmpty && e.moreInfo![0].isPlatinumItemC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                                                              dense: true,
                                                                              title: Row(
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    IconSystem.nine14Icon,
                                                                                    package: 'gc_customer_app',
                                                                                  ),
                                                                                  Text(" - 914", style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                                  Spacer(),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                                    child: Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].is914EligibleC! ? "Yes" : "No", style: TextStyle(color: e.moreInfo!.isNotEmpty && e.moreInfo![0].is914EligibleC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                                                              dense: true,
                                                                              title: Row(
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    IconSystem.backorderableIcon,
                                                                                    package: 'gc_customer_app',
                                                                                  ),
                                                                                  Text(" - Back Orderable", style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                                  Spacer(),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                                    child: Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].isBackorderableC! ? "Yes" : "No", style: TextStyle(color: e.moreInfo!.isNotEmpty && e.moreInfo![0].isBackorderableC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                                                              dense: true,
                                                                              title: Row(
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    IconSystem.clearenceIcon,
                                                                                    package: 'gc_customer_app',
                                                                                  ),
                                                                                  Text(" - Clearance", style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                                  Spacer(),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                                                    child: Text(e.moreInfo!.isNotEmpty && e.moreInfo![0].isClearanceItemC! ? "Yes" : "No", style: TextStyle(color: e.moreInfo!.isNotEmpty && e.moreInfo![0].isClearanceItemC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
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
                                            child: SvgPicture.asset(
                                              IconSystem.moreInfo,
                                              package: 'gc_customer_app',
                                              width: 20,
                                              color: ColorSystem.lavender3,
                                            )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        (state.isUpdating &&
                                                    state.updateID ==
                                                        e.productId) ||
                                                (state.fetchWarranties &&
                                                    state.updateID ==
                                                        e.childskus!.first
                                                            .skuPIMId)
                                            ? Card(
                                                elevation: 2,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: CircleBorder(),
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child:
                                                        CupertinoActivityIndicator(
                                                      color: Colors.white,
                                                    )))
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  double.parse(e.quantity!) > 0
                                                      ? Card(
                                                          elevation: 2,
                                                          color: Colors.red,
                                                          shape: CircleBorder(),
                                                          child: InkWell(
                                                            onTap: (state.isUpdating &&
                                                                        state.updateID !=
                                                                            e
                                                                                .productId!) ||
                                                                    (state.fetchWarranties &&
                                                                        state.updateID !=
                                                                            e.childskus!.first.skuPIMId!)
                                                                ? () {
                                                                    showMessage(context: context,message:
                                                                        "Please wait until previous item update");
                                                                  }
                                                                : () {
                                                                    inventorySearchBloc.add(RemoveFromCart(
                                                                        favouriteBrandScreenBloc:
                                                                            context.read<
                                                                                FavouriteBrandScreenBloc>(),
                                                                        records:
                                                                            e,
                                                                        quantity:
                                                                            -1,
                                                                        customerID:
                                                                            widget.customerInfoModel.records!.first.id ??
                                                                                "",
                                                                        orderID:
                                                                            state
                                                                                .orderId,
                                                                        productId:
                                                                            e.productId!));
                                                                  },
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: Text(
                                                                "-",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        SizeSystem
                                                                            .size24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        kRubik),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 0, width: 0),
                                                  double.parse(e.quantity!) > 0
                                                      ? Container(
                                                          width: 30,
                                                          child: TextFormField(
                                                            autofocus: false,
                                                            cursorColor:
                                                                ColorSystem
                                                                    .primary,
                                                            maxLength: 3,
                                                            controller:
                                                                itemQuantity,
                                                            textAlign: TextAlign
                                                                .center,
                                                            onFieldSubmitted:
                                                                (value) {
                                                              if ((state.isUpdating &&
                                                                      state.updateID !=
                                                                          e
                                                                              .productId!) ||
                                                                  (state.fetchWarranties &&
                                                                      state.updateID !=
                                                                          e.childskus!.first
                                                                              .skuPIMId!)) {
                                                                showMessage(context: context,message:
                                                                    "Please wait until previous item update");
                                                              }
                                                              if (itemQuantity
                                                                      .text
                                                                      .isEmpty ||
                                                                  itemQuantity
                                                                          .text ==
                                                                      "0" ||
                                                                  int.parse(itemQuantity
                                                                          .text) <
                                                                      0) {
                                                                showMessage(context: context,message:
                                                                    "Please enter valid quantity");
                                                              } else {
                                                                if (double.parse(
                                                                        itemQuantity
                                                                            .text) <
                                                                    double.parse(
                                                                        e.quantity!)) {
                                                                  inventorySearchBloc.add(RemoveFromCart(
                                                                      favouriteBrandScreenBloc:
                                                                          context.read<
                                                                              FavouriteBrandScreenBloc>(),
                                                                      records:
                                                                          e,
                                                                      quantity: int.parse(
                                                                          itemQuantity
                                                                              .text),
                                                                      customerID: widget
                                                                              .customerInfoModel
                                                                              .records!
                                                                              .first
                                                                              .id ??
                                                                          "",
                                                                      orderID: state
                                                                          .orderId,
                                                                      productId:
                                                                          e.productId!));
                                                                } else {
                                                                  e.productId = e
                                                                      .childskus!
                                                                      .first
                                                                      .skuId;
                                                                  e.productName = e
                                                                      .childskus!
                                                                      .first
                                                                      .skuDisplayName;
                                                                  e.productImageUrl = e
                                                                      .childskus!
                                                                      .first
                                                                      .skuImageUrl;
                                                                  inventorySearchBloc.add(AddToCart(
                                                                      favouriteBrandScreenBloc:
                                                                          context.read<
                                                                              FavouriteBrandScreenBloc>(),
                                                                      records:
                                                                          e,
                                                                      customerID: widget
                                                                              .customerInfoModel
                                                                              .records!
                                                                              .first
                                                                              .id ??
                                                                          "",
                                                                      quantity: int.parse(itemQuantity
                                                                          .text),
                                                                      productId: e
                                                                          .childskus!
                                                                          .first
                                                                          .skuId!,
                                                                      orderID: state
                                                                          .orderId,
                                                                      ifWarranties:
                                                                          false,
                                                                      orderItem:
                                                                          "",
                                                                      warranties:
                                                                          Warranties()));
                                                                }
                                                              }
                                                            },
                                                            textInputAction:
                                                                TextInputAction
                                                                    .done,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    SizeSystem
                                                                        .size20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFF222222),
                                                                fontFamily:
                                                                    kRubik),
                                                            keyboardType: TextInputType
                                                                .numberWithOptions(
                                                                    signed:
                                                                        true,
                                                                    decimal:
                                                                        false),
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly
                                                            ],
                                                            // Only numbers can be entered
                                                            decoration:
                                                                InputDecoration(
                                                              constraints:
                                                                  BoxConstraints(),
                                                              counter: SizedBox
                                                                  .shrink(),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              isDense: true,
                                                              enabledBorder:
                                                                  InputBorder
                                                                      .none,
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
                                                        )
                                                      : SizedBox(
                                                          height: 0, width: 0),
                                                  Container(),
                                                  Card(
                                                    elevation: 2,
                                                    color: ColorSystem
                                                        .primaryTextColor,
                                                    shape: CircleBorder(),
                                                    child: InkWell(
                                                      onTap: (state.isUpdating &&
                                                                  state.updateID !=
                                                                      e
                                                                          .productId!) ||
                                                              (state.fetchWarranties &&
                                                                  state.updateID !=
                                                                      e
                                                                          .childskus!
                                                                          .first
                                                                          .skuPIMId!)
                                                          ? () {
                                                              showMessage(context: context,message:
                                                                  "Please wait until previous item update");
                                                            }
                                                          : () async {
                                                              print(
                                                                  "state.isFirst ${state.isFirst}");
                                                              if (state
                                                                      .isFirst &&
                                                                  state
                                                                      .productsInCart
                                                                      .isNotEmpty) {
                                                                await showCupertinoDialog(
                                                                    barrierDismissible:
                                                                        true,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            dialogContext) {
                                                                      return BackdropFilter(
                                                                        filter:
                                                                            ImageFilter.blur(
                                                                          sigmaX:
                                                                              8.0,
                                                                          sigmaY:
                                                                              8.0,
                                                                        ),
                                                                        child: StatefulBuilder(builder:
                                                                            (context,
                                                                                setChildState) {
                                                                          return CupertinoAlertDialog(
                                                                            title:
                                                                                Text(
                                                                              'Replace Cart',
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            content:
                                                                                Text('You have already item in cart. Do you want to discard current cart and add new items?'),
                                                                            actions: [
                                                                              CupertinoButton(
                                                                                  child: Text(
                                                                                    'No',
                                                                                    style: TextStyle(color: Colors.red),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.of(dialogContext).pop("no");
                                                                                    inventorySearchBloc.add(UpdateIsFirst(value: false));
                                                                                  }),
                                                                              CupertinoButton(
                                                                                  child: Text(
                                                                                    "Yes",
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.of(dialogContext).pop("yes");
                                                                                    inventorySearchBloc.add(UpdateIsFirst(value: false));
                                                                                  }),
                                                                            ],
                                                                          );
                                                                        }),
                                                                      );
                                                                    }).then((value) {
                                                                  if (value ==
                                                                      "no") {
                                                                    addToCart(e,
                                                                        state);
                                                                  } else if (value ==
                                                                      "yes") {
                                                                    inventorySearchBloc.add(SetCart(
                                                                        itemOfCart: [],
                                                                        records: [],
                                                                        orderId:
                                                                            ""));
                                                                    addToCart(e,
                                                                        state);
                                                                  }
                                                                });
                                                              } else {
                                                                inventorySearchBloc.add(
                                                                    UpdateIsFirst(
                                                                        value:
                                                                            false));
                                                                addToCart(
                                                                    e, state);
                                                              }
                                                            },
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            10.0),
                                                        child: Text(
                                                          "+",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  SizeSystem
                                                                      .size24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  kRubik),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                      ],
                                    ),
                                  ],
                                ),
                                if ((e.childskus?.length ?? 0) > 1)
                                  Wrap(
                                    spacing: 4,
                                    children: e.childskus!.map(
                                      (childsku) {
                                        int skuIndex = e.childskus?.indexWhere(
                                                (s) =>
                                                    s.skuId ==
                                                    childsku.skuId) ??
                                            0;
                                        if (skuIndex < 4)
                                          return Stack(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:
                                                    childsku.skuImageUrl ?? '',
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image:
                                                              imageProvider)),
                                                ),
                                                placeholder: (context, url) =>
                                                    SizedBox.shrink(),
                                              ),
                                              if ((e.childskus ?? []).length >
                                                      4 &&
                                                  skuIndex == 3)
                                                Container(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  height: 40,
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '+${(e.childskus ?? []).length - 3}',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                            ],
                                          );
                                        return SizedBox.shrink();
                                      },
                                    ).toList(),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
                  child: Divider(
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  addToCart(Records e, InventorySearchState state) {
    e.productId = e.childskus!.first.skuId;
    e.productName = e.childskus!.first.skuDisplayName;
    e.productImageUrl = e.childskus!.first.skuImageUrl;
    if (double.parse(e.quantity!) > 0) {
      print("state.orderId ${e.oliRecId}");
      inventorySearchBloc.add(AddToCart(
          favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
          records: e,
          customerID: widget.customerInfoModel.records!.first.id ?? "",
          quantity: -1,
          productId: e.childskus!.first.skuId!,
          orderID: state.orderId,
          ifWarranties: false,
          orderItem: "",
          warranties: Warranties()));
    } else {
      inventorySearchBloc.add(GetWarranties(
          skuEntId: e.childskus!.first.skuPIMId ?? "",
          productId: e.childskus!.first.skuPIMId!,
          records: e));
    }
  }

  openProductDetail(
      {required String customerID,
      required cm.CustomerInfoModel? customer,
      required String? orderID,
      required String? orderLineItemId,
      required List<Records> productsInCart,
      required Records records}) {
    Navigator.push(
        context,
        CupertinoPageRoute<List<Records>>(
          builder: (context) => ProductDetailPage(
            customerID: customerID,
            warranties: records.warranties ?? Warranties(),
            warrantyId:
                records.warranties != null ? records.warranties!.id : "",
            customer: customer,
            highPrice: records.highPrice,
            fromInventory: true,
            orderLineItemId: orderLineItemId,
            orderId: orderID,
            productsInCart: productsInCart,
            skUID: records.childskus!.first.skuENTId ?? "",
            childskus: e.childskus,
          ),

            settings: RouteSettings(name: "/detail_page")
        )).then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          // inventorySearchBloc.add(UpdateBottomCart(items: value));
        });
      }
    });
  }

  _conditionWidget(String condition) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.selectedChipColor.withOpacity(0.2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 5,
          ),
          Text('${condition}'),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }
}
