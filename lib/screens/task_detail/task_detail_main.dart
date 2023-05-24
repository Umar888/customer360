import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/task_details_loading_bloc/task_details_loading_bloc.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart'
    as cim;
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/screens/product_detail/product_detail_list.dart';
import 'package:gc_customer_app/screens/task_detail/task_details_loading_screen.dart';
import 'package:gc_customer_app/screens/task_detail/task_details_screen.dart';

import '../../bloc/product_detail_bloc/product_detail_bloc.dart';
import '../../bloc/task_details_bloc/task_details_bloc.dart';
import '../../data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import '../../models/inventory_search/add_search_model.dart';
import '../../primitives/color_system.dart';

class TaskDetailMain extends StatelessWidget {
  final String? taskId;
  final String? email;
  final String? customerId;
  final TaskModel task;
  final LandingScreenBloc landingScreenBlocEvent;
  bool notification;
  TaskDetailMain({
    Key? key,
    required this.taskId,
    required this.customerId,
    required this.landingScreenBlocEvent,
    required this.task,
    this.email,
    this.notification = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskDetailsBloc>(create: (context) => TaskDetailsBloc(),
    child: BlocProvider<LandingScreenBloc>.value(
      value: landingScreenBlocEvent,
      child: TaskDetailsScreen(taskId: taskId,
      email: email,task: task,notification: notification, landingScreenBlocEvent: landingScreenBlocEvent,customerId:customerId),
    ));
  }
}
