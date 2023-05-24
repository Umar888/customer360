// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/models/task_detail_model/order_item.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:intl/intl.dart';

class OrderLineItemWidget extends StatelessWidget {
  OrderLineItemWidget(
      {Key? key,
      required this.orderItem,
      required this.taskType,
      required this.taskID,
      required this.createdDate,
      required this.isRescheduling,
      required this.orderNumber,
      required this.onComplete,
      required this.onReschedule,
      required this.isForceClosing,
      required this.isCompleting,
      required this.onForceClose,
      required this.isChildUpdating,
      this.isCompleted = false,
      this.warrantyEligible})
      : super(key: key);
  final OrderItem orderItem;
  final String? taskType;
  final String? orderNumber;
  final String? taskID;
  final String? createdDate;
  final VoidCallback? onComplete;
  final VoidCallback? onReschedule;
  final VoidCallback? onForceClose;
  Function isChildUpdating;
  final bool isCompleted;
  final bool isRescheduling;
  bool isCompleting;
  bool isForceClosing;
  final bool? warrantyEligible;

  String dateFormatter(String date) {
    var dateTime = DateTime.parse(date);
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    String deliveredDate = orderItem.deliveredDate != null
        ? DateFormat('MMM dd, yyyy')
            .format(DateTime.parse(orderItem.deliveredDate!))
        : '';
    return Stack(children: [
      Container(
        margin: EdgeInsets.only(
          bottom: isCompleted ? SizeSystem.size0 : SizeSystem.size30,
        ),
        decoration: BoxDecoration(
            color: ColorSystem.lavender3.withOpacity(0.08),
            borderRadius: BorderRadius.circular(
              SizeSystem.size14,
            )),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: SizeSystem.size20,
                right: SizeSystem.size20,
                top: SizeSystem.size20,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      // await Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (BuildContext context) {
                      //   return OrderItemsList(
                      //     orderNumber: orderNumber ?? '',
                      //     taskID: taskID ?? '',
                      //     date: createdDate ?? '',
                      //   );
                      // }));
                    },
                    child: Text(
                      orderNumber ?? '--',
                      style: TextStyle(
                        color: Color(0xff8C80F8),
                        fontWeight: FontWeight.bold,
                        fontSize: SizeSystem.size14,
                        fontFamily: kRubik,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    dateFormatter(createdDate ?? '--'),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.normal,
                      fontSize: SizeSystem.size14,
                      fontFamily: kRubik,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: SizeSystem.size6,
            ),
            Divider(
              height: SizeSystem.size1,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeSystem.size8,
                    vertical: SizeSystem.size14,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 116,
                        width: 104,
                        decoration: BoxDecoration(
                            color: ColorSystem.white,
                            borderRadius:
                                BorderRadius.circular(SizeSystem.size10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (orderItem.imageUrl != null)
                              Expanded(
                                  child: CachedNetworkImage(
                                      imageUrl: orderItem.imageUrl!)),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(
                                  vertical: SizeSystem.size3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(SizeSystem.size10),
                                    bottomRight:
                                        Radius.circular(SizeSystem.size10),
                                  ),
                                  color: Color(0xff9C9EB9)),
                              child: Center(
                                child: Text(
                                  '\$ ${orderItem.itemPrice!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: ColorSystem.white,
                                    fontSize: SizeSystem.size12,
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeSystem.size14,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Qty. ',
                          style: TextStyle(
                            fontSize: SizeSystem.size14,
                            color: Color(0xff2D3142),
                            fontFamily: kRubik,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: orderItem.orderedQuantity.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: kRubik,
                                  fontSize: SizeSystem.size16,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: SizeSystem.size22,
                      left: SizeSystem.size16,
                      top: SizeSystem.size8,
                      bottom: SizeSystem.size8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          orderItem.description ?? '--',
                          style: TextStyle(
                            fontSize: SizeSystem.size14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2D3142),
                            fontFamily: kRubik,
                          ),
                        ),
                        SizedBox(
                          height: SizeSystem.size8,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: SizeSystem.size10,
                            horizontal: SizeSystem.size15,
                          ),
                          decoration: BoxDecoration(
                            color: ColorSystem.white,
                            borderRadius: BorderRadius.circular(
                              SizeSystem.size5,
                            ),
                            border: Border.all(
                              color: ColorSystem.secondary,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (taskType?.toLowerCase() ==
                                      'warranty purchase' ||
                                  taskType?.toLowerCase() ==
                                      'associate follow up')
                                SvgPicture.asset(
                                  IconSystem.cart,
                                  package: 'gc_customer_app',
                                  color: ColorSystem.secondary,
                                  height: 14,
                                  width: 14,
                                ),
                              if (taskType?.toLowerCase() ==
                                      'ready for pickup' ||
                                  taskType?.toLowerCase() == 'spo delivery' ||
                                  taskType?.toLowerCase() ==
                                      'retail purchase' ||
                                  taskType?.toLowerCase() ==
                                      'delivery followup')
                                SvgPicture.asset(
                                  IconSystem.delivery,
                                  package: 'gc_customer_app',
                                  color: ColorSystem.secondary,
                                  height: 14,
                                  width: 14,
                                ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  taskType ?? '--',
                                  style: TextStyle(
                                    color: ColorSystem.secondary,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w400,
                                    fontSize: SizeSystem.size13,
                                    fontFamily: kRubik,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: SizeSystem.size8,
                        ),
                        if (taskType!.toLowerCase() == 'ready for pickup' ||
                            taskType!.toLowerCase() == 'spo delivery' ||
                            taskType!.toLowerCase() == 'delivery followup')
                          Text(
                              orderItem.deliveryDays != null
                                  ? 'Ready for Pickup: ${orderItem.deliveryDays} Days ago'
                                  : '',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: kRubik,
                                overflow: TextOverflow.ellipsis,
                                fontSize: SizeSystem.size11,
                              )),
                        if (warrantyEligible == true &&
                            orderItem.warrantyDays != null)
                          Text(
                              'Warranty Purchase: ${orderItem.warrantyDays} Days left',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: kRubik,
                                overflow: TextOverflow.ellipsis,
                                fontSize: SizeSystem.size11,
                              )),
                        if (orderItem.deliveredDate != null &&
                            orderItem.deliveredDateTime != null)
                          Text(
                              'Delivered: $deliveredDate ${DateFormat(DateFormat.HOUR_MINUTE).format(DateTime.parse(orderItem.deliveredDateTime!))}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: kRubik,
                                overflow: TextOverflow.ellipsis,
                                fontSize: SizeSystem.size11,
                              )),
                        SizedBox(
                          height: SizeSystem.size50,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      if (!isCompleted)
        Positioned(
            right: SizeSystem.size22,
            bottom: SizeSystem.size0,
            child: Row(
              children: [
                InkWell(
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: (isCompleting ||
                          isRescheduling ||
                          isForceClosing ||
                          orderItem.isCompleting! ||
                          orderItem.isLoading! ||
                          orderItem.isForceClosing!)
                      ? () {}
                      : onForceClose,
                  child: Container(
                    width: SizeSystem.size48,
                    height: SizeSystem.size48,
                    padding: EdgeInsets.all(
                      SizeSystem.size12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        SizeSystem.size12,
                      ),
                      color: ColorSystem.pieChartAmber,
                    ),
                    child: orderItem.isForceClosing!
                        ? CupertinoActivityIndicator(color: Colors.white)
                        : SvgPicture.asset(
                            IconSystem.createTaskClose,
                            package: 'gc_customer_app',
                            color: ColorSystem.white,
                          ),
                  ),
                ),
                SizedBox(
                  width: SizeSystem.size16,
                ),
                InkWell(
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: (isCompleting ||
                          isRescheduling ||
                          isForceClosing ||
                          orderItem.isCompleting! ||
                          orderItem.isLoading! ||
                          orderItem.isForceClosing!)
                      ? () {}
                      : onReschedule,
                  child: Container(
                    width: SizeSystem.size48,
                    height: SizeSystem.size48,
                    padding: EdgeInsets.all(
                      SizeSystem.size12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        SizeSystem.size12,
                      ),
                      color: ColorSystem.secondary,
                    ),
                    child: orderItem.isLoading!
                        ? CupertinoActivityIndicator(color: Colors.white)
                        : SvgPicture.asset(
                            IconSystem.calendar,
                            package: 'gc_customer_app',
                            color: ColorSystem.white,
                          ),
                  ),
                ),
                SizedBox(
                  width: SizeSystem.size16,
                ),
                InkWell(
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: (isCompleting ||
                          isRescheduling ||
                          isForceClosing ||
                          orderItem.isCompleting! ||
                          orderItem.isLoading! ||
                          orderItem.isForceClosing!)
                      ? () {}
                      : onComplete,
                  child: Container(
                    width: SizeSystem.size48,
                    height: SizeSystem.size48,
                    padding: EdgeInsets.all(
                      SizeSystem.size12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        SizeSystem.size12,
                      ),
                      color: ColorSystem.pieChartGreen,
                    ),
                    child: orderItem.isCompleting!
                        ? CupertinoActivityIndicator(color: Colors.white)
                        : SvgPicture.asset(
                            IconSystem.checkmark,
                            package: 'gc_customer_app',
                            color: ColorSystem.white,
                          ),
                  ),
                ),
              ],
            ))
    ]);
  }
}
