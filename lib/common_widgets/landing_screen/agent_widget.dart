import 'dart:ui';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/activity_landing_widget.dart';
import 'package:gc_customer_app/models/landing_screen/agent_list.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

import '../../constants/colors.dart';
import '../../primitives/icon_system.dart';
import '../../services/storage/shared_preferences_service.dart';
import '../agent_tile_widget.dart';
import '../other_tile_widget.dart';

class AgentWidget extends StatefulWidget {
  String agentId;
  AgentWidget({super.key, this.agentId = ""});

  @override
  State<AgentWidget> createState() => _AgentWidgetState();
}

class _AgentWidgetState extends State<AgentWidget> {
  late LandingScreenBloc landingScreenBloc;

  @override
  void initState() {
    landingScreenBloc = context.read<LandingScreenBloc>();
    landingScreenBloc.add(CheckAgent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<LandingScreenBloc, LandingScreenState>(
        buildWhen: (previous, current) {
      if (!kIsWeb) return true;
      return current.assignedAgent != null && !current.gettingAgentAssigned!;
    }, builder: (context, state) {
      if (state.landingScreenStatus == LandingScreenStatus.success) {
        if (!state.gettingAgentAssigned!) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Store",
                    style: TextStyle(
                        color: ColorSystem.blueGrey,
                        fontFamily: kRubik,
                        fontSize: 16)),
                AgentTilesWidget(
                  assignedAgent: state.assignedAgent,
                  isStore: true,
                  isAssigning: state.isAssigningStoreAgent!,
                  onTapList: () async {
                    // landingScreenBloc.add(GetAgentList());
                    await showCupertinoDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return StatefulBuilder(
                            builder: (context, setChildState) {
                          return CupertinoAlertDialog(
                            title: Text(
                              'Gear Advisor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text('Assign customer to you?'),
                            actions: [
                              CupertinoButton(
                                  child: Text(
                                    'Cancel',
                                  ),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  }),
                              CupertinoButton(
                                  child: Text(
                                    "Assign",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    var loggedInUserId =
                                        await SharedPreferenceService()
                                            .getValue(loggedInAgentId);
                                    landingScreenBloc.add(AssignAgent(
                                        agentId: loggedInUserId,
                                        isStore: true,
                                        index: 0));
                                    setChildState(() {});
                                    Navigator.of(dialogContext).pop();
                                  }),
                            ],
                          );
                        });
                      },
                    );

                    /* await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        if (!kIsWeb)
                          FirebaseAnalytics.instance
                              .setCurrentScreen(screenName: 'GearAdvisorBottomSheet');
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: BlocProvider.value(
                                value: landingScreenBloc,
                                child: StatefulBuilder(
                                  builder: (BuildContext statefulBuilderContext,
                                      void Function(void Function())
                                          statefulBuilderSetState) {
                                    return BlocBuilder<LandingScreenBloc,
                                            LandingScreenState>(
                                        builder: (context, bottomState) {
                                      if (bottomState.landingScreenStatus ==
                                          LandingScreenStatus.success) {
                                        return bottomState.gettingAgentsList!
                                            ? Center(
                                                child: CircularProgressIndicator())
                                            : Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextFormField(
                                                            maxLines: 1,
                                                            cursorColor:
                                                                Theme.of(context).primaryColor,
                                                            onChanged: (value) {
                                                              EasyDebounce
                                                                  .cancelAll();
                                                              if (bottomState
                                                                  .agentList!
                                                                  .isNotEmpty) {
                                                                if (value
                                                                    .trim()
                                                                    .isNotEmpty) {
                                                                  EasyDebounce.debounce(
                                                                      'search_name_debounce',
                                                                      Duration(
                                                                          seconds: 1),
                                                                      () {
                                                                    landingScreenBloc.add(
                                                                        SearchAgentList(
                                                                            searchString:
                                                                                value));
                                                                  });
                                                                } else if (value
                                                                    .trim()
                                                                    .isEmpty) {
                                                                  EasyDebounce.debounce(
                                                                      'search_name_debounce',
                                                                      Duration(
                                                                          seconds: 1),
                                                                      () {
                                                                    landingScreenBloc.add(
                                                                        ClearSearchList());
                                                                  });
                                                                }
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Search by agent name',
                                                              hintStyle: TextStyle(
                                                                color: ColorSystem
                                                                    .secondary,
                                                                fontSize:
                                                                    SizeSystem.size18,
                                                              ),
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: ColorSystem
                                                                      .primary,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: SizeSystem.size20,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: bottomState
                                                              .isSearchAgent!
                                                          ? showAgentList(
                                                              bottomState
                                                                      .searchedAgentList ??
                                                                  [],
                                                              bottomState,
                                                              statefulBuilderSetState)
                                                          : showAgentList(
                                                              bottomState.agentList ??
                                                                  [],
                                                              bottomState,
                                                              statefulBuilderSetState)),
                                                ],
                                              );
                                      } else {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );*/
                  },
                ),
                SizedBox(height: 10),
                Text("Contact Center",
                    style: TextStyle(
                        color: ColorSystem.blueGrey,
                        fontFamily: kRubik,
                        fontSize: 16)),
                AgentTilesWidget(
                  assignedAgent: state.assignedAgent,
                  isStore: false,
                  isAssigning: state.isAssigningCCAgent!,
                  onTapList: () async {},
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: size.height * 0.075,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      } else {
        return SizedBox(
          height: size.height * 0.075,
          child: Center(child: CircularProgressIndicator()),
        );
      }
    });
  }
}
