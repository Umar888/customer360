import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/models/landing_screen/landing_task_model.dart';
import 'package:gc_customer_app/models/task.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:provider/provider.dart';
import '../services/networking/endpoints.dart';
import '../services/networking/networking_service.dart';
import '../services/networking/request_body.dart';
import '../services/storage/shared_preferences_service.dart';

class TaskListWidget extends StatefulWidget {
  final String taskId;
  final String? subject;
  final String? taskType;
  final String? status;
  final String? activityDate;
  final String? phone;
  final String? email;
  final AllOpenTasks task;
  final VoidCallback onTap;
  final bool showingUnassignedTask;
  final bool isOverdue;
  final bool isFetching;
  final String agentName;

  TaskListWidget({
    Key? key,
    required this.taskId,
    required this.task,
    required this.onTap,
    this.subject,
    this.taskType,
    this.status,
    this.activityDate,
    this.email,
    this.phone,
    this.showingUnassignedTask = false,
    this.isOverdue = false,
    this.isFetching = false,
    required this.agentName,
  }) : super(key: key);

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  String assigneeId = '';

  bool showingStores = false;
  bool hasSearched = false;

  bool updatingTaskAssignee = false;

  List<Widget> taskTypes = [];

  bool hasDelivery = false;
  bool hasCart = false;
  Timer? timer;

  setList() async {
    model = await service.getKeyList(key: firebaseIds);
    setState(() {});
  }

  void checkMultipleTaskTypes() {
    if (widget.taskType != null) {
      if (widget.taskType!.contains(',')) {
        var tempTaskTypes = widget.taskType!.split(',');
        if (tempTaskTypes.any((element) =>
            element.toLowerCase().trim() == 'warranty purchase' ||
            element.toLowerCase().trim() == 'associate followup')) {
          hasCart = true;
        }

        if (tempTaskTypes.any((element) =>
            element.toLowerCase().trim() == 'ready for pickup' ||
            element.toLowerCase().trim() == 'spo delivery' ||
            element.toLowerCase().trim() == 'retail purchase' ||
            element.toLowerCase().trim() == 'delivery followup')) {
          hasDelivery = true;
        }
      } else {
        if (widget.taskType!.toLowerCase() == 'ready for pickup' ||
            widget.taskType!.toLowerCase() == 'spo delivery' ||
            widget.taskType!.toLowerCase().trim() == 'retail purchase' ||
            widget.taskType!.toLowerCase() == 'delivery followup') {
          hasDelivery = true;
        } else if (widget.taskType!.toLowerCase() == 'warranty purchase' ||
            widget.taskType!.toLowerCase() == 'associate followup') {
          hasCart = true;
        }
      }
    }
  }

  Future<void> updateTaskAssignee() async {
    var response = await HttpService().doPost(
      path: Endpoints.postTaskDetails(widget.task.id!),
      body: RequestBody.getUpdateTaskBody(
        recordId: widget.task.id!,
        feedbackDateTime: "",
        feedback: "",
        assignee: assigneeId,
      ),
    );
  }

  Color getLabelColor() {
    return widget.task.dateLabelC!.toLowerCase() == 'overdue'
        ? ColorSystem.pieChartRed
        : widget.task.dateLabelC!.toLowerCase() == 'open'
            ? ColorSystem.pieChartGreen
            : widget.task.dateLabelC!.toLowerCase() == 'unassigned'
                ? ColorSystem.pieChartAmber
                : widget.task.dateLabelC!.toLowerCase() == 'completed'
                    ? ColorSystem.additionalBlue
                    : Theme.of(context).primaryColor;
  }

  SharedPreferenceService service = SharedPreferenceService();
  List<String> model = [];
  @override
  initState() {
    super.initState();
    checkMultipleTaskTypes();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: PaddingSystem.padding5,
        ),
        color: model.contains(widget.taskId) ? Colors.yellow.shade100 : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.subject}',
                    style: TextStyle(
                      fontSize: SizeSystem.size16,
                      color: Theme.of(context).primaryColor,
                      fontFamily: kRubik,
                    ),
                  ),
                  SizedBox(
                    height: SizeSystem.size4,
                  ),
                  Text(
                    '${widget.task.dayLabelC == null ? '' : '${widget.task.dayLabelC} Days '}${widget.task.dateLabelC}',
                    style: TextStyle(
                        color: getLabelColor(), fontSize: SizeSystem.size14),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: SizeSystem.size20,
            ),
            if (widget.isFetching) CupertinoActivityIndicator(),
            if (!widget.isFetching &&
                !widget.showingUnassignedTask &&
                !widget.isOverdue)
              Row(
                children: [
                  if (hasCart)
                    SvgPicture.asset(
                      IconSystem.cart,
                      package: 'gc_customer_app',
                      width: SizeSystem.size24,
                      height: SizeSystem.size24,
                      color: ColorSystem.secondary,
                    ),
                  if (hasDelivery && hasCart)
                    SizedBox(
                      width: SizeSystem.size16,
                    ),
                  if (hasDelivery)
                    SvgPicture.asset(
                      IconSystem.delivery,
                      package: 'gc_customer_app',
                      color: ColorSystem.secondary,
                    ),
                ],
              ),
            if (!widget.isFetching && widget.isOverdue)
              Text(
                widget.agentName,
                maxLines: 2,
                style: TextStyle(
                  color: ColorSystem.secondary,
                  fontSize: SizeSystem.size12,
                  fontFamily: kRubik,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
