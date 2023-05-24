import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/common_widgets/circular_remove_button.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;
import 'package:gc_customer_app/models/favorite_brands_model/favorite_brand_detail_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';


import '../../constants/colors.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';
import '../circular_add_button.dart';

class FavouriteBrandSlidesWidget extends StatefulWidget {
  FavouriteBrandSlidesWidget(
      {Key? key, required this.index, required this.state, required this.ifNative, required this.customer, required this.inventorySearchBloc, required this.brandItems, required this.onTap, required this.favoriteItems, this.selectedBrandWeb,})
      : super(key: key);

  final int index;
  final bool ifNative;
  final InventorySearchState state;
  final FavoriteBrandDetailModel? favoriteItems;
  final InventorySearchBloc inventorySearchBloc;
  final CustomerInfoModel? customer;
  final Function onTap;
  final List<BrandItems> brandItems;
  final FavoriteBrandsLandingScreen? selectedBrandWeb;

  void doNothing(BuildContext context) {}

  @override
  State<FavouriteBrandSlidesWidget> createState() => _FavouriteBrandSlidesWidgetState();
}

class _FavouriteBrandSlidesWidgetState extends State<FavouriteBrandSlidesWidget> {
  final SwipeActionController controller = SwipeActionController();
  late FavouriteBrandScreenBloc favouriteBrandScreenBloc;

