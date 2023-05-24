import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as fdt;
import 'package:gc_customer_app/bloc/task_details_bloc/task_details_bloc.dart';
import 'package:gc_customer_app/common_widgets/task_detail/order_line_widget.dart';
import 'package:gc_customer_app/models/task_detail_model/order.dart';
import 'package:gc_customer_app/models/task_detail_model/order_item.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../primitives/size_system.dart';

class ProductListCard extends StatefulWidget {
  ProductListCard({
    Key? key,
    required this.ordersArray,
    required this.task,
    required this.isForceClosing,
    required this.isCompleting,
    required this.isChildUpdating,
    required this.ownerId,
    required this.isRescheduling,
    required this.customerId,
    required this.popContext,
  }) : super(key: key);
  final List<Order> ordersArray;
  final TaskModel task;
  bool isCompleting;
  bool isRescheduling;
  Function isChildUpdating;
  bool isForceClosing;
  String customerId;
  String ownerId;
  final BuildContext popContext;

  @override
  State<ProductListCard> createState() => _ProductListCardState();
}

class _ProductListCardState extends State<ProductListCard> {
  List<OrderItem> orderItems = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Order> completedOrders = [];

  String taskId = '';
  String snackBarMessage = '';
  String? closureReason;
  String? selectedDate;

  bool lastOrder = false;

  String dateFormatter(String date) {
    var dateTime = DateTime.parse(date);
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("this is widget task id ${widget.task.id!}");
    setState(() {
      taskId = widget.task.id!;
    });
  }

  Future<void> finishTask(
    String status,
    String closureReasons,
    String comment,
    String date,
  ) async {
    print("finishing task");
    var response = await HttpService().doPost(
      path: Endpoints.postTaskDetails(taskId),
      body: RequestBody.getUpdateTaskBody(
        recordId: taskId,
        feedbackDateTime: date.isEmpty
            ? DateFormat('hh:mm aa dd-MM-yyyy').format(DateTime.now())
            : date,
        feedback: comment,
        closureType: closureReasons,
        status: status,
      ),
    );
    context
        .read<TaskDetailsBloc>()
        .add(TaskDetailsEvent.loading(widget.task.id!));
  }

  Future<void> partialUpdateTask({
    String? dueDate,
    required OrderItem orderItem,
    required String taskCompletionStatus,
    required String closureReasons,
    required String comment,
    required String date,
  }) async {
//    context.read<TaskDetailsBloc>().add(TaskDetailsOnlyLoadingEvent());

    var agentStoreId = await SharedPreferenceService().getValue(storeId);
    var loogedInUserId = await SharedPreferenceService().getValue(agentId);

    if (completedOrders.length == 1) {
      if (completedOrders[0].orderLines?.length == 1) {
        lastOrder = true;
        await finishTask(taskCompletionStatus, closureReasons, comment, date);
        return;
      }
    }

    var requestBody = RequestBody.getCreateTaskBody(
      parentTaskId: taskId,
      subject: widget.task.subject,
      dueDate: dueDate ?? widget.task.createdDate,
      comment: widget.task.description,
      whatId: widget.task.whatId,
      whoId: widget.task.whoId,
      storeId: agentStoreId ?? '',
      ownerId: widget.task.ownerId,
      firstName: widget.task.firstNameC,
      lastName: "",
      email: widget.task.emailC,
      phone: widget.task.phoneC,
      completedOrders: completedOrders,
      taskType: orderItem.taskType,
      loggedinUserId: loogedInUserId,
      closureType: closureReasons,
      feedback: comment,
      feedbackDate: date.isEmpty
          ? DateFormat('hh:mm aa dd-MM-yyyy').format(DateTime.now())
          : date,
    );

    var response = await HttpService().doPost(
      path: Endpoints.completeTask(),
      body: requestBody,
    );

    //  log("new => "+jsonEncode(response.data));
    setState(() {
      taskId = response.data['task']['Id'];
    });

    // print("response task id $taskId");
  }

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  void processOrderList(Order order, int index, String status) {
    completedOrders.clear();
    for (var tempOrder in widget.ordersArray) {
      if (tempOrder == order) {
        var orderItems = <OrderItem>[];
        for (var orderItem in order.orderLines!) {
          if (orderItem == order.orderLines![index]) {
            orderItem.itemStatus = status;
          }
          orderItems.add(orderItem);
        }
        order.completedOrders = List.from(orderItems);
        completedOrders.add(order);
      } else {
        tempOrder.completedOrders = List.from(tempOrder.orderLines!);
        completedOrders.add(tempOrder);
      }
    }
  }

