import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart'
    as fbsb;
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/favorite%20brands/favourite_brand_slide_widget.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/favorite_brand_landing_widget.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/common_widgets/slayout.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/select_product_childkus_widget.dart';
import 'package:gc_customer_app/models/favourite_brand_screen_list.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;
import 'package:gc_customer_app/primitives/logout_button_web.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class FavouriteBrandsWebScreen extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  FavouriteBrandsWebScreen({super.key, required this.customerInfoModel});

  @override
  State<FavouriteBrandsWebScreen> createState() =>
      _FavouriteBrandsWebScreenState();
}

class _FavouriteBrandsWebScreenState extends State<FavouriteBrandsWebScreen> {
  late InventorySearchBloc inventorySearchBloc;
  final StreamController<int> _selectedBrandController =
      StreamController<int>.broadcast()..add(0);
  final StreamController<BrandItems?> _selectedItemController =
      StreamController<BrandItems?>.broadcast();
  final StreamController<int> _selectedItemSkuController =
      StreamController<int>.broadcast()..add(0);

  @override
  void initState() {
    inventorySearchBloc = context.read<InventorySearchBloc>();
    inventorySearchBloc.add(PageLoad(isFirstTime: true, name: '', offset: 0));

    context.read<LandingScreenBloc>().add(LoadFavoriteBrands());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        drawer: constraints.maxWidth.isMobileWebDevice()
            ? DrawerLandingWidget()
            : null,
        backgroundColor: ColorSystem.webBackgr,
        appBar: AppBar(
          backgroundColor: ColorSystem.webBackgr,
          centerTitle: true,
          title: Text(favoriteBrandtxt.toUpperCase(),
              style: TextStyle(
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: 15)),
          actions: [LogoutButtonWeb()],
        ),
        body: BlocBuilder<LandingScreenBloc, LandingScreenState>(
            builder: (context, state) {
          if (state.landingScreenStatus == LandingScreenStatus.success &&
              (state.favoriteBrandsLandingScreen ?? []).isNotEmpty) {
            var brands = state.favoriteBrandsLandingScreen;
            context.read<fbsb.FavouriteBrandScreenBloc>().add(fbsb.LoadData(
                brandName: brands?.first.brand,
                primaryInstrument: widget.customerInfoModel.records?.first
                        .primaryInstrumentCategoryC ??
                    '',
                isFavouriteScreen: false,
                brandItems: brands?.first.items));
            _selectedItemController.add(brands?.first.items?.first);
            return ListView(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 32),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: brands?.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 120,
                        width: 120,
                        padding: EdgeInsets.only(right: 8),
                        child: FavoriteBrandLandingWidget(
                          widthOfScreen: constraints.maxWidth,
                          heightOfScreen: constraints.maxHeight,
                          onTap: () {
                            _selectedBrandController.add(index);
                            _selectedItemController
                                .add(brands?[index].items?.first);
                            // context.read<fbsb.FavouriteBrandScreenBloc>().add(
                            //     fbsb.LoadData(
                            //         brandName: brands?[index].brand,
                            //         primaryInstrument: widget
                            //             .customerInfoModel
                            //             .records![index]
                            //             .primaryInstrumentCategoryC!,
                            //         brandItems: brands?[index].items));
                          },
                          brandName: brands?[index].brand ?? '',
                          updates:
                              (brands?[index].items?.length ?? 0).toString(),
                          imageUrl: brands?[index].brandIconName ?? '',
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 18),
                // Container(
                //   height: 55,
                //   margin: EdgeInsets.all(30),
                //   decoration: BoxDecoration(
                //     border: Border(
                //         top: BorderSide(color: ColorSystem.greyMild),
                //         bottom: BorderSide(color: ColorSystem.greyMild)),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       InkWell(
                //         onTap: () {
                //           showModalBottomSheet(
                //               context: context,
                //               builder: (context) {
                //                 return ListView(
                //                   children: [
                //                     Padding(
                //                       padding:
                //                           EdgeInsets.only(left: 24, top: 24),
                //                       child: Text(
                //                         'Recommended for you',
                //                         style: theme.headline4,
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 5,
                //                     ),
                //                     Divider(
                //                       thickness: 1,
                //                     ),
                //                     SizedBox(height: 8),
                //                     Padding(
                //                       padding: EdgeInsets.only(left: 24),
                //                       child: Text(
                //                         'Best Seller',
                //                         style: theme.headline4,
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 5,
                //                     ),
                //                     Divider(
                //                       thickness: 1,
                //                     ),
                //                     SizedBox(height: 8),
                //                     Padding(
                //                       padding: EdgeInsets.only(left: 24),
                //                       child: Text(
                //                         'Newest First',
                //                         style: theme.headline4,
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 5,
                //                     ),
                //                     Divider(
                //                       thickness: 1,
                //                     ),
                //                     SizedBox(height: 8),
                //                     Padding(
                //                       padding: EdgeInsets.only(left: 24),
                //                       child: Text(
                //                         'Brand A-Z',
                //                         style: theme.headline4,
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 5,
                //                     ),
                //                     Divider(
                //                       thickness: 1,
                //                     ),
                //                   ],
                //                 );
                //               });
                //         },
                //         child: SizedBox(
                //           height: 55,
                //           width: constraints.maxWidth - 180,
                //           child: Row(
                //             mainAxisSize: MainAxisSize.max,
                //             children: [
                //               Padding(
                //                 padding: EdgeInsets.symmetric(horizontal: 12),
                //                 child: Icon(Icons.keyboard_arrow_down),
                //               ),
                //               Text(
                //                 'New Arrived',
                //                 style: TextStyle(
                //                   fontSize: 18,
                //                   fontWeight: FontWeight.w500,
                //                   color: AppColors.redTextColor,
                //                 ),
                //               )
                //             ],
                //           ),
                //         ),
                //       ),
                //       Row(
                //         children: [
                //           InkWell(
                //             child: Container(
                //               width: 55,
                //               height: 55,
                //               decoration: BoxDecoration(
                //                   border: Border(
                //                       left: BorderSide(
                //                           color: ColorSystem.greyMild),
                //                       right: BorderSide(
                //                           color: ColorSystem.greyMild))),
                //               alignment: Alignment.center,
                //               child: SvgPicture.asset(
                //                 IconSystem.searchIcon,
                //                 width: 20,
                //                 height: 20,
                //               ),
                //             ),
                //           ),
                //           InkWell(
                //             child: Container(
                //               width: 55,
                //               height: 55,
                //               alignment: Alignment.center,
                //               child: SvgPicture.asset(
                //                 IconSystem.filterIcon,
                //                 width: 20,
                //                 height: 20,
                //               ),
                //             ),
                //           )
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                Container(
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
                  child: StreamBuilder<int>(
                      stream: _selectedBrandController.stream,
                      initialData: 0,
                      builder: (context, snapshot) {
                        var selectedBrands = brands?[snapshot.data ?? 0];
                        return SLayout(
                            desktop: (context, _) => Stack(
                                  children: [
                                    _productInfo(constraints, brands ?? []),
                                    _productList(constraints, selectedBrands),
                                  ],
                                ),
                            mobile: (context, _) =>
                                _productList(constraints, selectedBrands));
                      }),
                )
              ],
            );
          }
          if ((state.gettingFavorites ?? false) &&
              (state.favoriteBrandsLandingScreen ?? []).isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          if (state.landingScreenStatus == LandingScreenStatus.success &&
              (state.favoriteBrandsLandingScreen ?? []).isEmpty) {
            return Container(
                height: double.infinity,
                width: double.infinity,
                color: ColorSystem.white,
                child: Center(child: NoDataFound(fontSize: 14)));
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }),
      );
    });
  }

  Widget _productInfo(
      BoxConstraints constraints, List<FavoriteBrandsLandingScreen> brands) {
    var theme = Theme.of(context).textTheme;
    var widgetWidth = constraints.maxWidth / 2.3;
    return Container(
      height: 670,
      width: constraints.maxWidth - 60,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.fromLTRB(0, 60, 30, 60),
      child: Container(
        height: 550,
        width: constraints.maxWidth / 2.3,
        padding: EdgeInsets.all(30).copyWith(right: 0),
        decoration: BoxDecoration(
            color: AppColors.greyContainer,
            borderRadius: BorderRadius.circular(12)),
        child: StreamBuilder<BrandItems?>(
            stream: _selectedItemController.stream,
            initialData: brands.first.items?.first,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(child: Text('No data found'));
              }
              var brandItem = snapshot.data!;
              return FutureBuilder(
                  future: context
                      .read<fbsb.FavouriteBrandScreenBloc>()
                      .getProductDetail(brandItem.itemSkuID ?? ''),
                  builder: (context, productSnapshot) {
                    asm.Records? product;
                    if (productSnapshot.data != null) {
                      product = productSnapshot.data!;
                    }
                    return StreamBuilder<int>(
                        stream: _selectedItemSkuController.stream,
                        initialData: 0,
                        builder: (context, snapshot) {
                          var index = snapshot.data ?? 0;
                          return Column(
                            children: [
                              (productSnapshot.connectionState ==
                                      ConnectionState.waiting)
                                  ? Center(child: CircularProgressIndicator())
                                  : Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: ((product
                                                                  ?.childskus ??
                                                              [])
                                                          .isNotEmpty
                                                      ? product!
                                                              .childskus![index]
                                                              .skuImageUrl ??
                                                          ''
                                                      : brandItem.imageUrl ??
                                                          '')
                                                  .replaceAll(
                                                      '120x120', '500x500'),
                                              imageBuilder:
                                                  (context, imageProvider) {
                                                return Container(
                                                  alignment: Alignment.center,
                                                  width: widgetWidth / 1.7,
                                                  height: widgetWidth / 1.7,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
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
                                                    _selectedItemSkuController
                                                        .add(product!.childskus!
                                                            .indexWhere((p) =>
                                                                p.skuId ==
                                                                skuId));
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
                                                                    fontSize:
                                                                        20,
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
                                                            Text(
                                                                "${product?.totalReviews ?? '0'} reviews",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
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
                                              if (product != null &&
                                                  (product.childskus ?? [])
                                                      .isNotEmpty)
                                                _inStoreQuantityWidget(
                                                    product, index),
                                              SizedBox(height: 10),
                                              if (product != null &&
                                                  (product.childskus ?? [])
                                                      .isNotEmpty)
                                                _productStateWidget(
                                                    product, index)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                              SizedBox(height: 8),
                              Container(
                                margin: EdgeInsets.only(right: 30),
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
                                            brandItem.description ?? '',
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
                                                      text: (brandItem
                                                                  .unitPrice ??
                                                              0.00)
                                                          .toString(),
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
                      .where((element) =>
                          element.nodeCity! == "N/A" &&
                          element.nodeID! == "Store")
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
                                              element.nodeCity! == "N/A" &&
                                              element.nodeID! == "Store")
                                          .isEmpty
                                      ? "0"
                                      : getZipCodeList.otherNodeData!
                                              .firstWhere((element) =>
                                                  element.nodeCity! == "N/A" &&
                                                  element.nodeID! == "Store")
                                              .stockLevel ??
                                          '0',
                                  maxLines: 2,
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

  Widget _productList(
      BoxConstraints constraints, FavoriteBrandsLandingScreen? selectedBrands) {
    bool isMobile = constraints.maxWidth.isMobileWebDevice();
    return Container(
      height: 670,
      width: constraints.maxWidth / 2.3,
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: isMobile
              ? BorderRadius.circular(20)
              : BorderRadius.only(
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
        itemCount: selectedBrands?.items?.length ?? 0,
        itemBuilder: (context, index) {
          return FavouriteBrandSlidesWidget(
            brandItems: selectedBrands?.items ?? [],
            index: index,
            favoriteItems: null,
            selectedBrandWeb: selectedBrands,
            ifNative: true,
            customer: widget.customerInfoModel,
            onTap: () {
              _selectedItemController.add(selectedBrands?.items![index]);
            },
            state: inventorySearchBloc.state,
            inventorySearchBloc: inventorySearchBloc,
          );
        },
      ),
    );
  }
}
