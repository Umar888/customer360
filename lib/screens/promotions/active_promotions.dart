// import 'package:flutter/material.dart';
// import 'package:gc_customer_app/models/promotion_model.dart';
// import 'package:gc_customer_app/primitives/color_system.dart';
// import 'package:gc_customer_app/screens/promotions/active_promotion.dart';

// class ActivePromotionsScreen extends StatelessWidget {
//   final List<PromotionModel> promotions;
//   ActivePromotionsScreen({super.key, required this.promotions});

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     //Set the size how to the screen always show 3 promotion with the third just show 70%
//     double widgetWidth = (screenWidth - 72) / 2.3;
//     if (promotions.isEmpty) {
//       return SizedBox.shrink();
//     }
//     return Container(
//       height: widgetWidth + 90,
//       padding: EdgeInsets.only(top: 16),
//       margin: EdgeInsets.only(left: 24),
//       decoration: BoxDecoration(
//           color: ColorSystem.culturedGrey,
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
//       child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: promotions.length,
//           padding: EdgeInsets.only(left: 16),
//           itemBuilder: (context, index) => SizedBox(
//                 width: widgetWidth,
//                 child: ActivePromotion(
//                   promotion: promotions[index],
//                   promotionSize: widgetWidth,
//                 ),
//               )),
//     );
//   }
// }
