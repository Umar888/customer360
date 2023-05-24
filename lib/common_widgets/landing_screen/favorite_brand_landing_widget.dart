import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/common_widgets/user_circle_avatar.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class FavoriteBrandLandingWidget extends StatelessWidget {
  FavoriteBrandLandingWidget({
    Key? key,
    required this.widthOfScreen,
    required this.heightOfScreen,
    required this.brandName,
    required this.updates,
    required this.onTap,
    required this.imageUrl,
  }) : super(key: key);

  final double widthOfScreen;
  final double heightOfScreen;
  final void Function() onTap;
  final String brandName;
  final String updates;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () => onTap(),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(kIsWeb ? 10 : widthOfScreen * 0.02),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(kIsWeb ? 8 : widthOfScreen * 0.03)
                  .copyWith(top: kIsWeb ? 16 : widthOfScreen * 0.04),
              decoration: BoxDecoration(
                  color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                      .withOpacity(1.0),
                  shape: BoxShape.circle),
              child: Center(
                child: Text(
                  brandName[0].toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: heightOfScreen * 0.05,
                      fontFamily: kRubik,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Text(
              brandName,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: heightOfScreen * 0.018, fontFamily: kRubik),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              'Purchased $updates items',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: heightOfScreen * 0.015,
                  fontFamily: kRubik),
            ),
          ],
        ),
      ),
    );
  }
}
