import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model_buy_again.dart';
import 'package:gc_customer_app/models/order_history/order_history.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';

class OrderHistoryProductItem extends StatefulWidget {
  OrderHistoryProductItem(
      {Key? key,
      required this.orderItems,
      required this.isLanding,
      required this.onTap,
      required this.gettingFavorites,
      required this.gettingActivity,
      this.recommendationModel,
      this.recommendationModelBuyAgain})
      : super(key: key);

  final OrderItems orderItems;
  final bool isLanding;
  final bool gettingFavorites;
  final bool gettingActivity;
  final void Function() onTap;
  //From recommended widget in mobile
  final LandingScreenRecommendationModel? recommendationModel;
  //From recommended widget in mobile
  final LandingScreenRecommendationModelBuyAgain? recommendationModelBuyAgain;

  @override
  State<OrderHistoryProductItem> createState() =>
      _OrderHistoryProductItemState();
}

class _OrderHistoryProductItemState extends State<OrderHistoryProductItem> {
  late LandingScreenBloc landingScreenBloc;

  @override
  void initState() {
    if (widget.orderItems.itemSku != null &&
        widget.orderItems.itemSku!.isNotEmpty) {
      landingScreenBloc = context.read<LandingScreenBloc>();
      landingScreenBloc.add(GetRecommendedItemStock(
          itemSkuId: widget.orderItems.itemSku!,
          gettingFavorites: widget.gettingFavorites,
          gettingActivity: widget.gettingActivity,
          recommendationModel: widget.recommendationModel,
          recommendationModelBuyAgain: widget.recommendationModelBuyAgain));
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.isLanding) {
      return BlocBuilder<LandingScreenBloc, LandingScreenState>(
          builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(top: kIsWeb ? 8 : 2.0),
          height: kIsWeb ? 100 : null,
          width: kIsWeb ? 100 : null,
          child: InkWell(
              hoverColor: Colors.transparent,
              onTap: widget.onTap,
              child: AspectRatio(
                aspectRatio: 0.9,
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: ColorSystem.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      kIsWeb
                          ? BoxShadow(
                              color: Color.fromARGB(22, 140, 147, 248),
                              blurRadius: 9,
                              offset:
                                  Offset(0, 6), // changes position of shadow
                            )
                          : BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: widget.orderItems.itemPic!,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      widget.orderItems.isItemOutOfStock!
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: ColorSystem.pureRed,
                                  border: Border.all(
                                      color: Colors.white, width: 3)),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                          : widget.orderItems.isItemOnline!
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: ColorSystem.additionalGreen,
                                      border: Border.all(
                                          color: Colors.white, width: 3)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(IconSystem.tickIcon,
                                          package: 'gc_customer_app',
                                          color: Colors.white,
                                          width: 12,
                                          height: 15),
                                      SizedBox(width: 10),
                                      Text(
                                        "IN STORE".toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.italic,
                                            fontSize: SizeSystem.size11,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  width: 0,
                                  height: 10,
                                ),
                    ],
                  ),
                ),
              )),
        );
      });
    } else {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: ColorSystem.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          margin: EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: widget.orderItems.isNetwork ?? false
                      ? Padding(
                          padding: EdgeInsets.all(5.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.orderItems.itemPic!,
                            width: double.infinity,
                          ),
                        )
                      : Image.asset(
                          widget.orderItems.itemPic!,
                          width: double.infinity,
                        )),
              if (widget.orderItems.isItemOutOfStock!)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromRGBO(255, 0, 0, 0.61),
                        border: Border.all(color: Colors.white, width: 3)),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Out of Stock".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: SizeSystem.size11,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                )
              else
                widget.orderItems.isItemOnline!
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ColorSystem.additionalGreen,
                              border:
                                  Border.all(color: Colors.white, width: 3)),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(IconSystem.tickIcon,
                                  package: 'gc_customer_app',
                                  color: Colors.white,
                                  width: 12,
                                  height: 10),
                              SizedBox(width: 5),
                              Text(
                                "IN STORE".toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontSize: SizeSystem.size11,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 20,
                        width: 20,
                      )
            ],
          ),
        ),
      );
    }
  }
}
