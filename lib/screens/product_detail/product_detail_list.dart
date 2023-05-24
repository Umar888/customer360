import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlb;
import 'package:gc_customer_app/common_widgets/circular_add_button.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart'
    as cim;
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/zip_store_list/zip_stores_page.dart';
import 'package:gc_customer_app/services/extensions/list_sorting.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:rxdart/rxdart.dart';

import '../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../primitives/constants.dart';

class ProductDetailList extends StatefulWidget {
  final String customerID;
  final Warranties warranties;
  final cim.CustomerInfoModel? customer;
  String? orderId;
  String? previousPage;
  String? highPrice;
  String? warrantyId;
  String? orderLineItemId;
  String? skUEntId;
  bool? fromInventory;
  List<Records> productsInCart;
  List<Childskus>? childskus;
  Items? cartItemInfor;

  ProductDetailList(
      {Key? key,
      required this.warrantyId,
      required this.previousPage,
      required this.orderLineItemId,
      required this.highPrice,
      required this.warranties,
      required this.skUEntId,
      required this.fromInventory,
      required this.orderId,
      required this.customerID,
      this.customer,
      required this.productsInCart,
      this.cartItemInfor,
      this.childskus})
      : super(key: key);

  @override
  State<ProductDetailList> createState() => _ProductDetailListState();
}

