// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:gc_customer_app/models/promotion_model.dart';
// import 'package:gc_customer_app/primitives/color_system.dart';
// import 'package:intl/intl.dart';

// class ExpiredPromotion extends StatelessWidget {
//   final PromotionModel promotion;
//   ExpiredPromotion({Key? key, required this.promotion}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double widgetHeight = MediaQuery.of(context).size.width / 6.818;
//     final format = DateFormat('MMM dd, yyyy');
//     return Container(
//       height: widgetHeight,
//       margin: EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
//       child: Row(
//         children: [
//           CachedNetworkImage(
//             imageUrl: promotion.attributes?.url ?? '',
//             imageBuilder: (context, imageProvider) => Container(
//               height: widgetHeight,
//               width: widgetHeight,
//               margin: EdgeInsets.only(right: 16),
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Color.fromARGB(18, 0, 0, 0),
//                       spreadRadius: 0,
//                       blurRadius: 16,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                   image:
//                       DecorationImage(image: imageProvider, fit: BoxFit.cover)),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Text(
//                   promotion.createdBy?.name ?? '',
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                       fontSize: 12, color: Theme.of(context).primaryColor),
//                 ),
//                 Text(
//                   format.format(promotion.createdDate ?? DateTime.now()),
//                   style: Theme.of(context)
//                       .textTheme
//                       .headline5
//                       ?.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
