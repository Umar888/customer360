import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/browser_history/recommendation_browse_history_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/buy_again/recommendation_buy_again_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/cart/recommendation_cart_bloc.dart';
import 'package:gc_customer_app/common_widgets/circular_remove_button.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';


import '../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import '../models/cart_model/cart_warranties_model.dart';
import '../primitives/color_system.dart';
import '../primitives/constants.dart';
import '../primitives/size_system.dart';
import 'circular_add_button.dart';

class BrowseItemTileWidget extends StatelessWidget {
  BrowseItemTileWidget({
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
  final void Function()? onPressedProduct;
  final InventorySearchBloc inventorySearchBloc;
  final CustomerInfoModel customer;
  final String recommendedState;


  Widget _imageContainer(String imageUrl, double width) {
      return AspectRatio(
        aspectRatio: 1,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: 10,
                left: 10,
                right: 10),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
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
                child: Image(
                  image: imageProvider,
                ),
              );
            },
          ),
    )
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if(recommendedState == "RecommendationScreenSuccess") {
      return BlocBuilder<RecommendationBrowseHistoryBloc, RecommendationBrowseHistoryState>(
          builder: (context,recommendationScreenState) {
            return BlocBuilder<InventorySearchBloc, InventorySearchState>(
                builder: (context,state) {
                  if(recommendationScreenState is BrowseHistorySuccess) {
                    return InkWell(
                      onTap: onPressedProduct,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 5),
                            child: _imageContainer(
                                recommendationScreenState
                                    .recommendationScreenModel!
                                    .productBrowsing[mainIndex]
                                    .recommendedProductSet[childIndex]
                                    .imageURL,
                                80.0),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(recommendationScreenState
                                      .recommendationScreenModel!
                                      .productBrowsing[mainIndex]
                                      .recommendedProductSet[childIndex]
                                      .name,
                                      maxLines: 3, style: TextStyle(
                                          fontSize: SizeSystem.size16,
                                          fontWeight: FontWeight.w400,
                                          color: ColorSystem.chartBlack,
                                          fontFamily: kRubik)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        '\$'+amountFormatting(recommendationScreenState
                                            .recommendationScreenModel!
                                            .productBrowsing[mainIndex]
                                            .recommendedProductSet[childIndex]
                                            .salePrice!),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size18,
                                            fontWeight: FontWeight.bold,
                                            color: ColorSystem.chartBlack,
                                            fontFamily: kRubik),
                                      ),
                                      recommendationScreenState
                                          .recommendationScreenModel!
                                          .productBrowsing[mainIndex]
                                          .recommendedProductSet[childIndex].isUpdating?
                                      Container(
                                        decoration:  BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(11.0),
                                          child: Center(
                                            child: CupertinoActivityIndicator(color: Colors.white,),
                                          ),
                                        ),
                                      ):
                                      state.isUpdating &&
                                          (
                                              state.updateID == recommendationScreenState
                                                  .recommendationScreenModel!
                                                  .productBrowsing[mainIndex]
                                                  .recommendedProductSet[childIndex].productId ||
                                                  state.updateSKUID == recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].productId ||
                                                  state.updateID == recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].itemSKU ||
                                                  state.updateSKUID == recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].itemSKU ||
                                                  state.updateID == "${recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records.childskus!.isNotEmpty?recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records.childskus!.first.skuENTId!:"-PRODUCT"}" ||
                                                  state.updateSKUID == "${recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records.childskus != null && recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records.childskus!.isNotEmpty?recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records.childskus!.first.skuENTId!:"-PRODUCT"}"
                                          )?
                                      Container(
                                        decoration:  BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(11.0),
                                          child: Center(
                                            child: CupertinoActivityIndicator(color: Colors.white,),
                                          ),
                                        ),
                                      ):
                                      (state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                          .recommendationScreenModel!
                                          .productBrowsing[mainIndex]
                                          .recommendedProductSet[childIndex].itemSKU).isEmpty || recommendationScreenState
                                          .recommendationScreenModel!
                                          .productBrowsing[mainIndex]
                                          .recommendedProductSet[childIndex].records.childskus!.isEmpty)?
                                      CircularAddButton(
                                        buttonColor: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          if(recommendationScreenState
                                              .recommendationScreenModel!
                                              .productBrowsing[mainIndex]
                                              .recommendedProductSet[childIndex].records.childskus!.isEmpty){
                                            context.read<RecommendationBrowseHistoryBloc>().add(LoadProductDetailBrowseHistory(
                                                parentIndex: mainIndex,
                                                childIndex: childIndex,
                                                customerId: customer.records!.first.id!,
                                                ifDetail: false,
                                                inventorySearchBloc: inventorySearchBloc,
                                                state: state
                                            ));
                                          }
                                          else{
                                            if(state.productsInCart.where((element) => element
                                                .childskus!
                                                .first
                                                .skuENTId == recommendationScreenState
                                                .recommendationScreenModel!
                                                .productBrowsing[mainIndex]
                                                .recommendedProductSet[childIndex].itemSKU).isEmpty ||
                                                double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsing[mainIndex]
                                                    .recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt().toString() == "0") {
                                              inventorySearchBloc.add(GetWarranties(
                                                records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsing[mainIndex]
                                                    .recommendedProductSet[childIndex].itemSKU).isNotEmpty?
                                                state.productsInCart.firstWhere((element) =>
                                                element.childskus!.first.skuENTId == recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsing[mainIndex]
                                                    .recommendedProductSet[childIndex].itemSKU):
                                                recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsing[mainIndex]
                                                    .recommendedProductSet[childIndex].records,
                                                skuEntId:recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsing[mainIndex]
                                                    .recommendedProductSet[childIndex].records.childskus!.first.skuPIMId!,
                                                productId:recommendationScreenState
                                                    .recommendationScreenModel!
                                                    .productBrowsing[mainIndex]
                                                    .recommendedProductSet[childIndex].itemSKU,
                                              ));
                                            }
                                            else{
                                              inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                  records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].itemSKU).isNotEmpty?
                                                  state.productsInCart.firstWhere((element) =>
                                                  element.childskus!.first.skuENTId == recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records.childskus!.first.skuENTId!):
                                                  recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].records,
                                                  customerID: customer.records!.first.id!,
                                                  quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                  ifWarranties: false,
                                                  orderItem: "",
                                                  warranties: Warranties(),
                                                  productId: recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].productId,
                                                  skUid: recommendationScreenState
                                                      .recommendationScreenModel!
                                                      .productBrowsing[mainIndex]
                                                      .recommendedProductSet[childIndex].itemSKU,
                                                  orderID: state.orderId));
                                            }
                                          }
                                        },
                                      ):
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(1.0),
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap:(state.isUpdating &&  (state.updateID != recommendationScreenState
                                                  .recommendationScreenModel!
                                                  .productBrowsing[mainIndex]
                                                  .recommendedProductSet[childIndex].itemSKU&& state.updateSKUID != recommendationScreenState
                                                  .recommendationScreenModel!
                                                  .productBrowsing[mainIndex]
                                                  .recommendedProductSet[childIndex].itemSKU))? () {
                                                showMessage(context: context,message:"Please wait until previous item update");
                                              }:(){
                                                inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].itemSKU).isNotEmpty
                                                        ? state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].itemSKU)
                                                        : recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].records,
                                                    customerID: customer.records!.first.id!,
                                                    quantity: -1,
                                                    productId: recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].itemSKU,
                                                    orderID: state.orderId));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                                child: Text("-",
                                                  style: TextStyle(
                                                      fontSize: SizeSystem.size24,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                      fontFamily: kRubik
                                                  ),),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                              child: Text(double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                  .recommendationScreenModel!
                                                  .productBrowsing[mainIndex]
                                                  .recommendedProductSet[childIndex].itemSKU).quantity??"0").toInt().toString(),
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontFamily: kRubik
                                                ),),
                                            ),
                                            InkWell(
                                              onTap:(state.isUpdating && state.updateID != recommendationScreenState
                                                  .recommendationScreenModel!
                                                  .productBrowsing[mainIndex]
                                                  .recommendedProductSet[childIndex].itemSKU&& state.updateSKUID != recommendationScreenState
                                                  .recommendationScreenModel!
                                                  .productBrowsing[mainIndex]
                                                  .recommendedProductSet[childIndex].itemSKU)? () {
                                                showMessage(context: context,message:"Please wait until previous item update");
                                              }:() {
                                                inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].itemSKU).isNotEmpty?
                                                    state.productsInCart.firstWhere((element) =>
                                                    element.childskus!.first.skuENTId == recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].records.childskus!.first.skuENTId!):
                                                    recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].records,
                                                    customerID: customer.records!.first.id!,
                                                    quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].itemSKU).quantity ?? "0").toInt() + 1,
                                                    ifWarranties: false,
                                                    orderItem: "",
                                                    warranties: Warranties(),
                                                    productId: recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].productId,
                                                    skUid: recommendationScreenState
                                                        .recommendationScreenModel!
                                                        .productBrowsing[mainIndex]
                                                        .recommendedProductSet[childIndex].itemSKU,
                                                    orderID: state.orderId));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                                child: Text("+",
                                                  style: TextStyle(
                                                      fontSize: SizeSystem.size24,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                      fontFamily: kRubik
                                                  ),),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  else{
                    return SizedBox();
                  }
                }
            );
          }
      );
    }
    else if(recommendedState == "LoadBuyAgainItemsSuccess"){
      return BlocBuilder<RecommendationBuyAgainBloc, RecommendationBuyAgainState>(
          builder: (context,recommendationScreenState) {
            return BlocBuilder<InventorySearchBloc, InventorySearchState>(
                builder: (context,state) {
                  if(recommendationScreenState is LoadBuyAgainItemsSuccess) {
                    return InkWell(
                      onTap: onPressedProduct,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 5),
                            child: _imageContainer(
                                recommendationScreenState
                                    .buyAgainModel!.productBuyAgain[childIndex]
                                    .imageURLC,
                                80.0),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(recommendationScreenState
                                      .buyAgainModel!.productBuyAgain[childIndex].descriptionC,
                                      maxLines: 3, style: TextStyle(
                                          fontSize: SizeSystem.size16,
                                          fontWeight: FontWeight.w400,
                                          color: ColorSystem.chartBlack,
                                          fontFamily: kRubik)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        '\$'+amountFormatting(recommendationScreenState
                                            .buyAgainModel!.productBuyAgain[childIndex].itemPriceC),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size18,
                                            fontWeight: FontWeight.bold,
                                            color: ColorSystem.chartBlack,
                                            fontFamily: kRubik),
                                      ),
                                      recommendationScreenState
                                          .buyAgainModel!.productBuyAgain[childIndex].isUpdating?
                                      Container(
                                        decoration:  BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(11.0),
                                          child: Center(
                                            child: CupertinoActivityIndicator(color: Colors.white,),
                                          ),
                                        ),
                                      ):
                                      state.isUpdating &&
                                          (
                                              state.updateID == recommendationScreenState
                                                  .buyAgainModel!.productBuyAgain[childIndex].itemIdC ||
                                                  state.updateSKUID == recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].itemIdC ||
                                                  state.updateID == recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].itemSKUC ||
                                                  state.updateSKUID == recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].itemSKUC ||
                                                  state.updateID == "${recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records.childskus != null && recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.isNotEmpty?recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.first.skuENTId!:"-PRODUCT"}" ||
                                                  state.updateSKUID == "${recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records.childskus != null && recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.isNotEmpty?recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.first.skuENTId!:"-PRODUCT"}"
                                          )?
                                      Container(
                                        decoration:  BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(11.0),
                                          child: Center(
                                            child: CupertinoActivityIndicator(color: Colors.white,),
                                          ),
                                        ),
                                      ):
                                      (state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                          .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).isEmpty || recommendationScreenState
                                          .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.isEmpty)?
                                      CircularAddButton(
                                        buttonColor: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          if(recommendationScreenState
                                              .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.isEmpty){
                                            context.read<RecommendationBuyAgainBloc>().add(LoadProductDetailBuyAgain(
                                                index: childIndex,
                                                customerId: customer.records!.first.id!,
                                                ifDetail: false,
                                                inventorySearchBloc: inventorySearchBloc,
                                                state: state
                                            ));
                                          }
                                          else{
                                            if(state.productsInCart.where((element) => element
                                                .childskus!
                                                .first
                                                .skuENTId == recommendationScreenState
                                                .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).isEmpty ||
                                                double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                    .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).quantity ?? "0").toInt().toString() == "0") {
                                              inventorySearchBloc.add(GetWarranties(
                                                records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                    .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).isNotEmpty?
                                                state.productsInCart.firstWhere((element) =>
                                                element.childskus!.first.skuENTId == recommendationScreenState
                                                    .buyAgainModel!.productBuyAgain[childIndex].itemSKUC):
                                                recommendationScreenState
                                                    .buyAgainModel!.productBuyAgain[childIndex].records,
                                                skuEntId:recommendationScreenState
                                                    .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.first.skuPIMId!,
                                                productId:recommendationScreenState
                                                    .buyAgainModel!.productBuyAgain[childIndex].itemSKUC,
                                              ));
                                            }
                                            else{
                                              inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                  records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).isNotEmpty?
                                                  state.productsInCart.firstWhere((element) =>
                                                  element.childskus!.first.skuENTId == recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.first.skuENTId!):
                                                  recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].records,
                                                  customerID: customer.records!.first.id!,
                                                  quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).quantity ?? "0").toInt() + 1,
                                                  ifWarranties: false,
                                                  orderItem: "",
                                                  warranties: Warranties(),
                                                  productId: recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].itemSKUC,
                                                  skUid: recommendationScreenState
                                                      .buyAgainModel!.productBuyAgain[childIndex].itemSKUC,
                                                  orderID: state.orderId));
                                            }
                                          }
                                        },
                                      ):
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(1.0),
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap:(state.isUpdating &&  (state.updateID !=
                                                  recommendationScreenState
                                                  .buyAgainModel!.productBuyAgain[childIndex].itemSKUC && state.updateSKUID !=
                                                  recommendationScreenState
                                                  .buyAgainModel!.productBuyAgain[childIndex].itemSKUC))? () {
                                                showMessage(context: context,message:"Please wait until previous item update");
                                              }:(){
                                                inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).isNotEmpty
                                                        ? state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].itemSKUC)
                                                        : recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].records,
                                                    customerID: customer.records!.first.id!,
                                                    quantity: -1,
                                                    productId: recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].itemSKUC,
                                                    orderID: state.orderId));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                                child: Text("-",
                                                  style: TextStyle(
                                                      fontSize: SizeSystem.size24,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                      fontFamily: kRubik
                                                  ),),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                              child: Text(double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                  .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).quantity??"0").toInt().toString(),
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontFamily: kRubik
                                                ),),
                                            ),
                                            InkWell(
                                              onTap:(state.isUpdating && state.updateID != recommendationScreenState
                                                  .buyAgainModel!.productBuyAgain[childIndex].itemSKUC  && state.updateSKUID != recommendationScreenState
                                                  .buyAgainModel!.productBuyAgain[childIndex].itemSKUC)? () {
                                                showMessage(context: context,message:"Please wait until previous item update");
                                              }:() {
                                                inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).isNotEmpty?
                                                    state.productsInCart.firstWhere((element) =>
                                                    element.childskus!.first.skuENTId == recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].records.childskus!.first.skuENTId!):
                                                    recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].records,
                                                    customerID: customer.records!.first.id!,
                                                    quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].itemSKUC).quantity ?? "0").toInt() + 1,
                                                    ifWarranties: false,
                                                    orderItem: "",
                                                    warranties: Warranties(),
                                                    productId: recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].itemSKUC,
                                                    skUid: recommendationScreenState
                                                        .buyAgainModel!.productBuyAgain[childIndex].itemSKUC,
                                                    orderID: state.orderId));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                                child: Text("+",
                                                  style: TextStyle(
                                                      fontSize: SizeSystem.size24,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                      fontFamily: kRubik
                                                  ),),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  else{
                    return SizedBox();
                  }
                }
            );
          }
      );
    }
    else if(recommendedState == "LoadCartItemsSuccess"){
      return BlocBuilder<RecommendationCartBloc, RecommendationCartState>(
          builder: (context,recommendationScreenState) {
            return BlocBuilder<InventorySearchBloc, InventorySearchState>(
                builder: (context,state) {
                  if(recommendationScreenState is LoadCartItemsSuccess) {
                    return InkWell(
                      onTap: onPressedProduct,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 5),
                            child: _imageContainer(
                                recommendationScreenState.productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].productImageUrl,
                                80.0),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(recommendationScreenState.productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].productName,
                                      maxLines: 3, style: TextStyle(
                                          fontSize: SizeSystem.size16,
                                          fontWeight: FontWeight.w400,
                                          color: ColorSystem.chartBlack,
                                          fontFamily: kRubik)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        '\$'+amountFormatting(double.parse(recommendationScreenState.productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].productPrice)),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size18,
                                            fontWeight: FontWeight.bold,
                                            color: ColorSystem.chartBlack,
                                            fontFamily: kRubik),
                                      ),
                                      recommendationScreenState
                                          .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].isUpdating?
                                      Container(
                                        decoration:  BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(11.0),
                                          child: Center(
                                            child: CupertinoActivityIndicator(color: Colors.white,),
                                          ),
                                        ),
                                      ):
                                      state.isUpdating &&
                                          (
                                              state.updateID == recommendationScreenState
                                                  .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].productId ||
                                                  state.updateSKUID == recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].productId ||
                                                  state.updateID == recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId ||
                                                  state.updateSKUID == recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId ||
                                                  state.updateID == "${recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus != null && recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.isNotEmpty?recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.first.skuENTId!:"-PRODUCT"}" ||
                                                  state.updateSKUID == "${recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus != null && recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.isNotEmpty?recommendationScreenState
                                                  .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.first.skuENTId!:"-PRODUCT"}"
                                          )?
                                      Container(
                                        decoration:  BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(11.0),
                                          child: Center(
                                            child: CupertinoActivityIndicator(color: Colors.white,),
                                          ),
                                        ),
                                      ):
                                      (state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                          .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).isEmpty || recommendationScreenState
                                          .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.isEmpty)?
                                      CircularAddButton(
                                        buttonColor: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          if(recommendationScreenState
                                              .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.isEmpty){
                                            context.read<RecommendationCartBloc>().add(LoadProductDetailCart(
                                                parentIndex: mainIndex,
                                                childIndex: childIndex,
                                                customerId: customer.records!.first.id!,
                                                ifDetail: false,
                                                inventorySearchBloc: inventorySearchBloc,
                                                state: state
                                            ));
                                          }
                                          else{
                                            if(state.productsInCart.where((element) => element
                                                .childskus!
                                                .first
                                                .skuENTId == recommendationScreenState
                                                .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).isEmpty ||
                                                double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                    .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).quantity ?? "0").toInt().toString() == "0") {
                                              inventorySearchBloc.add(GetWarranties(
                                                records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                    .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).isNotEmpty?
                                                state.productsInCart.firstWhere((element) =>
                                                element.childskus!.first.skuENTId == recommendationScreenState
                                                    .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId):
                                                recommendationScreenState
                                                    .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records,
                                                skuEntId:recommendationScreenState
                                                    .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.first.skuPIMId!,
                                                productId:recommendationScreenState
                                                    .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId,
                                              ));
                                            }
                                            else{
                                              inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                  records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).isNotEmpty?
                                                  state.productsInCart.firstWhere((element) =>
                                                  element.childskus!.first.skuENTId == recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.first.skuENTId!):
                                                  recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records,
                                                  customerID: customer.records!.first.id!,
                                                  quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).quantity ?? "0").toInt() + 1,
                                                  ifWarranties: false,
                                                  orderItem: "",
                                                  warranties: Warranties(),
                                                  productId: recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].productId,
                                                  skUid: recommendationScreenState
                                                      .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId,
                                                  orderID: state.orderId));
                                            }
                                          }
                                        },
                                      ):
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(1.0),
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap:(state.isUpdating &&  (state.updateID != recommendationScreenState
                                                  .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId && state.updateSKUID != recommendationScreenState
                                                  .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId))? () {
                                                showMessage(context: context,message:"Please wait until previous item update");
                                              }:(){
                                                inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).isNotEmpty
                                                        ? state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId)
                                                        : recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records,
                                                    customerID: customer.records!.first.id!,
                                                    quantity: -1,
                                                    productId: recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId,
                                                    orderID: state.orderId));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                                child: Text("-",
                                                  style: TextStyle(
                                                      fontSize: SizeSystem.size24,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                      fontFamily: kRubik
                                                  ),),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                              child: Text(double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                  .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).quantity??"0").toInt().toString(),
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontFamily: kRubik
                                                ),),
                                            ),
                                            InkWell(
                                              onTap:(state.isUpdating && state.updateID != recommendationScreenState
                                                  .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId && state.updateSKUID != recommendationScreenState
                                                  .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId)? () {
                                                showMessage(context: context,message:"Please wait until previous item update");
                                              }:() {
                                                inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),
                                                    records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).isNotEmpty?
                                                    state.productsInCart.firstWhere((element) =>
                                                    element.childskus!.first.skuENTId == recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records.childskus!.first.skuENTId!):
                                                    recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].records,
                                                    customerID: customer.records!.first.id!,
                                                    quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId).quantity ?? "0").toInt() + 1,
                                                    ifWarranties: false,
                                                    orderItem: "",
                                                    warranties: Warranties(),
                                                    productId: recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].productId,
                                                    skUid: recommendationScreenState
                                                        .productCartBrowseItemsModel!.productCart[mainIndex].wrapperinstance.records[childIndex].childskus.first.skuENTId,
                                                    orderID: state.orderId));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                                                child: Text("+",
                                                  style: TextStyle(
                                                      fontSize: SizeSystem.size24,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                      fontFamily: kRubik
                                                  ),),
                                              ),
                                            )
                                          ],
                                        ),
                                      )

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  else{
                    return SizedBox();
                  }
                }
            );
          }
      );
    }
    else{
      return Text("hola");
    }
  }
}
