import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/task_details_bloc/task_details_bloc.dart';
import 'package:gc_customer_app/common_widgets/task_list_widget.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_task_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/task_detail/task_detail_loading_main.dart';
import 'package:gc_customer_app/screens/task_detail/task_details_loading_screen.dart';
import 'package:gc_customer_app/utils/common_widgets.dart';

import '../models/task.dart';
import '../services/storage/shared_preferences_service.dart';

class AgentsTasksView extends StatelessWidget {
  final bool showingUnAssigned;
  final LandingScreenBloc landingScreenBlocEvent;
  final CustomerInfoModel customerInfoModel;
  final List<AggregatedTaskList> tasks;
  final String? label;

  AgentsTasksView({
    Key? key,
    required this.landingScreenBlocEvent,
    required this.showingUnAssigned,
    required this.tasks,
    required this.customerInfoModel,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: SizeSystem.size20, left: 3),
      padding: EdgeInsets.symmetric(
        vertical: SizeSystem.size20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          SizeSystem.size20,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.blue1.withOpacity(0.15),
            blurRadius: 12.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
          children:tasks.map((e){

            return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tasks.indexOf(e) == 0?SizedBox(
                    height: SizeSystem.size0,
                  ):SizedBox(
                    height: SizeSystem.size10,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      "Allocated to : ${e.ownerName}"
                          .toUpperCase(),
                      style: TextStyle(
                          letterSpacing: 2,
                          color: ColorSystem.lavender3,
                          fontFamily: kRubik,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    height: SizeSystem.size5,
                  ),
                  ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: SizeSystem.size24),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: e.allOpenTasks!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return TaskListWidget(
                        onTap: () async {
                          String loggedInAgent =
                          await SharedPreferenceService().getValue(loggedInAgentId);
                          Navigator.push(
                              context,
                              kIsWeb
                                  ? webPageRoute(TaskDetailLoadingMain(
                                  taskId: e.allOpenTasks![index].id!,
                                  customerId: loggedInAgent,
                                  landingScreenBlocEvent:
                                  landingScreenBlocEvent))
                                  : MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: landingScreenBlocEvent,
                                    child: TaskDetailLoadingMain(
                                        taskId: e.allOpenTasks![index].id!,
                                        customerId: loggedInAgent,
                                        landingScreenBlocEvent:
                                        landingScreenBlocEvent),
                                  )))
                              .then((value) {
                            landingScreenBlocEvent.add(ReloadTasks());
                          });

                          // SharedPreferenceService sharedPreferences = SharedPreferenceService();
                          // List<String> ids = await sharedPreferences.getKeyList(key: firebaseIds);
                          // if(ids.isNotEmpty) {
                          //   if(ids.contains(agentTasks.allTasks[index].id!)) {
                          //     int i = ids.indexOf(agentTasks.allTasks[index].id!);
                          //     ids.removeAt(i);
                          //     ids= ids.toSet().toList();
                          //     await sharedPreferences.setKeyList(key: firebaseIds,value: ids);
                          //   }
                          // }
                          // context.read<TaskDetailsBloc>().add(
                          //     TaskDetailsLoadingEvent(agentTasks.allTasks[index].id!));
                          //
                          // context.read<TaskListBloc>().getAgentId(agentTasks.id!);
                          //
                          // await Navigator.of(context)
                          //     .push(MaterialPageRoute(builder: (BuildContext context) {
                          //   return TaskDetailsScreen(
                          //     taskId: agentTasks.allTasks[index].id!,
                          //     email: agentTasks.allTasks[index].email,
                          //     task: agentTasks.allTasks[index],
                          //   );
                          // }));
                          //
                          // context.read<HomeTabBloc>().add(HomeTabRefreshEvent());
                          // context.read<TaskListBloc>().add(TaskListRefreshEvent(
                          //     TaskListManagerViewingAgentsTasksState(
                          //         agentWithTasks: agentTasks,
                          //         showingUnAssigned: false)));
                        },
                        task: e.allOpenTasks![index],
                        taskId: e.allOpenTasks![index].id!,
                        status: e.allOpenTasks![index].status,
                        subject: e.allOpenTasks![index].subject,
                        taskType: e.allOpenTasks![index].storeTaskTypeC,
                        activityDate: e.allOpenTasks![index].activityDate,
                        phone: e.allOpenTasks![index].phoneC,
                        email: e.allOpenTasks![index].emailC,
                        isFetching: false,
                        showingUnassignedTask: false,
                        isOverdue: false,
                        // stores: [],
                        // agents: [],
                        agentName: e.allOpenTasks![index].owner!.name ?? '--',
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.grey.withOpacity(0.2),
                        height: 1,
                      );
                    },
                  ),
                  // tasks.indexOf(e) < tasks.length -1 ?Divider(
                  //   color: Colors.grey,
                  //   height: 1,
                  // ):Divider(
                  //   color: Colors.white,
                  //   height: 0,
                  // ),
                ],
              );
          }).toList()
        ),
    );
  }
}
