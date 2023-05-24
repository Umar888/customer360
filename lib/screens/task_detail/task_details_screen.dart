// ignore_for_file: empty_catches, unused_catch_clause, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/bloc/task_details_bloc/task_details_bloc.dart';
import 'package:gc_customer_app/common_widgets/task_detail/information_pop_up.dart';
import 'package:gc_customer_app/common_widgets/task_detail/product_list_card_widget.dart';
import 'package:gc_customer_app/common_widgets/task_detail/task_details_date_widget.dart';
import 'package:gc_customer_app/common_widgets/task_detail/tgc_app_bar.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/utils/utils_functions.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../common_widgets/task_detail/customer_popup.dart';
import '../../models/task_detail_model/task_completion_closure_model.dart';
import '../../services/networking/request_body.dart';
import '../../services/storage/shared_preferences_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String? taskId;
  final String? email;
  final String? customerId;
  final LandingScreenBloc landingScreenBlocEvent;
  final TaskModel task;
  bool notification;
  TaskDetailsScreen({
    Key? key,
    required this.customerId,
    required this.landingScreenBlocEvent,
    required this.taskId,
    required this.task,
    this.email,
    this.notification = false,
  }) : super(key: key);

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  String taskStatus = 'Open';

  List<TaskModel> childTasks = [];
  final ScrollController scrollController = ScrollController();
  bool isCallClicked = true;
  bool isMessageClicked = false;
  CustomerInfoModel? customerWithBasicDetails;
  bool isMailClicked = false;
  String? formattedPhoneNumber = '';
  bool? isLoading = false;
  bool isRescheduling = false;
  bool isCompleting = false;
  bool isForcingClose = false;
  bool isUpdateRescheduling = false;
  bool isForceClosed = false;
  bool isCompleted = false;
  String feedback = "";
  String feedbackDateTime = "";

  List<TaskCompletionClosureModel> closureType = [];

  String closureReason = "";
  String closureReason_2 = "";

  DateTime selectedDate = DateTime.now();
  StreamSubscription? navigatorListener;

  // Future<void> makephoneCall(String phoneNumber) async {
  //   try {
  //     await launchUrlString('tel:+1$phoneNumber');
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> openEmail(String email) async {
    try {
      await launchUrlString(
          'https://outlook.office.com/mail/deeplink/compose?to=$email');
    } catch (e) {
      print(e);
    }
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    widget.task.status = 'Completed';
    taskStatus = 'Completed';

    var loggedInUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);

    var response = await HttpService().doPost(
      path: Endpoints.postTaskDetails(taskId),
      body: RequestBody.getUpdateTaskBody(
          recordId: taskId,
          status: 'Completed',
          closureType: closureReason,
          loggedinUserId: loggedInUserId,
          feedback: feedback,
          feedbackDateTime: feedbackDateTime),
    );
  }

  Future<void> updateTaskDate(String taskId) async {
    var loggedInUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);
    var response = await HttpService().doPost(
        path: Endpoints.postTaskDetails(taskId),
        body: RequestBody.getUpdateTaskBody(
          recordId: taskId,
          feedbackDateTime: "",
          feedback: "",
          dueDate: DateFormat('yyyy-MM-dd').format(selectedDate),
          loggedinUserId: loggedInUserId,
        ));
    context.read<TaskDetailsBloc>().add(TaskDetailsEvent.loading(taskId));
    setState(() {});
  }

  Future<void> markTaskAsDelinquent(String taskId) async {
    widget.task.status = 'Delinquent';
    taskStatus = 'Delinquent';
    var loggedInUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);

    var response = await HttpService().doPost(
      path: Endpoints.postTaskDetails(taskId),
      body: RequestBody.getUpdateTaskBody(
        recordId: taskId,
        status: 'Delinquent',
        closureType: closureReason,
        feedbackDateTime: "",
        feedback: "",
        loggedinUserId: loggedInUserId,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> getClientBasicDetails() async {
    isLoading = true;
    try {
      // log("this is who id ${widget.task.whoId!}");
      var response = await HttpService()
          .doGet(path: Endpoints.getClientBasicDetails(widget.task.whoId!));
      customerWithBasicDetails = CustomerInfoModel.fromJson(response.data);
      isLoading = false;
    } catch (e) {}
    isLoading = false;
  }

  formatPhoneNumber(String? phoneNumber) {
    if (widget.task.phoneC != null) {
      setState(() {
        formattedPhoneNumber = "(" +
            widget.task.phoneC!.substring(0, 3) +
            ") " +
            widget.task.phoneC!.substring(3, 6) +
            "-" +
            widget.task.phoneC!.substring(6, widget.task.phoneC!.length);
      });
    }
  }

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  bool _isChildUpdating = false;
  late TaskDetailsBloc taskDetailsBloc;

  @override
  initState() {
    super.initState();
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'SmartTriggerTaskDetailScreen');
    taskDetailsBloc = context.read<TaskDetailsBloc>();
    taskDetailsBloc.add(TaskDetailsLoadingEvent(widget.taskId!));
    taskStatus = widget.task.status ?? 'Open';
    print("widget.taskId! in detail ${widget.taskId!}");
    formatPhoneNumber(widget.task.phoneC);
    getClientBasicDetails();
    if (widget.notification) {}
    if (kIsWeb)
      navigatorListener =
          context.read<NavigatorWebBloC>().selectedTab.listen((event) {
        if (event != 3 && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
  }

  @override
  void dispose() {
    navigatorListener?.cancel();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.scaffoldBackgroundColor,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Action Details',
          style: const TextStyle(
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: kRubik,
          ),
        ),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            print("widget.notification ${widget.notification}");
            Navigator.of(context).pop();
            widget.landingScreenBlocEvent.add(ReloadTasks());
          },
          color: ColorSystem.black,
        ),
        actions: [
          InkWell(
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return InformationPopUp();
                },
              );
            },
            child: SvgPicture.asset(
              IconSystem.infoCircled,
              package: 'gc_customer_app',
            ),
          ),
          const SizedBox(
            width: SizeSystem.size20,
          ),
        ],
      ),
      // appBar: AppBar(
      //   leading: BackButton(
      //     color: ColorSystem.black,
      //   ),
      // ),
      body: BlocBuilder<TaskDetailsBloc, TaskDetailsState>(
        builder: (BuildContext context, state) {
          if (state is TaskDetailsLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorSystem.primary,
              ),
            );
          } else if (state is TaskDetailsLoadedState) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    addAutomaticKeepAlives: true,
                    controller: scrollController,
                    padding: const EdgeInsets.all(10),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: InkWell(
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          onTap: () async {
                                            if (state.task.whoId != null) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomerPopup(
                                                    customerId:
                                                        customerWithBasicDetails!
                                                            .records!.first.id!,
                                                    clientName:
                                                        customerWithBasicDetails!
                                                                .records!
                                                                .first
                                                                .name ??
                                                            '--',
                                                    lastPurchaseValue:
                                                        customerWithBasicDetails!
                                                                .records!
                                                                .first
                                                                .gCOrdersR!
                                                                .records!
                                                                .first
                                                                .totalAmountC ??
                                                            0.0,
                                                    ltv: customerWithBasicDetails!
                                                        .records!
                                                        .first
                                                        .lifetimeNetSalesAmountC,
                                                    netTransactions:
                                                        customerWithBasicDetails!
                                                            .records!
                                                            .first
                                                            .lifetimeNetSalesTransactionsC,
                                                    primaryInstrument:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .primaryInstrumentCategoryC,
                                                    lastVisitDate:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .lastTransactionDateC,
                                                    lessons:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .lessonsCustomerC,
                                                    loyalty:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .loyaltyCustomerC,
                                                    openBox:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .openBoxPurchaserC,
                                                    synchrony:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .synchronyCustomerC,
                                                    vintage:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .vintagePurchaserC,
                                                    used:
                                                        customerWithBasicDetails
                                                            ?.records!
                                                            .first
                                                            .usedPurchaserC,
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Text(
                                            widget.task.owner!.name ?? '--',
                                            style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: kRubik,
                                                fontWeight: FontWeight.w500,
                                                fontSize: SizeSystem.size18,
                                                color: ColorSystem.purple),
                                          )),
                                    ),
                                    const TextSpan(
                                      text: ' for ',
                                      style: TextStyle(
                                        fontFamily: kRubik,
                                        fontSize: SizeSystem.size18,
                                        color: ColorSystem.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.task.storeTaskTypeC ?? ' ?',
                                      style: const TextStyle(
                                        fontFamily: kRubik,
                                        fontSize: SizeSystem.size16,
                                        color: ColorSystem.primary,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: PaddingSystem.padding8,
                      ),
                      if (state.task.phoneC != null)
                        CustomerContactTile(
                          iconData: IconSystem.phone,
                          text: formattedPhoneNumber!,
                          onTap: () => makephoneCall(
                            widget.task.phoneC.toString(),
                          ),
                          iconSize: SizeSystem.size24,
                        ),
                      if (state.task.phoneC != null &&
                          state.task.phoneC != null)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: PaddingSystem.padding16,
                          ),
                          color: ColorSystem.secondary.withOpacity(0.6),
                          height: SizeSystem.size1,
                        ),
                      if (state.task.emailC != null)
                        CustomerContactTile(
                          iconData: IconSystem.mail,
                          text: widget.task.emailC!,
                          onTap: () => openEmail(widget.task.emailC!),
                        ),
                      if (state.task.description != null &&
                          state.task.description.toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            enabled: false,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: widget.task.description,
                              hintStyle: TextStyle(
                                color: ColorSystem.lavender3,
                                fontSize: SizeSystem.size16,
                                fontFamily: kRubik,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: SizeSystem.size20,
                      ),
                      if (state.orders.isNotEmpty)
                        ProductListCard(
                          isRescheduling: isRescheduling,
                          isCompleting: isCompleting,
                          customerId: widget.customerId!,
                          ownerId: state.task.ownerId!,
                          isChildUpdating: callback,
                          isForceClosing: isForcingClose,
                          popContext: context,
                          task:
                              state.task.id != null && state.task.id!.isNotEmpty
                                  ? state.task
                                  : widget.task,
                          ordersArray: state.orders,
                        ),
                      TaskDetailsDateWidget(
                        task: state.task,
                        customerId: widget.customerId!,
                        ownerId: state.task.ownerId!,
                        assignedToName: state.task.owner!.name ?? '--',
                        modifiedByName: state.task.lastModifiedBy!.name ?? '--',
                        dueByDate: state.task.activityDate ?? '--',
                        modifiedDate: state.task.lastModifiedDate ?? '--',
                        lastModifiedById: state.task.lastModifiedById ?? '--',
                      ),
                      const SizedBox(
                        height: SizeSystem.size20,
                      ),
                      const SizedBox(
                        height: SizeSystem.size20,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // if (taskStatus != 'Completed')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SizeSystem.size20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TaskDetailsCompletionButton(
                              onPressed: widget.customerId! !=
                                      state.task.ownerId
                                  ? () {
                                      ScaffoldMessenger.of(
                                              _scaffoldKey.currentContext!)
                                          .showSnackBar(snackBar(
                                              "This task is not assigned to you"));
                                    }
                                  : (!_isChildUpdating &&
                                          !isCompleting &&
                                          !isForcingClose &&
                                          !isRescheduling)
                                      ? () async {
                                          showCupertinoDialog(
                                            barrierDismissible: true,
                                            context:
                                                _scaffoldKey.currentContext!,
                                            builder:
                                                (BuildContext dialogContext) {
                                              return ForceCloseDialog(
                                                onInvalidTap: () async {
                                                  feedback = "";
                                                  isForceClosed = true;
                                                  Navigator.of(dialogContext)
                                                      .pop();
                                                  widget.landingScreenBlocEvent
                                                      .add(ReloadTasks());
                                                  closureReason =
                                                      'Invalid/Incorrect Contact Info';
                                                },
                                                onNotPickupTap: () async {
                                                  feedback = "";
                                                  isForceClosed = true;
                                                  Navigator.of(dialogContext)
                                                      .pop();
                                                  widget.landingScreenBlocEvent
                                                      .add(ReloadTasks());
                                                  closureReason =
                                                      'Did Not Pick up';
                                                },
                                                onNotCustomerRejectedTap:
                                                    () async {
                                                  feedback = "";
                                                  isForceClosed = true;
                                                  Navigator.of(dialogContext)
                                                      .pop();
                                                  widget.landingScreenBlocEvent
                                                      .add(ReloadTasks());
                                                  closureReason =
                                                      'Customer Rejected';
                                                },
                                              );
                                            },
                                          ).then((value) async {
                                            if (isForceClosed) {
                                              setState(() {
                                                isForcingClose = true;
                                              });
                                              await markTaskAsDelinquent(
                                                  state.task.id != null &&
                                                          state.task.id!
                                                              .isNotEmpty
                                                      ? state.task.id!
                                                      : widget.task.id!);
                                              ScaffoldMessenger.of(_scaffoldKey
                                                      .currentContext!)
                                                  .showSnackBar(snackBar(
                                                      'Task Force Closed'));
                                              setState(() {
                                                isForcingClose = false;
                                                isForceClosed = false;
                                              });
                                              Navigator.of(_scaffoldKey
                                                      .currentContext!)
                                                  .pop();
                                              widget.landingScreenBlocEvent
                                                  .add(ReloadTasks());
                                            }
                                          });
                                        }
                                      : () {},
                              buttonColor: ColorSystem.pieChartAmber,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: isForcingClose ? 10 : 12,
                                ),
                                child: isForcingClose
                                    ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            IconSystem.createTaskClose,
                                            package: 'gc_customer_app',
                                            height: 12,
                                            width: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              'Force Close',
                                              style: TextStyle(
                                                fontSize: SizeSystem.size11,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: kRubik,
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: SizeSystem.size4,
                          ),
                          Expanded(
                            child: TaskDetailsCompletionButton(
                              onPressed:
                                  widget.customerId! != state.task.ownerId
                                      ? () {
                                          ScaffoldMessenger.of(
                                                  _scaffoldKey.currentContext!)
                                              .showSnackBar(snackBar(
                                                  "This task is not assigned to you"));
                                        }
                                      : (!_isChildUpdating &&
                                              !isCompleting &&
                                              !isForcingClose &&
                                              !isRescheduling)
                                          ? () async {
                                              selectedDate = DateTime.now();
                                              showCupertinoModalPopup(
                                                  context: context,
                                                  builder:
                                                      (BuildContext builder) {
                                                    return StatefulBuilder(
                                                        builder: (context,
                                                            setChildState) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 10),
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .copyWith()
                                                                  .size
                                                                  .height *
                                                              0.35,
                                                          color: Colors.white,
                                                          child:
                                                              NotificationListener(
                                                            onNotification:
                                                                (ScrollNotification
                                                                    notification) {
                                                              if (notification
                                                                          .depth ==
                                                                      0 &&
                                                                  notification
                                                                      is ScrollEndNotification &&
                                                                  notification
                                                                          .metrics
                                                                      is FixedExtentMetrics) {
                                                                setChildState(
                                                                    () {
                                                                  isUpdateRescheduling =
                                                                      false;
                                                                });
                                                              } else if (notification
                                                                  is ScrollStartNotification) {
                                                                setChildState(
                                                                    () {
                                                                  isUpdateRescheduling =
                                                                      true;
                                                                });
                                                              }
                                                              return false;
                                                            },
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      CupertinoDatePicker(
                                                                    mode: CupertinoDatePickerMode
                                                                        .date,
                                                                    onDateTimeChanged:
                                                                        (value) {
                                                                      setChildState(
                                                                          () {
                                                                        selectedDate =
                                                                            value;
                                                                      });
                                                                    },
                                                                    initialDateTime:
                                                                        DateTime
                                                                            .now(),
                                                                    maximumDate:
                                                                        DateTime(
                                                                            3100),
                                                                    minimumDate:
                                                                        DateTime.parse(state
                                                                            .task
                                                                            .activityDate!),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          SizeSystem
                                                                              .size40,
                                                                      vertical:
                                                                          SizeSystem
                                                                              .size10,
                                                                    ),
                                                                    child:
                                                                        ElevatedButton(
                                                                      style:
                                                                          ButtonStyle(
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all(
                                                                          ColorSystem
                                                                              .primary,
                                                                        ),
                                                                        shape: MaterialStateProperty.all<
                                                                            RoundedRectangleBorder>(
                                                                          RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(14.0),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onPressed: isRescheduling ||
                                                                              isUpdateRescheduling
                                                                          ? () {}
                                                                          : () async {
                                                                              setChildState(() {
                                                                                isRescheduling = true;
                                                                              });
                                                                              await updateTaskDate(state.task.id != null && state.task.id!.isNotEmpty ? state.task.id! : widget.task.id!);
                                                                              ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar('Task Date Changed'));
                                                                              setChildState(() {
                                                                                isRescheduling = false;
                                                                              });

                                                                              Navigator.of(_scaffoldKey.currentContext!).pop();
                                                                              widget.landingScreenBlocEvent.add(ReloadTasks());
                                                                              Navigator.of(_scaffoldKey.currentContext!).pop();
                                                                              widget.landingScreenBlocEvent.add(ReloadTasks());
                                                                            },
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(
                                                                              vertical: SizeSystem.size16,
                                                                            ),
                                                                            child: isRescheduling
                                                                                ? const CupertinoActivityIndicator(
                                                                                    color: Colors.white,
                                                                                  )
                                                                                : Text(
                                                                                    isUpdateRescheduling ? 'Please wait...' : 'Done',
                                                                                    style: const TextStyle(
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
                                                  });
                                            }
                                          : () {
                                              print(_isChildUpdating);
                                              print(isCompleting);
                                              print(isForcingClose);
                                              print(isRescheduling);
                                            },
                              buttonColor: ColorSystem.secondary,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: isRescheduling ? 10 : 12,
                                ),
                                child: isRescheduling
                                    ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SvgPicture.asset(
                                            IconSystem.calendar,
                                            package: 'gc_customer_app',
                                            height: 12,
                                            width: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              'Reschedule',
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: SizeSystem.size11,
                                                fontWeight: FontWeight.w700,
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: kRubik,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: SizeSystem.size6,
                          ),
                          Expanded(
                            child: TaskDetailsCompletionButton(
                              onPressed: widget.customerId! !=
                                      state.task.ownerId
                                  ? () {
                                      ScaffoldMessenger.of(
                                              _scaffoldKey.currentContext!)
                                          .showSnackBar(snackBar(
                                              "This task is not assigned to you"));
                                    }
                                  : (!_isChildUpdating &&
                                          !isCompleting &&
                                          !isForcingClose &&
                                          !isRescheduling)
                                      ? () async {
                                          //both warranty and spo delivery
                                          if (state.orders
                                                  .where((element) => element
                                                      .orderLines!
                                                      .where((innerElement) =>
                                                          innerElement.taskType
                                                              ?.toLowerCase() ==
                                                          'warranty purchase')
                                                      .isNotEmpty)
                                                  .isNotEmpty &&
                                              state.orders
                                                  .where((element) => element
                                                      .orderLines!
                                                      .where((innerElement) =>
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'spo delivery' ||
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'retail purchase' ||
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'delivery followup')
                                                      .isNotEmpty)
                                                  .isNotEmpty) {
                                            print(
                                                "both warranty and spo delivery");
                                            isCompleted = false;
                                            showCupertinoDialog(
                                              barrierDismissible: true,
                                              context:
                                                  _scaffoldKey.currentContext!,
                                              builder:
                                                  (BuildContext dialogContext) {
                                                return DeliveryDialog(
                                                  onHappyTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Happy';
                                                  },
                                                  onNeutralTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Neutral';
                                                  },
                                                  onSadTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Sad';
                                                  },
                                                );
                                              },
                                            ).then((value) async {
                                              if (isCompleted) {
                                                setState(() {
                                                  isCompleting = true;
                                                });
                                                await markTaskAsCompleted(
                                                    state.task.id != null &&
                                                            state.task.id!
                                                                .isNotEmpty
                                                        ? state.task.id!
                                                        : widget.task.id!);
                                                ScaffoldMessenger.of(
                                                        _scaffoldKey
                                                            .currentContext!)
                                                    .showSnackBar(snackBar(
                                                        'Task Completed'));
                                                setState(() {
                                                  isCompleting = false;
                                                });
                                                Navigator.of(_scaffoldKey
                                                        .currentContext!)
                                                    .pop();
                                                widget.landingScreenBlocEvent
                                                    .add(ReloadTasks());
                                              }
                                            });

                                            /*showDialog(
                                        context: _scaffoldKey.currentContext!,
                                        builder: (BuildContext dialogContextMain) {
                                            return StatefulBuilder(
                                              builder: (context,setVState) {
                                                TextEditingController controller = TextEditingController();

                                                return BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                  child:

                                                  AlertDialog(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    contentPadding: EdgeInsets.zero,
                                                    titlePadding: EdgeInsets.zero,
                                                    buttonPadding: EdgeInsets.zero,
                                                    insetPadding: EdgeInsets.zero,
                                                    actionsPadding: EdgeInsets.zero,
                                                    actions:[
                                                      SizedBox(
                                                              width: MediaQuery.of(context).size.width,
                                                              height: MediaQuery.of(context).size.height*0.8,
                                                              child: SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:MainAxisSize.min,
                                                                  children: [
                                                                    CupertinoAlertDialog(
                                                                      content:
                                                                        Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            const SizedBox(height: 3,),
                                                                            const Text("Delivery",
                                                                              style: TextStyle(
                                                                                  fontSize: 19,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.black
                                                                              ),),
                                                                            const SizedBox(height: 3,),
                                                                            Container(
                                                                              margin: const EdgeInsets.symmetric(
                                                                                vertical: SizeSystem.size12,
                                                                              ),
                                                                              height: SizeSystem.size1,
                                                                              color: Colors.black12,
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: (){
                                                                                setVState((){
                                                                                  closureReason = "Happy";
                                                                                });
                                                                              },
                                                                              child: closureReason.toLowerCase().contains("happy")?Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  SvgPicture.asset(IconSystem.checkmark,
                                                                                  color: Colors.blueAccent,),
                                                                                  SvgPicture.asset(IconSystem.happyEmoji),
                                                                                  SvgPicture.asset(IconSystem.checkmark,
                                                                                    color: Colors.white10,),
                                                                                ],
                                                                              ):SvgPicture.asset(IconSystem.happyEmoji),
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.symmetric(
                                                                                vertical: SizeSystem.size12,
                                                                              ),
                                                                              height: SizeSystem.size1,
                                                                              color: Colors.black12,
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: (){
                                                                                setVState((){
                                                                                  closureReason = "Neutral";
                                                                                });
                                                                                },
                                                                              child: closureReason.toLowerCase().contains("neutral")?Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                SvgPicture.asset(IconSystem.checkmark,
                                                                                  color: Colors.blueAccent,),
                                                                                SvgPicture.asset(IconSystem.neutralEmoji),
                                                                                SvgPicture.asset(IconSystem.checkmark,
                                                                                  color: Colors.white10,),
                                                                              ],
                                                                            ):SvgPicture.asset(IconSystem.neutralEmoji),
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.symmetric(
                                                                                vertical: SizeSystem.size12,
                                                                              ),
                                                                              height: SizeSystem.size1,
                                                                              color: Colors.black12,
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: (){
                                                                                setVState((){
                                                                                  closureReason = "Sad";
                                                                                });

                                                                              },
                                                                              child: closureReason.toLowerCase().contains("sad")?Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  SvgPicture.asset(IconSystem.checkmark,
                                                                                    color: Colors.blueAccent,),
                                                                                  SvgPicture.asset(IconSystem.sadEmoji),
                                                                                  SvgPicture.asset(IconSystem.checkmark,
                                                                                    color: Colors.white10,),
                                                                                ],
                                                                              ):SvgPicture.asset(IconSystem.sadEmoji),
                                                                            ),
                                                                          ],
                                                                        )

                                                                    ),
                                                                    CupertinoAlertDialog(
                                                                      content: Column(

                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment.spaceEvenly,
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          const SizedBox(height: 3,),
                                                                          const Text("Warranty",
                                                                            style: TextStyle(
                                                                                fontSize: 19,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Colors.black
                                                                            ),),
                                                                          const SizedBox(height: 3,),
                                                                          Container(
                                                                            margin: const EdgeInsets.symmetric(
                                                                              vertical: SizeSystem.size12,
                                                                            ),
                                                                            height: SizeSystem.size1,
                                                                            color: Colors.black12,
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap: (){
                                                                              setVState((){
                                                                                closureReason_2 = "Sold";
                                                                              });
                                                                              print(closureReason_2);
                                                                            },
                                                                            child: closureReason_2.toLowerCase().contains("sold")?Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children:  [
                                                                                SvgPicture.asset(IconSystem.checkmark,
                                                                                  color: Colors.blueAccent,),

                                                                                const Text(
                                                                                  'Sold',
                                                                                  style: TextStyle(
                                                                                    color: ColorSystem.additionalBlue,
                                                                                    fontSize: SizeSystem.size18,
                                                                                  ),
                                                                                ),
                                                                                SvgPicture.asset(IconSystem.checkmark,
                                                                                  color: Colors.white10,),

                                                                              ],
                                                                            ):
                                                                            const Text(
                                                                              'Sold',
                                                                              style: TextStyle(
                                                                                color: ColorSystem.additionalBlue,
                                                                                fontSize: SizeSystem.size18,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            margin: const EdgeInsets.symmetric(
                                                                              vertical: SizeSystem.size12,
                                                                            ),
                                                                            height: SizeSystem.size1,
                                                                            color: Colors.black12,
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap: (){
                                                                              setVState((){
                                                                                closureReason_2 = "Notold";
                                                                              });
                                                                              print(closureReason_2);
                                                                            },
                                                                            child: closureReason_2.toLowerCase().contains("notold")?Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children:  [
                                                                                SvgPicture.asset(IconSystem.checkmark,
                                                                                  color: Colors.blueAccent,),

                                                                                const Text(
                                                                                  'Not sold',
                                                                                  style: TextStyle(
                                                                                    color: ColorSystem.additionalBlue,
                                                                                    fontSize: SizeSystem.size18,
                                                                                  ),
                                                                                ),
                                                                                SvgPicture.asset(IconSystem.checkmark,
                                                                                  color: Colors.white10,),

                                                                              ],
                                                                            ):
                                                                            const Text(
                                                                              'Not sold',
                                                                              style: TextStyle(
                                                                                color: ColorSystem.additionalBlue,
                                                                                fontSize: SizeSystem.size18,
                                                                              ),
                                                                            ),
                                                                          ),

                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 70.0),
                                                                      child: TaskDetailsCompletionButton(
                                                                        buttonColor: ColorSystem.additionalPurple,
                                                                        onPressed: () async {
                                                                          if(closureReason.isEmpty){
                                                                            showMessage(context: context,message:"Please select closure reason for delivery");
                                                                          }
                                                                          else if(closureReason_2.isEmpty){
                                                                            showMessage(context: context,message:"Please select closure reason for warranty");
                                                                          }
                                                                          else{
                                                                            Navigator.pop(_scaffoldKey.currentContext!);
                                                                            isCompleted = false;
                                                                            await showCupertinoDialog(
                                                                              barrierDismissible: true,
                                                                              context: _scaffoldKey.currentContext!,
                                                                              builder: (BuildContext dialogContext) {
                                                                                return StatefulBuilder(
                                                                                    builder: (context,setWState) {
                                                                                      return BackdropFilter(
                                                                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                                                        child: CupertinoAlertDialog(
                                                                                          content: Material(
                                                                                            color: Colors.transparent,
                                                                                            child: SizedBox(
                                                                                              width: MediaQuery.of(context)
                                                                                                  .size
                                                                                                  .width /
                                                                                                  2,
                                                                                              child: Column(
                                                                                                mainAxisAlignment:
                                                                                                MainAxisAlignment.spaceEvenly,
                                                                                                children: [
                                                                                                  const Text("Feedback",
                                                                                                    style: TextStyle(
                                                                                                        fontSize: 19,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        color: Colors.black
                                                                                                    ),),
                                                                                                  const SizedBox(height: 3,),
                                                                                                  const Text("Please enter the experience you had with customer",
                                                                                                    textAlign: TextAlign.center,
                                                                                                    style: TextStyle(
                                                                                                        fontSize: 15,
                                                                                                        color: Colors.black
                                                                                                    ),),
                                                                                                  const SizedBox(height: 10),
                                                                                                  TextFormField(
                                                                                                    maxLines: 5,
                                                                                                    controller: controller,
                                                                                                    keyboardType: TextInputType.multiline,
                                                                                                    cursorColor: Colors.black,
                                                                                                    style: const TextStyle(
                                                                                                        color: Colors.black,
                                                                                                        fontSize: 14
                                                                                                    ),
                                                                                                    autofocus: false,
                                                                                                    decoration: InputDecoration(
                                                                                                        filled: true,
                                                                                                        fillColor: Colors.white,
                                                                                                        hintText: "Enter you feedback",
                                                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 7,horizontal: 10),
                                                                                                        constraints: const BoxConstraints(),
                                                                                                        hintStyle: const TextStyle(
                                                                                                            color: Colors.grey,
                                                                                                            fontSize: 14
                                                                                                        ),
                                                                                                        border: OutlineInputBorder(
                                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                                          borderSide: const BorderSide(color: ColorSystem.additionalGrey, width: 1),
                                                                                                        ),
                                                                                                        focusedBorder: OutlineInputBorder(
                                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                                          borderSide: const BorderSide(color: ColorSystem.additionalGrey, width: 1),
                                                                                                        ),
                                                                                                        enabledBorder: OutlineInputBorder(
                                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                                          borderSide: const BorderSide(color: ColorSystem.additionalGrey, width: 1),
                                                                                                        )
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(height: 10),

                                                                                                  GestureDetector(
                                                                                                    onTap: (){
                                                                                                      fdt.DatePicker.showDateTimePicker(context,
                                                                                                          showTitleActions: true,
                                                                                                          minTime: DateTime(1800, 1, 1),
                                                                                                          maxTime: DateTime(2100, 1, 1),
                                                                                                          onChanged: (date) {
                                                                                                            print('change $date');
                                                                                                          }, onConfirm: (date) {
                                                                                                            setWState(() {
                                                                                                              feedbackDateTime =DateFormat('hh:mm aa dd-MM-yyyy').format(date);
                                                                                                            });
                                                                                                          }, currentTime: DateTime.now(), locale: fdt.LocaleType.en);
                                                                                                    },
                                                                                                    child: Text(
                                                                                                      feedbackDateTime.isEmpty?DateFormat('hh:mm aa dd-MM-yyyy').format(DateTime.now()):feedbackDateTime,
                                                                                                      style: const TextStyle(
                                                                                                        color: ColorSystem.additionalBlue,
                                                                                                        fontSize: SizeSystem.size16,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    margin: const EdgeInsets.symmetric(
                                                                                                      vertical: SizeSystem.size12,
                                                                                                    ),
                                                                                                    height: SizeSystem.size1,
                                                                                                    color: ColorSystem.additionalGrey,
                                                                                                  ),
                                                                                                  GestureDetector(
                                                                                                    onTap: (){
                                                                                                      setWState((){
                                                                                                        feedback = controller.text;
                                                                                                        isCompleted = true;
                                                                                                        controller.clear();
                                                                                                      });
                                                                                                      Navigator.pop(_scaffoldKey.currentContext!);
                                                                                                    },
                                                                                                    child: const Text(
                                                                                                      'Submit',
                                                                                                      style: TextStyle(
                                                                                                        color: ColorSystem.additionalBlue,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        fontSize: SizeSystem.size16,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                );
                                                                              },
                                                                            ).then((value) async {
                                                                              if(closureReason_2.toLowerCase().contains("notold")){
                                                                                closureReason= closureReason+",Not sold";
                                                                              }
                                                                              else{
                                                                                closureReason= closureReason+","+closureReason_2;
                                                                              }

                                                                              if(isCompleted){
                                                                                setState(() {
                                                                                  isCompleting=true;
                                                                                });
                                                                                await markTaskAsCompleted(state.task.id != null && state.task.id!.isNotEmpty ? state.task.id! : widget.task.id!);
                                                                               ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar('Task Completed'));
                                                                                setState(() {
                                                                                  isCompleting=false;
                                                                                });
                                                                                Navigator.of(_scaffoldKey.currentContext! ).pop();  widget.landingScreenBlocEvent.add(ReloadTasks());
                                                                              }
                                                                            });
                                                                          }
                                                                        },
                                                                        child: Padding(
                                                                          padding:  EdgeInsets.symmetric(
                                                                            vertical: 12,
                                                                          ),
                                                                          child: Row(
                                                                            mainAxisSize: MainAxisSize.max,
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: const [
                                                                              SizedBox(
                                                                                width: 6,
                                                                              ),
                                                                              Text(
                                                                                'Submit',
                                                                                style: TextStyle(
                                                                                  fontSize: SizeSystem.size16,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontFamily: kRubik,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 6,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            );
                                        }
                                    );*/
                                          }
                                          //warranty, not spo delivery
                                          else if (state.orders
                                                  .where((element) => element
                                                      .orderLines!
                                                      .where((innerElement) =>
                                                          innerElement.taskType
                                                              ?.toLowerCase() ==
                                                          'warranty purchase')
                                                      .isNotEmpty)
                                                  .isNotEmpty &&
                                              state.orders
                                                  .where((element) => element
                                                      .orderLines!
                                                      .where((innerElement) =>
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'spo delivery' ||
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'retail purchase' ||
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'delivery followup')
                                                      .isEmpty)
                                                  .isNotEmpty) {
                                            print("warranty, not spo delivery");
                                            isCompleted = false;
                                            showCupertinoDialog(
                                              barrierDismissible: true,
                                              context:
                                                  _scaffoldKey.currentContext!,
                                              builder:
                                                  (BuildContext dialogContext) {
                                                return WarrantyPurchaseDialog(
                                                  onSoldTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Sold';
                                                  },
                                                  onNotSoldTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Not Sold';
                                                  },
                                                );
                                              },
                                            ).then((value) async {
                                              if (isCompleted) {
                                                setState(() {
                                                  isCompleting = true;
                                                });
                                                await markTaskAsCompleted(
                                                    state.task.id != null &&
                                                            state.task.id!
                                                                .isNotEmpty
                                                        ? state.task.id!
                                                        : widget.task.id!);
                                                ScaffoldMessenger.of(
                                                        _scaffoldKey
                                                            .currentContext!)
                                                    .showSnackBar(snackBar(
                                                        'Task Completed'));
                                                setState(() {
                                                  isCompleting = false;
                                                });
                                                Navigator.of(_scaffoldKey
                                                        .currentContext!)
                                                    .pop();
                                                widget.landingScreenBlocEvent
                                                    .add(ReloadTasks());
                                              }
                                            });
                                          }
                                          //not warranty, spo delivery
                                          else if (state.orders
                                                  .where((element) => element
                                                      .orderLines!
                                                      .where((innerElement) =>
                                                          innerElement.taskType
                                                              ?.toLowerCase() ==
                                                          'warranty purchase')
                                                      .isEmpty)
                                                  .isNotEmpty &&
                                              state.orders
                                                  .where((element) => element
                                                      .orderLines!
                                                      .where((innerElement) =>
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'spo delivery' ||
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'retail purchase' ||
                                                          innerElement.taskType
                                                                  ?.toLowerCase() ==
                                                              'delivery followup')
                                                      .isNotEmpty)
                                                  .isNotEmpty) {
                                            print("not warranty, spo delivery");
                                            isCompleted = false;
                                            showCupertinoDialog(
                                              barrierDismissible: true,
                                              context:
                                                  _scaffoldKey.currentContext!,
                                              builder:
                                                  (BuildContext dialogContext) {
                                                return DeliveryDialog(
                                                  onHappyTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Happy';
                                                  },
                                                  onNeutralTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Neutral';
                                                  },
                                                  onSadTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Sad';
                                                  },
                                                );
                                              },
                                            ).then((value) async {
                                              if (isCompleted) {
                                                setState(() {
                                                  isCompleting = true;
                                                });
                                                await markTaskAsCompleted(
                                                    state.task.id != null &&
                                                            state.task.id!
                                                                .isNotEmpty
                                                        ? state.task.id!
                                                        : widget.task.id!);
                                                ScaffoldMessenger.of(
                                                        _scaffoldKey
                                                            .currentContext!)
                                                    .showSnackBar(snackBar(
                                                        'Task Completed'));
                                                setState(() {
                                                  isCompleting = false;
                                                });
                                                Navigator.of(_scaffoldKey
                                                        .currentContext!)
                                                    .pop();
                                                widget.landingScreenBlocEvent
                                                    .add(ReloadTasks());
                                              }
                                            });
                                          } //ready for pickup
                                          else if (state.orders
                                              .where((element) => element
                                                  .orderLines!
                                                  .where((innerElement) =>
                                                      innerElement.taskType
                                                          ?.toLowerCase() ==
                                                      'ready for pickup')
                                                  .isNotEmpty)
                                              .isNotEmpty) {
                                            print("ready for pickup");
                                            TextEditingController controller =
                                                TextEditingController();
                                            isCompleted = false;
                                            await showCupertinoDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return PickUpDialog(
                                                  onAcknowledgedTap: () {
                                                    feedback = "Acknowledged";
                                                    Navigator.pop(context);
                                                    submitReadyForPickup(state);
                                                  },
                                                  onPickupTap: () {
                                                    feedback = "Pickup Later";
                                                    Navigator.pop(context);
                                                    submitReadyForPickup(state);
                                                  },
                                                  onCancelTap: () {
                                                    feedback = "Cancel Order";
                                                    Navigator.pop(context);
                                                    submitReadyForPickup(state);
                                                  },
                                                );
                                              },
                                            );
                                          } else {
                                            print(
                                                "not warranty, not spo delivery not ready for pickup");
                                            isCompleted = false;
                                            showCupertinoDialog(
                                              barrierDismissible: true,
                                              context:
                                                  _scaffoldKey.currentContext!,
                                              builder:
                                                  (BuildContext dialogContext) {
                                                return DeliveryDialog(
                                                  onHappyTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Happy';
                                                  },
                                                  onNeutralTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Neutral';
                                                  },
                                                  onSadTap: () async {
                                                    feedback = "";
                                                    isCompleted = true;
                                                    Navigator.pop(
                                                        dialogContext);
                                                    closureReason = 'Sad';
                                                  },
                                                );
                                              },
                                            ).then((value) async {
                                              if (isCompleted) {
                                                setState(() {
                                                  isCompleting = true;
                                                });
                                                await markTaskAsCompleted(
                                                    state.task.id != null &&
                                                            state.task.id!
                                                                .isNotEmpty
                                                        ? state.task.id!
                                                        : widget.task.id!);
                                                ScaffoldMessenger.of(
                                                        _scaffoldKey
                                                            .currentContext!)
                                                    .showSnackBar(snackBar(
                                                        'Task Completed'));
                                                setState(() {
                                                  isCompleting = false;
                                                });
                                                Navigator.of(_scaffoldKey
                                                        .currentContext!)
                                                    .pop();
                                                widget.landingScreenBlocEvent
                                                    .add(ReloadTasks());
                                              }
                                            });
                                          }
                                        }
                                      : () {
                                          print(!isCompleting);
                                          print(!isForcingClose);
                                          print(!_isChildUpdating);
                                        },
                              buttonColor: ColorSystem.pieChartGreen,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: isCompleting ? 10 : 12,
                                ),
                                child: isCompleting
                                    ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: const [
                                          Icon(
                                            CupertinoIcons.checkmark,
                                            color: Colors.white,
                                            size: SizeSystem.size14,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Complete',
                                              style: TextStyle(
                                                fontSize: SizeSystem.size11,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: kRubik,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: SizeSystem.size40,
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Center(
              child: Text(state.toString()),
            );
          }
        },
      ),
    );
  }

  Future<void> submitReadyForPickup(TaskDetailsLoadedState state) async {
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
                        isUpdateRescheduling = false;
                      });
                    } else if (notification is ScrollStartNotification) {
                      setChildState(() {
                        isUpdateRescheduling = true;
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
                              feedbackDateTime =
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: SizeSystem.size40,
                            vertical: SizeSystem.size10,
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                ColorSystem.primary,
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                            onPressed: isUpdateRescheduling
                                ? () {}
                                : () async {
                                    setChildState(() {
                                      isCompleted = true;
                                    });
                                    Navigator.pop(context);
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SizeSystem.size16,
                                  ),
                                  child: Text(
                                    isUpdateRescheduling
                                        ? 'Please wait...'
                                        : 'Done',
                                    style: const TextStyle(
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
      if (isCompleted) {
        setState(() {
          isCompleting = true;
        });
        await markTaskAsCompleted(
            state.task.id != null && state.task.id!.isNotEmpty
                ? state.task.id!
                : widget.task.id!);
        ScaffoldMessenger.of(_scaffoldKey.currentContext!)
            .showSnackBar(snackBar('Task Completed'));
        setState(() {
          isCompleting = false;
        });
        Navigator.of(_scaffoldKey.currentContext!).pop();
        widget.landingScreenBlocEvent.add(ReloadTasks());
      }
    });
  }

  callback(bool isChildUpdating) {
    setState(() {
      _isChildUpdating = isChildUpdating;
    });
  }
}

class CustomerContactTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String iconData;
  final String text;
  final double iconSize;

  const CustomerContactTile(
      {Key? key,
      this.onTap,
      required this.iconData,
      required this.text,
      this.iconSize = SizeSystem.size20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(
          PaddingSystem.padding16,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconData,
              color: ColorSystem.lavender3,
              package: 'gc_customer_app',
              height: iconSize,
            ),
            const SizedBox(
              width: SizeSystem.size10,
            ),
            Text(
              text,
              style: const TextStyle(
                color: ColorSystem.lavender3,
                fontSize: SizeSystem.size18,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TaskDetailsCompletionButton extends StatelessWidget {
  final Color buttonColor;
  final Widget child;
  final VoidCallback? onPressed;

  const TaskDetailsCompletionButton({
    Key? key,
    this.buttonColor = ColorSystem.primary,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(buttonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ))),
    );
  }
}

class DeliveryClosureSelectionDialogWidget extends StatefulWidget {
  const DeliveryClosureSelectionDialogWidget({Key? key}) : super(key: key);

  @override
  State<DeliveryClosureSelectionDialogWidget> createState() =>
      _DeliveryClosureSelectionDialogWidgetState();
}

class _DeliveryClosureSelectionDialogWidgetState
    extends State<DeliveryClosureSelectionDialogWidget> {
  int selectedIndex = 0;
  Color unSelectedIconColor = Colors.transparent,
      selectedIconColor = ColorSystem.additionalBlue;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SizeSystem.size12,
            horizontal: SizeSystem.size12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Material(
                color: Colors.transparent,
                child: Text(
                  'Delivery',
                  style: TextStyle(
                    color: ColorSystem.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeSystem.size16,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: SizeSystem.size12,
                ),
                height: SizeSystem.size1,
                color: ColorSystem.additionalGrey,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark,
                      color: selectedIndex == 1
                          ? selectedIconColor
                          : unSelectedIconColor,
                    ),
                    SvgPicture.asset(
                      IconSystem.happyEmoji,
                      package: 'gc_customer_app',
                    ),
                    const SizedBox(
                      width: SizeSystem.size24,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: SizeSystem.size12,
                ),
                height: SizeSystem.size1,
                color: ColorSystem.additionalGrey,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark,
                      color: selectedIndex == 2
                          ? selectedIconColor
                          : unSelectedIconColor,
                    ),
                    SvgPicture.asset(
                      IconSystem.neutralEmoji,
                      package: 'gc_customer_app',
                    ),
                    const SizedBox(
                      width: SizeSystem.size24,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: SizeSystem.size12,
                ),
                height: SizeSystem.size1,
                color: ColorSystem.additionalGrey,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 3;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark,
                      color: selectedIndex == 3
                          ? selectedIconColor
                          : unSelectedIconColor,
                    ),
                    SvgPicture.asset(
                      IconSystem.sadEmoji,
                      package: 'gc_customer_app',
                    ),
                    const SizedBox(
                      width: SizeSystem.size24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class TaskCompletionDialogWidget extends StatelessWidget {
  final bool hasDeliveryCompletion;
  final bool hasWarrantyPurchase;

  const TaskCompletionDialogWidget(
      {Key? key,
      required this.hasDeliveryCompletion,
      required this.hasWarrantyPurchase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10,
        sigmaY: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasDeliveryCompletion)
            const DeliveryClosureSelectionDialogWidget(),
          if (hasWarrantyPurchase) const WarrantyClosureSelectionDialogWidget(),
        ],
      ),
    );
  }
}

class WarrantyClosureSelectionDialogWidget extends StatefulWidget {
  const WarrantyClosureSelectionDialogWidget({Key? key}) : super(key: key);

  @override
  State<WarrantyClosureSelectionDialogWidget> createState() =>
      _WarrantyClosureSelectionDialogWidgetState();
}

class _WarrantyClosureSelectionDialogWidgetState
    extends State<WarrantyClosureSelectionDialogWidget> {
  int selectedIndex = 0;
  Color unSelectedIconColor = Colors.transparent,
      selectedIconColor = ColorSystem.additionalBlue;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SizeSystem.size12,
            horizontal: SizeSystem.size12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Material(
                color: Colors.transparent,
                child: Text(
                  'Warranty',
                  style: TextStyle(
                    color: ColorSystem.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeSystem.size16,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: SizeSystem.size12,
                ),
                height: SizeSystem.size1,
                color: ColorSystem.additionalGrey,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark,
                      color: selectedIndex == 1
                          ? selectedIconColor
                          : unSelectedIconColor,
                    ),
                    const Material(
                      color: Colors.transparent,
                      child: Text(
                        'Sold',
                        style: TextStyle(
                          color: ColorSystem.additionalBlue,
                          fontSize: SizeSystem.size14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: SizeSystem.size24,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: SizeSystem.size12,
                ),
                height: SizeSystem.size1,
                color: ColorSystem.additionalGrey,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark,
                      color: selectedIndex == 2
                          ? selectedIconColor
                          : unSelectedIconColor,
                    ),
                    const Material(
                      color: Colors.transparent,
                      child: Text(
                        'Not sold',
                        style: TextStyle(
                          color: ColorSystem.additionalBlue,
                          fontSize: SizeSystem.size14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: SizeSystem.size24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
