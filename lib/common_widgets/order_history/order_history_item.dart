import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/models/order_history/open_order_model.dart';
import 'package:gc_customer_app/models/order_history/order_history.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';

class OrderHistoryItem extends StatefulWidget {
  OrderHistoryItem({
    Key? key,
    required this.recordIndex,
    required this.records,
    required this.orderId,
    required this.skuId,
    required this.onTap,
  }) : super(key: key);

  final int recordIndex;
  final Records records;
  final String orderId;
  final String skuId;
  final void Function() onTap;

  @override
  State<OrderHistoryItem> createState() => _OrderHistoryItemState();
}

class _OrderHistoryItemState extends State<OrderHistoryItem> {
  late OrderHistoryBloc orderHistoryBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: 2.0),
      child: InkWell(
          onTap: widget.onTap,
          child: AspectRatio(
            aspectRatio: 0.9,
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: ColorSystem.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text(widget.records.itemSKUC!),
                  SizedBox(
                    height: 2,
                  ),
                  Expanded(
                    child: Center(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (context, url, s) => FadeShimmer(
                          height: 80,
                          width: 100,
                          radius: 20,
                          highlightColor: Colors.grey.shade300,
                          baseColor: Colors.grey.shade100,
                        ),
                        placeholder: (context, url) => FadeShimmer(
                          height: 80,
                          width: 100,
                          radius: 20,
                          highlightColor: Colors.grey.shade300,
                          baseColor: Colors.grey.shade100,
                        ),
                        imageUrl: widget.records.imageURL1C ?? "",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  widget.records.outOfStock!
                      ? Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ColorSystem.pureRed,
                              border:
                                  Border.all(color: Colors.white, width: 3)),
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
                      : widget.records.inStore!
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
                                crossAxisAlignment: CrossAxisAlignment.center,
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
  }
}