  Future<void> updateTaskDate(String taskId, String selectedDate) async {
    var loogedInUserId = await SharedPreferenceService().getValue(agentId);
    var response = await HttpService().doPost(
        path: Endpoints.postTaskDetails(taskId),
        body: RequestBody.getUpdateTaskBody(
          recordId: widget.task.id!,
          feedback: "",
          feedbackDateTime: "",
          dueDate: selectedDate,
          loggedinUserId: loogedInUserId,
        ));
    context
        .read<TaskDetailsBloc>()
        .add(TaskDetailsEvent.loading(widget.task.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeSystem.size10,
      ),
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int orderIndex) {
            var order = widget.ordersArray[orderIndex];
            return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: MasonryGridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  crossAxisCount: 1,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return OrderLineItemWidget(
                      isRescheduling: widget.isRescheduling,
                      isChildUpdating: widget.isChildUpdating,
                      isCompleting: widget.isCompleting,
                      isForceClosing: widget.isForceClosing,
                      onComplete: widget.customerId != widget.ownerId
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  snackBar("This task is not assigned to you"));
                            }
                          : () async {
                              print(order.orderLines![index].taskType
                                  ?.toLowerCase());
                              if (order.orderLines![index].taskType
                                      ?.toLowerCase() ==
                                  'warranty purchase') {
                                order.orderLines![index].isCompleted = false;
                                showCupertinoDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return WarrantyPurchaseDialog(
                                      onSoldTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Sold';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                      onNotSoldTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Not Sold';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                    );
                                  },
                                );
                              } else if (order.orderLines![index].taskType
                                          ?.toLowerCase() ==
                                      'retail purchase' ||
                                  order.orderLines![index].taskType
                                          ?.toLowerCase() ==
                                      'spo delivery' ||
                                  order.orderLines![index].taskType
                                          ?.toLowerCase() ==
                                      'delivery followup') {
                                order.orderLines![index].isCompleted = false;
                                showCupertinoDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return DeliveryDialog(
                                      onHappyTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Happy';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                      onNeutralTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Neutral';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                      onSadTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Sad';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                    );
                                  },
                                );
                              } else if (order.orderLines![index].taskType
                                      ?.toLowerCase() ==
                                  'ready for pickup') {
                                order.orderLines![index].isCompleted = false;
                                await showCupertinoDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PickUpDialog(
                                      onAcknowledgedTap: () {
                                        order.orderLines![index].feedback =
                                            "Acknowledged";
                                        Navigator.pop(context);
                                        submitReadyForPickup(order, index);
                                      },
                                      onPickupTap: () {
                                        order.orderLines![index].feedback =
                                            "Pickup Later";
                                        Navigator.pop(context);
                                        submitReadyForPickup(order, index);
                                      },
                                      onCancelTap: () {
                                        order.orderLines![index].feedback =
                                            "Cancel Order";
                                        Navigator.pop(context);
                                        submitReadyForPickup(order, index);
                                      },
                                    );
                                  },
                                );
                              } else {
                                order.orderLines![index].isCompleted = false;
                                showCupertinoDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return DeliveryDialog(
                                      onHappyTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Happy';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                      onNeutralTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Neutral';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                      onSadTap: () async {
                                        order.orderLines![index].feedback = "";
                                        order.orderLines![index].isCompleted =
                                            true;
                                        Navigator.pop(dialogContext);
                                        closureReason = 'Sad';
                                        if (order
                                            .orderLines![index].isCompleted!) {
                                          setState(() {
                                            widget.isChildUpdating(true);
                                            order.orderLines![index]
                                                .isCompleting = true;
                                          });

                                          processOrderList(
                                              order, index, 'Completed');
                                          snackBarMessage =
                                              'Order Line Item Completed';
                                          await partialUpdateTask(
                                              orderItem:
                                                  order.orderLines![index],
                                              closureReasons:
                                                  closureReason ?? "",
                                              comment: order
                                                  .orderLines![index].feedback!,
                                              date: order.orderLines![index]
                                                  .feedbackDateTime!,
                                              taskCompletionStatus:
                                                  'Completed');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBar(snackBarMessage));
                                          snackBarMessage = '';
                                          if (!lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            context.read<TaskDetailsBloc>().add(
                                                TaskDetailsRefreshEvent(
                                                    taskId));
                                          }
                                          if (lastOrder) {
                                            for (OrderItem orderItem
                                                in order.orderLines!) {
                                              setState(() {
                                                orderItem.isCompleting = false;
                                                widget.isChildUpdating(false);
                                              });
                                            }
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            },
                      onForceClose: widget.customerId != widget.ownerId
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  snackBar("This task is not assigned to you"));
                            }
                          : () async {
                              showCupertinoDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return ForceCloseDialog(
                                    onInvalidTap: () async {
                                      order.orderLines![index].feedback = "";
                                      order.orderLines![index].isForceClosed =
                                          true;
                                      Navigator.pop(dialogContext);
                                      closureReason =
                                          'Invalid/Incorrect Contact Info';
                                      if (order
                                          .orderLines![index].isForceClosed!) {
                                        setState(() {
                                          order.orderLines![index]
                                              .isForceClosing = true;
                                          widget.isChildUpdating(true);
                                        });
                                        processOrderList(
                                            order, index, 'Delinquent');
                                        snackBarMessage =
                                            'Order Line Item Force Closed';

                                        await partialUpdateTask(
                                            orderItem: order.orderLines![index],
                                            closureReasons: closureReason ?? "",
                                            comment: order
                                                .orderLines![index].feedback!,
                                            date: order.orderLines![index]
                                                .feedbackDateTime!,
                                            taskCompletionStatus: 'Delinquent');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                                snackBar(snackBarMessage));
                                        snackBarMessage = '';
                                        if (!lastOrder) {
                                          for (OrderItem orderItem
                                              in order.orderLines!) {
                                            setState(() {
                                              orderItem.isForceClosing = false;
                                              widget.isChildUpdating(false);
                                            });
                                          }
                                          context.read<TaskDetailsBloc>().add(
                                              TaskDetailsRefreshEvent(taskId));
                                        }
                                        if (lastOrder) {
                                          for (OrderItem orderItem
                                              in order.orderLines!) {
                                            setState(() {
                                              orderItem.isForceClosing = false;
                                              widget.isChildUpdating(false);
                                            });
                                          }
                                          Navigator.of(dialogContext).pop();
                                        }
                                      }
                                    },
                                    onNotPickupTap: () async {
                                      order.orderLines![index].feedback = "";
                                      order.orderLines![index].isForceClosed =
                                          true;
                                      Navigator.pop(dialogContext);
                                      closureReason = 'Did Not Pick up';
                                      if (order
                                          .orderLines![index].isForceClosed!) {
                                        setState(() {
                                          order.orderLines![index]
                                              .isForceClosing = true;
                                          widget.isChildUpdating(true);
                                        });
                                        processOrderList(
                                            order, index, 'Delinquent');
                                        snackBarMessage =
                                            'Order Line Item Force Closed';

                                        await partialUpdateTask(
                                            orderItem: order.orderLines![index],
                                            closureReasons: closureReason ?? "",
                                            comment: order
                                                .orderLines![index].feedback!,
                                            date: order.orderLines![index]
                                                .feedbackDateTime!,
                                            taskCompletionStatus: 'Delinquent');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                                snackBar(snackBarMessage));
                                        snackBarMessage = '';
                                        if (!lastOrder) {
                                          for (OrderItem orderItem
                                              in order.orderLines!) {
                                            setState(() {
                                              orderItem.isForceClosing = false;
                                              widget.isChildUpdating(false);
                                            });
                                          }
                                          context.read<TaskDetailsBloc>().add(
                                              TaskDetailsRefreshEvent(taskId));
                                        }
                                        if (lastOrder) {
                                          for (OrderItem orderItem
                                              in order.orderLines!) {
                                            setState(() {
                                              orderItem.isForceClosing = false;
                                              widget.isChildUpdating(false);
                                            });
                                          }
                                          Navigator.of(dialogContext).pop();
                                        }
                                      }
                                    },
                                    onNotCustomerRejectedTap: () async {
                                      order.orderLines![index].feedback = "";
                                      order.orderLines![index].isForceClosed =
                                          true;
                                      Navigator.pop(dialogContext);
                                      closureReason = 'Customer Rejected';
                                      if (order
                                          .orderLines![index].isForceClosed!) {
                                        setState(() {
                                          order.orderLines![index]
                                              .isForceClosing = true;
                                          widget.isChildUpdating(true);
                                        });
                                        processOrderList(
                                            order, index, 'Delinquent');
                                        snackBarMessage =
                                            'Order Line Item Force Closed';

                                        await partialUpdateTask(
                                            orderItem: order.orderLines![index],
                                            closureReasons: closureReason ?? "",
                                            comment: order
                                                .orderLines![index].feedback!,
                                            date: order.orderLines![index]
                                                .feedbackDateTime!,
                                            taskCompletionStatus: 'Delinquent');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                                snackBar(snackBarMessage));
                                        snackBarMessage = '';
                                        if (!lastOrder) {
                                          for (OrderItem orderItem
                                              in order.orderLines!) {
                                            setState(() {
                                              orderItem.isForceClosing = false;
                                              widget.isChildUpdating(false);
                                            });
                                          }
                                          context.read<TaskDetailsBloc>().add(
                                              TaskDetailsRefreshEvent(taskId));
                                        }
                                        if (lastOrder) {
                                          for (OrderItem orderItem
                                              in order.orderLines!) {
                                            setState(() {
                                              orderItem.isForceClosing = false;
                                              widget.isChildUpdating(false);
                                            });
                                          }
                                          Navigator.of(dialogContext).pop();
                                        }
                                      }
                                    },
                                  );
                                },
                              );
                            },
                      onReschedule: widget.customerId != widget.ownerId
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  snackBar("This task is not assigned to you"));
                            }
                          : () async {
                              selectedDate = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return StatefulBuilder(
                                        builder: (context, setChildState) {
                                      return BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .copyWith()
                                                  .size
                                                  .height *
                                              0.35,
                                          color: Colors.white,
                                          child: NotificationListener(
                                            onNotification: (ScrollNotification
                                                notification) {
                                              if (notification.depth == 0 &&
                                                  notification
                                                      is ScrollEndNotification &&
                                                  notification.metrics
                                                      is FixedExtentMetrics) {
                                                setChildState(() {
                                                  order.orderLines![index]
                                                          .isUpdateRescheduling =
                                                      false;
                                                });
                                              } else if (notification
                                                  is ScrollStartNotification) {
                                                setChildState(() {
                                                  order.orderLines![index]
                                                          .isUpdateRescheduling =
                                                      true;
                                                });
                                              }
                                              return false;
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                  child: CupertinoDatePicker(
                                                    mode:
                                                        CupertinoDatePickerMode
                                                            .date,
                                                    onDateTimeChanged: (value) {
                                                      setChildState(() {
                                                        selectedDate =
                                                            DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(value);
                                                      });
                                                    },
                                                    initialDateTime:
                                                        DateTime.now(),
                                                    maximumDate: DateTime(3100),
                                                    minimumDate: DateTime.parse(
                                                        widget.task
                                                            .activityDate!),
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          SizeSystem.size40,
                                                      vertical:
                                                          SizeSystem.size10,
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(
                                                          Theme.of(context)
                                                              .primaryColor,
                                                        ),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14.0),
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: order
                                                                  .orderLines![
                                                                      index]
                                                                  .isLoading! ||
                                                              order
                                                                  .orderLines![
                                                                      index]
                                                                  .isUpdateRescheduling!
                                                          ? () {}
                                                          : () async {
                                                              setChildState(() {
                                                                order
                                                                    .orderLines![
                                                                        index]
                                                                    .isLoading = true;
                                                              });
                                                              processOrderList(
                                                                  order,
                                                                  index,
                                                                  'Scheduled');
                                                              await partialUpdateTask(
                                                                  dueDate:
                                                                      selectedDate,
                                                                  closureReasons:
                                                                      "",
                                                                  comment: "",
                                                                  date: "",
                                                                  orderItem:
                                                                      order.orderLines![
                                                                          index],
                                                                  taskCompletionStatus:
                                                                      'Scheduled');
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      snackBar(
                                                                          'Task Date Changed'));

                                                              if (!lastOrder) {
                                                                context
                                                                    .read<
                                                                        TaskDetailsBloc>()
                                                                    .add(TaskDetailsRefreshEvent(
                                                                        taskId));
                                                                setState(() {
                                                                  order
                                                                      .orderLines![
                                                                          index]
                                                                      .isLoading = false;
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              } else {
                                                                setState(() {
                                                                  order
                                                                      .orderLines![
                                                                          index]
                                                                      .isLoading = false;
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical:
                                                                  SizeSystem
                                                                      .size16,
                                                            ),
                                                            child: order
                                                                    .orderLines![
                                                                        index]
                                                                    .isLoading!
                                                                ? CupertinoActivityIndicator(
                                                                    color: Colors
                                                                        .white,
                                                                  )
                                                                : Text(
                                                                    order.orderLines![index]
                                                                            .isUpdateRescheduling!
                                                                        ? 'Please wait...'
                                                                        : 'Done',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          kRubik,
                                                                    ),
                                                                  ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  });
                            },
                      warrantyEligible:
                          order.orderLines![index].warrantyEligible,
                      orderItem: order.orderLines![index],
                      taskType: order.orderLines![index].taskType,
                      taskID: taskId,
                      createdDate: order.createdDate,
                      orderNumber: order.orderNumber,
                      isCompleted: widget.task.status == 'Completed',
                    );
                  },
                  itemCount: order.orderLines!.length,
                ));
          },
          itemCount: widget.ordersArray.length),
    );
  }

  Future<void> submitReadyForPickup(Order order, int index) async {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return StatefulBuilder(builder: (context, setChildState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: MediaQuery.of(context).copyWith().size.height * 0.35,
                color: Colors.white,
                child: NotificationListener(
                  onNotification: (ScrollNotification notification) {
                    if (notification.depth == 0 &&
                        notification is ScrollEndNotification &&
                        notification.metrics is FixedExtentMetrics) {
                      setChildState(() {
                        order.orderLines![index].isUpdateRescheduling = false;
                      });
                    } else if (notification is ScrollStartNotification) {
                      setChildState(() {
                        order.orderLines![index].isUpdateRescheduling = true;
                      });
                    }
                    return false;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          onDateTimeChanged: (value) {
                            setChildState(() {
                              order.orderLines![index].feedbackDateTime =
                                  DateFormat('hh:mm aa dd-MM-yyyy')
                                      .format(value);
                            });
                          },
                          initialDateTime: DateTime.now(),
                          maximumDate: DateTime(3100),
                          minimumDate: DateTime(1500),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeSystem.size40,
                            vertical: SizeSystem.size10,
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor,
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                            onPressed:
                                order.orderLines![index].isUpdateRescheduling!
                                    ? () {}
                                    : () async {
                                        setChildState(() {
                                          order.orderLines![index].isCompleted =
                                              true;
                                        });
                                        Navigator.pop(context);
                                      },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: SizeSystem.size16,
                                  ),
                                  child: Text(
                                    order.orderLines![index]
                                            .isUpdateRescheduling!
                                        ? 'Please wait...'
                                        : 'Done',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: kRubik,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            );
          });
        }).then((value) async {
      closureReason = '';
      if (order.orderLines![index].isCompleted!) {
        setState(() {
          widget.isChildUpdating(true);
          order.orderLines![index].isCompleting = true;
        });

        processOrderList(order, index, 'Completed');
        snackBarMessage = 'Order Line Item Completed';
        await partialUpdateTask(
            orderItem: order.orderLines![index],
            closureReasons: closureReason ?? "",
            comment: order.orderLines![index].feedback!,
            date: order.orderLines![index].feedbackDateTime!,
            taskCompletionStatus: 'Completed');
        ScaffoldMessenger.of(context).showSnackBar(snackBar(snackBarMessage));
        snackBarMessage = '';
        if (!lastOrder) {
          for (OrderItem orderItem in order.orderLines!) {
            setState(() {
              orderItem.isCompleting = false;
              widget.isChildUpdating(false);
            });
          }
          context.read<TaskDetailsBloc>().add(TaskDetailsRefreshEvent(taskId));
        }
        if (lastOrder) {
          for (OrderItem orderItem in order.orderLines!) {
            setState(() {
              orderItem.isCompleting = false;
              widget.isChildUpdating(false);
            });
          }
          Navigator.of(context).pop();
        }
      }
    });
  }
}

