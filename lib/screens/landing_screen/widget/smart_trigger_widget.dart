import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/smart_trigger_bloc/smart_trigger_bloc.dart';
import 'package:gc_customer_app/common_widgets/agent_task_view.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/landing_screen/landing_task_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class SmartTriggerWidget extends StatefulWidget {
  final LandingScreenState landingScreenState;
  SmartTriggerWidget({Key? key, required this.landingScreenState})
      : super(key: key);

  @override
  State<SmartTriggerWidget> createState() => _SmartTriggerWidgetState();
}

class _SmartTriggerWidgetState extends State<SmartTriggerWidget> {
  @override
  void initState() {
    super.initState();
    context.read<SmartTriggerBloc>().add(LoadTasksData());
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    return kIsWeb
        ? Scaffold(
            drawer: widthOfScreen.isMobileWebDevice()
                ? DrawerLandingWidget()
                : null,
            backgroundColor: ColorSystem.webBackgr,
            appBar: AppBar(
              backgroundColor: ColorSystem.webBackgr,
              centerTitle: true,
              title: Text(smartTriggerTasks.toUpperCase(),
                  style: TextStyle(
                      fontFamily: kRubik,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      fontSize: 15)),
            ),
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: ColorSystem.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(child: _body(context)),
            ),
          )
        : _body(context);
  }

  Widget _body(BuildContext context) {
    return BlocBuilder<SmartTriggerBloc, SmartTriggerState>(
        builder: (context, state) {
      List<AggregatedTaskList>? tasks;
      bool isLoading = false;
      Widget dataWidget = SizedBox.shrink();
      if (state is SmartTriggerSuccess) {
//        dataWidget = Text(state.tasks.length.toString());
        tasks = state.tasks;
        if (tasks != null && tasks.isNotEmpty) {
          dataWidget = BlocProvider.value(
            value: context.read<LandingScreenBloc>(),
            child: AgentsTasksView(
                label: 'MY ACTIONS',
                showingUnAssigned: false,
                landingScreenBlocEvent: context.read<LandingScreenBloc>(),
                tasks: tasks,
                customerInfoModel:
                    widget.landingScreenState.customerInfoModel!),
          );
        } else {
          kIsWeb
              ? dataWidget = Container(
                  height: MediaQuery.of(context).size.height - 110,
                  width: double.infinity,
                  color: ColorSystem.white,
                  child: Center(child: NoDataFound(fontSize: 14)))
              : dataWidget = SizedBox(
                  // height: MediaQuery.of(context).size.height * 0.15,
                  // child: Center(
                  //     child: Text(" No Smart Trigger Tasks Assigned")),
                  );
        }
      }
      if (state is SmartTriggerProgress) {
        dataWidget = Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: CircularProgressIndicator(),
        ));
      }

      return tasks != null && tasks.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!kIsWeb)
                  Text(
                    smartTriggerTasks,
                    style: TextStyle(
                        color: ColorSystem.blueGrey,
                        fontFamily: kRubik,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                SizedBox(height: 20),
                dataWidget,
                SizedBox(height: 25),
              ],
            )
          : Container();
    });
  }
}
