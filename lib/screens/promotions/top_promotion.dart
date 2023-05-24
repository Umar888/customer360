import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/promotion_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/promotions/promotion_detail_screen.dart';
import 'package:gc_customer_app/utils/common_widgets.dart';
import 'package:intl/intl.dart';

class TopPromotion extends StatelessWidget {
  final PromotionModel promotion;
  TopPromotion(this.promotion, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM dd, yyyy');
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: (() => Navigator.push(
          context,
          kIsWeb
              ? webPageRoute(PromotionDetailScreen(promotion: promotion))
              : MaterialPageRoute(
                  builder: (context) =>
                      PromotionDetailScreen(promotion: promotion),
                ))),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
            color: ColorSystem.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(18, 0, 0, 0),
                spreadRadius: 0,
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ]),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    promotion.subject ?? '',
                    maxLines: 4,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 8),
                  Text(
                    format.format(DateTime.parse(
                        promotion.messageDate ?? DateTime.now().toString())),
                    style: TextStyle(
                        color: ColorSystem.secondary, fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
