import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/product_detail/product_detail_page.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;

import 'package:visibility_detector/visibility_detector.dart';

import '../../bloc/recommended_screen_bloc/buy_again/recommendation_buy_again_bloc.dart';
import '../../common_widgets/browse_item_tile_widget.dart';
import '../../common_widgets/frequently_baught_widget.dart';
import '../../common_widgets/no_data_found.dart';
import '../../constants/text_strings.dart';
import '../product_screen/product_screen_page.dart';

class BuyAgainItemPage extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  final isb.InventorySearchBloc inventorySearchBloc;
  final isb.InventorySearchState state;
  BuyAgainItemPage(
      {super.key,
      required this.customerInfoModel,
      required this.inventorySearchBloc,
      required this.state});

  @override
  State<BuyAgainItemPage> createState() => _BuyAgainItemPageState();
}

class _BuyAgainItemPageState extends State<BuyAgainItemPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<Widget> userBrowsedWidget = [];
  late RecommendationBuyAgainBloc recommendedScreenBlocBloc;
  CarouselController carouselController = CarouselController();
  late StreamSubscription<RecommendationBuyAgainState> subscription;

  @override
  initState() {
    super.initState();
    // FirebaseAnalytics.instance.setCurrentScreen(screenName: 'BuyAgainPage');
    recommendedScreenBlocBloc = context.read<RecommendationBuyAgainBloc>();
    recommendedScreenBlocBloc.add(BuyAgainItems());
  }

  void onPressedFrequentlyButton() {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => OffersScreenMain(customerInfoModel: widget.customerInfoModel,),
    //   ),
    // );
  }

  List<Widget> generateListOfBrowsedItems(
      LoadBuyAgainItemsSuccess state, int indexOfList) {
    if (userBrowsedWidget.isEmpty) {
      for (var i = 0; i < indexOfList; i++) {
        if (widget.inventorySearchBloc.state.productsInCart.isNotEmpty) {
          for (asm.Records records
              in widget.inventorySearchBloc.state.productsInCart) {
            if (state.buyAgainModel!.productBuyAgain[i].itemSKUC ==
                records.childskus!.first.skuENTId) {
              recommendedScreenBlocBloc
                  .add(UpdateProductInBuyAgain(index: i, records: records));
            }
          }
        }
        userBrowsedWidget.add(BlocProvider.value(
          value: recommendedScreenBlocBloc,
          child: BrowseItemTileWidget(
            inventorySearchBloc: widget.inventorySearchBloc,
            customer: widget.customerInfoModel,
            mainIndex: 0,
            childIndex: i,
            recommendedState: "LoadBuyAgainItemsSuccess",
            onPressedProduct: () {
              recommendedScreenBlocBloc.add(
                LoadProductDetailBuyAgain(
                  ifDetail: true,
                  index: i,
                  inventorySearchBloc: widget.inventorySearchBloc,
                  state: widget.state,
                  customerId: widget.customerInfoModel.records!.first.id!,
                ),
              );
            },
          ),
        ));
      }
    }

    return userBrowsedWidget;
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return BlocConsumer<RecommendationBuyAgainBloc,
        RecommendationBuyAgainState>(
      listener: (context, state) {
        if (state is LoadBuyAgainItemsSuccess) {
          if (state.message!.isNotEmpty && state.message != "done") {
            Future.delayed(Duration.zero, () {
              setState(() {});
              showMessage(context: context,message:state.message!);
            });
          }
          if (state.product != null &&
              state.product!.childskus != null &&
              state.product!.childskus!.isNotEmpty) {
            print("in detail");
            String id = state.product!.childskus!.first.skuENTId!;
            recommendedScreenBlocBloc.add(InitializeProduct());
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ProductDetailPage(
                    customerID: widget.customerInfoModel.records!.first.id!,
                    customer: widget.customerInfoModel,
                    warranties: Warranties(),
                    productsInCart: widget.inventorySearchBloc.state.productsInCart.isNotEmpty?widget.inventorySearchBloc.state.productsInCart:[],
                    skUID: id,
                    orderId: '',
                    orderLineItemId: '',
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
          }
          recommendedScreenBlocBloc.add(EmptyMessage());
        }
      },
      builder: (context, state) {
        if (state is LoadBuyAgainItemsSuccess) {
          generateListOfBrowsedItems(
              state, state.buyAgainModel!.productBuyAgain.length);
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: widthOfScreen * 0.04, top: heightOfScreen * 0.04),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(right: widthOfScreen * 0.045),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Buy Again Items",
                                style: textThem.headline2,
                              ),
                              // GestureDetector(
                              //   onTap: () => Navigator.of(context).push(
                              //       MaterialPageRoute(
                              //           builder: (context) =>
                              //               ProductScreen(customerInfoModel: widget.customerInfoModel,))),
                              //   child: Text(
                              //     viewalltxt,
                              //     style: textThem.headline2,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: heightOfScreen * 0.03),
                        userBrowsedWidget.isNotEmpty
                            ? Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _currentIndex > 0
                                        ? carouselController.previousPage()
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: CarouselSlider(
                                      carouselController: carouselController,
                                      items: userBrowsedWidget,
                                      options: CarouselOptions(
                                        viewportFraction: 1,
                                        enableInfiniteScroll: false,
                                        onPageChanged: (index, reason) {
                                          _currentIndex = index;
//                                         setState((){});
                                        },
                                        aspectRatio: 2.6,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _currentIndex <
                                            (userBrowsedWidget.length - 1)
                                        ? carouselController.nextPage()
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 10.0, right: 5),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: heightOfScreen * 0.25,
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      IconSystem.accessoriesNotFound,
                                      package: 'gc_customer_app',
                                    ),
                                    Text(
                                      'Data Not Found',
                                      style: textThem.headline4,
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(height: heightOfScreen * 0.02),
                        Padding(
                          padding:
                              EdgeInsets.only(right: widthOfScreen * 0.045),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                frequentlyBaughttxt,
                                style: textThem.headline2,
                              ),
                              // Text(
                              //   viewalltxt,
                              //   style: textThem.headline2,
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: heightOfScreen * 0.02),
                        state.buyAgainModel!.productBuyAgainOthers.isNotEmpty
                            ? SizedBox(
                                height: heightOfScreen * 0.25,
                                width: widthOfScreen,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: state.buyAgainModel!
                                        .productBuyAgainOthers.length,
                                    itemBuilder: (context, i) {
                                      return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: state
                                              .buyAgainModel!
                                              .productBuyAgainOthers[i]
                                              .recommendedProductSet
                                              .length,
                                          itemBuilder: (context, index) {
                                            if (widget.inventorySearchBloc.state
                                                .productsInCart.isNotEmpty) {
                                              for (asm.Records records in widget
                                                  .inventorySearchBloc
                                                  .state
                                                  .productsInCart) {
                                                if (state
                                                        .buyAgainModel!
                                                        .productBuyAgainOthers[
                                                            i]
                                                        .recommendedProductSet[
                                                            index]
                                                        .itemSKU ==
                                                    records.childskus!.first
                                                        .skuENTId) {
                                                  recommendedScreenBlocBloc.add(
                                                      UpdateProductInBuyAgainOthers(
                                                          childIndex: index,
                                                          records: records,
                                                          parentIndex: i));
                                                }
                                              }
                                            }
                                            return Row(
                                              children: [
                                                BlocProvider.value(
                                                  value:
                                                      recommendedScreenBlocBloc,
                                                  child: VisibilityDetector(
                                                    key: Key(state
                                                        .buyAgainModel!
                                                        .productBuyAgainOthers[
                                                            i]
                                                        .recommendedProductSet[
                                                            index]
                                                        .productId),
                                                    onVisibilityChanged:
                                                        (VisibilityInfo info) {
                                                      var visiblePercentage =
                                                          info.visibleFraction *
                                                              100;
                                                      if (visiblePercentage >
                                                          25) {
                                                        if (!state
                                                            .buyAgainModel!
                                                            .productBuyAgainOthers[
                                                                i]
                                                            .recommendedProductSet[
                                                                index]
                                                            .hasInfo!) {
                                                          recommendedScreenBlocBloc.add(
                                                              GetItemAvailabilityBuyAgain(
                                                                  childIndex:
                                                                      index,
                                                                  parentIndex:
                                                                      i));
                                                        }
                                                      }
                                                    },
                                                    child:
                                                        FrequentlyBoughtWidget(
                                                      // imageUrl: state
                                                      //     .recommendationScreenModel!
                                                      //     .productBrowsingOthers[i]
                                                      //     .recommendedProductSet[index]
                                                      //     .imageURL,
                                                      mainIndex: i,
                                                      childIndex: index,
                                                      customer: widget
                                                          .customerInfoModel,
                                                      inventorySearchBloc: widget
                                                          .inventorySearchBloc,
                                                      recommendedState:
                                                          "LoadBuyAgainItemsSuccess",
                                                      onPressedProduct: () {},
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: widthOfScreen * 0.04,
                                                )
                                              ],
                                            );
                                          });
                                    }),
                              )
                            : SizedBox(
                                height: heightOfScreen * 0.25,
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      IconSystem.accessoriesNotFound,
                                      package: 'gc_customer_app',
                                    ),
                                    Text(
                                      'Data Not Found',
                                      style: textThem.headline4,
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                  )
                ],
              ),
            ],
          );
        } else if (state is BuyAgainFailure) {
          return Center(
            child: NoDataFound(
              fontSize: 24,
            ),
          );
        } else {
          return Container(
              height: heightOfScreen / 2,
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ));
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
