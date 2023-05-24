import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';

import '../primitives/constants.dart';

class OffersWidget extends StatelessWidget {
  OffersWidget({
    Key? key,
    required this.widthOfScreen,
    required this.pathOfImage,
    required this.percentageOff,
    required this.backOf,
    required this.numberOfProducts,
    required this.totalPrice,
  }) : super(key: key);

  final double widthOfScreen;
  final String pathOfImage;
  final String percentageOff;
  final String backOf;
  final String totalPrice;
  final String numberOfProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthOfScreen*0.9,
      decoration:
      BoxDecoration(
        color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)
          // image: DecorationImage(
          //     image: CachedNetworkImageProvider(pathOfImage))
      ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0,vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text("Daily Pick",
                style: TextStyle(
                  fontFamily: kRubik,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                    fontSize: 2 * (MediaQuery.of(context).size.height * 0.0095)
                ),),
                Text("$percentageOff% OFF",
                style:  TextStyle(
                  fontFamily: kRubik,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                    fontSize: 2 * (MediaQuery.of(context).size.height * 0.0095)
                ),),
              ],
            ),
            SizedBox(height: 5,),
            Expanded(
              child: Row(
                children: [
                  AspectRatio(aspectRatio: 1,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    errorWidget:(context, url,s) =>   FadeShimmer(
                      height: 100,
                      width: 100,
                      radius: 10,
                      highlightColor: Colors.grey.shade500,
                      baseColor: Colors.grey.shade300,
                    ),
                    placeholder:(context, url) =>   FadeShimmer(
                      height: 100,
                      width: 100,
                      radius: 10,
                      highlightColor: Colors.grey.shade500,
                      baseColor: Colors.grey.shade300,
                    ),
                    imageUrl: pathOfImage,
                  ),),

                  Expanded(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(numberOfProducts,
                          maxLines: 3,
                          style:  TextStyle(
                              fontFamily: kRubik,
                              fontSize: 2 * (MediaQuery.of(context).size.height * 0.01),
                              color: Colors.black,
                          ),),
                       Spacer(),
                        Text("USD $backOf",
                          maxLines: 1,
                          style:  TextStyle(
                              fontFamily: kRubik,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            fontSize: 2 * (MediaQuery.of(context).size.height * 0.012),
                          ),),
                        Text("USD $totalPrice",
                          maxLines: 3,
                          style:  TextStyle(
                              fontFamily: kRubik,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black,
                              fontSize: 2 * (MediaQuery.of(context).size.height * 0.007)
                          ),),

                      ],
                    ),
                  ))
                ],
              ),
            )
          ],
          ),
        ),
    );
  }
}
