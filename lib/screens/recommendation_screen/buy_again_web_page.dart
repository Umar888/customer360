import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/buy_again/recommendation_buy_again_bloc.dart';
import 'package:gc_customer_app/common_widgets/browse_item_tile_widget.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/common_widgets/order_history/order_product.dart';
import 'package:gc_customer_app/common_widgets/slayout.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/select_product_childkus_widget.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/order_history/order_history.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/models/recommendation_Screen_model/buy_again_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/recommendation_screen/recommended_product_detail_web_page.dart';
import 'package:gc_customer_app/utils/common_widgets.dart';

class BuyAgainWebPage extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  BuyAgainWebPage({super.key, required this.customerInfoModel});

  @override
  State<BuyAgainWebPage> createState() => _BuyAgainWebPageState();
}

class _BuyAgainWebPageState extends State<BuyAgainWebPage> {
  late RecommendationBuyAgainBloc recommendedScreenBlocBloc;
  final StreamController<ProductBuyAgain> _selectedItemController =
      StreamController<ProductBuyAgain>.broadcast();
  final StreamController<int> _selectedItemSkuController =
      StreamController<int>.broadcast()..add(0);

  @override
  initState() {
    super.initState();
    recommendedScreenBlocBloc = context.read<RecommendationBuyAgainBloc>();
    recommendedScreenBlocBloc.add(BuyAgainItems());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<RecommendationBuyAgainBloc,
          RecommendationBuyAgainState>(builder: (context, state) {
        if (state is LoadBuyAgainItemsSuccess) {
          var products = state.buyAgainModel!.productBuyAgain;
          if (products.isEmpty) {
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
        if (state is BuyAgainPageProgress) {
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
  }

  Widget _webBody(BoxConstraints constraints, List<ProductBuyAgain> products) {
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
                      itemSku: products[index].itemSKUC,
                      itemPrice: products[index].itemPriceC.toStringAsFixed(2),
                      itemPic: products[index].imageURLC,
                      itemName: products[index].descriptionC,
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
        StreamBuilder<ProductBuyAgain>(
            stream: _selectedItemController.stream,
            initialData: products.first,
            builder: (context, selected) {
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
                  child: FutureBuilder(
                    future: recommendedScreenBlocBloc
                        .getProductDetail(selected.data!.itemSKUC),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        var widgetWidth = constraints.maxWidth - 280;
                        var product = snapshot.data!;
                        return StreamBuilder<int>(
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
                                        imageUrl: (product.childskus?[index]
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
                                          product: product,
                                          width: widgetWidth / 2,
                                          onTap: ((skuId) {
                                            _selectedItemSkuController.add(
                                                product.childskus!.indexWhere(
                                                    (p) => p.skuId == skuId));
                                          }))
                                    ],
                                  ),

                                  ///Store information
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SvgPicture.asset(
                                                        IconSystem.star,
                                                        width: 20,
                                                      ),
                                                      SizedBox(
                                                        width: 12,
                                                      ),
                                                      Text(
                                                          product.overallRating ??
                                                              "0.0",
                                                          style: TextStyle(
                                                              fontSize: 20,
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
                                                    ]),
                                                SizedBox(height: 10),
                                                Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text("${product.totalReviews ?? '0'} reviews",
                                                          style: TextStyle(
                                                              fontSize: 14,
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
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _inStoreQuantityWidget(product, index),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _productStateWidget(product, index)
                                      ],
                                    ),
                                  ),

                                  ///Product information
                                  Container(
                                    width: widgetWidth / 2,
                                    padding: EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                        color: ColorSystem.white,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                    style: theme.caption
                                                        ?.copyWith(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                    children: [
                                                      TextSpan(
                                                          text: product
                                                                  .childskus?[
                                                                      index]
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
                            });
                      }
                      return Center(
                          child: Text(
                        '''Have problem with ${selected.data!.descriptionC}''',
                        maxLines: 2,
                        style: theme.caption
                            ?.copyWith(fontWeight: FontWeight.w400),
                      ));
                    },
                  ),
                ),
              );
            })
      ],
    );
  }

  Widget _mobileBody(List<ProductBuyAgain> products) {
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
                    getProductFunction: recommendedScreenBlocBloc
                        .getProductDetail(products[index].itemSKUC),
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
                    imageUrl: products[index].imageURLC,
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
                        Text(products[index].descriptionC,
                            maxLines: 3,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorSystem.chartBlack,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: kRubik)),
                        SizedBox(height: 10),
                        Text('\$${products[index].itemPriceC}',
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