class _ProductDetailListState extends State<ProductDetailList>
    with TickerProviderStateMixin {
  late ProductDetailBloc productDetailBloc;
  late isb.InventorySearchBloc inventorySearchBloc;
  late zlb.ZipStoreListBloc zipStoreListBloc;

  late StreamSubscription<isb.InventorySearchState> subscription;

  @override
  void initState() {
    if (!kIsWeb)
    FirebaseAnalytics.instance
              .setCurrentScreen(screenName: 'ProductDetaiScreen');
        productDetailBloc = context.read<ProductDetailBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    zipStoreListBloc = context.read<zlb.ZipStoreListBloc>();

    productDetailBloc.add(PageLoad(
        skuENTId: widget.skUEntId!,
        orderId: widget.orderId!,
        orderLineItemId: widget.orderLineItemId!,
        inventorySearchBloc: inventorySearchBloc,
        warrantyId: widget.warrantyId ?? "",
        productsInCart: widget.productsInCart));
    productDetailBloc.add(SetExpandColor(expandColor: false));
    productDetailBloc.add(SetExpandCoverage(expandCoverage: false));
    productDetailBloc.add(SetExpandEligibility(value: false));
    productDetailBloc.add(SetExpandBundle(expandBundle: false));

    subscription = inventorySearchBloc.stream
        .debounceTime(Duration(milliseconds: 100))
        .listen((state) {
      if (state.showDialog &&
          !state.fetchWarranties &&
          state.warrantiesRecord.isNotEmpty &&
          mounted &&
          ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.isCurrent) {
        inventorySearchBloc.add(isb.ChangeShowDialog(false));
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
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: state.warrantiesModel.isNotEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Text(
                                    "Pro Coverage",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Divider(
                                  color: Colors.black54,
                                  height: 1,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: state.warrantiesModel
                                      .sortedBy((it) => it.price!)
                                      .map((Warranties value) {
                                    int index = state.warrantiesModel
                                        .sortedBy((it) => it.price!)
                                        .toList()
                                        .indexOf(value);
                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(dialogContext);
                                              // Navigator.popUntil(
                                              //     dialogContext,
                                              //     (route) =>
                                              //         route.settings.name ==
                                              //         "/detail_page");
                                              if (value.styleDescription1!
                                                  .isNotEmpty) {
                                                inventorySearchBloc.add(
                                                    isb.AddToCart(
                                                        favouriteBrandScreenBloc:
                                                            context.read<
                                                                FavouriteBrandScreenBloc>(),
                                                        records: state
                                                            .warrantiesRecord
                                                            .first,
                                                        customerID:
                                                            widget
                                                                .customer!
                                                                .records!
                                                                .first
                                                                .id!,
                                                        productId: state
                                                            .warrantiesRecord
                                                            .first
                                                            .childskus!
                                                            .first
                                                            .skuENTId!,
                                                        orderID: state.orderId,
                                                        ifWarranties: true,
                                                        orderItem: "",
                                                        warranties: value));
                                              } else {
                                                inventorySearchBloc.add(isb.AddToCart(
                                                    records: state
                                                        .warrantiesRecord.first,
                                                    customerID: widget.customer!
                                                        .records!.first.id!,
                                                    favouriteBrandScreenBloc:
                                                        context.read<
                                                            FavouriteBrandScreenBloc>(),
                                                    productId: state
                                                        .warrantiesRecord
                                                        .first
                                                        .childskus!
                                                        .first
                                                        .skuENTId!,
                                                    orderID: state.orderId,
                                                    ifWarranties: false,
                                                    orderItem: "",
                                                    warranties: Warranties()));
                                              }
                                              setState(() {});
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15.0),
                                                child: value.price == 0.0
                                                    ? Text(
                                                        "${value.displayName}",
                                                        style: TextStyle(
                                                            fontSize: SizeSystem
                                                                .size16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black87,
                                                            fontFamily: kRubik),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "${value.styleDescription1!.replaceAll("-", "")}: ",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    SizeSystem
                                                                        .size16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black87,
                                                                fontFamily:
                                                                    kRubik),
                                                          ),
                                                          Text(
                                                            "\$${value.price}",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    SizeSystem
                                                                        .size16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black87,
                                                                fontFamily:
                                                                    kRubik),
                                                          ),
                                                        ],
                                                      )),
                                          ),
                                          index ==
                                                  state.warrantiesModel
                                                          .sortedBy(
                                                              (it) => it.price!)
                                                          .toList()
                                                          .length -
                                                      1
                                              ? SizedBox.shrink()
                                              : Divider(
                                                  color: Colors.black54,
                                                  height: 1,
                                                ),
                                        ]);
                                  }).toList(),
                                )
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Pro Coverage",
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "No Coverage plan available for this product",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.black54,
                                  height: 1,
                                ),
                                InkWell(
                                  onTap: () {
                                    print(
                                        "this is id ${state.warrantiesRecord.first.childskus!.first.skuENTId!}");
                                    Navigator.pop(dialogContext);
                                    inventorySearchBloc.add(isb.AddToCart(
                                        favouriteBrandScreenBloc: context
                                            .read<FavouriteBrandScreenBloc>(),
                                        records: state.warrantiesRecord.first,
                                        customerID:
                                            widget.customer!.records!.first.id!,
                                        productId: state.warrantiesRecord.first
                                            .childskus!.first.skuENTId!,
                                        orderID: state.orderId,
                                        ifWarranties: false,
                                        orderItem: "",
                                        warranties: Warranties()));
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "OK",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).then((value) {
          inventorySearchBloc.add(isb.ClearWarranties());
          inventorySearchBloc.add(isb.ChangeShowDialog(false));
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  CachedNetworkImage _imageContainer(
      {required String imageUrl,
      required double width,
      required double height}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 8),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(15),
              color: ColorSystem.greyBackground,
            ),
            child: Center(
              child: Image(
                image: imageProvider,
                height: height,
                width: width,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(widget.skUEntId);
    return BlocBuilder<isb.InventorySearchBloc, isb.InventorySearchState>(
        builder: (context, inventoryState) {
      return BlocConsumer<ProductDetailBloc, ProductDetailState>(
          listener: (context, state) {
        if (state.message.isNotEmpty &&
            state.message != "done" &&
            state.message != "zebon") {
          Future.delayed(Duration.zero, () {
            setState(() {});
            showMessage(context: context, message: state.message);
          });
        }
        productDetailBloc.add(ClearMessage());
      }, builder: (context, state) {
        if (state.productDetailStatus == ProductDetailStatus.loadState) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          if (state.records.isEmpty) {
            return Scaffold(
              body: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Product detail not found"),
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
                backgroundColor: ColorSystem.greyBackground,
                bottomNavigationBar: kIsWeb
                    ? null
                    : AppBottomNavBar(
                        widget.customer,
                        "",
                        null,
                        inventorySearchBloc,
                        productDetailBloc,
                        zipStoreListBloc),
                body: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        height: size.height * 0.3,
                        color: ColorSystem.greyBackground,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 0),
                                child: IconButton(
                                    onPressed: () {
                                      if (!state.isUpdating) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    constraints: BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.arrow_back,
                                      size: 30,
                                      color: ColorSystem.greyDark,
                                    )),
                              ),
                              Expanded(
                                  child: Center(
                                      child: _imageContainer(
                                          imageUrl: state
                                              .records.first.productImageUrl!,
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4))),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  IconSystem.star,
                                                  width: 20,
                                                  package: 'gc_customer_app',
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                    state.records.first
                                                            .overallRating ??
                                                        "0.0",
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontFamily: kRubik)),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "${state.records.first.totalReviews ?? '0'} reviews",
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size14,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontFamily: kRubik)),
                                              ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  state.isInStoreLoading
                                      ? Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Padding(
                                            padding: EdgeInsets.all(30.0),
                                            child: CupertinoActivityIndicator(),
                                          ),
                                        )
                                      : state.getZipCodeList.isEmpty ||
                                              state.getZipCodeList[0]
                                                  .otherNodeData!
                                                  .where((element) =>
                                                      element.nodeCity! ==
                                                          "N/A" &&
                                                      element.nodeID! ==
                                                          "Store")
                                                  .isEmpty ||
                                              state.getZipCodeList[0]
                                                      .otherNodeData!
                                                      .firstWhere((element) =>
                                                          element.nodeCity! ==
                                                              "N/A" &&
                                                          element.nodeID! ==
                                                              "Store")
                                                      .stockLevel! ==
                                                  "0"
                                          ? Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: InkWell(
                                                onTap: () {
                                                  if (!kIsWeb)
                                                    Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              ZipStorePage(
                                                            customerID: widget
                                                                .customerID,
                                                            getZipCodeListSearch:
                                                                state
                                                                    .getZipCodeListSearch,
                                                            getZipCodeList: state
                                                                .getZipCodeList,
                                                            customer:
                                                                widget.customer,
                                                            orderLineItemId: state.orderLineItemId,
                                                            orderID:
                                                                state.orderId,
                                                            productsInCart:
                                                                inventoryState
                                                                    .productsInCart,
                                                            cartItemInfor: widget
                                                                .cartItemInfor,
                                                            records: state
                                                                .records[0],
                                                          ),
                                                        )).then((value) {
                                                      if (value != null &&
                                                          value.isNotEmpty) {
                                                        setState(() {
                                                          productDetailBloc.add(
                                                              UpdateBottomCart(
                                                                  items:
                                                                      value));
                                                        });
                                                      }
                                                    });
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            SvgPicture.asset(
                                                              IconSystem.search,
                                                              color: ColorSystem
                                                                  .white,
                                                              width: 30,
                                                              package:
                                                                  'gc_customer_app',
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text("0",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        SizeSystem
                                                                            .size20,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: ColorSystem
                                                                        .white,
                                                                    fontFamily:
                                                                        kRubik)),
                                                          ]),
                                                      SizedBox(height: 5),
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text("In Store",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        SizeSystem
                                                                            .size14,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: ColorSystem
                                                                        .white,
                                                                    fontFamily:
                                                                        kRubik)),
                                                          ]),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                if (state.getZipCodeList
                                                        .isNotEmpty &&
                                                    state.getZipCodeList[0]
                                                        .otherNodeData!
                                                        .where((element) =>
                                                            element.nodeCity! ==
                                                                "N/A" &&
                                                            element.nodeID! ==
                                                                "Store")
                                                        .isNotEmpty &&
                                                    !kIsWeb) {
                                                  Navigator.push(
                                                      context,
                                                      CupertinoPageRoute<
                                                          List<Records>>(
                                                        builder: (context) =>
                                                            ZipStorePage(
                                                          customerID:
                                                              widget.customerID,
                                                          getZipCodeList: state
                                                              .getZipCodeList,
                                                          getZipCodeListSearch:
                                                              state
                                                                  .getZipCodeListSearch,
                                                          customer:
                                                              widget.customer,
                                                          orderLineItemId: state.orderLineItemId,
                                                          orderID:
                                                              state.orderId,
                                                          productsInCart:
                                                              inventoryState
                                                                  .productsInCart,
                                                          cartItemInfor: widget
                                                              .cartItemInfor,
                                                          records:
                                                              state.records[0],
                                                        ),
                                                      )).then((value) {
                                                    if (value != null &&
                                                        value.isNotEmpty) {
                                                      setState(() {
                                                        productDetailBloc.add(
                                                            UpdateBottomCart(
                                                                items: value));
                                                      });
                                                    }
                                                  });
                                                }
                                              },
                                              child: Container(
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            SvgPicture.asset(
                                                              IconSystem
                                                                  .greenTick,
                                                              width: 20,
                                                              package:
                                                                  'gc_customer_app',
                                                            ),
                                                            SizedBox(
                                                              width: 15,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                  state.getZipCodeList
                                                                          .isEmpty
                                                                      ? "0.0"
                                                                      : state.getZipCodeList[0].otherNodeData!
                                                                              .where((element) =>
                                                                                  element.nodeCity! == "N/A" &&
                                                                                  element.nodeID! ==
                                                                                      "Store")
                                                                              .isEmpty
                                                                          ? "0"
                                                                          : state.getZipCodeList[0].otherNodeData!
                                                                              .firstWhere((element) =>
                                                                                  element.nodeCity! == "N/A" &&
                                                                                  element.nodeID! ==
                                                                                      "Store")
                                                                              .stockLevel
                                                                              .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          SizeSystem
                                                                              .size20,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: ColorSystem
                                                                          .primary,
                                                                      fontFamily:
                                                                          kRubik)),
                                                            ),
                                                          ]),
                                                      SizedBox(height: 5),
                                                      Text("In Store",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  SizeSystem
                                                                      .size14,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: ColorSystem
                                                                  .primary,
                                                              fontFamily:
                                                                  kRubik)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  state.currentCondition.toLowerCase() == "new"
                                      ? Container()
                                      : state.currentCondition.toLowerCase() ==
                                              "open box"
                                          ? Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SvgPicture.asset(
                                                            IconSystem
                                                                .openBoxLable,
                                                            width: 30,
                                                            package:
                                                                'gc_customer_app',
                                                          ),
                                                        ]),
                                                    SizedBox(height: 5),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text("Open-Box",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      SizeSystem
                                                                          .size14,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: ColorSystem
                                                                      .primary,
                                                                  fontFamily:
                                                                      kRubik)),
                                                        ]),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SvgPicture.asset(
                                                            IconSystem
                                                                .usedLabel,
                                                            width: 20,
                                                            package:
                                                                'gc_customer_app',
                                                          ),
                                                        ]),
                                                    SizedBox(height: 5),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text("Used",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      SizeSystem
                                                                          .size14,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: ColorSystem
                                                                      .primary,
                                                                  fontFamily:
                                                                      kRubik)),
                                                        ]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: size.height * 0.1,
                        color: ColorSystem.greyBackground,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 10.0, left: 50, right: 50),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: state.images.map((e) {
                                return AspectRatio(
                                  aspectRatio: 1,
                                  child: InkWell(
                                    onTap: () {
                                      productDetailBloc
                                          .add(SetCurrentImage(image: e));
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: state.currentImage == e
                                                  ? Colors.black
                                                  : ColorSystem.culturedGrey,
                                              width: state.currentImage == e
                                                  ? 1.5
                                                  : 0),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Image(
                                            fit: BoxFit.contain,
                                            image:
                                                CachedNetworkImageProvider(e),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            )),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 0),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              state.records.first.childskus
                                                      ?.first.skuDisplayName ??
                                                  state.records.first
                                                      .productName ??
                                                  '',
                                              maxLines: 3,
                                              style: TextStyle(
                                                  fontSize: SizeSystem.size22,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontFamily: kRubik)),
                                        ),
                                        SizedBox(width: 10),
                                        InkWell(
                                            onTap: () {
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
                                                      value: productDetailBloc,
                                                      child: BlocBuilder<
                                                              ProductDetailBloc,
                                                              ProductDetailState>(
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
                                                                child: cartEligibilityState
                                                                        .fetchEligibility
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
                                                                                      Navigator.pop(dialogContext);
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
                                                                                        await Clipboard.setData(ClipboardData(text: state.records.first.childskus?.first.gcItemNumber ?? ''));
                                                                                        showMessage(context: context, message: 'Copied POS Sku - ${state.records.first.childskus?.first.gcItemNumber ?? ''}');
                                                                                      },
                                                                                      child: Container(
                                                                                        color: Colors.transparent,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Text("POS Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                            SizedBox(height: 4),
                                                                                            Text(state.records.first.childskus?.first.gcItemNumber ?? '',
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
                                                                                        await Clipboard.setData(ClipboardData(text: state.records.first.childskus?.first.skuPIMId ?? ''));
                                                                                        showMessage(context: context, message: 'Copied PIM Sku - ${state.records.first.childskus?.first.skuPIMId ?? ''}');
                                                                                      },
                                                                                      child: Container(
                                                                                        color: Colors.transparent,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Text("PIM Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                            SizedBox(height: 4),
                                                                                            Text(state.records.first.childskus?.first.skuPIMId ?? '',
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
                                                                                        await Clipboard.setData(ClipboardData(text: state.records.first.childskus?.first.skuENTId ?? ''));
                                                                                        showMessage(context: context, message: 'Copied Sku - ${state.records.first.childskus?.first.skuENTId ?? ''}');
                                                                                      },
                                                                                      child: Container(
                                                                                        color: Colors.transparent,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Text("Sku", textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                                                                                            SizedBox(height: 4),
                                                                                            Text(state.records.first.childskus?.first.skuENTId ?? '',
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
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              dense: true,
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
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
                                                                                    child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isReturnableC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isReturnableC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              dense: true,
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                                                                                    child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPickupAllowedC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPickupAllowedC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              dense: true,
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                                                                                    child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isTruckShipC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isTruckShipC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              dense: true,
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                                                                                    child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPlatinumItemC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isPlatinumItemC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              dense: true,
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                                                                                    child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].is914EligibleC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].is914EligibleC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              dense: true,
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                                                                                    child: Text(cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isBackorderableC! ? "Yes" : "No", style: TextStyle(color: cartEligibilityState.moreInfo.isNotEmpty && cartEligibilityState.moreInfo[0].isBackorderableC! ? Colors.green.shade800 : Colors.red.shade700, fontSize: 19, fontFamily: kRubik)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.black38,
                                                                              height: 1,
                                                                            ),
                                                                            ListTile(
                                                                              dense: true,
                                                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                                              color: ColorSystem.lavender3,
                                              package: 'gc_customer_app',
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(r"$",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size22,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontFamily: kRubik)),
                                                Text(
                                                    amountFormatting(
                                                        double.parse((state
                                                                    .records
                                                                    .first
                                                                    .lowPrice ??
                                                                "0.00")
                                                            .replaceAll(
                                                                "\$", "")
                                                            .replaceAll(
                                                                "Starting at ",
                                                                ""))),
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size24,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontFamily: kRubik)),
                                              ],
                                            ),
                                            widget.highPrice!.isNotEmpty &&
                                                    widget.highPrice
                                                            .toString()
                                                            .replaceAll(
                                                                "Starting at ", "")
                                                            .replaceAll(
                                                                "\$", "") !=
                                                        (state.records.first
                                                                    .lowPrice ??
                                                                "0.00")
                                                            .replaceAll(
                                                                "\$", "")
                                                            .replaceAll(
                                                                "Starting at ", "")
                                                ? Text("\$${double.parse(widget.highPrice ?? "0.00").toStringAsFixed(2)}",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size18,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        decoration: TextDecoration.lineThrough,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.red,
                                                        fontFamily: kRubik))
                                                : SizedBox.shrink(),
                                          ],
                                        ),
                                        inventoryState.isUpdating &&
                                                (inventoryState.updateID == (inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).isNotEmpty ? inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).productId! : state.records.first.productId!) ||
                                                    inventoryState.updateID ==
                                                        (inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).isNotEmpty
                                                            ? inventoryState
                                                                .productsInCart
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId ==
                                                                    state
                                                                        .records
                                                                        .first
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId!)
                                                                .childskus!
                                                                .first
                                                                .skuENTId
                                                            : state
                                                                .records
                                                                .first
                                                                .childskus!
                                                                .first
                                                                .skuENTId) ||
                                                    inventoryState.updateID ==
                                                        (inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).isNotEmpty
                                                            ? inventoryState
                                                                .productsInCart
                                                                .firstWhere((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!)
                                                                .childskus!
                                                                .first
                                                                .skuPIMId
                                                            : state.records.first.childskus!.first.skuPIMId))
                                            ? Card(
                                                elevation: 2,
                                                color: Theme.of(context).primaryColor,
                                                shape: CircleBorder(),
                                                child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child:
                                                      CupertinoActivityIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ))
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  inventoryState.productsInCart
                                                              .isNotEmpty &&
                                                          inventoryState
                                                              .productsInCart
                                                              .where((element) =>
                                                                  element
                                                                      .childskus!
                                                                      .first
                                                                      .skuENTId ==
                                                                  state
                                                                      .records
                                                                      .first
                                                                      .childskus!
                                                                      .first
                                                                      .skuENTId!)
                                                              .isNotEmpty &&
                                                          double.parse(inventoryState
                                                                      .productsInCart
                                                                      .firstWhere((element) =>
                                                                          element.childskus!.first.skuENTId ==
                                                                          state
                                                                              .records
                                                                              .first
                                                                              .childskus!
                                                                              .first
                                                                              .skuENTId!)
                                                                      .quantity!)
                                                                  .toInt() >
                                                              0
                                                      ? Card(
                                                          elevation: 2,
                                                          color: Colors.red,
                                                          shape: CircleBorder(),
                                                          child: InkWell(
                                                            onTap: () {
                                                              inventorySearchBloc.add(isb.RemoveFromCart(
                                                                  favouriteBrandScreenBloc:
                                                                      context.read<
                                                                          FavouriteBrandScreenBloc>(),
                                                                  records: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).isNotEmpty
                                                                      ? inventoryState.productsInCart.firstWhere((element) =>
                                                                          element.childskus!.first.skuENTId ==
                                                                          state
                                                                              .records
                                                                              .first
                                                                              .childskus!
                                                                              .first
                                                                              .skuENTId!)
                                                                      : state
                                                                          .records
                                                                          .first,
                                                                  productId: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).isNotEmpty
                                                                      ? inventoryState
                                                                          .productsInCart
                                                                          .firstWhere((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!)
                                                                          .productId!
                                                                      : state.records.first.productId!,
                                                                  customerID: widget.customerID,
                                                                  orderID: state.orderId!));
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          15.0),
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
                                                      : SizedBox(height: 0, width: 0),
                                                  SizedBox(
                                                    width: inventoryState
                                                                .productsInCart
                                                                .isNotEmpty &&
                                                            inventoryState
                                                                .productsInCart
                                                                .where((element) =>
                                                                    element
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId ==
                                                                    state
                                                                        .records
                                                                        .first
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId!)
                                                                .isNotEmpty &&
                                                            double.parse(inventoryState
                                                                        .productsInCart
                                                                        .firstWhere((element) =>
                                                                            element.childskus!.first.skuENTId ==
                                                                            state.records.first.childskus!.first.skuENTId!)
                                                                        .quantity!)
                                                                    .toInt() >
                                                                0
                                                        ? 10
                                                        : 0,
                                                  ),
                                                  inventoryState.productsInCart
                                                              .isNotEmpty &&
                                                          inventoryState
                                                              .productsInCart
                                                              .where((element) =>
                                                                  element
                                                                      .childskus!
                                                                      .first
                                                                      .skuENTId ==
                                                                  state
                                                                      .records
                                                                      .first
                                                                      .childskus!
                                                                      .first
                                                                      .skuENTId!)
                                                              .isNotEmpty &&
                                                          double.parse(inventoryState
                                                                      .productsInCart
                                                                      .firstWhere((element) =>
                                                                          element.childskus!.first.skuENTId ==
                                                                          state
                                                                              .records
                                                                              .first
                                                                              .childskus!
                                                                              .first
                                                                              .skuENTId!)
                                                                      .quantity!)
                                                                  .toInt() >
                                                              0
                                                      ? Text(
                                                          double.parse(inventoryState
                                                                  .productsInCart
                                                                  .firstWhere((element) =>
                                                                      element
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId ==
                                                                      state
                                                                          .records
                                                                          .first
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId!)
                                                                  .quantity!)
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  SizeSystem
                                                                      .size20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Color(
                                                                  0xFF222222),
                                                              fontFamily:
                                                                  kRubik),
                                                        )
                                                      : SizedBox(height: 0, width: 0),
                                                  inventoryState.productsInCart
                                                              .isNotEmpty &&
                                                          inventoryState
                                                              .productsInCart
                                                              .where((element) =>
                                                                  element
                                                                      .childskus!
                                                                      .first
                                                                      .skuENTId ==
                                                                  state
                                                                      .records
                                                                      .first
                                                                      .childskus!
                                                                      .first
                                                                      .skuENTId!)
                                                              .isNotEmpty &&
                                                          double.parse(inventoryState
                                                                      .productsInCart
                                                                      .firstWhere((element) =>
                                                                          element.childskus!.first.skuENTId ==
                                                                          state
                                                                              .records
                                                                              .first
                                                                              .childskus!
                                                                              .first
                                                                              .skuENTId!)
                                                                      .quantity!)
                                                                  .toInt() >
                                                              0
                                                      ? SizedBox(
                                                          width: 10,
                                                        )
                                                      : SizedBox(height: 0, width: 0),
                                                  Card(
                                                    elevation: 2,
                                                    color: ColorSystem
                                                        .primaryTextColor,
                                                    shape: CircleBorder(),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (state
                                                                .records
                                                                .first
                                                                .childskus
                                                                ?.first
                                                                .skuId !=
                                                            null) {
                                                          state.records.first
                                                                  .productId =
                                                              state
                                                                  .records
                                                                  .first
                                                                  .childskus!
                                                                  .first
                                                                  .skuId;
                                                          state.records.first
                                                                  .productName =
                                                              state
                                                                  .records
                                                                  .first
                                                                  .childskus!
                                                                  .first
                                                                  .skuDisplayName;
                                                        }

                                                        inventorySearchBloc.add(isb.AddToCart(
                                                            favouriteBrandScreenBloc: context.read<
                                                                FavouriteBrandScreenBloc>(),
                                                            records: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).isNotEmpty
                                                                ? inventoryState.productsInCart.firstWhere((element) =>
                                                                    element
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId ==
                                                                    state
                                                                        .records
                                                                        .first
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId!)
                                                                : state.records
                                                                    .first,
                                                            productId: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!).isNotEmpty
                                                                ? inventoryState
                                                                    .productsInCart
                                                                    .firstWhere((element) => element.childskus!.first.skuENTId == state.records.first.childskus!.first.skuENTId!)
                                                                    .productId!
                                                                : state.records.first.productId!,
                                                            ifWarranties: state.currentProCoverage.isEmpty ? false : true,
                                                            orderItem: "",
                                                            warranties: state.currentProCoverage.isEmpty ? Warranties() : state.currentProCoverage.first,
                                                            customerID: widget.customerID,
                                                            orderID: inventoryState.orderId));
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            15.0),
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
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: ColorSystem.greyBackground,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(50),
                                        topRight: Radius.circular(50),
                                      )),
                                  child: Column(
                                    children: [
                                      state.loadingBundles
                                          ? Container(
                                              height: 100,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            )
                                          : state.productRecommands.isEmpty ||
                                                  state
                                                      .productRecommands
                                                      .first
                                                      .recommendedProductSet!
                                                      .isEmpty
                                              ? Container(
                                                  height: 100,
                                                  child: Center(
                                                      child: Text(
                                                          "No Add-on found",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  SizeSystem
                                                                      .size15,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: ColorSystem
                                                                  .primaryTextColor,
                                                              fontFamily:
                                                                  kRubik))),
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 30),
                                                  child: state.expandBundle
                                                      ? InkWell(
                                                          onTap: () {
                                                            productDetailBloc.add(
                                                                SetExpandBundle(
                                                                    expandBundle:
                                                                        false));
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                  height: 10),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      "Add-on :",
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          fontSize: SizeSystem
                                                                              .size20,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color: ColorSystem
                                                                              .primary,
                                                                          fontFamily:
                                                                              kRubik)),
                                                                  Text(
                                                                      " ${state.productRecommands.first.recommendedProductSet!.length}",
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          fontSize: SizeSystem
                                                                              .size20,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          color: ColorSystem
                                                                              .primary,
                                                                          fontFamily:
                                                                              kRubik)),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 20),
                                                              Flexible(
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: state
                                                                        .productRecommands
                                                                        .first
                                                                        .recommendedProductSet!
                                                                        .map(
                                                                            (e) {
                                                                      int index = state
                                                                          .productRecommands
                                                                          .first
                                                                          .recommendedProductSet!
                                                                          .indexOf(
                                                                              e);
                                                                      return Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                5),
                                                                        child:
                                                                            Container(
                                                                          constraints:
                                                                              BoxConstraints(maxWidth: 120),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Stack(
                                                                                clipBehavior: Clip.none,
                                                                                children: [
                                                                                  Container(
                                                                                    height: 120,
                                                                                    width: 120,
                                                                                    clipBehavior: Clip.hardEdge,
                                                                                    decoration: BoxDecoration(color: ColorSystem.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                                                                                      BoxShadow(
                                                                                        color: Colors.grey.withOpacity(0.3),
                                                                                        spreadRadius: 1,
                                                                                        blurRadius: 5,
                                                                                        offset: Offset(0, 3), // changes position of shadow
                                                                                      ),
                                                                                    ]),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(8.0),
                                                                                      child: CachedNetworkImage(fit: BoxFit.cover, imageUrl: e.imageURL!),
                                                                                    ),
                                                                                  ),
                                                                                  Positioned(
                                                                                      bottom: 5,
                                                                                      right: 3,
                                                                                      child: e.records!.isUpdating!
                                                                                          ? Container(
                                                                                              decoration: BoxDecoration(
                                                                                                shape: BoxShape.circle,
                                                                                                color: Theme.of(context).primaryColor,
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.all(11.0),
                                                                                                child: Center(
                                                                                                  child: CupertinoActivityIndicator(
                                                                                                    color: Colors.white,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          : inventoryState.isUpdating && (inventoryState.updateID == e.productId! || inventoryState.updateSKUID == e.productId! || inventoryState.updateID == e.itemSKU! || inventoryState.updateSKUID == e.itemSKU! || inventoryState.updateID == "${e.records!.childskus != null && e.records!.childskus!.isNotEmpty ? e.records!.childskus!.first.skuENTId! : "-PRODUCT"}" || inventoryState.updateSKUID == "${e.records!.childskus != null && e.records!.childskus!.isNotEmpty ? e.records!.childskus!.first.skuENTId! : "-PRODUCT"}")
                                                                                              ? Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    shape: BoxShape.circle,
                                                                                                    color: Theme.of(context).primaryColor,
                                                                                                  ),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsets.all(11.0),
                                                                                                    child: Center(
                                                                                                      child: CupertinoActivityIndicator(
                                                                                                        color: Colors.white,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              : (inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == e.itemSKU).isEmpty)
                                                                                                  ? CircularAddButton(
                                                                                                      buttonColor: Theme.of(context).primaryColor,
                                                                                                      onPressed: () {
                                                                                                        if (e.records!.childskus!.isEmpty) {
                                                                                                          productDetailBloc.add(GetProductDetail(index: index, id: e.itemSKU!, customerId: widget.customerID, inventorySearchBloc: inventorySearchBloc, state: inventoryState));
                                                                                                        } else {
                                                                                                          if (inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == e.itemSKU).isEmpty || double.parse(inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.itemSKU!).quantity ?? "0").toInt().toString() == "0") {
                                                                                                            inventorySearchBloc.add(isb.GetWarranties(
                                                                                                              records: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == e.itemSKU!).isNotEmpty ? inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.itemSKU) : e.records!,
                                                                                                              skuEntId: e.records!.childskus!.first.skuENTId!,
                                                                                                              productId: e.itemSKU!,
                                                                                                            ));
                                                                                                          } else {
                                                                                                            inventorySearchBloc.add(isb.AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(), records: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == e.itemSKU).isNotEmpty ? inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.records!.childskus!.first.skuENTId!) : e.records!, customerID: widget.customerID, quantity: double.parse(inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.itemSKU!).quantity ?? "0").toInt() + 1, ifWarranties: false, orderItem: "", warranties: Warranties(), productId: e.itemSKU!, skUid: e.itemSKU!, orderID: inventoryState.orderId));
                                                                                                          }
                                                                                                        }
                                                                                                      },
                                                                                                    )
                                                                                                  : Container(
                                                                                                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.6), borderRadius: BorderRadius.circular(100)),
                                                                                                      child: Row(
                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                        children: [
                                                                                                          InkWell(
                                                                                                            onTap: (inventoryState.isUpdating && (inventoryState.updateID != e.itemSKU! && inventoryState.updateSKUID != e.itemSKU!))
                                                                                                                ? () {
                                                                                                                    showMessage(context: context, message: "Please wait until previous item update");
                                                                                                                  }
                                                                                                                : () {
                                                                                                                    inventorySearchBloc.add(isb.RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(), records: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == e.itemSKU).isNotEmpty ? inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.itemSKU) : e.records!, customerID: widget.customerID, quantity: -1, productId: e.itemSKU!, orderID: inventoryState.orderId));
                                                                                                                  },
                                                                                                            child: Padding(
                                                                                                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                                                                                                              child: Text(
                                                                                                                "-",
                                                                                                                style: TextStyle(fontSize: SizeSystem.size24, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: kRubik),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          Padding(
                                                                                                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                                                                                                            child: Text(
                                                                                                              double.parse(inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.itemSKU).quantity ?? "0").toInt().toString(),
                                                                                                              style: TextStyle(fontSize: SizeSystem.size18, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: kRubik),
                                                                                                            ),
                                                                                                          ),
                                                                                                          InkWell(
                                                                                                            onTap: (inventoryState.isUpdating && inventoryState.updateID != e.itemSKU! && inventoryState.updateSKUID != e.itemSKU!)
                                                                                                                ? () {
                                                                                                                    showMessage(context: context, message: "Please wait until previous item update");
                                                                                                                  }
                                                                                                                : () {
                                                                                                                    inventorySearchBloc.add(isb.AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(), records: inventoryState.productsInCart.where((element) => element.childskus!.first.skuENTId == e.itemSKU!).isNotEmpty ? inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.itemSKU!) : e.records!, customerID: widget.customerID, quantity: double.parse(inventoryState.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == e.itemSKU!).quantity ?? "0").toInt() + 1, ifWarranties: false, orderItem: "", warranties: Warranties(), productId: e.itemSKU!, skUid: e.itemSKU!, orderID: inventoryState.orderId));
                                                                                                                  },
                                                                                                            child: Padding(
                                                                                                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                                                                                                              child: Text(
                                                                                                                "+",
                                                                                                                style: TextStyle(fontSize: SizeSystem.size24, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: kRubik),
                                                                                                              ),
                                                                                                            ),
                                                                                                          )
                                                                                                        ],
                                                                                                      ),
                                                                                                    )),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 5),
                                                                              Text(e.name!, maxLines: 3, textAlign: TextAlign.center, style: TextStyle(fontSize: SizeSystem.size13, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor, fontFamily: kRubik)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            productDetailBloc.add(
                                                                SetExpandBundle(
                                                                    expandBundle:
                                                                        true));
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                      "Add-on :",
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          fontSize: SizeSystem
                                                                              .size20,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color: ColorSystem
                                                                              .primary,
                                                                          fontFamily:
                                                                              kRubik)),
                                                                  Text(
                                                                      " ${state.productRecommands.first.recommendedProductSet!.length}",
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          fontSize: SizeSystem
                                                                              .size20,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          color: ColorSystem
                                                                              .primary,
                                                                          fontFamily:
                                                                              kRubik)),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  width: 50),
                                                              Flexible(
                                                                child: SingleChildScrollView(
                                                                    scrollDirection: Axis.horizontal,
                                                                    child: Row(
                                                                        children: state.productRecommands.first.recommendedProductSet!.map((e) {
                                                                      return Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  2,
                                                                              vertical:
                                                                                  1),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                55,
                                                                            child:
                                                                                AspectRatio(
                                                                              aspectRatio: 1,
                                                                              child: Padding(
                                                                                padding: EdgeInsets.all(4.0),
                                                                                child: Container(
                                                                                  clipBehavior: Clip.hardEdge,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.white,
                                                                                    borderRadius: BorderRadius.circular(1000),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(5.0),
                                                                                    child: CachedNetworkImage(
                                                                                      height: 50,
                                                                                      width: 50,
                                                                                      fit: BoxFit.cover,
                                                                                      imageUrl: e.imageURL!,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ));
                                                                    }).toList())),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(50),
                                              topRight: Radius.circular(50),
                                            )),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 30),
                                          child: InkWell(
                                              onTap: () {
                                                productDetailBloc.add(
                                                    SetExpandColor(
                                                        expandColor:
                                                            state.expandColor
                                                                ? false
                                                                : true));
                                              },
                                              child: _styleWidget(state)),
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: ColorSystem.greyBackground,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(50),
                                        topRight: Radius.circular(50),
                                      )),
                                  child: Column(
                                    children: [
                                      state.productDetailStatus ==
                                              ProductDetailStatus.loadState
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 30),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(),
                                                ],
                                              ),
                                            )
                                          : state.proCoverageModel.isEmpty ||
                                                  state.proCoverageModel[0]
                                                      .warranties!.isEmpty
                                              ? Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 20.0,
                                                              horizontal: 23),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              "No coverage plans are available for this product.",
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      SizeSystem
                                                                          .size14,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: ColorSystem
                                                                      .primary,
                                                                  fontFamily:
                                                                      kRubik)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    !state.expandCoverage
                                                        ? Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        20.0,
                                                                    horizontal:
                                                                        30),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    productDetailBloc.add(SetExpandCoverage(
                                                                        expandCoverage:
                                                                            false));
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          "Pro-Coverage :",
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              fontSize: SizeSystem.size20,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Theme.of(context).primaryColor,
                                                                              fontFamily: kRubik)),
                                                                      Text(
                                                                          state.currentProCoverage.isEmpty
                                                                              ? "Select Pro Coverage"
                                                                              : state.currentProCoverage[0].styleDescription1!.isEmpty
                                                                                  ? state.currentProCoverage[0].displayName!
                                                                                  : state.currentProCoverage[0].styleDescription1!.replaceAll("", ""),
                                                                          style: TextStyle(fontSize: SizeSystem.size17, overflow: TextOverflow.ellipsis, fontWeight: state.currentProCoverage.isEmpty ? FontWeight.w400 : FontWeight.w400, color: state.currentProCoverage.isEmpty ? Colors.red : ColorSystem.lavender3, fontFamily: kRubik)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: state
                                                                      .proCoverageModel
                                                                      .first
                                                                      .warranties!
                                                                      .sortedBy(
                                                                          (it) =>
                                                                              it.price!)
                                                                      .toList()
                                                                      .map((e) {
                                                                    return InkWell(
                                                                      onTap: (state.proCoverageModel.first.warranties!.where((element) => (element.isLoading??false)).isNotEmpty) ?
                                                                          (){
                                                                        showMessage(message: "Pro-coverage is updating", context: context);
                                                                      }:() {
                                                                        // productDetailBloc.add(
                                                                        //     SetExpandCoverage(
                                                                        //         expandCoverage:
                                                                        //         false));
                                                                        productDetailBloc.add(SetCurrentCoverage(
                                                                          currentCoverage: e,
                                                                          inventorySearchBloc: inventorySearchBloc,
                                                                          itemsOfCart: inventoryState.itemOfCart,
                                                                          productsInCart: inventoryState.productsInCart,
                                                                          orderID: state.orderId ?? "",
                                                                          styleDescription1: e.styleDescription1 ?? "",
                                                                          orderLineItemID: state.orderLineItemId ?? "",
                                                                        ));
                                                                      },
                                                                      child: Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                45,
                                                                            child: AspectRatio(
                                                                              aspectRatio: 1,
                                                                              child: Padding(
                                                                                padding: EdgeInsets.all(10.0),
                                                                                child: (e.isLoading??false)?CupertinoActivityIndicator():Container(
                                                                                  clipBehavior: Clip.hardEdge,
                                                                                  decoration: BoxDecoration(
                                                                                    color: ColorSystem.culturedGrey,
                                                                                    border: Border.all(color: Colors.black, width: 2),
                                                                                    borderRadius: BorderRadius.circular(1000),
                                                                                  ),
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: state.currentProCoverage.isNotEmpty && state.currentProCoverage[0] == e ? Colors.black : null,
                                                                                      shape: BoxShape.circle,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          e.styleDescription1!.isEmpty
                                                                              ? Text(e.displayName.toString(), style: TextStyle(fontSize: SizeSystem.size18, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w400, color: state.currentProCoverage.isNotEmpty && state.currentProCoverage[0] == e ? ColorSystem.lavender3 : ColorSystem.greyDark, fontFamily: kRubik))
                                                                              : Text(e.styleDescription1! + r" $" + e.price!.toStringAsFixed(2), style: TextStyle(fontSize: SizeSystem.size18, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w400, color: state.currentProCoverage.isNotEmpty && state.currentProCoverage[0] == e ? ColorSystem.lavender3 : ColorSystem.greyDark, fontFamily: kRubik)),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () {
                                                              productDetailBloc.add(
                                                                  SetExpandCoverage(
                                                                      expandCoverage:
                                                                          true));
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          20.0,
                                                                      horizontal:
                                                                          30),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      "Pro-Coverage :",
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          fontSize: SizeSystem
                                                                              .size20,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color: ColorSystem
                                                                              .primary,
                                                                          fontFamily:
                                                                              kRubik)),
                                                                  Flexible(
                                                                    child: Text(
                                                                        state.currentProCoverage.isEmpty
                                                                            ? "Select Pro Coverage"
                                                                            : state.currentProCoverage[0].styleDescription1!.isEmpty
                                                                                ? state.currentProCoverage[0].displayName!
                                                                                : state.currentProCoverage[0].styleDescription1!.replaceAll("", ""),
                                                                        maxLines: 2,
                                                                        style: TextStyle(fontSize: SizeSystem.size17, overflow: TextOverflow.ellipsis, fontWeight: state.currentProCoverage.isEmpty ? FontWeight.w400 : FontWeight.w400, color: state.currentProCoverage.isEmpty ? Colors.red : ColorSystem.lavender3, fontFamily: kRubik)),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(50),
                                              topRight: Radius.circular(50),
                                            )),
                                        child: state.fetchEligibility
                                            ? Container(
                                                height: 100,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator()))
                                            : Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                    horizontal: 30),
                                                child: state.moreInfo.isEmpty ||
                                                        (!state.moreInfo[0]
                                                                .is914EligibleC! &&
                                                            !state.moreInfo[0]
                                                                .isClearanceItemC! &&
                                                            !state.moreInfo[0]
                                                                .isBackorderableC! &&
                                                            !state.moreInfo[0]
                                                                .isPlatinumItemC! &&
                                                            !state.moreInfo[0]
                                                                .isTruckShipC! &&
                                                            !state.moreInfo[0]
                                                                .isPickupAllowedC! &&
                                                            !state.moreInfo[0]
                                                                .isReturnableC!)
                                                    ? Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20.0,
                                                                horizontal: 30),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                                "Eligibility not found",
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        SizeSystem
                                                                            .size16,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: ColorSystem
                                                                        .primary,
                                                                    fontFamily:
                                                                        kRubik)),
                                                          ],
                                                        ),
                                                      )
                                                    : state.expandEligibility
                                                        ? InkWell(
                                                            onTap: () {
                                                              productDetailBloc.add(
                                                                  SetExpandEligibility(
                                                                      value:
                                                                          false));
                                                            },
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              10.0),
                                                                  child: Text(
                                                                    "Eligibility",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontSize:
                                                                            SizeSystem
                                                                                .size20,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                state.moreInfo
                                                                            .isNotEmpty &&
                                                                        state
                                                                            .moreInfo[
                                                                                0]
                                                                            .isReturnableC!
                                                                    ? ListTile(
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                0),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.returnableIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Returnable",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                                state.moreInfo
                                                                            .isNotEmpty &&
                                                                        state
                                                                            .moreInfo[
                                                                                0]
                                                                            .isPickupAllowedC!
                                                                    ? ListTile(
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                0),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.pickupIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Pickup",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                                state.moreInfo
                                                                            .isNotEmpty &&
                                                                        state
                                                                            .moreInfo[
                                                                                0]
                                                                            .isTruckShipC!
                                                                    ? ListTile(
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                0),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.truckshipIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Truckship",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                                state.moreInfo
                                                                            .isNotEmpty &&
                                                                        state
                                                                            .moreInfo[
                                                                                0]
                                                                            .isPlatinumItemC!
                                                                    ? ListTile(
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                0),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.platinumIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Platinum",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                                state.moreInfo
                                                                            .isNotEmpty &&
                                                                        state
                                                                            .moreInfo[
                                                                                0]
                                                                            .is914EligibleC!
                                                                    ? ListTile(
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
                                                                            Text("914",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                                state.moreInfo
                                                                            .isNotEmpty &&
                                                                        state
                                                                            .moreInfo[
                                                                                0]
                                                                            .isBackorderableC!
                                                                    ? ListTile(
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                0),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.backorderableIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Back Orderable",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                                state.moreInfo
                                                                            .isNotEmpty &&
                                                                        state
                                                                            .moreInfo[
                                                                                0]
                                                                            .isClearanceItemC!
                                                                    ? ListTile(
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                0,
                                                                            horizontal:
                                                                                0),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              IconSystem.clearenceIcon,
                                                                              package: 'gc_customer_app',
                                                                            ),
                                                                            Text(" - Clearance",
                                                                                style: TextStyle(color: Colors.black87, fontSize: 19, fontFamily: kRubik)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                              ],
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () {
                                                              productDetailBloc.add(
                                                                  SetExpandEligibility(
                                                                      value:
                                                                          true));
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                    "Eligibility :",
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            SizeSystem
                                                                                .size20,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: ColorSystem
                                                                            .primary,
                                                                        fontFamily:
                                                                            kRubik)),
                                                                SizedBox(
                                                                    width: 50),
                                                                Flexible(
                                                                  child: SingleChildScrollView(
                                                                      scrollDirection: Axis.horizontal,
                                                                      child: Row(
                                                                        children: [
                                                                          state.moreInfo.isNotEmpty && state.moreInfo[0].isReturnableC!
                                                                              ? Container(
                                                                                  height: 40,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: 1,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(4.0),
                                                                                      child: Container(
                                                                                        clipBehavior: Clip.hardEdge,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          border: Border.all(color: Colors.black, width: 1),
                                                                                          borderRadius: BorderRadius.circular(1000),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: SvgPicture.asset(
                                                                                            IconSystem.returnableIcon,
                                                                                            package: 'gc_customer_app',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                          state.moreInfo.isNotEmpty && state.moreInfo[0].isPickupAllowedC!
                                                                              ? Container(
                                                                                  height: 40,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: 1,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(4.0),
                                                                                      child: Container(
                                                                                        clipBehavior: Clip.hardEdge,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          border: Border.all(color: Colors.black, width: 1),
                                                                                          borderRadius: BorderRadius.circular(1000),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: SvgPicture.asset(
                                                                                            IconSystem.pickupIcon,
                                                                                            package: 'gc_customer_app',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                          state.moreInfo.isNotEmpty && state.moreInfo[0].isTruckShipC!
                                                                              ? Container(
                                                                                  height: 40,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: 1,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(4.0),
                                                                                      child: Container(
                                                                                        clipBehavior: Clip.hardEdge,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          border: Border.all(color: Colors.black, width: 1),
                                                                                          borderRadius: BorderRadius.circular(1000),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: SvgPicture.asset(
                                                                                            IconSystem.truckshipIcon,
                                                                                            package: 'gc_customer_app',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                          state.moreInfo.isNotEmpty && state.moreInfo[0].isPlatinumItemC!
                                                                              ? Container(
                                                                                  height: 40,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: 1,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(4.0),
                                                                                      child: Container(
                                                                                        clipBehavior: Clip.hardEdge,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          border: Border.all(color: Colors.black, width: 1),
                                                                                          borderRadius: BorderRadius.circular(1000),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: SvgPicture.asset(
                                                                                            IconSystem.platinumIcon,
                                                                                            package: 'gc_customer_app',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                          state.moreInfo.isNotEmpty && state.moreInfo[0].is914EligibleC!
                                                                              ? Container(
                                                                                  height: 40,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: 1,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(4.0),
                                                                                      child: Container(
                                                                                        clipBehavior: Clip.hardEdge,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          border: Border.all(color: Colors.black, width: 1),
                                                                                          borderRadius: BorderRadius.circular(1000),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: SvgPicture.asset(
                                                                                            IconSystem.nine14Icon,
                                                                                            package: 'gc_customer_app',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                          state.moreInfo.isNotEmpty && state.moreInfo[0].isBackorderableC!
                                                                              ? Container(
                                                                                  height: 40,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: 1,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(4.0),
                                                                                      child: Container(
                                                                                        clipBehavior: Clip.hardEdge,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          border: Border.all(color: Colors.black, width: 1),
                                                                                          borderRadius: BorderRadius.circular(1000),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: SvgPicture.asset(
                                                                                            IconSystem.backorderableIcon,
                                                                                            package: 'gc_customer_app',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                          state.moreInfo.isNotEmpty && state.moreInfo[0].isClearanceItemC!
                                                                              ? Container(
                                                                                  height: 40,
                                                                                  child: AspectRatio(
                                                                                    aspectRatio: 1,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(4.0),
                                                                                      child: Container(
                                                                                        clipBehavior: Clip.hardEdge,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          border: Border.all(color: Colors.black, width: 1),
                                                                                          borderRadius: BorderRadius.circular(1000),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: SvgPicture.asset(
                                                                                            IconSystem.clearenceIcon,
                                                                                            package: 'gc_customer_app',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : SizedBox.shrink(),
                                                                        ],
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                              ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          }
        }
      });
    });
  }

  Widget _styleWidget(ProductDetailState state) {
    var listItems = widget.childskus ?? state.records.first.childskus!;
    return state.expandColor
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text("Styles :",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: SizeSystem.size20,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                      fontFamily: kRubik)),
              SizedBox(height: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listItems.map((e) {
                  bool isSelected = e.skuENTId ==
                      state.records.first.childskus?.first.skuENTId;
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                    leading: Container(
                      height: 55,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 1)
                                  : null,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(7.0),
                              child: CachedNetworkImage(
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                imageUrl: e.skuImageUrl!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    trailing: Text(
                        "\$ " +
                            double.parse(e.skuPrice ?? "0.00")
                                .toStringAsFixed(2),
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: SizeSystem.size17,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik)),
                    onTap: () {
                      if (!isSelected && e.skuENTId != null) {
                        productDetailBloc.add(PageLoad(
                            skuENTId: e.skuENTId!,
                            inventorySearchBloc: inventorySearchBloc,
                            orderLineItemId: state.orderLineItemId,
                            orderId: state.orderId,
                            warrantyId: widget.warrantyId ?? "",
                            productsInCart: widget.productsInCart));
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          )
        : Row(
            children: [
              Text("Style :",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: SizeSystem.size20,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                      fontFamily: kRubik)),
              Spacer(),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: listItems.map((e) {
                      bool isSelected = e.skuENTId ==
                          state.records.first.childskus?.first.skuENTId;
                      return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          child: Container(
                            height: 55,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: InkWell(
                                onTap: () {
                                  if (!isSelected && e.skuENTId != null) {
                                    productDetailBloc.add(PageLoad(
                                        skuENTId: e.skuENTId!,
                                        orderLineItemId: state.orderLineItemId,
                                        orderId: state.orderId,
                                        inventorySearchBloc: inventorySearchBloc,
                                        warrantyId: widget.warrantyId ?? "",
                                        productsInCart: widget.productsInCart));
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.black, width: 1)
                                          : null,
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: CachedNetworkImage(
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        imageUrl: e.skuImageUrl!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ));
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
  }
}