  @override
  void initState() {
    super.initState();
    favouriteBrandScreenBloc = context.read<FavouriteBrandScreenBloc>();


    if (widget.ifNative) {
      if (widget.inventorySearchBloc.state.productsInCart.isNotEmpty) {
        for (asm.Records records in widget.inventorySearchBloc.state.productsInCart) {
          if (widget.brandItems[widget.index].itemSkuID == records.childskus!.first.skuENTId) {
            favouriteBrandScreenBloc.add(UpdateProduct(index: widget.index, records: records, ifNative: true));
          }
        }
      } else {
        favouriteBrandScreenBloc.add(
            UpdateProduct(index: widget.index, records: asm.Records(childskus: [], quantity: "-1", productId: "null"), ifNative: true));
      }
    } else {
      if (widget.inventorySearchBloc.state.productsInCart.isNotEmpty) {
        for (asm.Records records in widget.inventorySearchBloc.state.productsInCart) {
          if (widget.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId == records.childskus!.first.skuENTId) {
            favouriteBrandScreenBloc.add(UpdateProduct(index: widget.index, records: records, ifNative: false));
          }
        }
      } else {
        favouriteBrandScreenBloc.add(
            UpdateProduct(index: widget.index, records: asm.Records(childskus: [], quantity: "-1", productId: "null"), ifNative: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var textThem = Theme
        .of(context)
        .textTheme;
    double heightOfScreen = MediaQuery
        .of(context)
        .size
        .height;
    double widthOfScreen = MediaQuery
        .of(context)
        .size
        .width;
    return BlocBuilder<FavouriteBrandScreenBloc, FavouriteBrandScreenState>(builder: (context, favouriteBrandScreenState) {
      return BlocConsumer<InventorySearchBloc, InventorySearchState>(listener: (context, state) {
        if (favouriteBrandScreenState is FavouriteBrandScreenSuccess) {
          late BrandItems brandItem;
          if (widget.selectedBrandWeb != null && widget.selectedBrandWeb!.items != null) {
            brandItem = widget.selectedBrandWeb!.items![widget.index];
          } else if (widget.ifNative) {
            brandItem = favouriteBrandScreenState.brandItems![widget.index];
          }
        }
      }, builder: (context, state) {
        if (favouriteBrandScreenState is FavouriteBrandScreenSuccess) {
          late BrandItems brandItem;
          if (widget.selectedBrandWeb != null && widget.selectedBrandWeb!.items != null) {
            brandItem = widget.selectedBrandWeb!.items![widget.index];
          } else if (widget.ifNative) {
            brandItem = favouriteBrandScreenState.brandItems![widget.index];
          }

          return SwipeActionCell(controller: controller,
              key: ObjectKey(Random().nextInt(10000)),
              trailingActions: (widget.ifNative && state.productsInCart.isNotEmpty && state.productsInCart
                  .where((element) => element.childskus!.first.skuENTId == (brandItem.itemSkuID ?? ""))
                  .isNotEmpty && double.parse(state.productsInCart
                  .firstWhere((element) => element.childskus!.first.skuENTId == (brandItem.itemSkuID ?? ""))
                  .quantity ?? "0").toInt() > 0) || (!widget.ifNative && state.productsInCart.isNotEmpty &&
                  state.productsInCart.where((element) => element.childskus!.first.skuENTId == favouriteBrandScreenState.favoriteItems!
                      .wrapperinstance!.records![widget.index].childskus!.first.skuENTId!).isNotEmpty &&
                  double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                      favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId!).quantity ?? "0")
                      .toInt() > 0) ? <SwipeAction>[
                SwipeAction(
                  performsFirstActionWithFullSwipe: false,
                  widthSpace: widthOfScreen * 0.3,
                  closeOnTap: true,
                  title: "Remove from cart",
                  style: TextStyle(fontSize: SizeSystem.size12,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: kRubik),
                  icon: Icon(Icons.delete_outline, color: Colors.white, size: 32,),
                  onTap: !widget.ifNative && state.isUpdating ? (CompletionHandler handler) async {
                    controller.closeAllOpenCell();
                  } : widget.ifNative && (brandItem.isUpdating ?? false) ? (CompletionHandler handler) async {
                    controller.closeAllOpenCell();
                  } : favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records!.where((element) => element.isUpdating!).isNotEmpty ? (
                      CompletionHandler handler) async {
                    controller.closeAllOpenCell();
                  } : widget.ifNative && (brandItem.records!.childskus!.isEmpty || state.productsInCart.where((element) => element.childskus!.first
                      .skuENTId == brandItem.itemSkuID).isEmpty || double.parse(state.productsInCart
                      .firstWhere((element) => element.childskus!.first.skuENTId == (brandItem.itemSkuID ?? ""))
                      .quantity ?? "0").toInt().toString() == "0") ? (CompletionHandler handler) async {
                    controller.closeAllOpenCell();
                  } : !widget.ifNative && (favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].records!.childskus!
                      .isEmpty || state.productsInCart.where((element) => element.childskus!.first.skuENTId ==
                      favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId).isEmpty || double
                      .parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                      favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId!).quantity ?? "0")
                      .toInt().toString() == "0") ? (CompletionHandler handler) async {
                    controller.closeAllOpenCell();
                  } : (CompletionHandler handler) async {
                    controller.closeAllOpenCell();
                    if (state.isUpdating || state.fetchWarranties) {
                      showMessage(context: context,message:"Please wait until previous item update");
                    } else {
                      if (widget.ifNative) {
                        widget.inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                            records: state.productsInCart
                                .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                .isNotEmpty
                                ? state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                : brandItem.records!,
                            customerID: widget.customer!.records!.first.id!,
                            quantity: 0,
                            productId: (brandItem.itemSkuID ?? ""),
                            orderID: state.orderId));
                      } else {
                        widget.inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                            records: state.productsInCart.where((element) => element.childskus!.first.skuENTId ==
                                favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId).isNotEmpty
                                ? state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId)
                                : favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].records!,
                            customerID: widget.customer!.records!.first.id!,
                            quantity: 0,
                            productId: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId!,
                            orderID: state.orderId));
                      }
                    }
                  },),
              ] : [],
              child: widget.ifNative ? Column(
                mainAxisSize: MainAxisSize.min, children: [Padding(padding: EdgeInsets.symmetric(horizontal: widthOfScreen * 0.05,
                vertical: heightOfScreen * 0.00,), child: SizedBox(width: double.infinity, child: Column(mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  InkWell(onTap: () => widget.onTap(),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2,
                          child: AspectRatio(aspectRatio: 0.99,
                            child: Container(decoration: BoxDecoration(color: Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(20)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover, imageUrl: brandItem.imageUrl ?? '', imageBuilder: (context, imageProvider) {
                                return Container(decoration: BoxDecoration(color: Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(20),),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover, imageUrl: brandItem.imageUrl ?? '', imageBuilder: (context, imageProvider) {
                                    return Container(
                                      width: widthOfScreen * 0.3,
                                      height: heightOfScreen * 0.15,
                                      decoration: BoxDecoration(color: ColorSystem.addtionalCulturedGrey, borderRadius: BorderRadius.circular(20),),
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [Expanded(child: Image.network(brandItem.imageUrl ?? '', width: double.infinity,)),
                                        ],),);
                                  },),);
                              },),),),),
                        SizedBox(width: 10,),
                        Expanded(flex: 5,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(brandItem.description ?? '', maxLines: 2, style: textThem.headline3),
                              SizedBox(height: 5),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      (brandItem.condition != null && brandItem.condition!.isNotEmpty) ? Container(padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(border: Border.all(color: Colors.black26),
                                            borderRadius: BorderRadius.circular(20),
                                            color: AppColors.selectedChipColor.withOpacity(0.2)),
                                        child: Center(child: Row(children: [SizedBox(width: 5,), Text('${brandItem.condition}'), SizedBox(width: 5,),
                                        ],),),) : SizedBox(height: 4),
                                      SizedBox(height: 4),
                                      Padding(padding: EdgeInsets.only(left: 4.0), child: Text('\$' + amountFormatting(double.parse(brandItem
                                          .unitPrice ?? "0.00")), style: TextStyle(fontSize: SizeSystem.size20,
                                          fontWeight: FontWeight.bold,
                                          color: ColorSystem.chartBlack,
                                          fontFamily: kRubik),),),
                                    ],),
                                  kIsWeb ? SizedBox.shrink() : (state.isUpdating && state.updateID == brandItem.itemSkuID) || brandItem.isUpdating!
                                      ? Container(decoration: BoxDecoration(shape: BoxShape.circle, color: ColorSystem.primaryTextColor,),
                                    child: Padding(
                                      padding: EdgeInsets.all(11.0), child: Center(child: CupertinoActivityIndicator(color: Colors.white,),),),)
                                      : (brandItem.records!.childskus!.isEmpty || state.productsInCart
                                      .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                      .isEmpty || double.parse(state.productsInCart
                                      .firstWhere((element) => element.childskus!.first.skuENTId == (brandItem.itemSkuID ?? ""))
                                      .quantity ?? "0").toInt().toString() == "0" || state.productsInCart
                                      .firstWhere((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                      .quantity!
                                      .trim() == "") ? CircularAddButton(buttonColor: ColorSystem.primaryTextColor, onPressed: () {
                                    if (state.isUpdating || state.fetchWarranties) {
                                      showMessage(context: context,message:"Please wait until previous item update");
                                    } else {
                                      if (brandItem.records!.childskus!.isEmpty) {
                                        context.read<FavouriteBrandScreenBloc>().add(LoadProductDetail(index: widget.index,
                                            ifNative: true,
                                            ifDetail: false,
                                            id: brandItem.itemSkuID!,
                                            customerId: widget.customer!.records!.first.id!,
                                            inventorySearchBloc: widget.inventorySearchBloc,
                                            state: state));
                                      } else {
                                        if (state.productsInCart
                                            .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                            .isEmpty || double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                            (brandItem.itemSkuID ?? "")).quantity ?? "0").toInt().toString() == "0") {
                                          widget.inventorySearchBloc.add(GetWarranties(records: state.productsInCart
                                              .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                              .isNotEmpty ? state.productsInCart.firstWhere((element) =>
                                          element.childskus!.first.skuENTId == brandItem.itemSkuID) : brandItem.records!,
                                            skuEntId: (brandItem.itemSkuID ?? ""),
                                            productId: (brandItem.itemSkuID ?? ""),));
                                        } else {
                                          widget.inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                                              records: state.productsInCart
                                                  .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                                  .isNotEmpty ? state.productsInCart.firstWhere((element) =>
                                              element.childskus!.first.skuENTId == brandItem.itemSkuID) : brandItem.records!,
                                              customerID: widget.customer!.records!.first.id!,
                                              quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                                  (brandItem.itemSkuID ?? "")).quantity ?? "0").toInt() + 1,
                                              ifWarranties: false,
                                              orderItem: "",
                                              warranties: Warranties(),
                                              productId: (brandItem.itemSkuID ?? ""),
                                              orderID: state.orderId));
                                        }
                                      }
                                    }
                                  },) : Row(mainAxisSize: MainAxisSize.min, children: [
                                    state.productsInCart
                                        .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                        .isEmpty || (state.isUpdating && state.updateID == (brandItem.itemSkuID ?? ""))
                                        ? SizedBox(width: 0, height: 0,)
                                        : CircularRemoveButton(buttonColor: Colors.red, onPressed: state.isUpdating || state.fetchWarranties ? () {
                                      showMessage(context: context,message:"Please wait until previous item update");
                                    } : () {
                                      widget.inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                                          records: state.productsInCart
                                              .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                              .isNotEmpty ? state.productsInCart.firstWhere((element) =>
                                          element.childskus!.first.skuENTId == brandItem.itemSkuID) : brandItem.records!,
                                          customerID: widget.customer!.records!.first.id!,
                                          quantity: -1,
                                          productId: (brandItem.itemSkuID ?? ""),
                                          orderID: state.orderId));
                                    },),
                                    state.productsInCart
                                        .where((element) => element.childskus!.first.skuENTId == (brandItem.itemSkuID ?? ""))
                                        .isEmpty || (state.isUpdating && state.updateID == (brandItem.itemSkuID ?? ""))
                                        ? SizedBox(width: 0, height: 0,)
                                        : Padding(padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5), child: Text(double.parse(
                                        state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == (brandItem.itemSkuID ?? ""))
                                            .quantity ?? "0").toInt().toString(), style: TextStyle(fontSize: SizeSystem.size18, fontWeight: FontWeight
                                        .w500, color: Theme
                                        .of(context)
                                        .primaryColor, fontFamily: kRubik),),),
                                    (state.isUpdating && state.updateID == (brandItem.itemSkuID ?? "")) || brandItem.isUpdating! ? Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme
                                          .of(context)
                                          .primaryColor,),
                                      child: Padding(padding: EdgeInsets.all(11.0), child: Center(child: CupertinoActivityIndicator(
                                        color: Colors.white,),),),) : CircularAddButton(buttonColor: Theme
                                        .of(context)
                                        .primaryColor, onPressed: (state.isUpdating || state.fetchWarranties) ? () {
                                      showMessage(context: context,message:"Please wait until previous item update");
                                    } : () {
                                      widget.inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                                          records: state.productsInCart
                                              .where((element) => element.childskus!.first.skuENTId == brandItem.itemSkuID)
                                              .isNotEmpty ? state.productsInCart.firstWhere((element) =>
                                          element.childskus!.first.skuENTId == brandItem.itemSkuID) : brandItem.records!,
                                          customerID: widget.customer!.records!.first.id!,
                                          productId: (brandItem.itemSkuID ?? ""),
                                          quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                              (brandItem.itemSkuID ?? "")).quantity ?? "0").toInt() + 1,
                                          ifWarranties: false,
                                          orderItem: "",
                                          warranties: Warranties(),
                                          orderID: state.orderId));
                                    },),
                                  ],),
                                ],),
                            ],),),
                      ],),),
                ],),),), Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10), child: Divider(color: Colors.grey.shade400,
                height: 1.5,),)
              ],) : Column(mainAxisSize: MainAxisSize.min, children: [
                Stack(children: [Padding(padding: EdgeInsets.symmetric(horizontal: widthOfScreen * 0.05, vertical: heightOfScreen * 0.00,),
                  child: SizedBox(width: double.infinity,
                    child: Column(mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        InkWell(onTap: () => widget.onTap(),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2,
                                child: AspectRatio(aspectRatio: 0.99,
                                  child: Container(decoration: BoxDecoration(color: Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(20)),
                                    child: CachedNetworkImage(fit: BoxFit.cover,
                                      imageUrl: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus?.first
                                          .skuImageUrl ?? '',
                                      imageBuilder: (context, imageProvider) {
                                        return Container(width: widthOfScreen * 0.3,
                                          height: heightOfScreen * 0.15,
                                          decoration: BoxDecoration(color: ColorSystem.addtionalCulturedGrey,
                                              borderRadius: BorderRadius.circular(20),
                                              image: DecorationImage(image: imageProvider)),
                                          margin: EdgeInsets.only(bottom: 8),);
                                      },),),),),
                              SizedBox(width: 10,),
                              Expanded(flex: 5,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus?.first
                                        .skuDisplayName ?? '', maxLines: 2, style: textThem.headline3),
                                    SizedBox(height: 5),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(border: Border.all(color: Colors.black26),
                                                borderRadius: BorderRadius.circular(20),
                                                color: AppColors.selectedChipColor.withOpacity(0.2)), child: Center(child: Row(children: [
                                              SizedBox(width: 5,),
                                              Text(favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                  .skuCondition == 'New' ? '${favouriteBrandScreenState.favoriteItems!.wrapperinstance!
                                                  .records![widget.index].childskus!.first.skuCondition}' : favouriteBrandScreenState.favoriteItems!
                                                  .wrapperinstance!.records![widget.index].childskus!.first.skuCondition ?? ''),
                                              SizedBox(width: 5,),
                                            ],),),),
                                            SizedBox(height: 4),
                                            Padding(padding: EdgeInsets.only(left: 4.0), child: Text('\$' + amountFormatting(double.parse(
                                                favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus![0]
                                                    .skuPrice ?? '0.00')), style: TextStyle(fontSize: SizeSystem.size20,
                                                fontWeight: FontWeight.bold,
                                                color: ColorSystem.chartBlack,
                                                fontFamily: kRubik),),),
                                          ],),
                                        (state.isUpdating && state.updateID ==
                                            favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                .skuENTId) ||
                                            favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].isUpdating! ? Container(
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: ColorSystem.primaryTextColor,),
                                          child: Padding(padding: EdgeInsets.all(11.0), child: Center(child: CupertinoActivityIndicator(color: Colors
                                              .white,),),),) : (favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index]
                                            .records!.childskus!.isEmpty ||
                                            state.productsInCart.where((element) => element.childskus!.first.skuENTId == favouriteBrandScreenState
                                                .favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId).isEmpty ||
                                            double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                                favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                    .skuENTId!).quantity ?? "0").toInt().toString() == "0") ? CircularAddButton(
                                          buttonColor: ColorSystem.primaryTextColor, onPressed: () {
                                          print("this is id ${favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index]
                                              .childskus!.first.skuENTId!}");
                                          if (favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].records!.childskus!
                                              .isEmpty) {
                                            print("ye index e ${widget.index}");
                                            context.read<FavouriteBrandScreenBloc>().add(LoadProductDetail(index: widget.index,
                                                id: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                    .skuENTId!,
                                                ifNative: false,
                                                ifDetail: false,
                                                customerId: widget.customer!.records!.first.id!,
                                                inventorySearchBloc: widget.inventorySearchBloc,
                                                state: state));
                                          } else {
                                            if (state.productsInCart.where((element) => element.childskus!.first.skuENTId ==
                                                favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                    .skuENTId).isEmpty || double.parse(
                                                state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                                    favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                        .skuENTId!).quantity ?? "0").toInt().toString() == "0") {
                                              widget.inventorySearchBloc.add(GetWarranties(records: state.productsInCart.where((element) =>
                                              element.childskus!.first.skuENTId ==
                                                  favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                      .skuENTId).isNotEmpty ? state.productsInCart.firstWhere((element) =>
                                              element.childskus!.first.skuENTId ==
                                                  favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                      .skuENTId) : favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index]
                                                  .records!,
                                                skuEntId: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!
                                                    .first.skuPIMId!,
                                                productId: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!
                                                    .first.skuENTId!,));
                                            } else {
                                              widget.inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                                                  records: state.productsInCart.where((element) =>
                                                  element.childskus!.first.skuENTId ==
                                                      favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!
                                                          .first.skuENTId).isNotEmpty ? state.productsInCart.firstWhere((element) =>
                                                  element.childskus!.first.skuENTId ==
                                                      favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!
                                                          .first.skuENTId) : favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget
                                                      .index].records!,
                                                  customerID: widget.customer!.records!.first.id!,
                                                  quantity: double.parse(state.productsInCart.firstWhere((element) =>
                                                  element.childskus!.first.skuENTId ==
                                                      favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!
                                                          .first.skuENTId!).quantity ?? "0").toInt() + 1,
                                                  productId: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index]
                                                      .childskus!.first.skuENTId!,
                                                  ifWarranties: false,
                                                  orderItem: "",
                                                  warranties: Warranties(),
                                                  orderID: state.orderId));
                                            }
                                          }
                                        },) : Row(mainAxisSize: MainAxisSize.min, children: [state.productsInCart.where((element) => element
                                            .childskus!.first.skuENTId ==
                                            favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                .skuENTId).isEmpty || (state.isUpdating && state.updateID == favouriteBrandScreenState.favoriteItems!
                                            .wrapperinstance!.records![widget.index].childskus!.first.skuENTId!)
                                            ? SizedBox(width: 0, height: 0,)
                                            : CircularRemoveButton(
                                          buttonColor: Colors.red, onPressed: state.isUpdating || state.fetchWarranties ? () {
                                          showMessage(context: context,message:"Please wait until previous item update");
                                        } : () {
                                          widget.inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId ==
                                                  favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                      .skuENTId).isNotEmpty ? state.productsInCart.firstWhere((element) => element.childskus!.first
                                                  .skuENTId ==
                                                  favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                      .skuENTId) : favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index]
                                                  .records!,
                                              customerID: widget.customer!.records!.first.id!,
                                              quantity: -1,
                                              productId: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!
                                                  .first.skuENTId!,
                                              orderID: state.orderId));
                                        },), state.productsInCart.where((element) => element.childskus!.first.skuENTId ==
                                            favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                .skuENTId!).isEmpty || (state.isUpdating && state.updateID == favouriteBrandScreenState.favoriteItems!
                                            .wrapperinstance!.records![widget.index].childskus!.first.skuENTId!)
                                            ? SizedBox(width: 0, height: 0,)
                                            : Padding(padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5), child: Text(double.parse(
                                            state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                                favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                    .skuENTId!).quantity ?? "0").toInt().toString(),
                                          style: TextStyle(fontSize: SizeSystem.size18, fontWeight: FontWeight.w500, color: Theme
                                              .of(context)
                                              .primaryColor, fontFamily: kRubik),),), state.isUpdating && state.updateID == favouriteBrandScreenState
                                            .favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first.skuENTId! ? Container(
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme
                                              .of(context)
                                              .primaryColor,), child: Padding(padding: EdgeInsets.all(11.0),
                                          child: Center(child: CupertinoActivityIndicator(color: Colors.white,),),),) : CircularAddButton(
                                          buttonColor: Theme
                                              .of(context)
                                              .primaryColor, onPressed: (state.isUpdating || state.fetchWarranties) ? () {
                                          showMessage(context: context,message:"Please wait until previous item update");
                                        } : () {
                                          widget.inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<FavouriteBrandScreenBloc>(),fromFavorite: true,
                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId ==
                                                  favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                      .skuENTId).isNotEmpty ? state.productsInCart.firstWhere((element) => element.childskus!.first
                                                  .skuENTId ==
                                                  favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                      .skuENTId) : favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index]
                                                  .records!,
                                              customerID: widget.customer!.records!.first.id!,
                                              ifWarranties: false,
                                              orderItem: "",
                                              warranties: Warranties(),
                                              quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                                  favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!.first
                                                      .skuENTId!).quantity ?? "0").toInt() + 1,
                                              productId: favouriteBrandScreenState.favoriteItems!.wrapperinstance!.records![widget.index].childskus!
                                                  .first.skuENTId!,
                                              orderID: state.orderId));
                                        },),
                                        ],),
                                      ],),
                                  ],),),
                            ],),),
                      ],),),),
                ],),
                Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10), child: Divider(color: Colors.grey.shade400, height: 1.5,),)
              ],));
        } else {
          return SizedBox();
        }
      });
    });
  }
}
