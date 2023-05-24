import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as pdb;
import 'package:gc_customer_app/bloc/recommended_screen_bloc/browser_history/recommendation_browse_history_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/buy_again/recommendation_buy_again_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/cart/recommendation_cart_bloc.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/logout_button_web.dart';
import 'package:gc_customer_app/screens/recommendation_screen/browse_history_web_page.dart';
import 'package:gc_customer_app/screens/recommendation_screen/buy_again_web_page.dart';
import 'package:gc_customer_app/screens/recommendation_screen/buy_item_page.dart';
import 'package:gc_customer_app/screens/recommendation_screen/cart_item_web_page.dart';
import 'package:gc_customer_app/services/extensions/list_sorting.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

import '../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../primitives/size_system.dart';
import 'browse_history_page.dart';
import 'cart_items_page.dart';

class RecommendationScreen extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  final String? selectedItemId;

  RecommendationScreen(
      {super.key, required this.customerInfoModel, this.selectedItemId});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with TickerProviderStateMixin {
  late InventorySearchBloc inventorySearchBloc;
  late pdb.ProductDetailBloc productDetailBloc;
  late ZipStoreListBloc zipStoreListBloc;
  late StreamSubscription<InventorySearchState> subscription;

  @override
  void initState() {
    super.initState();
    // if (!kIsWeb) FirebaseAnalytics.instance.setCurrentScreen(screenName: 'RecommendationsScreen');
    inventorySearchBloc = context.read<InventorySearchBloc>();
    productDetailBloc = context.read<pdb.ProductDetailBloc>();
    zipStoreListBloc = context.read<ZipStoreListBloc>();

    subscription = inventorySearchBloc.stream.listen((state) {
      if (state.showDialog &&
          !state.fetchWarranties &&
          state.warrantiesRecord.isNotEmpty &&
          mounted &&
          ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.isCurrent) {
        inventorySearchBloc.add(ChangeShowDialog(false));
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
                                              if (value.styleDescription1!
                                                  .isNotEmpty) {
                                                inventorySearchBloc.add(AddToCart(
                                                    favouriteBrandScreenBloc:
                                                        context.read<
                                                            FavouriteBrandScreenBloc>(),
                                                    records: state
                                                        .warrantiesRecord.first,
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
                                                inventorySearchBloc.add(AddToCart(
                                                    records: state
                                                        .warrantiesRecord.first,
                                                    customerID: widget
                                                        .customerInfoModel
                                                        .records!
                                                        .first
                                                        .id!,
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
                                    inventorySearchBloc.add(AddToCart(
                                        favouriteBrandScreenBloc: context
                                            .read<FavouriteBrandScreenBloc>(),
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
          inventorySearchBloc.add(ClearWarranties());
          inventorySearchBloc.add(ChangeShowDialog(false));
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double widthOfScreen = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // drawer: widthOfScreen.isMobileWebDevice() && kIsWeb
        //     ? DrawerLandingWidget()
        //     : null,
        bottomNavigationBar: kIsWeb
            ? null
            : AppBottomNavBar(widget.customerInfoModel, null, null,
                inventorySearchBloc, productDetailBloc, zipStoreListBloc),
        backgroundColor: kIsWeb ? ColorSystem.webBackgr : null,
        appBar: AppBar(
            backgroundColor: kIsWeb ? ColorSystem.webBackgr : null,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: kIsWeb ? ColorSystem.webBackgr : null,
                    leading: kIsWeb ? null : BackButton(),
                    centerTitle: true,
                    title: Text('RECOMMENDATIONS',
                        style: TextStyle(
                            fontFamily: kRubik,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            fontSize: 15)),
                    actions: [
                      if (kIsWeb && !widthOfScreen.isMobileWebDevice())
                        LogoutButtonWeb()
                    ],
                  ),
                  Container(
                      height: 14, color: kIsWeb ? ColorSystem.webBackgr : null),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: kIsWeb ? 4 : SizeSystem.size15,
                        vertical: kIsWeb ? 4 : 0),
                    margin:
                        kIsWeb ? EdgeInsets.symmetric(horizontal: 34) : null,
                    decoration: BoxDecoration(
                      color: kIsWeb ? Color(0xFFE7E5F9) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(
                              0.0,
                              1.0,
                            ),
                            blurRadius: 2,
                            spreadRadius: 2,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      labelColor: Colors.black,
                      tabs: [
                        FittedBox(
                          child: Tab(
                            text: 'Browse History',
                          ),
                        ),
                        FittedBox(
                          child: Tab(
                            text: 'Buy Again',
                          ),
                        ),
                        FittedBox(
                          child: Tab(
                            text: 'Cart',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        body: TabBarView(
            children: kIsWeb
                ? [
                    BlocProvider<RecommendationBrowseHistoryBloc>(
                        create: (context) => RecommendationBrowseHistoryBloc(
                            recommendationScreenRepository:
                                RecommendationScreenRepository()),
                        child: BrowseHistoryWebPage(
                            customerInfoModel: widget.customerInfoModel)),
                    BlocProvider<RecommendationBuyAgainBloc>(
                        create: (context) => RecommendationBuyAgainBloc(
                            recommendationScreenRepository:
                                RecommendationScreenRepository()),
                        child: BuyAgainWebPage(
                            customerInfoModel: widget.customerInfoModel)),
                    BlocProvider<RecommendationCartBloc>(
                        create: (context) => RecommendationCartBloc(
                            recommendationScreenRepository:
                                RecommendationScreenRepository()),
                        child: CartItemWebPage(
                            customerInfoModel: widget.customerInfoModel)),
                  ]
                : [
                    BlocProvider<RecommendationBrowseHistoryBloc>(
                        create: (context) => RecommendationBrowseHistoryBloc(
                            recommendationScreenRepository:
                                RecommendationScreenRepository()),
                        child: BrowseHistoryPage(
                          customerInfoModel: widget.customerInfoModel,
                          inventorySearchBloc: inventorySearchBloc,
                          state: inventorySearchBloc.state,
                          selectedItemId: widget.selectedItemId,
                        )),
                    BlocProvider<RecommendationBuyAgainBloc>(
                        create: (context) => RecommendationBuyAgainBloc(
                            recommendationScreenRepository:
                                RecommendationScreenRepository()),
                        child: BuyAgainItemPage(
                            customerInfoModel: widget.customerInfoModel,
                            inventorySearchBloc: inventorySearchBloc,
                            state: inventorySearchBloc.state)),
                    BlocProvider<RecommendationCartBloc>(
                        create: (context) => RecommendationCartBloc(
                            recommendationScreenRepository:
                                RecommendationScreenRepository()),
                        child: CartItemPage(
                            customerInfoModel: widget.customerInfoModel,
                            inventorySearchBloc: inventorySearchBloc,
                            state: inventorySearchBloc.state))
                  ]),
      ),
    );
  }
}
