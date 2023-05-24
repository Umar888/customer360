import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/order_lookup_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/order_lookup/widgets.dart';

class OrderLookupDetailScreen extends StatelessWidget {
  final OrderLookupModel order;
  OrderLookupDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: true,
        title: Text(
          order.orderNo ?? '',
          style: theme.caption?.copyWith(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${order.grandTotal}',
                  style: theme.caption?.copyWith(fontSize: 16),
                ),
                orderStatusWidget(order.orderStatus ?? ''),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
                child: ListView.builder(
              itemCount: order.items?.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: ColorSystem.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: ColorSystem.black.withOpacity(0.1),
                            blurRadius: 16,
                            offset: Offset(5, 5))
                      ]),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: order.items?[index]?.imageUrl ?? '',
                        imageBuilder: (context, imageProvider) => Stack(
                          children: [
                            Container(
                              height: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain)),
                            ),
                            if (!(order.items?[index]?.itemStatus ?? '')
                                .toLowerCase()
                                .contains('added'))
                              Container(
                                height: 100,
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.1, 0.8]),
                                ),
                              ),
                            if (!(order.items?[index]?.itemStatus ?? '')
                                .toLowerCase()
                                .contains('added'))
                              Positioned(
                                right: 4,
                                top: 4,
                                child: orderStatusWidget(
                                    order.items?[index]?.itemStatus ?? '',
                                    false),
                              )
                          ],
                        ),
                        errorWidget: (context, url, error) => Stack(
                          children: [
                            Container(
                              height: 120,
                              color: ColorSystem.greyLight,
                              alignment: Alignment.center,
                              child: Text('Image not found'),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: orderStatusWidget(
                                  order.items?[index]?.itemStatus ?? '', false),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        order.items?[index]?.itemDesc ?? '',
                        maxLines: 3,
                        style: theme.caption?.copyWith(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${order.items?[index]?.unitPrice ?? '0'}',
                            style: theme.caption?.copyWith(fontSize: 18),
                          ),
                          Text(
                            order.items?[index]?.orderedQuantity?.toString() ??
                                '0',
                            style: theme.caption?.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unit Price',
                            style: TextStyle(fontFamily: kRubik, fontSize: 12),
                          ),
                          Text(
                            'Qty',
                            style: TextStyle(fontFamily: kRubik, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     // Expanded(
                      //     //     child: Text(
                      //     //   'Tracking ID: ${order.items?[index]?.trackingNo ?? 'N/A'}',
                      //     //   style: TextStyle(fontFamily: kRubik),
                      //     // )),
                      //     orderStatusWidget(
                      //         order.items?[index]?.itemStatus ?? '', false),
                      //   ],
                      // ),
                    ],
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
