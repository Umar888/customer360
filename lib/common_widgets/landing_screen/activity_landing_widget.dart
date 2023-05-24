import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';

import '../../primitives/color_system.dart';
import '../../primitives/icon_system.dart';

class ActivityLandingWidget extends StatelessWidget {
  ActivityLandingWidget({
    Key? key,
    required this.size,
    required this.colors,
    required this.valueOfOrder,
    required this.typeOfOrder,
    required this.numberOfOrders,
    required this.dateoforder,
    required this.itemsOfOrder,
    required this.onTap,
  }) : super(key: key);

  final Size size;
  final Color colors;
  final String valueOfOrder;
  final String dateoforder;
  final String itemsOfOrder;
  final String typeOfOrder;
  final String numberOfOrders;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      height: size.height * 0.05,
                      width: size.width * 0.03,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(4),
                        color: colors,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.04,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Text(
                            '$typeOfOrder${typeOfOrder == "Open Orders" ? ": ${numberOfOrders}" : ""}',
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                                fontFamily: kRubik,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          'Value: \$${numberOfOrders == "0" ? '0.00' : valueOfOrder}',
                          style: TextStyle(
                              fontFamily: kRubik,
                              color: ColorSystem.greyDark,
                              fontSize: 15),
                        )
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    typeOfOrder == "Open Orders"
                        ? Text(
                            "${typeOfOrder == "Open Orders" ? "${dateoforder}" : ""}",
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(fontFamily: kRubik, fontSize: 14),
                          )
                        : SizedBox.shrink(),
                    typeOfOrder == "Open Orders"
                        ? SizedBox(height: size.height * 0.01)
                        : SizedBox.shrink(),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      '$itemsOfOrder items',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: kRubik,
                          color: ColorSystem.greyDark),
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: SvgPicture.asset(
              IconSystem.gotoArrow,
              package: 'gc_customer_app',
              width: 28,
              height: 28,
            ),
          )
        ],
      ),
    );
  }
}
