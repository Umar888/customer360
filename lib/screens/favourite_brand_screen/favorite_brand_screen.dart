import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';

import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/filter_screen/filter_screen.dart';
import 'package:gc_customer_app/screens/product_detail/product_detail_page.dart';
import 'package:gc_customer_app/services/extensions/list_sorting.dart';

import '../../bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import '../../constants/colors.dart';

import '../../common_widgets/app_bar_widget.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../common_widgets/favorite brands/favourite_brand_slide_widget.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';

class FavoriteBrandScreen extends StatefulWidget {
  FavoriteBrandScreen(
      {super.key,
      required this.listOfBrand,
      required this.instrumentName,
      required this.brandName,
      required this.customerInfoModel});
  final List<BrandItems> listOfBrand;
  final String brandName;
  final String instrumentName;
  final CustomerInfoModel customerInfoModel;

  @override
  State<FavoriteBrandScreen> createState() => _FavoriteBrandScreenState();
}

class _FavoriteBrandScreenState extends State<FavoriteBrandScreen> {
  late bool? newArrived;
  late isb.InventorySearchBloc inventorySearchBloc;
  late ProductDetailBloc productDetailBloc;
  late ZipStoreListBloc zipStoreListBloc;
  late FavouriteBrandScreenBloc favouriteBrandScreenBloc;
  TextEditingController searchNameController = TextEditingController();

  bool showSearchName = false;

  // Stream<bool> searchProductStream = responseStream.stream;

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        backgroundColor: ColorSystem.lavender3,
        behavior: SnackBarBehavior.floating,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  late StreamSubscription<isb.InventorySearchState> subscription;
  @override
  void initState() {
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'FavoriteBrandsScreen');
    showUpdates = true;
    newArrived = false;
    favouriteBrandScreenBloc = context.read<FavouriteBrandScreenBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    productDetailBloc = context.read<ProductDetailBloc>();
    zipStoreListBloc = context.read<ZipStoreListBloc>();

    inventorySearchBloc.add(isb.PageLoad(
        isFirstTime: false,
        name: widget.instrumentName + ' ' + widget.brandName,
        offset: 1));
    searchNameInFavouriteBrandScreen =
        widget.instrumentName + ' ' + widget.brandName;

    favouriteBrandScreenBloc.add(
      LoadData(
        brandName: widget.brandName,
        primaryInstrument: widget.instrumentName,
        brandItems: widget.listOfBrand,
        isFavouriteScreen: false,
      ),
    );

