import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/offers_screen_bloc/offers_screen_bloc.dart';
import 'package:gc_customer_app/common_widgets/circular_remove_button.dart';

import '../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart' as fbsb;
import '../constants/colors.dart';
import '../models/cart_model/cart_warranties_model.dart';
import '../models/landing_screen/customer_info_model.dart';
import '../primitives/color_system.dart';
import '../primitives/constants.dart';
import '../primitives/size_system.dart';
import 'circular_add_button.dart';

class OffersScreenTileWidget extends StatelessWidget {
  OffersScreenTileWidget({
    Key? key,
    required this.index,
    required this.state,
    required this.inventorySearchBloc,
    required this.customer,
  }) : super(key: key);

  final int index;
  final InventorySearchState state;
  final InventorySearchBloc inventorySearchBloc;
  final CustomerInfoModel? customer;


  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return BlocBuilder<OffersScreenBloc, OfferScreenState>(
        builder: (context,offerScreenState) {
          return BlocBuilder<InventorySearchBloc, InventorySearchState>(
              builder: (context,state) {
                if(offerScreenState is OfferScreenSuccess) {
                  return InkWell(
                    onTap: (){
                      context.read<OffersScreenBloc>().add(LoadProductDetail(
                          index: index,
                          ifDetail: true,
                          customerId: customer!.records!.first.id!,
                          inventorySearchBloc: inventorySearchBloc,
                          state: state
                      ));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: widthOfScreen * 0.05,
                                vertical: heightOfScreen * 0.01,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: AspectRatio(
                                            aspectRatio: 0.99,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFF4F6FA),
                                                  borderRadius: BorderRadius
                                                      .circular(20)),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: offerScreenState.offersScreenModel![index].flashDeal!.assetPath??"",
                                                imageBuilder: (context,
                                                    imageProvider) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                          0xFFF4F6FA),
                                                      borderRadius: BorderRadius
                                                          .circular(20),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl: offerScreenState.offersScreenModel![index].flashDeal!.assetPath??"",
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Container(
                                                          width: widthOfScreen *
                                                              0.3,
                                                          height: heightOfScreen *
                                                              0.15,
                                                          decoration: BoxDecoration(
                                                            color: ColorSystem
                                                                .addtionalCulturedGrey,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                          ),
                                                          margin:
                                                          EdgeInsets.only(
                                                              bottom: 8),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                            children: [
                                                              Expanded(
                                                                  child: Image
                                                                      .network(
                                                                    offerScreenState.offersScreenModel![index].flashDeal!.assetPath??"",
                                                                    width: double
                                                                        .infinity,
                                                                  )),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(offerScreenState.offersScreenModel![index].flashDeal!.productDisplayName??"",
                                                  maxLines: 2,
                                                  style: textThem.headline3),
                                              SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '\$${(offerScreenState.offersScreenModel![index].flashDeal!.todaysPrice??0.0).toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                            fontSize: SizeSystem
                                                                .size20,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: ColorSystem
                                                                .chartBlack,
                                                            fontFamily: kRubik),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '\$${(offerScreenState.offersScreenModel![index].flashDeal!.msrpPrice??0.0).toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold,

                                                                color: AppColors
                                                                    .redTextColor,
                                                                decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                                fontSize: 12),
                                                          ),
                                                          SizedBox(
                                                              width: 2),
                                                          Text(
                                                            '(${offerScreenState.offersScreenModel![index].flashDeal!.savingsPercentRounded??0.0}%)',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold,
                                                                color: AppColors
                                                                    .redTextColor,
                                                                fontSize: 10),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  offerScreenState
                                                      .offersScreenModel![index]
                                                      .flashDeal!.isUpdating!?
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
                                                  state.isUpdating && (state.updateID == offerScreenState.offersScreenModel![index].flashDeal!.enterpriseSkuId ||
                                                          state.updateSKUID == offerScreenState.offersScreenModel![index].flashDeal!.enterpriseSkuId ||
                                                          state.updateID == offerScreenState.offersScreenModel![index].flashDeal!.productId ||
                                                          state.updateSKUID == offerScreenState.offersScreenModel![index].flashDeal!.productId ||
                                                          state.updateID == "${offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus != null && offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.isNotEmpty?offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId!:"-PRODUCT"}" ||
                                                          state.updateSKUID == "${offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus != null && offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.isNotEmpty?offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId!:"-PRODUCT"}"
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

                                                  (state.productsInCart.where((element) => element.childskus!.first.skuENTId == offerScreenState
                                                      .offersScreenModel![index]
                                                      .flashDeal!.enterpriseSkuId).isEmpty || offerScreenState
                                                      .offersScreenModel![index]
                                                      .flashDeal!.records!.childskus!.isEmpty)?
                                                  CircularAddButton(
                                                    buttonColor: ColorSystem
                                                        .primaryTextColor,
                                                    onPressed: () {
                                                      if(offerScreenState
                                                          .offersScreenModel![index]
                                                          .flashDeal!.records!.childskus!.isEmpty){
                                                        context.read<OffersScreenBloc>().add(LoadProductDetail(
                                                            index: index,
                                                            ifDetail: false,
                                                            customerId: customer!.records!.first.id!,
                                                            inventorySearchBloc: inventorySearchBloc,
                                                            state: state
                                                        ));
                                                      }
                                                      else{
                                                        if(state.productsInCart.where((element) => element.childskus!.first.skuENTId ==
                                                            offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId).isEmpty ||
                                                            double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==
                                                                offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId).quantity ?? "0").toInt().toString() == "0") {
                                                          inventorySearchBloc.add(GetWarranties(
                                                            records: state.productsInCart.where((element) => element.childskus!.first.skuENTId ==offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId).isNotEmpty?
                                                            state.productsInCart.firstWhere((element) =>
                                                            element.childskus!.first.skuENTId == offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId):
                                                            offerScreenState.offersScreenModel![index].flashDeal!.records!,
                                                            skuEntId:offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuPIMId!,
                                                            productId:offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId!,
                                                          ));
                                                        }
                                                        else{
                                                          inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<fbsb.FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId ==offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId).isNotEmpty?
                                                              state.productsInCart.firstWhere((element) =>
                                                              element.childskus!.first.skuENTId == offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId):
                                                              offerScreenState.offersScreenModel![index].flashDeal!.records!,
                                                              customerID: customer!.records!.first.id!,
                                                              quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId).quantity ?? "0").toInt() + 1,
                                                              ifWarranties: false,
                                                              orderItem: "",
                                                              warranties: Warranties(),
                                                              productId: offerScreenState.offersScreenModel![index].flashDeal!.records!.productId!,
                                                              skUid: offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId!,
                                                              orderID: state.orderId));
                                                        }
                                                      }

