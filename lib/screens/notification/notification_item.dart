import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:gc_customer_app/bloc/approval_process_bloc/approval_process_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/action_pane_motions.dart';
import 'package:gc_customer_app/intermediate_widgets/actions.dart';
import 'package:gc_customer_app/intermediate_widgets/slidable.dart';
import 'package:gc_customer_app/models/approval_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/notification/approval_web_view.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationItem extends StatefulWidget {
  final ApprovalModel approvalModel;
  final int index;
  NotificationItem(
      {super.key, required this.approvalModel, required this.index});

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  StreamSubscription? streamSubscription;
  final StreamController<bool> isApprovedController =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<bool> isRejectedController =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<int> isCompletedController =
      StreamController<int>.broadcast()..add(0);

  @override
  void initState() {
    streamSubscription =
        context.read<ApprovalProcessBloC>().stream.listen((event) {
      if (event is ApprovalProcessSuccess) {
        if (event.itemIndex != null && event.itemIndex == widget.index) {
          if (event.message == 'Approved') {
            isApprovedController.add(true);
            isCompletedController.add(1);
          } else {
            isRejectedController.add(true);
            isCompletedController.add(2);
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM dd, yyyy');
    return Slidable(
      // controller: controller,
      // index: 0,
      endActionPane: ActionPane(
        motion: DrawerMotion(),
        children: [
          SlidableAction(
            // performsFirstActionWithFullSwipe: false,
            // widthSpace: MediaQuery.of(context).size.width * 0.3,
            // closeOnTap: true,
            backgroundColor: ColorSystem.additionalGreen,
            label: StreamBuilder<bool>(
                stream: isApprovedController.stream,
                builder: (context, snapshot) {
                  return Text(snapshot.data == true ? 'Approved' : 'Approve',
                      style: TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: kRubik));
                }),

            icon: Icons.check_circle_outline,
            foregroundColor: ColorSystem.white,
            onPressed: (_) async {
              context.read<ApprovalProcessBloC>().add(ApproveApprovalProcess(
                  widget.approvalModel.recordId ?? '',
                  orderId: widget.approvalModel.orderNumber ?? '',
                  unitPrice: widget.approvalModel.unitPrice?.toString() ?? ''));
            },
          ),
          SlidableAction(
            // performsFirstActionWithFullSwipe: false,
            // widthSpace: MediaQuery.of(context).size.width * 0.3,
            // closeOnTap: true,
            backgroundColor: ColorSystem.pureRed,
            label: StreamBuilder<bool>(
                stream: isRejectedController.stream,
                builder: (context, snapshot) {
                  return Text(snapshot.data == true ? 'Rejected' : 'Reject',
                      style: TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: kRubik));
                }),
            icon: Icons.delete_outline,
            onPressed: (_) async {
              context.read<ApprovalProcessBloC>().add(RejectApprovalProcesss(
                  widget.approvalModel.recordId ?? '',
                  orderId: widget.approvalModel.orderNumber ?? '',
                  unitPrice: widget.approvalModel.unitPrice?.toString() ?? ''));
            },
          ),
        ],
      ),
      key: ValueKey(
          '${widget.approvalModel.recordId}-${DateTime.now().microsecondsSinceEpoch}'),
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () async {
          // launchUrl(Uri.parse(widget.approvalModel.approvalProcessUrl ?? ''),
          //     mode: LaunchMode.inAppWebView);
          Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApprovalWebViewWidget(
                        url: widget.approvalModel.approvalProcessUrl ?? ''),
                  ))
              .then((value) => context
                  .read<ApprovalProcessBloC>()
                  .add(LoadApprovalProcess()));
        },
        child: StreamBuilder<int>(
            stream: isCompletedController.stream,
            builder: (context, snapshot) {
              var completedIndex = snapshot.data ?? 0;
              return Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: widget.index % 2 != 0
                              ? Color.fromARGB(255, 240, 241, 255)
                              : ColorSystem.white,
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
                                (widget.approvalModel.orderNumber ?? '')
                                        .isNotEmpty
                                    ? Text(
                                        'Order Number: ${widget.approvalModel.orderNumber}',
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            ?.copyWith(
                                                fontWeight: FontWeight.w500),
                                      )
                                    : Text(
                                        '${widget.approvalModel.itemDesc}',
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            ?.copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                SizedBox(height: 4),
                                Text(
                                  (widget.approvalModel
                                                  .shipmentOverrideReason ??
                                              '')
                                          .isNotEmpty
                                      ? widget.approvalModel
                                              .shipmentOverrideReason ??
                                          ''
                                      : widget.approvalModel
                                              .overridePriceReason ??
                                          '',
                                  maxLines: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 4),
                                (widget.approvalModel.shippingAndHandling !=
                                        null)
                                    ? Text(
                                        'Shipping Handling: ${(widget.approvalModel.shippingAndHandling ?? 0).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: ColorSystem.secondary,
                                            fontSize: 12),
                                      )
                                    : Text(
                                        'Unit Price: ${(widget.approvalModel.unitPrice ?? 0).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: ColorSystem.secondary,
                                            fontSize: 12),
                                      ),
                                (widget.approvalModel.shippingAndHandling !=
                                        null)
                                    ? Text(
                                        'Shipping Adjustment: ${(widget.approvalModel.shippingAdjustment ?? 0).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: ColorSystem.secondary,
                                            fontSize: 12),
                                      )
                                    : Text(
                                        'Override Price: ${(widget.approvalModel.overridePrice ?? 0).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: ColorSystem.secondary,
                                            fontSize: 12),
                                      ),
                                if (widget.approvalModel.notificationDate !=
                                    null)
                                  Container(
                                    padding: EdgeInsets.only(top: 2),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      widget.approvalModel.notificationDate!,
                                      style: TextStyle(
                                          // color: ColorSystem.secondary,
                                          fontSize: 12),
                                    ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    if (completedIndex == 1)
                      Container(
                        width: double.infinity,
                        height: 100,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  ColorSystem.additionalGreen.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            width: double.infinity,
                            height: 100,
                            child: Center(
                                child: Text(
                              'Approved',
                              style: TextStyle(
                                  fontFamily: kRubik,
                                  fontSize: 24,
                                  color: ColorSystem.black,
                                  fontWeight: FontWeight.w500),
                            )),
                          ),
                        ),
                      ),
                    if (completedIndex == 2)
                      Container(
                        width: double.infinity,
                        height: 100,
                        // padding: EdgeInsets.all(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorSystem.pureRed.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            width: double.infinity,
                            height: 100,
                            child: Center(
                                child: Text(
                              'Rejected',
                              style: TextStyle(
                                  fontFamily: kRubik,
                                  fontSize: 24,
                                  color: ColorSystem.black,
                                  fontWeight: FontWeight.w500),
                            )),
                          ),
                        ),
                      )
                  ],
                ),
              );
            }),
      ),
    );
  }
}
