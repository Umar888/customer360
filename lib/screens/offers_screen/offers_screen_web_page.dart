import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/bloc/offers_screen_bloc/offers_screen_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/offers_screen_tile_widget.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/select_product_childkus_widget.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;


class OfferScreenWebPage extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  OfferScreenWebPage({super.key, required this.customerInfoModel});

  @override
  State<OfferScreenWebPage> createState() => _OfferScreenWebPageState();
}

class _OfferScreenWebPageState extends State<OfferScreenWebPage> {
  late OffersScreenBloc offersScreenBloc;
  late isb.InventorySearchBloc inventorySearchBloc;
  final StreamController<FlashDeal?> _selectedItemController =
      StreamController<FlashDeal?>.broadcast();
  final StreamController<int> _selectedItemSkuController =
      StreamController<int>.broadcast()..add(0);

  @override
  void initState() {
    offersScreenBloc = context.read<OffersScreenBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    offersScreenBloc.add(LoadOffers());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: ColorSystem.webBackgr,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBarWidget(
            backgroundColor: ColorSystem.webBackgr,
            titletxt: offerstxt,
            leadingWidget: SizedBox.shrink(),
            paddingFromleftLeading: 0,
            textThem: Theme.of(context).textTheme,
            onPressedLeading: () {},
            actionOnPress: () {},
            actionsWidget: SizedBox.shrink(),
            paddingFromRightActions: 0,
          ),
        ),
        body: ListView(
          children: [
            Container(
              height: 55,
              margin: EdgeInsets.all(30),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: ColorSystem.greyMild),
                    bottom: BorderSide(color: ColorSystem.greyMild)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 24, top: 24),
                                  child: Text(
                                    'Recommended for you',
                                    style: theme.headline4,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    'Best Seller',
                                    style: theme.headline4,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    'Newest First',
                                    style: theme.headline4,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    'Brand A-Z',
                                    style: theme.headline4,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                              ],
                            );
                          });
                    },
                    child: SizedBox(
                      height: 55,
                      width: constraints.maxWidth - 180,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.keyboard_arrow_down),
                          ),
                          Text(
                            '42% Clearance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.redTextColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(color: ColorSystem.greyMild),
                                  right:
                                      BorderSide(color: ColorSystem.greyMild))),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            IconSystem.searchIcon,
                            package: 'gc_customer_app',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          width: 55,
                          height: 55,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            IconSystem.filterIcon,
                            package: 'gc_customer_app',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            BlocConsumer<OffersScreenBloc, OfferScreenState>(
                listener: (context, state) {
              if (state is OfferScreenSuccess) {
                if (state.message!.isNotEmpty && state.message != "done") {
                  Future.delayed(Duration.zero, () {
                    setState(() {});
                    showMessage(context: context,message:state.message!);
                  });
                }
                offersScreenBloc.add(EmptyMessage());
              }
            }, builder: (context, state) {
              if (state is OfferScreenSuccess) {
                List<Offers> offers = state.offersScreenModel ?? [];
                return Container(
                  height: 670,
                  width: constraints.maxWidth,
                  margin: EdgeInsets.all(30).copyWith(top: 0),
                  decoration: BoxDecoration(
                      color: ColorSystem.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(35, 140, 128, 248),
                            blurRadius: 18,
                            offset: Offset(0, 12))
                      ]),
                  child: Stack(
                    children: [
                      _productInfo(constraints, offers),
                      Container(
                        height: 670,
                        width: constraints.maxWidth / 2.3,
                        decoration: BoxDecoration(
                            color: ColorSystem.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(35, 140, 128, 248),
                                  blurRadius: 18,
                                  offset: Offset(0, 12))
                            ]),
                        child: ListView.builder(
                          itemCount: offers.length,
                          itemBuilder: (context, index) {
                            print(offers[index].toJson());
                            return BlocProvider.value(
                              value: offersScreenBloc,
                              child: OffersScreenTileWidget(
                                index: index,
                                state: inventorySearchBloc.state,
                                inventorySearchBloc: inventorySearchBloc,
                                customer: widget.customerInfoModel,
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            })
          ],
        ),
      );
    });
  }

  Widget _productInfo(BoxConstraints constraints, List<Offers> offers) {
    var theme = Theme.of(context).textTheme;
    var widgetWidth = constraints.maxWidth / 2.3;
    return Container(
      height: 640,
      width: constraints.maxWidth - 60,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.fromLTRB(0, 60, 30, 60),
      child: Container(
        height: 520,
        width: constraints.maxWidth / 2.3,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: AppColors.greyContainer,
            borderRadius: BorderRadius.circular(12)),
        child: StreamBuilder<FlashDeal?>(
            stream: _selectedItemController.stream,
            initialData: offers.first.flashDeal,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(child: Text('No data found'));
              }
              var offer = snapshot.data!;
              return FutureBuilder(
                  future: offersScreenBloc.getProductDetail(offer.productId!),
                  builder: (context, productSnapshot) {
                    asm.Records? product;
                    if (productSnapshot.data != null &&
                        (productSnapshot.data?.childskus ?? []).isNotEmpty) {
                      product = productSnapshot.data!;
                    }
                    return StreamBuilder<int>(
                        stream: _selectedItemSkuController.stream,
                        initialData: 0,
                        builder: (context, snapshot) {
                          var index = snapshot.data ?? 0;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: (product?.childskus?[index]
                                                        .skuImageUrl ??
                                                    offer.assetPath)
                                                ?.replaceAll(
                                                    '120x120', '500x500') ??
                                            '',
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            alignment: Alignment.center,
                                            width: widgetWidth / 1.7,
                                            height: widgetWidth / 1.7,
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
                                      if (product != null)
                                        SelectProductChildkusWidget(
                                            product: product,
                                            width: widgetWidth / 2,
                                            onTap: ((skuId) {
                                              _selectedItemSkuController.add(
                                                  product!.childskus!
                                                      .indexWhere((p) =>
                                                          p.skuId == skuId));
                                            }))
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 16),
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
                                                        package:
                                                            'gc_customer_app',
                                                        width: 20,
                                                      ),
                                                      SizedBox(
                                                        width: 12,
                                                      ),
                                                      Text(
                                                          product?.overallRating ??
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
                                                      Text("${product?.totalReviews ?? '0'} reviews",
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
                                        SizedBox(height: 10),
                                        if (product != null)
                                          _inStoreQuantityWidget(
                                              product, index),
                                        SizedBox(height: 10),
                                        if (product != null)
                                          _productStateWidget(product, index)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                    color: ColorSystem.white,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            offer.productDisplayName ?? '',
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
                                                    fontWeight:
                                                        FontWeight.w300),
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          '${offer.salePrice}',
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
                                    SvgPicture.asset(
                                      IconSystem.productInfo,
                                      package: 'gc_customer_app',
                                    )
                                  ],
                                ),
                              )
                            ],
                          );
                        });
                  });
            }),
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
                                package: 'gc_customer_app',
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
                                package: 'gc_customer_app',
                                width: 20,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
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
                                  style: TextStyle(
                                      fontSize: 20,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                      fontFamily: kRubik)),
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
                      package: 'gc_customer_app',
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
                      package: 'gc_customer_app',
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
