import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/select_product_childkus_widget.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/buy_again_model.dart'
as bam;
import 'package:gc_customer_app/models/recommendation_Screen_model/product_cart_browse_items.dart'
as pcbi;
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
as asm;

import '../../models/recommendation_Screen_model/recommendation_screen_browse_history_model.dart';

class RecommendedProductDetailWebPage extends StatefulWidget {
  final dynamic selectedItem;
  final Future? getProductFunction;
  final bool isCart;
  RecommendedProductDetailWebPage(
      {Key? key,
        required this.selectedItem,
        this.getProductFunction,
        this.isCart = false})
      : super(key: key);

  @override
  State<RecommendedProductDetailWebPage> createState() =>
      _RecommendedProductDetailWebPageState();
}

class _RecommendedProductDetailWebPageState
    extends State<RecommendedProductDetailWebPage> {
  final StreamController<int> _selectedItemSkuController =
  StreamController<int>.broadcast()..add(0);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;

    String productName = '';
    if (widget.selectedItem is RecommendedProductSet) {
      productName = (widget.selectedItem as RecommendedProductSet).name;
    } else if (widget.selectedItem is bam.ProductBuyAgain) {
      productName = (widget.selectedItem as bam.ProductBuyAgain).descriptionC;
    } else if (widget.selectedItem is pcbi.Records) {
      productName = (widget.selectedItem as pcbi.Records).productName;
    }
    return Scaffold(
      backgroundColor: ColorSystem.webBackgr,
      appBar: AppBar(
        backgroundColor: ColorSystem.webBackgr,
        centerTitle: true,
        leading: BackButton(),
        title: Text('Product detail',
            style: TextStyle(
                fontFamily: kRubik,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 15)),
      ),
      body: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: ColorSystem.culturedGrey,
            borderRadius: BorderRadius.circular(12)),
        child: FutureBuilder(
          future: widget.getProductFunction,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if ((snapshot.hasData &&
                snapshot.data != null &&
                (snapshot.data?.childskus ?? []).isNotEmpty) ||
                widget.isCart) {
              var widgetWidth = MediaQuery.of(context).size.width;
              var product = snapshot.data ?? widget.selectedItem;
              return StreamBuilder<int>(
                  stream: _selectedItemSkuController.stream,
                  initialData: 0,
                  builder: (context, snapshot) {
                    var index = snapshot.data ?? 0;
                    return ListView(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ///Image Widget
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                  (product.childskus?[index].skuImageUrl ??
                                      '')
                                      .replaceAll('120x120', '500x500'),
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      alignment: Alignment.center,
                                      width: (widgetWidth / 2),
                                      height: widgetWidth / 2,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.contain)),
                                    );
                                  },
                                ),
                                SizedBox(height: 12),
                                SelectProductChildkusWidget(
                                    product: widget.isCart
                                        ? asm.Records.fromJson(product.toJson())
                                        : product,
                                    width: widgetWidth / 2,
                                    onTap: ((skuId) {
                                      _selectedItemSkuController.add(product
                                          .childskus!
                                          .indexWhere((p) => p.skuId == skuId));
                                    }))
                              ],
                            ),

                            ///Store information
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.0),
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
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                    widget.isCart
                                                        ? "0.0"
                                                        : product
                                                        .overallRating ??
                                                        "0.0",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color:
                                                        Theme.of(context).primaryColor,
                                                        fontFamily: kRubik)),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "${product.totalReviews ?? '0'} reviews",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color:
                                                        Theme.of(context).primaryColor,
                                                        fontFamily: kRubik)),
                                              ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _inStoreQuantityWidget(
                                      widget.isCart
                                          ? asm.Records.fromJson(
                                          product.toJson())
                                          : product,
                                      index),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _productStateWidget(
                                      widget.isCart
                                          ? asm.Records.fromJson(
                                          product.toJson())
                                          : product,
                                      index)
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        ///Product information
                        Container(
                          width: widgetWidth / 2,
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: ColorSystem.white,
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '''${product.childskus?[index].skuDisplayName}''',
                                      maxLines: 5,
                                      style: theme.caption?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20),
                                    ),
                                    SizedBox(height: 8),
                                    RichText(
                                      text: TextSpan(
                                          text: '\$',
                                          style: theme.caption?.copyWith(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w300),
                                          children: [
                                            TextSpan(
                                                text: product.childskus?[index]
                                                    .skuPrice ??
                                                    '',
                                                style: theme.caption?.copyWith(
                                                    fontSize: 24,
                                                    fontWeight:
                                                    FontWeight.w500))
                                          ]),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 18),
                              SvgPicture.asset(IconSystem.productInfo)
                            ],
                          ),
                        )
                      ],
                    );
                  });
            }
            return Center(
                child: Text(
                  '''Have problem with ${productName}''',
                  maxLines: 2,
                  style: theme.caption?.copyWith(fontWeight: FontWeight.w400),
                ));
          },
        ),
      ),
    );
  }

  Widget _inStoreQuantityWidget(asm.Records product, int index) {
    return FutureBuilder(
        future: getAddress(product.childskus?[index].skuENTId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var getZipCodeList = snapshot.data;
          return getZipCodeList == null ||
              getZipCodeList.otherNodeData!
                  .where((element) => element.nodeCity! == "N/A")
                  .isEmpty ||
              getZipCodeList.otherNodeData!
                  .firstWhere((element) => element.nodeCity! == "N/A")
                  .stockLevel! ==
                  "0"
              ? Container(
            width: 100,
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          IconSystem.search,
                          color: ColorSystem.white,
                          width: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("0",
                            style: TextStyle(
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w600,
                                color: ColorSystem.white,
                                fontFamily: kRubik)),
                      ]),
                  SizedBox(height: 5),
                  Text("In Store",
                      style: TextStyle(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: ColorSystem.white,
                          fontFamily: kRubik)),
                ],
              ),
            ),
          )
              : Container(
            width: 100,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          IconSystem.greenTick,
                          width: 20,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Text(
                              getZipCodeList.otherNodeData!
                                  .where((element) =>
                              element.nodeCity! == "N/A")
                                  .isEmpty
                                  ? "0"
                                  : getZipCodeList.otherNodeData!
                                  .firstWhere((element) =>
                              element.nodeCity! == "N/A")
                                  .stockLevel
                                  .toString(),
                              maxLines: 3,
                              style: TextStyle(
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: kRubik)),
                        ),
                      ]),
                  SizedBox(height: 5),
                  Text("In Store",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                          fontFamily: kRubik)),
                ],
              ),
            ),
          );
        });
  }

  Future<GetZipCodeList> getAddress(String skuId) async {
    var resp = await ProductDetailRepository(
        productDetailDataSource: ProductDetailDataSource())
        .getAddress(skuId);
    return GetZipCodeList.fromJson(resp.data);
  }

  Widget _productStateWidget(asm.Records product, int index) {
    if (product.childskus?[index].skuCondition?.toLowerCase() == "used") {
      return Container(
        width: 100,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      IconSystem.usedLabel,
                      width: 20,
                    ),
                  ]),
              SizedBox(height: 5),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Used",
                        style: TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik)),
                  ]),
            ],
          ),
        ),
      );
    }
    if (product.childskus?[index].skuCondition?.toLowerCase() == "open box") {
      return Container(
        width: 100,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      IconSystem.openBoxLable,
                      width: 30,
                    ),
                  ]),
              SizedBox(height: 5),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Open-Box",
                        style: TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik)),
                  ]),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}