class ForceCloseDialog extends StatelessWidget {
  final VoidCallback onInvalidTap;
  final VoidCallback onNotPickupTap;
  final VoidCallback onNotCustomerRejectedTap;

  ForceCloseDialog({
    Key? key,
    required this.onInvalidTap,
    required this.onNotPickupTap,
    required this.onNotCustomerRejectedTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: CupertinoAlertDialog(actions: [
        Material(
          color: Colors.white38,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Force Close",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Choose a reason",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onInvalidTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Invalid/Incorrect Contact Info',
                          style: TextStyle(
                            color: ColorSystem.additionalBlue,
                            fontSize: SizeSystem.size17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onNotPickupTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Did Not Pick up',
                          style: TextStyle(
                            color: ColorSystem.additionalBlue,
                            fontSize: SizeSystem.size17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onNotCustomerRejectedTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Customer Rejected',
                          style: TextStyle(
                            color: ColorSystem.additionalBlue,
                            fontSize: SizeSystem.size17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class WarrantyPurchaseDialog extends StatelessWidget {
  final VoidCallback onSoldTap;
  final VoidCallback onNotSoldTap;

  WarrantyPurchaseDialog({
    Key? key,
    required this.onSoldTap,
    required this.onNotSoldTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: CupertinoAlertDialog(
        actions: [
          Material(
            color: Colors.white38,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Pro Coverage",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Choose a reason",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: SizeSystem.size1,
                    color: ColorSystem.additionalGrey,
                  ),
                  InkWell(
                    onTap: onSoldTap,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Sold',
                            style: TextStyle(
                              color: ColorSystem.additionalBlue,
                              fontSize: SizeSystem.size17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: SizeSystem.size1,
                    color: ColorSystem.additionalGrey,
                  ),
                  InkWell(
                    onTap: onNotSoldTap,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Not sold',
                            style: TextStyle(
                              color: ColorSystem.additionalBlue,
                              fontSize: SizeSystem.size17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DeliveryDialog extends StatelessWidget {
  final VoidCallback onHappyTap;
  final VoidCallback onNeutralTap;
  final VoidCallback onSadTap;

  DeliveryDialog({
    Key? key,
    required this.onHappyTap,
    required this.onNeutralTap,
    required this.onSadTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: CupertinoAlertDialog(actions: [
        Material(
          color: Colors.white38,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Customer Satisfaction",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Choose a reason",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onHappyTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconSystem.happyEmoji,
                          package: 'gc_customer_app',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onNeutralTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconSystem.neutralEmoji,
                          package: 'gc_customer_app',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onSadTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconSystem.sadEmoji,
                          package: 'gc_customer_app',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class PickUpDialog extends StatelessWidget {
  final VoidCallback onAcknowledgedTap;
  final VoidCallback onPickupTap;
  final VoidCallback onCancelTap;

  PickUpDialog({
    Key? key,
    required this.onAcknowledgedTap,
    required this.onCancelTap,
    required this.onPickupTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: CupertinoAlertDialog(actions: [
        Material(
          color: Colors.white38,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Pickup",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Choose a reason",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onAcknowledgedTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Acknowledged',
                          style: TextStyle(
                            color: ColorSystem.additionalBlue,
                            fontSize: SizeSystem.size17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onPickupTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Pickup Later',
                          style: TextStyle(
                            color: ColorSystem.additionalBlue,
                            fontSize: SizeSystem.size17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeSystem.size1,
                  color: ColorSystem.additionalGrey,
                ),
                InkWell(
                  onTap: onCancelTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Cancel Order',
                          style: TextStyle(
                            color: ColorSystem.additionalBlue,
                            fontSize: SizeSystem.size17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