    inventorySearchBloc.add(isb.AddOptions());
    searchNameController.text = widget.instrumentName + ' ' + widget.brandName;
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
                                              Navigator.pop(dialogContext);
                                              if (value.styleDescription1!.isNotEmpty) {
                                                inventorySearchBloc.add(isb.AddToCart(
                                                    favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    fromFavorite: true,
                                                    records: state.warrantiesRecord.first,
                                                    customerID: widget.customerInfoModel.records!.first.id!,
                                                    productId: state.warrantiesRecord.first.childskus!.first.skuENTId!,
                                                    orderID: state.orderId,
                                                    ifWarranties: true,
                                                    orderItem: "",
                                                    warranties: value));
                                              }
                                              else {
                                                inventorySearchBloc.add(
                                                    isb.AddToCart(
                                                        favouriteBrandScreenBloc:
                                                            context.read<
                                                                FavouriteBrandScreenBloc>(),
                                                        records: state
                                                            .warrantiesRecord
                                                            .first,
                                                        customerID: widget
                                                            .customerInfoModel
                                                            .records!
                                                            .first
                                                            .id!,
                                                        fromFavorite: true,
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
                                        customerID: widget.customerInfoModel
                                            .records!.first.id!,
                                        fromFavorite: true,
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

  bool isLoading = true;
  bool? showUpdates;

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
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 30,
          ),
          onPressedLeading: () => Navigator.of(context).pop(),
          titletxt: 'FAVORITE BRANDS',
          actionsWidget: SizedBox.shrink(),
          actionOnPress: () => () {},
        ),
      ),
      body: BlocListener<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
        listener: (context, state) {
          if (state is FavouriteBrandScreenSuccess) {
            if (state.product != null && state.product!.childskus!.isNotEmpty) {
              print("state.product!.warranties!.id ${state.product!.warranties!.id}");
              Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ProductDetailPage(
                                customerID: widget.customerInfoModel.records!.first.id!,
                                customer: widget.customerInfoModel,
                                productsInCart: inventorySearchBloc.state.productsInCart.isNotEmpty?inventorySearchBloc.state.productsInCart:[],
                                warranties: state.product!.warranties != null?state.product!.warranties!:Warranties(),
                                highPrice: state.product!.highPrice!,
                                //warrantyId: state.product!.warranties!.id,
                                skUID: state.product!.childskus!.first.skuENTId ?? "",
                                orderId: '',
                                orderLineItemId: '',
                              ),
                          settings: RouteSettings(name: "/detail_page")))
                  .then((value) {
                // if (value != null && value.isNotEmpty) {
                //   setState(() {
                //     inventorySearchBloc.add(
                //         UpdateBottomCart(items: value));
                //   });
                // }
              });
              favouriteBrandScreenBloc.add(InitializeProduct());
            }
            if (state.message != null && state.message!.isNotEmpty) {
              Future.delayed(Duration.zero, () {
                favouriteBrandScreenBloc.add(EmptyMessage());
              });
            }
          }
        },
        child: BlocBuilder<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(
            builder: (context, favState) {
          if (favState is FavouriteBrandScreenSuccess) {
            if ((favState.brandItems != null &&
                    favState.brandItems!.isNotEmpty) ||
                (favState.favoriteItems != null &&
                    favState.favoriteItems!.wrapperinstance != null &&
                    favState.favoriteItems!.wrapperinstance!.records != null &&
                    favState
                        .favoriteItems!.wrapperinstance!.records!.isNotEmpty)) {
              return BlocBuilder<isb.InventorySearchBloc,
                  isb.InventorySearchState>(
                builder: (context, state) {
                  // inventorySearchBloc.state.searchDetailModel.first.faceLst;
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: widthOfScreen * 0.05,
                            right: widthOfScreen * 0.05),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: AspectRatio(
                                      aspectRatio: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color(
                                                    (Random().nextDouble() *
                                                            0xFFFFFF)
                                                        .toInt())
                                                .withOpacity(1.0),
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: Text(
                                            widget.brandName
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: heightOfScreen * 0.03,
                                                fontFamily: kRubik,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: widthOfScreen * 0.02),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.brandName,
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 17,
                                                fontFamily: kRubik,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            'Purchased ${favState.brandItems!.length} Items',
                                            style: textThem.headline5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                inventorySearchBloc.add(
                                  isb.OnClearFilters(
                                    searchDetailModel: state.searchDetailModel,
                                    buildOnTap: true,
                                    isSearchName:
                                        searchNameController.text.isNotEmpty
                                            ? true
                                            : false,
                                    searchName:
                                        searchNameController.text.isEmpty
                                            ? ""
                                            : searchNameController.text,
                                    sortBy: !state.sortName.contains(sortByText)
                                        ? true
                                        : false,
                                    isFavouriteScreen: true,
                                    brandName: widget.brandName,
                                    primaryInstrument: widget.instrumentName,
                                    brandItems: widget.listOfBrand,
                                    favouriteBrandScreenBloc:
                                        favouriteBrandScreenBloc,
                                    favoriteItems: favState.favoriteItems,
                                    productsInCart: state.productsInCart,
                                  ),
                                );
                                // searchNameInFavouriteBrandScreen='';
                                // searchNameController.text='';
                                state.searchDetailModel.first
                                            .lengthOfSelectedFilters >
                                        0
                                    ? showMessage(
                                        context: context,
                                        message: 'Filters has been cleared')
                                    : null;
                              },
                              child: Text(
                                "Clear Filter",
                                style: TextStyle(
                                    fontSize: SizeSystem.size16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                    fontFamily: kRubik),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showSearchName)
                        Column(
                          children: [
                            SizedBox(
                              height: heightOfScreen * 0.02,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: widthOfScreen * 0.07,
                                  right: widthOfScreen * 0.07,
                                  bottom: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        cursorColor: Colors.black,
                                        controller: searchNameController,
                                        decoration: InputDecoration(
                                            hintText: 'Search Name',
                                            border: InputBorder.none),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size30,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: kRubik),
                                        onChanged: (name) {
                                          EasyDebounce.cancelAll();
                                          EasyDebounce.debounce(
                                              'search_name_debounce',
                                              Duration(seconds: 1), () {
                                            showUpdates = false;
                                            inventorySearchBloc.add(
                                              isb.InventorySearchFetch(
                                                  name: name,
                                                  productsInCart:
                                                      state.productsInCart,
                                                  choice: state.selectedChoice,
                                                  searchDetailModel:
                                                      state.searchDetailModel,
                                                  isFavouriteScreen: true,
                                                  favoriteItems:
                                                      favState.favoriteItems!,
                                                  isOfferScreen: false),
                                            );
                                          });
                                          searchNameInFavouriteBrandScreen =
                                              name;
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showUpdates = false;

                                        setState(() {
                                          searchNameController.text = '';
                                          searchNameInFavouriteBrandScreen = '';
                                          inventorySearchBloc.add(
                                            isb.InventorySearchFetch(
                                                name:
                                                    searchNameInFavouriteBrandScreen,
                                                productsInCart:
                                                    state.productsInCart,
                                                choice: state.selectedChoice,
                                                searchDetailModel:
                                                    state.searchDetailModel,
                                                isFavouriteScreen: true,
                                                favoriteItems:
                                                    favState.favoriteItems!,
                                                isOfferScreen: false),
                                          );
                                        });
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        size: 40,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: heightOfScreen * 0.03),
                      Container(
                        width: widthOfScreen,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.favoriteContainerBorder),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: heightOfScreen * 0.08,
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () {
                                          if (inventorySearchBloc
                                              .state.showDiscount) {
                                            inventorySearchBloc.add(
                                                isb.ChangeShowDiscount(
                                                    showDiscount: false));
                                          } else {
                                            inventorySearchBloc.add(
                                                isb.ChangeShowDiscount(
                                                    showDiscount: true));
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: 20, left: 5),
                                                child: RotationTransition(
                                                  turns: inventorySearchBloc
                                                          .state.showDiscount
                                                      ? AlwaysStoppedAnimation(
                                                          90 / 360)
                                                      : AlwaysStoppedAnimation(
                                                          0 / 360),
                                                  child: Icon(
                                                    Icons
                                                        .keyboard_arrow_down_sharp,
                                                    color: Colors.black87,
                                                  ),
                                                )),
                                            Text(
                                              inventorySearchBloc
                                                  .state.sortName,
                                              style: TextStyle(
                                                  fontSize: SizeSystem.size18,
                                                  fontWeight: FontWeight.w500,
                                                  color: inventorySearchBloc
                                                          .state.sortName
                                                          .contains(sortByText)
                                                      ? Colors.black87
                                                      : Colors.red,
                                                  fontFamily: kRubik),
                                            ),
                                            SizedBox(width: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Container(
                                            color: AppColors
                                                .favoriteContainerBorder,
                                            width: 1,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: IconButton(
                                                  onPressed: (() {
                                                    setState(() {
                                                      showSearchName =
                                                          !showSearchName;
                                                    });
                                                  }),
                                                  icon: SvgPicture.asset(
                                                    IconSystem.searchIcon,
                                                    package: 'gc_customer_app',
                                                    width: 25,
                                                    height: 25,
                                                  )),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Container(
                                            color: AppColors
                                                .favoriteContainerBorder,
                                            width: 1,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Container(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                                Expanded(
                                                  child: Center(
                                                    child: Stack(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BlocProvider
                                                                        .value(
                                                                  value:
                                                                      inventorySearchBloc,
                                                                  child:
                                                                      FilterScreen(),
                                                                ),
                                                              ),
                                                            )
                                                                .then((value) {
                                                              if (value) {
                                                                showUpdates =
                                                                    false;
                                                                inventorySearchBloc
                                                                    .add(
                                                                  isb.SearchProductWithFilters(
                                                                    searchDetailModel:
                                                                        inventorySearchBloc
                                                                            .state
                                                                            .searchDetailModel,
                                                                    productsInCart:
                                                                        inventorySearchBloc
                                                                            .state
                                                                            .productsInCart,
                                                                    filteredListOfRefinements: inventorySearchBloc
                                                                        .state
                                                                        .searchDetailModel
                                                                        .first
                                                                        .filteredListOfRefinments!,
                                                                    searchNameInFavouriteBrandScreen,
                                                                    choice: inventorySearchBloc
                                                                        .state
                                                                        .selectedChoice,
                                                                    isFavouriteScreen:
                                                                        true,
                                                                    favoriteItems:
                                                                        favState
                                                                            .favoriteItems,
                                                                    brandName:
                                                                        widget
                                                                            .brandName,
                                                                    brandItems:
                                                                        widget
                                                                            .listOfBrand,
                                                                    primaryInstrument:
                                                                        widget
                                                                            .instrumentName,
                                                                    isOfferScreen:
                                                                        false,
                                                                  ),
                                                                );
                                                              }
                                                              ;
                                                            });
                                                          },
                                                          icon:
                                                              SvgPicture.asset(
                                                            IconSystem
                                                                .filterIcon,
                                                            package:
                                                                'gc_customer_app',
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 0,
                                                          child: Card(
                                                            elevation: 2,
                                                            color: Colors.red,
                                                            shadowColor: Colors
                                                                .red.shade100,
                                                            shape:
                                                                CircleBorder(),
                                                            child: state.inventorySearchStatus ==
                                                                        isb.InventorySearchStatus
                                                                            .successState &&
                                                                    inventorySearchBloc
                                                                            .state
                                                                            .searchDetailModel
                                                                            .first
                                                                            .lengthOfSelectedFilters >
                                                                        0
                                                                ? Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    child: Text(
                                                                      inventorySearchBloc.state.searchDetailModel.first.lengthOfSelectedFilters >
                                                                              0
                                                                          ? inventorySearchBloc
                                                                              .state
                                                                              .searchDetailModel
                                                                              .first
                                                                              .lengthOfSelectedFilters
                                                                              .toString()
                                                                          : '',
                                                                      style: TextStyle(
                                                                          fontSize: SizeSystem
                                                                              .size12,
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Colors
                                                                              .white,
                                                                          fontFamily:
                                                                              kRubik),
                                                                    ),
                                                                  )
                                                                : Container(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: heightOfScreen * 0.02,
                      ),
                      inventorySearchBloc.state.showDiscount
                          ? Expanded(
                              child: ListView.builder(
                                itemCount:
                                    inventorySearchBloc.state.options.length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          showUpdates = false;
                                          inventorySearchBloc.add(
                                              isb.ChangeSelectedChoice(
                                                  choice: inventorySearchBloc
                                                      .state.options[i].title,
                                                  searchText:
                                                      searchNameInFavouriteBrandScreen,
                                                  searchDetailModel:
                                                      inventorySearchBloc.state
                                                          .searchDetailModel,
                                                  productsInCart:
                                                      inventorySearchBloc
                                                          .state.productsInCart,
                                                  indexOfItem: i,
                                                  isFavouriteScreen: true,
                                                  favoriteItems:
                                                      favState.favoriteItems!,
                                                  isOfferScreen: false));
                                        },
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 2),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 50.0),
                                              child: Text(
                                                inventorySearchBloc
                                                    .state.options[i].title,
                                                style: TextStyle(
                                                  color: inventorySearchBloc
                                                              .state
                                                              .selectedChoice ==
                                                          inventorySearchBloc
                                                              .state
                                                              .options[i]
                                                              .title
                                                      ? Colors.red
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: kRubik,
                                                  fontSize: SizeSystem.size18,
                                                ),
                                              ),
                                            ),
                                            inventorySearchBloc
                                                        .state.selectedChoice ==
                                                    inventorySearchBloc
                                                        .state.options[i].title
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.red,
                                                    size: 35,
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: ColorSystem.greyDark,
                                      )
                                    ],
                                  );
                                },
                              ),
                            )
                          : inventorySearchBloc.state.loadingSearch
                              ? Expanded(
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : Expanded(
                                  child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      showUpdates!
                                          ? ListView.builder(
                                              itemCount:
                                                  favState.brandItems!.length,
                                              shrinkWrap: true,
                                              primary: false,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder:
                                                  (context, childListIndex) {
                                                return BlocProvider.value(
                                                  value:
                                                      favouriteBrandScreenBloc,
                                                  child:
                                                      FavouriteBrandSlidesWidget(
                                                    brandItems:
                                                        favState.brandItems ??
                                                            [],
                                                    favoriteItems:
                                                        favState.favoriteItems,
                                                    inventorySearchBloc:
                                                        inventorySearchBloc,
                                                    customer: widget
                                                        .customerInfoModel,
                                                    index: childListIndex,
                                                    ifNative: true,
                                                    state: inventorySearchBloc
                                                        .state,
                                                    onTap: () {
                                                      context.read<FavouriteBrandScreenBloc>().add(LoadProductDetail(
                                                          index: childListIndex,
                                                          ifNative: true,
                                                          id: favState
                                                              .brandItems![
                                                                  childListIndex]
                                                              .itemSkuID!,
                                                          ifDetail: true,
                                                          customerId: widget
                                                              .customerInfoModel
                                                              .records!
                                                              .first
                                                              .id!,
                                                          inventorySearchBloc:
                                                              inventorySearchBloc,
                                                          state:
                                                              inventorySearchBloc
                                                                  .state));
                                                    },
                                                  ),
                                                );
                                              },
                                            )
                                          : SizedBox.shrink(),
                                      favState.favoriteItems!.wrapperinstance!
                                              .records!.isNotEmpty
                                          ? ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: favState
                                                  .favoriteItems!
                                                  .wrapperinstance!
                                                  .records!
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return BlocProvider.value(
                                                  value:
                                                      favouriteBrandScreenBloc,
                                                  child:
                                                      FavouriteBrandSlidesWidget(
                                                    brandItems:
                                                        favState.brandItems ??
                                                            [],
                                                    favoriteItems:
                                                        favState.favoriteItems,
                                                    inventorySearchBloc:
                                                        inventorySearchBloc,
                                                    customer: widget
                                                        .customerInfoModel,
                                                    index: index,
                                                    ifNative: false,
                                                    state: inventorySearchBloc
                                                        .state,
                                                    onTap: () {
                                                      context
                                                          .read<
                                                              FavouriteBrandScreenBloc>()
                                                          .add(LoadProductDetail(
                                                              index: index,
                                                              ifNative: false,
                                                              id: favState
                                                                  .favoriteItems!
                                                                  .wrapperinstance!
                                                                  .records![
                                                                      index]
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId!,
                                                              ifDetail: true,
                                                              customerId: widget
                                                                  .customerInfoModel
                                                                  .records!
                                                                  .first
                                                                  .id!,
                                                              inventorySearchBloc:
                                                                  inventorySearchBloc,
                                                              state:
                                                                  inventorySearchBloc
                                                                      .state));
                                                    },
                                                  ),
                                                );
                                              })
                                          : favState
                                                      .favoriteItems!
                                                      .wrapperinstance!
                                                      .records!
                                                      .isEmpty &&
                                                  favState
                                                      .brandItems!.isNotEmpty
                                              ? Container()
                                              : Center(
                                                  child: NoDataFound(
                                                  fontSize: 24,
                                                )),
                                    ],
                                  ),
                                ))
                    ],
                  );
                },
              );
            } else {
              return Center(
                  child: NoDataFound(
                fontSize: 24,
              ));
            }
          } else if (favState is FavouriteBrandScreenFailure) {
            return Center(
                child: NoDataFound(
              fontSize: 24,
            ));
          } else if (favState is FavouriteBrandScreenProgress) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }

  void doNothing(BuildContext context) {}
}
