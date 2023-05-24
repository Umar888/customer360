import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/browser_history/recommendation_browse_history_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/buy_again/recommendation_buy_again_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/cart/recommendation_cart_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';

import '../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import '../models/cart_model/cart_warranties_model.dart';
import '../primitives/color_system.dart';
import '../primitives/constants.dart';
import '../primitives/size_system.dart';
import 'circular_add_button.dart';

class FrequentlyBoughtWidget extends StatelessWidget {
  FrequentlyBoughtWidget({
    Key? key,
    required this.mainIndex,
    required this.childIndex,
    required this.onPressedProduct,
    required this.inventorySearchBloc,
    required this.customer,
    required this.recommendedState,
  }) : super(key: key);

  final int mainIndex;
  final int childIndex;
  final Function onPressedProduct;
  final InventorySearchBloc inventorySearchBloc;
  final CustomerInfoModel customer;
  final String recommendedState;

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    if (recommendedState == "RecommendationScreenSuccess") {
      return BlocBuilder<RecommendationBrowseHistoryBloc,
              RecommendationBrowseHistoryState>(
          builder: (context, recommendationScreenState) {
        return BlocBuilder<InventorySearchBloc, InventorySearchState>(
            builder: (context, state) {
          if (recommendationScreenState is BrowseHistorySuccess) {
            return AspectRatio(
              aspectRatio: 0.7,
              child: InkWell(
                onTap: () {
                  context.read<RecommendationBrowseHistoryBloc>().add(
                        LoadProductDetailBrowseOtherHistory(
                            childIndex: childIndex,
                            ifDetail: true,
                            customerId: customer.records!.first.id!,
                            parentIndex: mainIndex,
                            inventorySearchBloc: inventorySearchBloc,
                            state: state),
                      );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.1,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                color: ColorSystem.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: Column(
                              children: [
                                Expanded(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: recommendationScreenState
                                        .recommendationScreenModel!
                                        .productBrowsingOthers[mainIndex]
                                        .recommendedProductSet[childIndex]
                                        .imageURL,
                                    imageBuilder: (context, imageProvider) {
                                      return Image.network(
                                        recommendationScreenState
                                            .recommendationScreenModel!
                                            .productBrowsingOthers[mainIndex]
                                            .recommendedProductSet[childIndex]
                                            .imageURL,
                                        width: double.infinity,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                recommendationScreenState
                                        .recommendationScreenModel!
                                        .productBrowsingOthers[mainIndex]
                                        .recommendedProductSet[childIndex]
                                        .isItemOutOfStock!
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 8),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: ColorSystem.pureRed,
                                            border: Border.all(
                                                color: Colors.white, width: 3)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "OUT OF STOCK".toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: SizeSystem.size11,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                      )
                                    : recommendationScreenState
                                            .recommendationScreenModel!
                                            .productBrowsingOthers[mainIndex]
                                            .recommendedProductSet[childIndex]
                                            .isItemOnline!
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color:
                                                    ColorSystem.additionalGreen,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 3)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                    IconSystem.tickIcon,
                                                    package: 'gc_customer_app',
                                                    color: Colors.white,
                                                    width: 12,
                                                    height: 15),
                                                SizedBox(width: 10),
                                                Text(
                                                  "IN STORE".toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize:
                                                          SizeSystem.size11,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            width: 0,
                                            height: 0,
                                          ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 5,
                            left: 3,
                            child: recommendationScreenState
                                    .recommendationScreenModel!
                                    .productBrowsingOthers[mainIndex]
                                    .recommendedProductSet[childIndex]
                                    .isUpdating
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
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
                                : state.isUpdating &&
                                        (state.updateID ==
                                                recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsingOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .productId ||
                                            state.updateSKUID ==
                                                recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsingOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .productId ||
                                            state.updateID ==
                                                recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsingOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .itemSKU ||
                                            state.updateSKUID ==
                                                recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsingOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .itemSKU ||
                                            state.updateID ==
                                                "${recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.isNotEmpty ? recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.first.skuENTId! : "-PRODUCT"}" ||
                                            state.updateSKUID ==
                                                "${recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.isNotEmpty ? recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.first.skuENTId! : "-PRODUCT"}")
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.6),
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
                                    : (state.productsInCart
                                                .where((element) =>
                                                    element.childskus!.first
                                                        .skuENTId ==
                                                    recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsingOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .itemSKU)
                                                .isEmpty ||
                                            recommendationScreenState
                                                .recommendationScreenModel!
                                                .productBrowsingOthers[
                                                    mainIndex]
                                                .recommendedProductSet[
                                                    childIndex]
                                                .records
                                                .childskus!
                                                .isEmpty)
                                        ? CircularAddButton(
                                            buttonColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.6),
                                            onPressed: () {
                                              if (recommendationScreenState
                                                  .recommendationScreenModel!
                                                  .productBrowsingOthers[
                                                      mainIndex]
                                                  .recommendedProductSet[
                                                      childIndex]
                                                  .records
                                                  .childskus!
                                                  .isEmpty) {
                                                context
                                                    .read<
                                                        RecommendationBrowseHistoryBloc>()
                                                    .add(
                                                        LoadProductDetailBrowseOtherHistory(
                                                            parentIndex:
                                                                mainIndex,
                                                            childIndex:
                                                                childIndex,
                                                            customerId: customer
                                                                .records!
                                                                .first
                                                                .id!,
                                                            ifDetail: false,
                                                            inventorySearchBloc:
                                                                inventorySearchBloc,
                                                            state: state));
                                              } else {
                                                if (state.productsInCart
                                                        .where((element) =>
                                                            element
                                                                .childskus!
                                                                .first
                                                                .skuENTId ==
                                                            recommendationScreenState
                                                                .recommendationScreenModel!
                                                                .productBrowsingOthers[
                                                                    mainIndex]
                                                                .recommendedProductSet[
                                                                    childIndex]
                                                                .itemSKU)
                                                        .isEmpty ||
                                                    double.parse(state.productsInCart
                                                                    .firstWhere((element) =>
                                                                        element
                                                                            .childskus!
                                                                            .first
                                                                            .skuENTId ==
                                                                        recommendationScreenState
                                                                            .recommendationScreenModel!
                                                                            .productBrowsingOthers[mainIndex]
                                                                            .recommendedProductSet[childIndex]
                                                                            .itemSKU)
                                                                    .quantity ??
                                                                "0")
                                                            .toInt()
                                                            .toString() ==
                                                        "0") {
                                                  inventorySearchBloc
                                                      .add(GetWarranties(
                                                    records: state.productsInCart
                                                            .where((element) =>
                                                                element
                                                                    .childskus!
                                                                    .first
                                                                    .skuENTId ==
                                                                recommendationScreenState
                                                                    .recommendationScreenModel!
                                                                    .productBrowsingOthers[
                                                                        mainIndex]
                                                                    .recommendedProductSet[
                                                                        childIndex]
                                                                    .itemSKU)
                                                            .isNotEmpty
                                                        ? state.productsInCart.firstWhere((element) =>
                                                            element
                                                                .childskus!
                                                                .first
                                                                .skuENTId ==
                                                            recommendationScreenState
                                                                .recommendationScreenModel!
                                                                .productBrowsingOthers[
                                                                    mainIndex]
                                                                .recommendedProductSet[
                                                                    childIndex]
                                                                .itemSKU)
                                                        : recommendationScreenState
                                                            .recommendationScreenModel!
                                                            .productBrowsingOthers[
                                                                mainIndex]
                                                            .recommendedProductSet[childIndex]
                                                            .records,
                                                    skuEntId: recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsingOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .records
                                                        .childskus!
                                                        .first
                                                        .skuPIMId!,
                                                    productId: recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsingOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .itemSKU,
                                                  ));
                                                } else {
                                                  inventorySearchBloc.add(AddToCart(
                                                      favouriteBrandScreenBloc:
                                                          context.read<
                                                              FavouriteBrandScreenBloc>(),
                                                      records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                          ? state.productsInCart.firstWhere((element) =>
                                                              element
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId ==
                                                              recommendationScreenState
                                                                  .recommendationScreenModel!
                                                                  .productBrowsingOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[childIndex]
                                                                  .records
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId!)
                                                          : recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records,
                                                      customerID: customer.records!.first.id!,
                                                      quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                      ifWarranties: false,
                                                      orderItem: "",
                                                      warranties: Warranties(),
                                                      productId: recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].productId,
                                                      skUid: recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                      orderID: state.orderId));
                                                }
                                              }
                                            },
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: (state.isUpdating &&
                                                          (state.updateID !=
                                                                  recommendationScreenState
                                                                      .recommendationScreenModel!
                                                                      .productBrowsingOthers[
                                                                          mainIndex]
                                                                      .recommendedProductSet[
                                                                          childIndex]
                                                                      .itemSKU &&
                                                              state.updateSKUID !=
                                                                  recommendationScreenState
                                                                      .recommendationScreenModel!
                                                                      .productBrowsingOthers[
                                                                          mainIndex]
                                                                      .recommendedProductSet[
                                                                          childIndex]
                                                                      .itemSKU))
                                                      ? () {
                                                          showMessage(
                                                              context: context,
                                                              message:
                                                                  "Please wait until previous item update");
                                                        }
                                                      : () {
                                                          inventorySearchBloc.add(RemoveFromCart(
                                                              favouriteBrandScreenBloc: context.read<
                                                                  FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                                  ? state.productsInCart.firstWhere((element) =>
                                                                      element.childskus!.first.skuENTId ==
                                                                      recommendationScreenState
                                                                          .recommendationScreenModel!
                                                                          .productBrowsingOthers[
                                                                              mainIndex]
                                                                          .recommendedProductSet[
                                                                              childIndex]
                                                                          .itemSKU)
                                                                  : recommendationScreenState
                                                                      .recommendationScreenModel!
                                                                      .productBrowsingOthers[mainIndex]
                                                                      .recommendedProductSet[childIndex]
                                                                      .records,
                                                              customerID: customer.records!.first.id!,
                                                              quantity: -1,
                                                              productId: recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                              orderID: state.orderId));
                                                        },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5),
                                                    child: Text(
                                                      "-",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5),
                                                  child: Text(
                                                    double.parse(state
                                                                .productsInCart
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId ==
                                                                    recommendationScreenState
                                                                        .recommendationScreenModel!
                                                                        .productBrowsingOthers[
                                                                            mainIndex]
                                                                        .recommendedProductSet[
                                                                            childIndex]
                                                                        .itemSKU)
                                                                .quantity ??
                                                            "0")
                                                        .toInt()
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontFamily: kRubik),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: (state.isUpdating &&
                                                          state.updateID !=
                                                              recommendationScreenState
                                                                  .recommendationScreenModel!
                                                                  .productBrowsingOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[
                                                                      childIndex]
                                                                  .itemSKU &&
                                                          state.updateSKUID !=
                                                              recommendationScreenState
                                                                  .recommendationScreenModel!
                                                                  .productBrowsingOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[
                                                                      childIndex]
                                                                  .itemSKU)
                                                      ? () {
                                                          showMessage(
                                                              context: context,
                                                              message:
                                                                  "Please wait until previous item update");
                                                        }
                                                      : () {
                                                          inventorySearchBloc.add(AddToCart(
                                                              favouriteBrandScreenBloc:
                                                                  context.read<
                                                                      FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                                  ? state.productsInCart.firstWhere((element) =>
                                                                      element
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId ==
                                                                      recommendationScreenState
                                                                          .recommendationScreenModel!
                                                                          .productBrowsingOthers[
                                                                              mainIndex]
                                                                          .recommendedProductSet[childIndex]
                                                                          .records
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId!)
                                                                  : recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].records,
                                                              customerID: customer.records!.first.id!,
                                                              quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                              ifWarranties: false,
                                                              orderItem: "",
                                                              warranties: Warranties(),
                                                              productId: recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].productId,
                                                              skUid: recommendationScreenState.recommendationScreenModel!.productBrowsingOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                              orderID: state.orderId));
                                                        },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5),
                                                    child: Text(
                                                      "+",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                      ],
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    SizedBox(
                      width: widthOfScreen * 0.3,
                      child: Text(
                        recommendationScreenState
                            .recommendationScreenModel!
                            .productBrowsingOthers[mainIndex]
                            .recommendedProductSet[childIndex]
                            .name,
                        style: textThem.headline3,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(
                      height: heightOfScreen * 0.0015,
                    ),
                    Text(
                        '\$' +
                            amountFormatting(recommendationScreenState
                                .recommendationScreenModel!
                                .productBrowsingOthers[mainIndex]
                                .recommendedProductSet[childIndex]
                                .salePrice!),
                        style: TextStyle(
                            fontSize: SizeSystem.size17,
                            fontWeight: FontWeight.w500,
                            color: ColorSystem.chartBlack,
                            fontFamily: kRubik))
                  ],
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        });
      });
    } else if (recommendedState == "LoadBuyAgainItemsSuccess") {
      return BlocBuilder<RecommendationBuyAgainBloc,
              RecommendationBuyAgainState>(
          builder: (context, recommendationScreenState) {
        return BlocBuilder<InventorySearchBloc, InventorySearchState>(
            builder: (context, state) {
          if (recommendationScreenState is LoadBuyAgainItemsSuccess) {
            return AspectRatio(
              aspectRatio: 0.7,
              child: InkWell(
                onTap: () {
                  context.read<RecommendationBuyAgainBloc>().add(
                        LoadProductDetailBuyAgainOther(
                            childIndex: childIndex,
                            ifDetail: true,
                            inventorySearchBloc: inventorySearchBloc,
                            state: state,
                            customerId: customer.records!.first.id!,
                            parentIndex: mainIndex),
                      );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.1,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                color: ColorSystem.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: Column(
                              children: [
                                Expanded(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: recommendationScreenState
                                        .buyAgainModel!
                                        .productBuyAgainOthers[mainIndex]
                                        .recommendedProductSet[childIndex]
                                        .imageURL,
                                    imageBuilder: (context, imageProvider) {
                                      return Image.network(
                                        recommendationScreenState
                                            .buyAgainModel!
                                            .productBuyAgainOthers[mainIndex]
                                            .recommendedProductSet[childIndex]
                                            .imageURL,
                                        width: double.infinity,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                recommendationScreenState
                                        .buyAgainModel!
                                        .productBuyAgainOthers[mainIndex]
                                        .recommendedProductSet[childIndex]
                                        .isItemOutOfStock!
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 8),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: ColorSystem.pureRed,
                                            border: Border.all(
                                                color: Colors.white, width: 3)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "OUT OF STOCK".toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: SizeSystem.size11,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                      )
                                    : recommendationScreenState
                                            .buyAgainModel!
                                            .productBuyAgainOthers[mainIndex]
                                            .recommendedProductSet[childIndex]
                                            .isItemOnline!
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color:
                                                    ColorSystem.additionalGreen,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 3)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                    IconSystem.tickIcon,
                                                    package: 'gc_customer_app',
                                                    color: Colors.white,
                                                    width: 12,
                                                    height: 15),
                                                SizedBox(width: 10),
                                                Text(
                                                  "IN STORE".toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize:
                                                          SizeSystem.size11,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            width: 0,
                                            height: 0,
                                          ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 5,
                            left: 3,
                            child: recommendationScreenState
                                    .buyAgainModel!
                                    .productBuyAgainOthers[mainIndex]
                                    .recommendedProductSet[childIndex]
                                    .isUpdating
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
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
                                : state.isUpdating &&
                                        (state.updateID ==
                                                recommendationScreenState
                                                    .buyAgainModel!
                                                    .productBuyAgainOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .productId ||
                                            state.updateSKUID ==
                                                recommendationScreenState
                                                    .buyAgainModel!
                                                    .productBuyAgainOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .productId ||
                                            state.updateID ==
                                                recommendationScreenState
                                                    .buyAgainModel!
                                                    .productBuyAgainOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .itemSKU ||
                                            state.updateSKUID ==
                                                recommendationScreenState
                                                    .buyAgainModel!
                                                    .productBuyAgainOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .itemSKU ||
                                            state.updateID ==
                                                "${recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.isNotEmpty ? recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.first.skuENTId! : "-PRODUCT"}" ||
                                            state.updateSKUID ==
                                                "${recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.isNotEmpty ? recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.first.skuENTId! : "-PRODUCT"}")
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.6),
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
                                    : (state.productsInCart
                                                .where((element) =>
                                                    element.childskus!.first
                                                        .skuENTId ==
                                                    recommendationScreenState
                                                        .buyAgainModel!
                                                        .productBuyAgainOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .itemSKU)
                                                .isEmpty ||
                                            recommendationScreenState
                                                .buyAgainModel!
                                                .productBuyAgainOthers[
                                                    mainIndex]
                                                .recommendedProductSet[
                                                    childIndex]
                                                .records
                                                .childskus!
                                                .isEmpty)
                                        ? CircularAddButton(
                                            buttonColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.6),
                                            onPressed: () {
                                              if (recommendationScreenState
                                                  .buyAgainModel!
                                                  .productBuyAgainOthers[
                                                      mainIndex]
                                                  .recommendedProductSet[
                                                      childIndex]
                                                  .records
                                                  .childskus!
                                                  .isEmpty) {
                                                context
                                                    .read<
                                                        RecommendationBuyAgainBloc>()
                                                    .add(
                                                        LoadProductDetailBuyAgainOther(
                                                            parentIndex:
                                                                mainIndex,
                                                            childIndex:
                                                                childIndex,
                                                            customerId: customer
                                                                .records!
                                                                .first
                                                                .id!,
                                                            ifDetail: false,
                                                            inventorySearchBloc:
                                                                inventorySearchBloc,
                                                            state: state));
                                              } else {
                                                if (state.productsInCart
                                                        .where((element) =>
                                                            element
                                                                .childskus!
                                                                .first
                                                                .skuENTId ==
                                                            recommendationScreenState
                                                                .buyAgainModel!
                                                                .productBuyAgainOthers[
                                                                    mainIndex]
                                                                .recommendedProductSet[
                                                                    childIndex]
                                                                .itemSKU)
                                                        .isEmpty ||
                                                    double.parse(state.productsInCart
                                                                    .firstWhere((element) =>
                                                                        element
                                                                            .childskus!
                                                                            .first
                                                                            .skuENTId ==
                                                                        recommendationScreenState
                                                                            .buyAgainModel!
                                                                            .productBuyAgainOthers[mainIndex]
                                                                            .recommendedProductSet[childIndex]
                                                                            .itemSKU)
                                                                    .quantity ??
                                                                "0")
                                                            .toInt()
                                                            .toString() ==
                                                        "0") {
                                                  inventorySearchBloc
                                                      .add(GetWarranties(
                                                    records: state.productsInCart
                                                            .where((element) =>
                                                                element
                                                                    .childskus!
                                                                    .first
                                                                    .skuENTId ==
                                                                recommendationScreenState
                                                                    .buyAgainModel!
                                                                    .productBuyAgainOthers[
                                                                        mainIndex]
                                                                    .recommendedProductSet[
                                                                        childIndex]
                                                                    .itemSKU)
                                                            .isNotEmpty
                                                        ? state.productsInCart.firstWhere((element) =>
                                                            element
                                                                .childskus!
                                                                .first
                                                                .skuENTId ==
                                                            recommendationScreenState
                                                                .buyAgainModel!
                                                                .productBuyAgainOthers[
                                                                    mainIndex]
                                                                .recommendedProductSet[
                                                                    childIndex]
                                                                .itemSKU)
                                                        : recommendationScreenState
                                                            .buyAgainModel!
                                                            .productBuyAgainOthers[
                                                                mainIndex]
                                                            .recommendedProductSet[childIndex]
                                                            .records,
                                                    skuEntId: recommendationScreenState
                                                        .buyAgainModel!
                                                        .productBuyAgainOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .records
                                                        .childskus!
                                                        .first
                                                        .skuPIMId!,
                                                    productId:
                                                        recommendationScreenState
                                                            .buyAgainModel!
                                                            .productBuyAgainOthers[
                                                                mainIndex]
                                                            .recommendedProductSet[
                                                                childIndex]
                                                            .itemSKU,
                                                  ));
                                                } else {
                                                  inventorySearchBloc.add(AddToCart(
                                                      favouriteBrandScreenBloc:
                                                          context.read<
                                                              FavouriteBrandScreenBloc>(),
                                                      records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                          ? state.productsInCart.firstWhere((element) =>
                                                              element
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId ==
                                                              recommendationScreenState
                                                                  .buyAgainModel!
                                                                  .productBuyAgainOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[childIndex]
                                                                  .records
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId!)
                                                          : recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records,
                                                      customerID: customer.records!.first.id!,
                                                      quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                      ifWarranties: false,
                                                      orderItem: "",
                                                      warranties: Warranties(),
                                                      productId: recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].productId,
                                                      skUid: recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                      orderID: state.orderId));
                                                }
                                              }
                                            },
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: (state.isUpdating &&
                                                          (state.updateID !=
                                                                  recommendationScreenState
                                                                      .buyAgainModel!
                                                                      .productBuyAgainOthers[
                                                                          mainIndex]
                                                                      .recommendedProductSet[
                                                                          childIndex]
                                                                      .itemSKU &&
                                                              state.updateSKUID !=
                                                                  recommendationScreenState
                                                                      .buyAgainModel!
                                                                      .productBuyAgainOthers[
                                                                          mainIndex]
                                                                      .recommendedProductSet[
                                                                          childIndex]
                                                                      .itemSKU))
                                                      ? () {
                                                          showMessage(
                                                              context: context,
                                                              message:
                                                                  "Please wait until previous item update");
                                                        }
                                                      : () {
                                                          inventorySearchBloc.add(RemoveFromCart(
                                                              favouriteBrandScreenBloc: context.read<
                                                                  FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                                  ? state.productsInCart.firstWhere((element) =>
                                                                      element.childskus!.first.skuENTId ==
                                                                      recommendationScreenState
                                                                          .buyAgainModel!
                                                                          .productBuyAgainOthers[
                                                                              mainIndex]
                                                                          .recommendedProductSet[
                                                                              childIndex]
                                                                          .itemSKU)
                                                                  : recommendationScreenState
                                                                      .buyAgainModel!
                                                                      .productBuyAgainOthers[mainIndex]
                                                                      .recommendedProductSet[childIndex]
                                                                      .records,
                                                              customerID: customer.records!.first.id!,
                                                              quantity: -1,
                                                              productId: recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                              orderID: state.orderId));
                                                        },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5),
                                                    child: Text(
                                                      "-",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5),
                                                  child: Text(
                                                    double.parse(state
                                                                .productsInCart
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId ==
                                                                    recommendationScreenState
                                                                        .buyAgainModel!
                                                                        .productBuyAgainOthers[
                                                                            mainIndex]
                                                                        .recommendedProductSet[
                                                                            childIndex]
                                                                        .itemSKU)
                                                                .quantity ??
                                                            "0")
                                                        .toInt()
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontFamily: kRubik),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: (state.isUpdating &&
                                                          state.updateID !=
                                                              recommendationScreenState
                                                                  .buyAgainModel!
                                                                  .productBuyAgainOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[
                                                                      childIndex]
                                                                  .itemSKU &&
                                                          state.updateSKUID !=
                                                              recommendationScreenState
                                                                  .buyAgainModel!
                                                                  .productBuyAgainOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[
                                                                      childIndex]
                                                                  .itemSKU)
                                                      ? () {
                                                          showMessage(
                                                              context: context,
                                                              message:
                                                                  "Please wait until previous item update");
                                                        }
                                                      : () {
                                                          inventorySearchBloc.add(AddToCart(
                                                              favouriteBrandScreenBloc:
                                                                  context.read<
                                                                      FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                                  ? state.productsInCart.firstWhere((element) =>
                                                                      element
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId ==
                                                                      recommendationScreenState
                                                                          .buyAgainModel!
                                                                          .productBuyAgainOthers[
                                                                              mainIndex]
                                                                          .recommendedProductSet[childIndex]
                                                                          .records
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId!)
                                                                  : recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].records,
                                                              customerID: customer.records!.first.id!,
                                                              quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                              ifWarranties: false,
                                                              orderItem: "",
                                                              warranties: Warranties(),
                                                              productId: recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].productId,
                                                              skUid: recommendationScreenState.buyAgainModel!.productBuyAgainOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                              orderID: state.orderId));
                                                        },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5),
                                                    child: Text(
                                                      "+",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                      ],
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    SizedBox(
                      width: widthOfScreen * 0.3,
                      child: Text(
                        recommendationScreenState
                            .buyAgainModel!
                            .productBuyAgainOthers[mainIndex]
                            .recommendedProductSet[childIndex]
                            .name,
                        style: textThem.headline3,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(
                      height: heightOfScreen * 0.0015,
                    ),
                    Text(
                        '\$' +
                            amountFormatting(recommendationScreenState
                                .buyAgainModel!
                                .productBuyAgainOthers[mainIndex]
                                .recommendedProductSet[childIndex]
                                .salePrice!),
                        style: TextStyle(
                            fontSize: SizeSystem.size17,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.chartBlack,
                            fontFamily: kRubik))
                  ],
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        });
      });
    } else if (recommendedState == "LoadCartItemsSuccess") {
      return BlocBuilder<RecommendationCartBloc, RecommendationCartState>(
          builder: (context, recommendationScreenState) {
        return BlocBuilder<InventorySearchBloc, InventorySearchState>(
            builder: (context, state) {
          if (recommendationScreenState is LoadCartItemsSuccess) {
            return AspectRatio(
              aspectRatio: 0.7,
              child: InkWell(
                onTap: () {
                  context.read<RecommendationCartBloc>().add(
                        LoadProductDetailCartOthers(
                          childIndex: childIndex,
                          ifDetail: true,
                          parentIndex: mainIndex,
                          inventorySearchBloc: inventorySearchBloc,
                          state: state,
                          customerId: customer.records!.first.id!,
                        ),
                      );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.1,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                color: ColorSystem.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: Column(
                              children: [
                                Expanded(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: recommendationScreenState
                                        .productCartFrequentlyBaughtItemsModel!
                                        .productCartOthers[mainIndex]
                                        .recommendedProductSet[childIndex]
                                        .imageURL,
                                    imageBuilder: (context, imageProvider) {
                                      return Image.network(
                                        recommendationScreenState
                                            .productCartFrequentlyBaughtItemsModel!
                                            .productCartOthers[mainIndex]
                                            .recommendedProductSet[childIndex]
                                            .imageURL,
                                        width: double.infinity,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                recommendationScreenState
                                        .productCartFrequentlyBaughtItemsModel!
                                        .productCartOthers[mainIndex]
                                        .recommendedProductSet[childIndex]
                                        .isItemOutOfStock!
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 8),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: ColorSystem.pureRed,
                                            border: Border.all(
                                                color: Colors.white, width: 3)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "OUT OF STOCK".toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: SizeSystem.size11,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                      )
                                    : recommendationScreenState
                                            .productCartFrequentlyBaughtItemsModel!
                                            .productCartOthers[mainIndex]
                                            .recommendedProductSet[childIndex]
                                            .isItemOnline!
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color:
                                                    ColorSystem.additionalGreen,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 3)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                    IconSystem.tickIcon,
                                                    package: 'gc_customer_app',
                                                    color: Colors.white,
                                                    width: 12,
                                                    height: 15),
                                                SizedBox(width: 10),
                                                Text(
                                                  "IN STORE".toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize:
                                                          SizeSystem.size11,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            width: 0,
                                            height: 0,
                                          ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 5,
                            left: 3,
                            child: recommendationScreenState
                                    .productCartFrequentlyBaughtItemsModel!
                                    .productCartOthers[mainIndex]
                                    .recommendedProductSet[childIndex]
                                    .isUpdating
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
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
                                : state.isUpdating &&
                                        (state.updateID ==
                                                recommendationScreenState
                                                    .productCartFrequentlyBaughtItemsModel!
                                                    .productCartOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .productId ||
                                            state.updateSKUID ==
                                                recommendationScreenState
                                                    .productCartFrequentlyBaughtItemsModel!
                                                    .productCartOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .productId ||
                                            state.updateID ==
                                                recommendationScreenState
                                                    .productCartFrequentlyBaughtItemsModel!
                                                    .productCartOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .itemSKU ||
                                            state.updateSKUID ==
                                                recommendationScreenState
                                                    .productCartFrequentlyBaughtItemsModel!
                                                    .productCartOthers[
                                                        mainIndex]
                                                    .recommendedProductSet[
                                                        childIndex]
                                                    .itemSKU ||
                                            state.updateID ==
                                                "${recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.isNotEmpty ? recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.first.skuENTId! : "-PRODUCT"}" ||
                                            state.updateSKUID ==
                                                "${recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.isNotEmpty ? recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records.childskus!.first.skuENTId! : "-PRODUCT"}")
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.6),
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
                                    : (state.productsInCart
                                                .where((element) =>
                                                    element.childskus!.first
                                                        .skuENTId ==
                                                    recommendationScreenState
                                                        .productCartFrequentlyBaughtItemsModel!
                                                        .productCartOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .itemSKU)
                                                .isEmpty ||
                                            recommendationScreenState
                                                .productCartFrequentlyBaughtItemsModel!
                                                .productCartOthers[mainIndex]
                                                .recommendedProductSet[
                                                    childIndex]
                                                .records
                                                .childskus!
                                                .isEmpty)
                                        ? CircularAddButton(
                                            buttonColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.6),
                                            onPressed: () {
                                              if (recommendationScreenState
                                                  .productCartFrequentlyBaughtItemsModel!
                                                  .productCartOthers[mainIndex]
                                                  .recommendedProductSet[
                                                      childIndex]
                                                  .records
                                                  .childskus!
                                                  .isEmpty) {
                                                context
                                                    .read<
                                                        RecommendationCartBloc>()
                                                    .add(
                                                        LoadProductDetailCartOthers(
                                                            parentIndex:
                                                                mainIndex,
                                                            childIndex:
                                                                childIndex,
                                                            customerId: customer
                                                                .records!
                                                                .first
                                                                .id!,
                                                            ifDetail: false,
                                                            inventorySearchBloc:
                                                                inventorySearchBloc,
                                                            state: state));
                                              } else {
                                                if (state.productsInCart
                                                        .where((element) =>
                                                            element
                                                                .childskus!
                                                                .first
                                                                .skuENTId ==
                                                            recommendationScreenState
                                                                .productCartFrequentlyBaughtItemsModel!
                                                                .productCartOthers[
                                                                    mainIndex]
                                                                .recommendedProductSet[
                                                                    childIndex]
                                                                .itemSKU)
                                                        .isEmpty ||
                                                    double.parse(state.productsInCart
                                                                    .firstWhere((element) =>
                                                                        element
                                                                            .childskus!
                                                                            .first
                                                                            .skuENTId ==
                                                                        recommendationScreenState
                                                                            .productCartFrequentlyBaughtItemsModel!
                                                                            .productCartOthers[mainIndex]
                                                                            .recommendedProductSet[childIndex]
                                                                            .itemSKU)
                                                                    .quantity ??
                                                                "0")
                                                            .toInt()
                                                            .toString() ==
                                                        "0") {
                                                  inventorySearchBloc
                                                      .add(GetWarranties(
                                                    records: state.productsInCart
                                                            .where((element) =>
                                                                element
                                                                    .childskus!
                                                                    .first
                                                                    .skuENTId ==
                                                                recommendationScreenState
                                                                    .productCartFrequentlyBaughtItemsModel!
                                                                    .productCartOthers[
                                                                        mainIndex]
                                                                    .recommendedProductSet[
                                                                        childIndex]
                                                                    .itemSKU)
                                                            .isNotEmpty
                                                        ? state.productsInCart.firstWhere((element) =>
                                                            element
                                                                .childskus!
                                                                .first
                                                                .skuENTId ==
                                                            recommendationScreenState
                                                                .productCartFrequentlyBaughtItemsModel!
                                                                .productCartOthers[
                                                                    mainIndex]
                                                                .recommendedProductSet[
                                                                    childIndex]
                                                                .itemSKU)
                                                        : recommendationScreenState
                                                            .productCartFrequentlyBaughtItemsModel!
                                                            .productCartOthers[
                                                                mainIndex]
                                                            .recommendedProductSet[childIndex]
                                                            .records,
                                                    skuEntId: recommendationScreenState
                                                        .productCartFrequentlyBaughtItemsModel!
                                                        .productCartOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .records
                                                        .childskus!
                                                        .first
                                                        .skuPIMId!,
                                                    productId: recommendationScreenState
                                                        .productCartFrequentlyBaughtItemsModel!
                                                        .productCartOthers[
                                                            mainIndex]
                                                        .recommendedProductSet[
                                                            childIndex]
                                                        .itemSKU,
                                                  ));
                                                } else {
                                                  inventorySearchBloc.add(AddToCart(
                                                      favouriteBrandScreenBloc:
                                                          context.read<
                                                              FavouriteBrandScreenBloc>(),
                                                      records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                          ? state.productsInCart.firstWhere((element) =>
                                                              element
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId ==
                                                              recommendationScreenState
                                                                  .productCartFrequentlyBaughtItemsModel!
                                                                  .productCartOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[childIndex]
                                                                  .records
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId!)
                                                          : recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records,
                                                      customerID: customer.records!.first.id!,
                                                      quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                      ifWarranties: false,
                                                      orderItem: "",
                                                      warranties: Warranties(),
                                                      productId: recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].productId,
                                                      skUid: recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                      orderID: state.orderId));
                                                }
                                              }
                                            },
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: (state.isUpdating &&
                                                          (state.updateID !=
                                                                  recommendationScreenState
                                                                      .productCartFrequentlyBaughtItemsModel!
                                                                      .productCartOthers[
                                                                          mainIndex]
                                                                      .recommendedProductSet[
                                                                          childIndex]
                                                                      .itemSKU &&
                                                              state.updateSKUID !=
                                                                  recommendationScreenState
                                                                      .productCartFrequentlyBaughtItemsModel!
                                                                      .productCartOthers[
                                                                          mainIndex]
                                                                      .recommendedProductSet[
                                                                          childIndex]
                                                                      .itemSKU))
                                                      ? () {
                                                          showMessage(
                                                              context: context,
                                                              message:
                                                                  "Please wait until previous item update");
                                                        }
                                                      : () {
                                                          inventorySearchBloc.add(RemoveFromCart(
                                                              favouriteBrandScreenBloc: context.read<
                                                                  FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                                  ? state.productsInCart.firstWhere((element) =>
                                                                      element.childskus!.first.skuENTId ==
                                                                      recommendationScreenState
                                                                          .productCartFrequentlyBaughtItemsModel!
                                                                          .productCartOthers[
                                                                              mainIndex]
                                                                          .recommendedProductSet[
                                                                              childIndex]
                                                                          .itemSKU)
                                                                  : recommendationScreenState
                                                                      .productCartFrequentlyBaughtItemsModel!
                                                                      .productCartOthers[mainIndex]
                                                                      .recommendedProductSet[childIndex]
                                                                      .records,
                                                              customerID: customer.records!.first.id!,
                                                              quantity: -1,
                                                              productId: recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                              orderID: state.orderId));
                                                        },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5),
                                                    child: Text(
                                                      "-",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5),
                                                  child: Text(
                                                    double.parse(state
                                                                .productsInCart
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId ==
                                                                    recommendationScreenState
                                                                        .productCartFrequentlyBaughtItemsModel!
                                                                        .productCartOthers[
                                                                            mainIndex]
                                                                        .recommendedProductSet[
                                                                            childIndex]
                                                                        .itemSKU)
                                                                .quantity ??
                                                            "0")
                                                        .toInt()
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontFamily: kRubik),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: (state.isUpdating &&
                                                          state.updateID !=
                                                              recommendationScreenState
                                                                  .productCartFrequentlyBaughtItemsModel!
                                                                  .productCartOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[
                                                                      childIndex]
                                                                  .itemSKU &&
                                                          state.updateSKUID !=
                                                              recommendationScreenState
                                                                  .productCartFrequentlyBaughtItemsModel!
                                                                  .productCartOthers[
                                                                      mainIndex]
                                                                  .recommendedProductSet[
                                                                      childIndex]
                                                                  .itemSKU)
                                                      ? () {
                                                          showMessage(
                                                              context: context,
                                                              message:
                                                                  "Please wait until previous item update");
                                                        }
                                                      : () {
                                                          inventorySearchBloc.add(AddToCart(
                                                              favouriteBrandScreenBloc:
                                                                  context.read<
                                                                      FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                                  ? state.productsInCart.firstWhere((element) =>
                                                                      element
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId ==
                                                                      recommendationScreenState
                                                                          .productCartFrequentlyBaughtItemsModel!
                                                                          .productCartOthers[
                                                                              mainIndex]
                                                                          .recommendedProductSet[childIndex]
                                                                          .records
                                                                          .childskus!
                                                                          .first
                                                                          .skuENTId!)
                                                                  : recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].records,
                                                              customerID: customer.records!.first.id!,
                                                              quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                              ifWarranties: false,
                                                              orderItem: "",
                                                              warranties: Warranties(),
                                                              productId: recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].productId,
                                                              skUid: recommendationScreenState.productCartFrequentlyBaughtItemsModel!.productCartOthers[mainIndex].recommendedProductSet[childIndex].itemSKU,
                                                              orderID: state.orderId));
                                                        },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5),
                                                    child: Text(
                                                      "+",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                      ],
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    SizedBox(
                      width: widthOfScreen * 0.3,
                      child: Text(
                        recommendationScreenState
                            .productCartFrequentlyBaughtItemsModel!
                            .productCartOthers[mainIndex]
                            .recommendedProductSet[childIndex]
                            .name,
                        style: textThem.headline3,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(
                      height: heightOfScreen * 0.0015,
                    ),
                    Text(
                        '\$' +
                            amountFormatting(recommendationScreenState
                                .productCartFrequentlyBaughtItemsModel!
                                .productCartOthers[mainIndex]
                                .recommendedProductSet[childIndex]
                                .salePrice!),
                        style: TextStyle(
                            fontSize: SizeSystem.size17,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.chartBlack,
                            fontFamily: kRubik))
                  ],
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        });
      });
    } else {
      return SizedBox();
    }
  }
}
