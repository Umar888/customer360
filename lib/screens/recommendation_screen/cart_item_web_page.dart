import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/cart/recommendation_cart_bloc.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/common_widgets/order_history/order_product.dart';
import 'package:gc_customer_app/common_widgets/slayout.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/select_product_childkus_widget.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart'
    as cim;
import 'package:gc_customer_app/models/order_history/order_history.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/product_cart_browse_items.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/recommendation_screen/recommended_product_detail_web_page.dart';
import 'package:gc_customer_app/utils/common_widgets.dart';

class CartItemWebPage extends StatefulWidget {
  final cim.CustomerInfoModel customerInfoModel;
  CartItemWebPage({super.key, required this.customerInfoModel});

  @override
  State<CartItemWebPage> createState() => _CartItemWebPageState();
}

class _CartItemWebPageState extends State<CartItemWebPage> {
  late RecommendationCartBloc recommendedScreenBlocBloc;
  final StreamController<Records> _selectedItemController =
      StreamController<Records>.broadcast();
  final StreamController<int> _selectedItemSkuController =
      StreamController<int>.broadcast()..add(0);

  @override
  initState() {
    super.initState();
    recommendedScreenBlocBloc = context.read<RecommendationCartBloc>();
    recommendedScreenBlocBloc.add(LoadCartItems());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<RecommendationCartBloc, RecommendationCartState>(
          builder: (context, state) {
        if (state is LoadCartItemsSuccess) {
          if ((state.productCartBrowseItemsModel?.productCart ?? []).isEmpty) {
            return Container(
                height: double.infinity,
                width: double.infinity,
                color: ColorSystem.white,
                child: Center(child: NoDataFound(fontSize: 14)));
          }
          var products = state.productCartBrowseItemsModel!.productCart.first
              .wrapperinstance.records;
          if ((state.productCartBrowseItemsModel?.productCart ?? []).isEmpty) {
            return Container(
                height: double.infinity,
                width: double.infinity,
                color: ColorSystem.white,
                child: Center(child: NoDataFound(fontSize: 14)));
          }
          _selectedItemController.add(products.first);
          return SLayout(
            desktop: (context, _) => _webBody(constraints, products),
            mobile: (context, _) => _mobileBody(products),
          );
        }
        if (state is CartLoadProgress) {
          return Center(child: CircularProgressIndicator());
        }
        return Center(child: Text("No items in recommendations"));
      });
    });
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
                      .where((element) =>
                          element.nodeCity! == "N/A" &&
                          element.nodeID! == "Store")
                      .isEmpty ||
                  getZipCodeList.otherNodeData!
                          .firstWhere((element) =>
                              element.nodeCity! == "N/A" &&
                              element.nodeID! == "Store")
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
                              Text(
                                  getZipCodeList.otherNodeData!
                                          .where((element) =>
                                              element.nodeCity! == "N/A" &&
                                              element.nodeID! == "Store")
                                          .isEmpty
                                      ? "0"
                                      : getZipCodeList.otherNodeData!
                                          .firstWhere((element) =>
                                              element.nodeCity! == "N/A" &&
                                              element.nodeID! == "Store")
                                          .stockLevel
                                          .toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w600,
                                      color: ColorSystem.primary,
                                      fontFamily: kRubik)),
                            ]),
                        SizedBox(height: 5),
                        Text("In Store",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                color: ColorSystem.primary,
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
                            color: ColorSystem.primary,
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
                            color: ColorSystem.primary,
                            fontFamily: kRubik)),
                  ]),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
    ;
  }

  Widget _webBody(BoxConstraints constraints, List<Records> products) {
    var theme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          margin: EdgeInsets.only(left: 32),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 14),
                child: OrderHistoryProductItem(
                  isLanding: true,
                  gettingFavorites: false,
                  gettingActivity: true,
                  orderItems: OrderItems(
                      itemSku: products[index].productId,
                      itemPrice: products[index].productPrice,
                      itemPic: products[index].productImageUrl,
                      itemName: products[index].productName,
                      isNetwork: true,
                      isItemOnline: false,
                      isItemOutOfStock: false),
                  onTap: () {
                    _selectedItemController.add(products[index]);
                  },
                ),
              );
            },
          ),
        ),
        StreamBuilder<Records>(
            stream: _selectedItemController.stream,
            initialData: products.first,
            builder: (context, selected) {
              var widgetWidth = constraints.maxWidth - 280;
              return Container(
                height: constraints.maxHeight - 130,
                width: constraints.maxWidth,
                margin:
                    EdgeInsets.symmetric(horizontal: 31).copyWith(bottom: 10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: ColorSystem.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: ColorSystem.culturedGrey,
                      borderRadius: BorderRadius.circular(12)),
                  child: StreamBuilder<int>(
                      stream: _selectedItemSkuController.stream,
                      initialData: 0,
                      builder: (context, snapshot) {
                        var index = snapshot.data ?? 0;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Image Widget
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: (selected.data?.childskus[index]
                                              .skuImageUrl ??
                                          '')
                                      .replaceAll('120x120', '500x500'),
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      alignment: Alignment.center,
                                      width: (widgetWidth / 2),
                                      height: constraints.maxHeight / 2,
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
                                    product: asm.Records.fromJson(
                                        selected.data!.toJson()),
                                    width: widgetWidth / 2,
                                    onTap: ((skuId) {
                                      _selectedItemSkuController.add(asm.Records
                                              .fromJson(selected.data!.toJson())
                                          .childskus!
                                          .indexWhere((p) => p.skuId == skuId));
                                    }))
                              ],
                            ),

                            ///Store information
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                    (selected.data?.overallRating ??
                                                                '')
                                                            .isEmpty
                                                        ? "0.0"
                                                        : selected.data
                                                            ?.overallRating,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            ColorSystem.primary,
                                                        fontFamily: kRubik)),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "${(selected.data?.totalReviews ?? '').isEmpty ? '0' : selected.data?.totalReviews} reviews",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            ColorSystem.primary,
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
                                      asm.Records.fromJson(
                                          selected.data!.toJson()),
                                      index),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _productStateWidget(
                                      asm.Records.fromJson(
                                          selected.data!.toJson()),
                                      index)
                                ],
                              ),
                            ),

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '''${selected.data?.childskus[index].skuDisplayName}''',
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
                                                    text: selected
                                                            .data
                                                            ?.childskus[index]
                                                            .skuPrice ??
                                                        '',
                                                    style: theme.caption
                                                        ?.copyWith(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
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
                      }),
                ),
              );
            })
      ],
    );
  }

  Widget _mobileBody(List<Records> products) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: products.length,
      padding: EdgeInsets.only(top: 8, bottom: 80),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => Navigator.push(
              context,
              webPageRoute(BlocProvider.value(
                  value: recommendedScreenBlocBloc,
                  child: RecommendedProductDetailWebPage(
                    selectedItem: products[index],
                    isCart: true,
                    // getProductFunction: recommendedScreenBlocBloc
                    //     .getProductDetail(products[index].),
                  )))),
          child: Container(
              height: 130,
              decoration: BoxDecoration(
                  color: ColorSystem.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: ShadowSystem.webWidgetShadow),
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: products[index].productImageUrl,
                    placeholder: (context, url) => Padding(
                      padding: EdgeInsets.all(15.0),
                      child: CupertinoActivityIndicator(),
                    ),
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(0),
                          color: Colors.transparent,
                        ),
                        child: Image(image: imageProvider),
                      );
                    },
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(products[index].productName,
                            maxLines: 3,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorSystem.chartBlack,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: kRubik)),
                        SizedBox(height: 10),
                        Text('\$${products[index].productPrice}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColorSystem.chartBlack,
                                fontFamily: kRubik))
                      ],
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