                                                      print('Add to cart');
                                                    },
                                                  ):
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      state.productsInCart.where((element) => element.childskus!.first.skuENTId == offerScreenState
                                                          .offersScreenModel![index]
                                                          .flashDeal!.enterpriseSkuId).isEmpty || (state.isUpdating && state.updateID == offerScreenState
                                                          .offersScreenModel![index]
                                                          .flashDeal!.enterpriseSkuId!)?
                                                      SizedBox(width: 0,height: 0,):
                                                      CircularRemoveButton(
                                                        buttonColor: Colors.red,
                                                        onPressed: () {
                                                          inventorySearchBloc.add(RemoveFromCart(favouriteBrandScreenBloc: context.read<fbsb.FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId == offerScreenState
                                                                  .offersScreenModel![index]
                                                                  .flashDeal!.enterpriseSkuId).isNotEmpty?
                                                              state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == offerScreenState
                                                                  .offersScreenModel![index]
                                                                  .flashDeal!.enterpriseSkuId):
                                                              offerScreenState
                                                                  .offersScreenModel![index]
                                                                  .flashDeal!.records!,
                                                              customerID: customer!.records!.first.id!,
                                                              quantity: -1,
                                                              productId: offerScreenState
                                                                  .offersScreenModel![index]
                                                                  .flashDeal!.enterpriseSkuId!,
                                                              orderID: state.orderId));
                                                        },
                                                      ),
                                                      state.productsInCart.where((element) => element.childskus!.first.skuENTId == offerScreenState
                                                          .offersScreenModel![index]
                                                          .flashDeal!.enterpriseSkuId!).isEmpty || (state.isUpdating && state.updateID == offerScreenState
                                                          .offersScreenModel![index]
                                                          .flashDeal!.enterpriseSkuId!)?
                                                      SizedBox(width: 0,height: 0,):
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5),
                                                        child:
                                                        Text(
                                                          double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == offerScreenState
                                                              .offersScreenModel![index]
                                                              .flashDeal!.enterpriseSkuId!).quantity??"0.0").toInt().toString(),
                                                          style: TextStyle(
                                                              fontSize:
                                                              SizeSystem.size18,
                                                              fontWeight: FontWeight.w500,
                                                              color: ColorSystem
                                                                  .primaryTextColor,
                                                              fontFamily: kRubik),
                                                        ),
                                                      ),
                                                      state.isUpdating && state.updateID ==offerScreenState
                                                          .offersScreenModel![index]
                                                          .flashDeal!.enterpriseSkuId!?Container(
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
                                                      CircularAddButton(
                                                        buttonColor: ColorSystem
                                                            .primaryTextColor,
                                                        onPressed: () {
                                                          inventorySearchBloc.add(AddToCart(favouriteBrandScreenBloc: context.read<fbsb.FavouriteBrandScreenBloc>(),
                                                              records: state.productsInCart.where((element) => element.childskus!.first.skuENTId ==offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId).isNotEmpty?
                                                              state.productsInCart.firstWhere((element) =>
                                                              element.childskus!.first.skuENTId == offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId):
                                                              offerScreenState.offersScreenModel![index].flashDeal!.records!,
                                                              customerID: customer!.records!.first.id!,
                                                              quantity: double.parse(state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId ==  offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId).quantity ?? "0").toInt() + 1,
                                                              ifWarranties: false,
                                                              orderItem: "",
                                                              warranties: Warranties(),
                                                              productId: offerScreenState.offersScreenModel![index].flashDeal!.records!.productId!,
                                                              skUid: offerScreenState.offersScreenModel![index].flashDeal!.records!.childskus!.first.skuENTId!,
                                                              orderID: state.orderId));
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 10),
                          child: Divider(
                            color: Colors.grey.shade400,
                            height: 1.5,
                          ),
                        )
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
}
