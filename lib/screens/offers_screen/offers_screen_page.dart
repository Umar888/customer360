import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/extensions/list_sorting.dart';


import '../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart'
    as fbsb;
import '../../bloc/offers_screen_bloc/offers_screen_bloc.dart';
import '../../common_widgets/app_bar_widget.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../common_widgets/offers_screen_tile_widget.dart';
import '../../primitives/size_system.dart';
import '../product_detail/product_detail_page.dart';

class OffersScreenPage extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  final List<Offers> offers;

  OffersScreenPage(
      {super.key, required this.customerInfoModel, required this.offers});

  @override
  State<OffersScreenPage> createState() => _OffersScreenPageState();
}

class _OffersScreenPageState extends State<OffersScreenPage> {
  late OffersScreenBloc offersScreenBloc;
  late isb.InventorySearchBloc inventorySearchBloc;
  late ProductDetailBloc productDetailBloc;
  late ZipStoreListBloc zipStoreListBloc;

  bool? newArrived;
  late StreamSubscription<isb.InventorySearchState> subscription;
  late StreamSubscription<OfferScreenState> offerSubscription;

  @override
  void initState() {
    super.initState();
    // if (!kIsWeb) FirebaseAnalytics.instance.setCurrentScreen(screenName: 'OffersScreen');
    newArrived = false;
    offersScreenBloc = context.read<OffersScreenBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    productDetailBloc = context.read<ProductDetailBloc>();
    zipStoreListBloc = context.read<ZipStoreListBloc>();
    offersScreenBloc.add(LoadData(offers: widget.offers));
    offerSubscription = offersScreenBloc.stream.listen((state) {
      if (state is OfferScreenSuccess &&
          state.product != null &&
          state.product!.childskus!.isNotEmpty &&
          mounted) {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ProductDetailPage(
                customerID: widget.customerInfoModel.records!.first.id!,
                customer: widget.customerInfoModel,
                highPrice: state.product!.highPrice,
                productsInCart: inventorySearchBloc.state.productsInCart.isNotEmpty?inventorySearchBloc.state.productsInCart:[],

                orderId: '',
                orderLineItemId: '',
                skUID: state.product!.childskus!.first.skuENTId ?? "",
                warranties: Warranties(),
              ),

                settings: RouteSettings(name: "/detail_page")
            )).then((value) {
          // if (value != null && value.isNotEmpty) {
          //   setState(() {
          //     inventorySearchBloc.add(
          //         UpdateBottomCart(items: value));
          //   });
          // }
        });

        offersScreenBloc.add(InitializeProduct());
      }
    });
    subscription = inventorySearchBloc.stream.listen((state) {
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
                                              if (!kIsWeb) {
                                                Navigator.pop(dialogContext);
                                                if (value.styleDescription1!
                                                    .isNotEmpty) {
                                                  inventorySearchBloc.add(isb.AddToCart(
                                                      favouriteBrandScreenBloc:
                                                          context.read<
                                                              fbsb
                                                                  .FavouriteBrandScreenBloc>(),
                                                      records: state
                                                          .warrantiesRecord
                                                          .first,
                                                      customerID: widget
                                                          .customerInfoModel
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
                                                          .warrantiesRecord
                                                          .first,
                                                      customerID: widget
                                                          .customerInfoModel
                                                          .records!
                                                          .first
                                                          .id!,
                                                      favouriteBrandScreenBloc:
                                                          context.read<
                                                              fbsb
                                                                  .FavouriteBrandScreenBloc>(),
                                                      productId: state
                                                          .warrantiesRecord
                                                          .first
                                                          .childskus!
                                                          .first
                                                          .skuENTId!,
                                                      orderID: state.orderId,
                                                      ifWarranties: false,
                                                      orderItem: "",
                                                      warranties:
                                                          Warranties()));
                                                }
                                                setState(() {});
                                              }
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
                                        favouriteBrandScreenBloc: context.read<
                                            fbsb.FavouriteBrandScreenBloc>(),
                                        records: state.warrantiesRecord.first,
                                        customerID: widget.customerInfoModel
                                            .records!.first.id!,
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
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    offerSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar: kIsWeb
          ? null
          : AppBottomNavBar(widget.customerInfoModel, null, null,
              inventorySearchBloc, productDetailBloc, zipStoreListBloc),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBarWidget(
          paddingFromleftLeading: widthOfScreen * 0.034,
          paddingFromRightActions: widthOfScreen * 0.034,
          textThem: textThem,
          leadingWidget: Icon(
            Icons.arrow_back,
            color: Colors.grey[600],
            size: 30,
          ),
          onPressedLeading: () => Navigator.of(context).pop(),
          titletxt: 'OFFERS',
          actionsWidget: SizedBox.shrink(),
          actionOnPress: () => () {},
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Divider(
            height: 1,
          ),
          // Container(
          //   width: widthOfScreen,
          //   decoration: BoxDecoration(
          //     border: Border.all(color: AppColors.favoriteContainerBorder),
          //   ),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       SizedBox(
          //         height: heightOfScreen * 0.08,
          //         child: Center(
          //           child: Row(
          //             children: [
          //               InkWell(
          //                 onTap: () {
          //                   setState(() {
          //                     newArrived = !newArrived!;
          //                   });
          //                 },
          //                 child: Row(
          //                   mainAxisSize: MainAxisSize.min,
          //                   children: [
          //                     Container(
          //                         margin: EdgeInsets.only(
          //                             right: 20, left: widthOfScreen * 0.04),
          //                         child: Icon(
          //                           Icons.keyboard_arrow_down_sharp,
          //                           color: Colors.black87,
          //                         )),
          //                     Text(
          //                       'Sort By',
          //                       style: TextStyle(
          //                         fontSize: SizeSystem.size18,
          //                         fontWeight: FontWeight.w500,
          //                         color: Colors.black,
          //                       ),
          //                     ),
          //                     SizedBox(width: widthOfScreen * 0.2),
          //                   ],
          //                 ),
          //               ),
          //               Expanded(
          //                 child: Flex(
          //                   direction: Axis.horizontal,
          //                   children: [
          //                     Expanded(
          //                       flex: 1,
          //                       child: Row(
          //                         children: [
          //                           Container(
          //                             color: AppColors.favoriteContainerBorder,
          //                             width: 1,
          //                           ),
          //                           Expanded(
          //                             child: Center(
          //                               child: IconButton(
          //                                   onPressed: (() {}),
          //                                   icon: SvgPicture.asset(
          //                                     IconSystem.searchIcon,
          //                                     width: 25,
          //                                     height: 25,
          //                                   )),
          //                             ),
          //                           )
          //                         ],
          //                       ),
          //                     ),
          //                     Expanded(
          //                       flex: 1,
          //                       child: Row(
          //                         children: [
          //                           Container(
          //                             color: AppColors.favoriteContainerBorder,
          //                             width: 1,
          //                           ),
          //                           Expanded(
          //                             child: Center(
          //                               child: Stack(
          //                                 clipBehavior: Clip.none,
          //                                 children: [
          //                                   IconButton(
          //                                       onPressed: () {},
          //                                       icon: SvgPicture.asset(
          //                                         IconSystem.filterIcon,
          //                                         width: 30,
          //                                         height: 30,
          //                                       )),
          //                                   // Positioned(
          //                                   //   right: -4,
          //                                   //   top: -10,
          //                                   //   child: Card(
          //                                   //     elevation: 2,
          //                                   //     color: Colors.red,
          //                                   //     shadowColor:
          //                                   //         Colors.red.shade100,
          //                                   //     shape: CircleBorder(),
          //                                   //     child: Padding(
          //                                   //       padding: EdgeInsets.all(8.0),
          //                                   //       child: Text(
          //                                   //         "5",
          //                                   //         style: TextStyle(
          //                                   //           fontSize:
          //                                   //               SizeSystem.size14,
          //                                   //           fontWeight:
          //                                   //               FontWeight.w500,
          //                                   //           color: Colors.white,
          //                                   //         ),
          //                                   //       ),
          //                                   //     ),
          //                                   //   ),
          //                                   // ),
          //                                 ],
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               )
          //             ],
          //           ),
          //         ),
          //       ),
          //       Divider(
          //         height: 1,
          //         color: Colors.grey.shade300,
          //       )
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: heightOfScreen * 0.02,
          // ),
          Expanded(
            child: !newArrived!
                ? BlocConsumer<OffersScreenBloc, OfferScreenState>(
                    listener: (context, state) {
                    if (state is OfferScreenSuccess) {
                      if (state.message!.isNotEmpty &&
                          state.message != "done") {
                        Future.delayed(Duration.zero, () {
                          setState(() {});
                          showMessage(context: context,message:state.message!);
                        });
                      }
                      offersScreenBloc.add(EmptyMessage());
                    }
                  }, builder: (context, state) {
                    if (state is OfferScreenSuccess) {
                      if (state.offersScreenModel != null &&
                          state.offersScreenModel!.isNotEmpty) {
                        return ListView.builder(
                            itemCount: state.offersScreenModel!.length,
                            itemBuilder: (context, index) {
                              if (inventorySearchBloc
                                  .state.productsInCart.isNotEmpty) {
                                for (asm.Records records in inventorySearchBloc
                                    .state.productsInCart) {
                                  if (state.offersScreenModel![index].flashDeal!
                                          .enterpriseSkuId ==
                                      records.childskus!.first.skuENTId) {
                                    offersScreenBloc.add(UpdateProduct(
                                        index: index, records: records));
                                  }
                                }
                              }

                              return BlocProvider.value(
                                value: offersScreenBloc,
                                child: OffersScreenTileWidget(
                                  inventorySearchBloc: inventorySearchBloc,
                                  customer: widget.customerInfoModel,
                                  index: index,
                                  state: inventorySearchBloc.state,
                                ),
                              );
                            });
                      } else {
                        return Center(
                            child: NoDataFound(
                          fontSize: SizeSystem.size24,
                        ));
                      }
                    } else {
                      return Center(
                          child: NoDataFound(
                        fontSize: SizeSystem.size24,
                      ));
                    }
                  })
                : ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: widthOfScreen * 0.1),
                        child: Text(
                          'Recommended for you',
                          style: textThem.headline4,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      SizedBox(height: heightOfScreen * 0.02),
                      Padding(
                        padding: EdgeInsets.only(left: widthOfScreen * 0.1),
                        child: Text(
                          'Best Seller',
                          style: textThem.headline4,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      SizedBox(height: heightOfScreen * 0.02),
                      Padding(
                        padding: EdgeInsets.only(left: widthOfScreen * 0.1),
                        child: Text(
                          'Newest First',
                          style: textThem.headline4,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      SizedBox(height: heightOfScreen * 0.02),
                      Padding(
                        padding: EdgeInsets.only(left: widthOfScreen * 0.1),
                        child: Text(
                          'Brand A-Z',
                          style: textThem.headline4,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void doNothing(BuildContext context) {}
}
