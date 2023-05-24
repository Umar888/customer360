// ignore_for_file: empty_catches, unused_catch_clause, deprecated_member_use

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/task_details_bloc/task_details_bloc.dart'
    as tdb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/task_details_loading_bloc/task_details_loading_bloc.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/task_detail/task_detail_main.dart';
import 'package:gc_customer_app/screens/task_detail/task_details_screen.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/common_widgets.dart';
import 'package:intl/intl.dart';

class TaskDetailsLoadingScreen extends StatefulWidget {
  final String? taskId;
  final String? customerId;
  final LandingScreenBloc landingScreenBlocEvent;
  TaskDetailsLoadingScreen({
    Key? key,
    required this.customerId,
    required this.taskId,
    required this.landingScreenBlocEvent,
  }) : super(key: key);

  @override
  State<TaskDetailsLoadingScreen> createState() =>
      _TaskDetailsLoadingScreenState();
}

class _TaskDetailsLoadingScreenState extends State<TaskDetailsLoadingScreen> {
  late TaskDetailsLoadingBloc taskDetailsLoadingBloc;

  setCredentials() async {
    // SharedPreferenceService sharedPreferences = SharedPreferenceService();
    // List<String> ids = await sharedPreferences.getKeyList(key: firebaseIds);
    // if(ids.isNotEmpty) {
    //   if(ids.contains(widget.taskId)) {
    //     int i = ids.indexOf(widget.taskId!);
    //     ids.removeAt(i);
    //     ids= ids.toSet().toList();
    //     await sharedPreferences.setKeyList(key: firebaseIds,value: ids);
    //   }
    // }
    // if(await FlutterAppBadger.isAppBadgeSupported()) {
    //   FlutterAppBadger.removeBadge();
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  initState() {
    super.initState();
    print("widget.taskId! in loading ${widget.taskId!}");
    taskDetailsLoadingBloc = context.read<TaskDetailsLoadingBloc>();
    taskDetailsLoadingBloc.add(TaskDetailsLoadingFetchEvent(widget.taskId!));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.scaffoldBackgroundColor,
      key: _scaffoldKey,
      body: Column(
        children: [
          Expanded(
            child:
                BlocConsumer<TaskDetailsLoadingBloc, TaskDetailsLoadingState>(
              listener: (context, state) async {
                if (state is TaskDetailsFetchingState &&
                    state.taskDetailLoadingStatus ==
                        TaskDetailLoadingStatus.success) {}
              },
              builder: (BuildContext context, state) {
                if (state is TaskDetailsFetchingState) {
                  if (state.taskDetailLoadingStatus == TaskDetailLoadingStatus.success) {
                    Future.delayed(Duration.zero, () {
                      // context.read<tdb.TaskDetailsBloc>().add(tdb.TaskDetailsLoadingEvent(state.task[0].id!));
                      print("state.taskId! in loading ${state.task[0].id!}");
                      Navigator.of(context)
                          .pushReplacement(kIsWeb
                              ? webPageRoute(BlocProvider.value(
                                  value: widget.landingScreenBlocEvent,
                                  child: TaskDetailMain(
                                    taskId: state.task[0].id!,
                                    customerId: widget.customerId,
                                    landingScreenBlocEvent:
                                        widget.landingScreenBlocEvent,
                                    email: state.task[0].emailC ?? "",
                                    task: state.task[0],
                                    notification: true,
                                  ),
                                ))
                              : MaterialPageRoute(
                                  builder: (BuildContext context) {
                                  return BlocProvider.value(
                                    value: widget.landingScreenBlocEvent,
                                    child: TaskDetailMain(
                                      taskId: state.task[0].id!,
                                      customerId: widget.customerId,
                                      landingScreenBlocEvent:
                                          widget.landingScreenBlocEvent,
                                      email: state.task[0].emailC ?? "",
                                      task: state.task[0],
                                      notification: true,
                                    ),
                                  );
                                }))
                          .then((value) {
                        widget.landingScreenBlocEvent.add(ReloadTasks());
                      });
                    });
                    return Container();
                  } else if (state.taskDetailLoadingStatus == TaskDetailLoadingStatus.failed) {
                    return SafeArea(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(onPressed: (){
                                Navigator.pop(context);
                              },
                                  icon: Icon(
                                Icons.arrow_back_ios,
                                    color: Theme.of(context).primaryColor,
                              ))
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Task Detail Not Found',
                                style: TextStyle(
                                    fontFamily: kRubik,
                                    fontSize: SizeSystem.size16,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SafeArea(
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(onPressed: (){
                              Navigator.pop(context);
                            },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).primaryColor,
                                ))
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SafeArea(
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(onPressed: (){
                              Navigator.pop(context);
                            },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).primaryColor,
                                ))
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
