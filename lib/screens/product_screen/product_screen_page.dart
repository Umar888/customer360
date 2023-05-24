import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';

import '../../bloc/offers_screen_bloc/offers_screen_bloc.dart';
import '../../common_widgets/app_bar_widget.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../common_widgets/offers_screen_tile_widget.dart';
import '../../constants/colors.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';

class ProductScreen extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  ProductScreen({super.key, required this.customerInfoModel});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late OffersScreenBloc offersScreenBloc;
  late InventorySearchBloc inventorySearchBloc;
  late ProductDetailBloc productDetailBloc;
  late ZipStoreListBloc zipStoreListBloc;

  bool? newArrived;
  @override
  void initState() {
    super.initState();
    newArrived = false;
    offersScreenBloc = context.read<OffersScreenBloc>();
    inventorySearchBloc = context.read<InventorySearchBloc>();
    productDetailBloc = context.read<ProductDetailBloc>();
    zipStoreListBloc = context.read<ZipStoreListBloc>();

    offersScreenBloc.add(LoadData(offers: []));
  }

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(widget.customerInfoModel,null,null,inventorySearchBloc,productDetailBloc,zipStoreListBloc),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBarWidget(
          paddingFromleftLeading: widthOfScreen * 0.034,
          paddingFromRightActions: widthOfScreen * 0.034,
          textThem: textThem,
          leadingWidget: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 30,
          ),
          onPressedLeading: () => Navigator.of(context).pop(),
          titletxt: 'PRODUCT',
          actionsWidget: SizedBox.shrink(),
          actionOnPress: () => () {},
        ),
      ),
      // body: Column(
      //   mainAxisSize: MainAxisSize.max,
      //   children: <Widget>[
      //     SizedBox(height: heightOfScreen * 0.03),
      //     Container(
      //       width: widthOfScreen,
      //       decoration: BoxDecoration(
      //         border: Border.all(color: AppColors.favoriteContainerBorder),
      //       ),
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           SizedBox(
      //             height: heightOfScreen * 0.08,
      //             child: Center(
      //               child: Row(
      //                 children: [
      //                   InkWell(
      //                     onTap: () {
      //                       setState(() {
      //                         newArrived = !newArrived!;
      //                       });
      //                     },
      //                     child: Row(
      //                       mainAxisSize: MainAxisSize.min,
      //                       children: [
      //                         Container(
      //                             margin: EdgeInsets.only(
      //                                 right: 20, left: widthOfScreen * 0.04),
      //                             child: Icon(
      //                               Icons.keyboard_arrow_down_sharp,
      //                               color: Colors.black87,
      //                             )),
      //                         Text(
      //                           'CUSTOMER BROWSED',
      //                           style: TextStyle(
      //                             fontSize: SizeSystem.size14,
      //                             fontWeight: FontWeight.w500,
      //                             color: AppColors.redTextColor,
      //                           ),
      //                         ),
      //                         SizedBox(width: widthOfScreen * 0.2),
      //                       ],
      //                     ),
      //                   ),
      //                   Expanded(
      //                     child: Flex(
      //                       direction: Axis.horizontal,
      //                       children: [
      //                         Expanded(
      //                           flex: 1,
      //                           child: Row(
      //                             children: [
      //                               Container(
      //                                 color: AppColors.favoriteContainerBorder,
      //                                 width: 1,
      //                               ),
      //                               Expanded(
      //                                 child: Center(
      //                                   child: IconButton(
      //                                       onPressed: (() {}),
      //                                       icon: SvgPicture.asset(
      //                                         IconSystem.searchIcon,
      //                                         width: 25,
      //                                         height: 25,
      //                                       )),
      //                                 ),
      //                               )
      //                             ],
      //                           ),
      //                         ),
      //                         Expanded(
      //                           flex: 1,
      //                           child: Row(
      //                             children: [
      //                               Container(
      //                                 color: AppColors.favoriteContainerBorder,
      //                                 width: 1,
      //                               ),
      //                               Expanded(
      //                                 child: Center(
      //                                   child: Stack(
      //                                     clipBehavior: Clip.none,
      //                                     children: [
      //                                       IconButton(
      //                                           onPressed: () {},
      //                                           icon: SvgPicture.asset(
      //                                             IconSystem.filterIcon,
      //                                             width: 30,
      //                                             height: 30,
      //                                           )),
      //                                       Positioned(
      //                                         right: -4,
      //                                         top: -10,
      //                                         child: Card(
      //                                           elevation: 2,
      //                                           color: Colors.red,
      //                                           shadowColor:
      //                                               Colors.red.shade100,
      //                                           shape: CircleBorder(),
      //                                           child: Padding(
      //                                             padding: EdgeInsets.all(8.0),
      //                                             child: Text(
      //                                               "5",
      //                                               style: TextStyle(
      //                                                 fontSize:
      //                                                     SizeSystem.size14,
      //                                                 fontWeight:
      //                                                     FontWeight.w500,
      //                                                 color: Colors.white,
      //                                               ),
      //                                             ),
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   )
      //                 ],
      //               ),
      //             ),
      //           ),
      //           Divider(
      //             height: 1,
      //             color: Colors.grey.shade300,
      //           )
      //         ],
      //       ),
      //     ),
      //     SizedBox(
      //       height: heightOfScreen * 0.02,
      //     ),
      //     BlocBuilder<OffersScreenBloc, OfferScreenState>(
      //       builder: (context, state) {
      //         if (state is OfferScreenSuccess) {
      //           return Expanded(
      //             child: !newArrived!
      //                 ? ListView.builder(
      //                     itemCount: state.offersScreenModel!.offers.length,
      //                     itemBuilder: (context, index) =>
      //                         OffersScreenTileWidget(
      //                       imageUrl: state.offersScreenModel!.offers[0]
      //                           .flashDeal.assetPath,
      //                       productDescriptiontxt: state.offersScreenModel!
      //                           .offers[0].flashDeal.productDisplayName,
      //                       amount: state.offersScreenModel!.offers[0].flashDeal
      //                           .salePrice
      //                           .toString(),
      //                       cutPrice: state.offersScreenModel!.offers[0]
      //                           .flashDeal.listPrice,
      //                       cutPricePercentage: state.offersScreenModel!
      //                           .offers[0].flashDeal.savingsPercentRounded
      //                           .toStringAsFixed(2),
      //                     ),
      //                   )
      //                 : ListView(
      //                     children: [
      //                       Padding(
      //                         padding:
      //                             EdgeInsets.only(left: widthOfScreen * 0.1),
      //                         child: Text(
      //                           'Recommended for you',
      //                           style: textThem.headline4,
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         height: 5,
      //                       ),
      //                       Divider(
      //                         thickness: 1,
      //                       ),
      //                       SizedBox(height: heightOfScreen * 0.02),
      //                       Padding(
      //                         padding:
      //                             EdgeInsets.only(left: widthOfScreen * 0.1),
      //                         child: Text(
      //                           'Best Seller',
      //                           style: textThem.headline4,
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         height: 5,
      //                       ),
      //                       Divider(
      //                         thickness: 1,
      //                       ),
      //                       SizedBox(height: heightOfScreen * 0.02),
      //                       Padding(
      //                         padding:
      //                             EdgeInsets.only(left: widthOfScreen * 0.1),
      //                         child: Text(
      //                           'Newest First',
      //                           style: textThem.headline4,
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         height: 5,
      //                       ),
      //                       Divider(
      //                         thickness: 1,
      //                       ),
      //                       SizedBox(height: heightOfScreen * 0.02),
      //                       Padding(
      //                         padding:
      //                             EdgeInsets.only(left: widthOfScreen * 0.1),
      //                         child: Text(
      //                           'Brand A-Z',
      //                           style: textThem.headline4,
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         height: 5,
      //                       ),
      //                       Divider(
      //                         thickness: 1,
      //                       ),
      //                     ],
      //                   ),
      //           );
      //         } else {
      //           return Container(
      //               height: heightOfScreen/2,
      //               color: Colors.white,
      //               child: Center(
      //                 child: Padding(
      //                   padding: EdgeInsets.all(20.0),
      //                   child: CircularProgressIndicator(),
      //                 ),
      //               ));
      //         }
      //       },
      //     )
      //   ],
      // ),
    );
  }
}
