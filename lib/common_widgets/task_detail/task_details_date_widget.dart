import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/common_widgets/task_detail/agent_popup.dart';
import 'package:gc_customer_app/models/landing_screen/agent_list.dart';
import 'package:gc_customer_app/models/task_detail_model/agent_info.dart';
import 'package:gc_customer_app/models/task_detail_model/store.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/set_time_zone.dart';
import 'package:intl/intl.dart';

import '../../models/task_detail_model/agent.dart';

class TaskDetailsDateWidget extends StatefulWidget {
  TaskDetailsDateWidget({
    Key? key,
    this.showModifiedBy = true,
    required this.task,
    required this.assignedToName,
    required this.customerId,
    required this.ownerId,
    required this.modifiedByName,
    required this.dueByDate,
    required this.modifiedDate,
    required this.lastModifiedById,
  }) : super(key: key);

  final TaskModel task;
  final String assignedToName;
  final String modifiedByName;
  final String dueByDate;
  final String customerId;
  final String ownerId;
  final String modifiedDate;
  final String lastModifiedById;
  final bool showModifiedBy;

  @override
  State<TaskDetailsDateWidget> createState() => _TaskDetailsDateWidgetState();
}

class _TaskDetailsDateWidgetState extends State<TaskDetailsDateWidget>
    with AutomaticKeepAliveClientMixin {
  String dueDate = '';
  String lastModifiedDate = '';
  String assigneeName = '';
  String assigneeId = '';
  late DateTime selectedDate;
  late Future<void> futureAgents;
  late Future<void> futureAgentProfile;
  late Future<void> futureStores;
  Agent? agent;
  List<AgentList> agents = [];
  List<AgentList> searchedAgentList = [];
  List<Store> stores = [];
  List<Store> searchedStoreList = [];
  bool showingStores = false;
  bool hasSearched = false;
  bool isChanged = false;
  String? updatedModifier = '';
  String? updatedDate = '';

  Future<void> getFutureStores() async {
    var response = await HttpService().doGet(path: Endpoints.getStoreList());
    if (response.data != null) {
      for (var storeJson in response.data['Groups']) {
        stores.add(Store.fromJson(storeJson));
      }
    }
  }

  void onStoreClicked(int index, List<Store> storeList) async {
    assigneeId = storeList[index].id;
    assigneeName = storeList[index].name ?? 'Store';
    if (assigneeId.isNotEmpty) {
      await updateTaskAssignee();
      Navigator.of(context).pop();
    }
    setState(() {});
  }

  Future<void> getAgentProfile() async {
    var response = await HttpService().doPost(
        path: Endpoints.getAgentProfile(),
        body: RequestBody.getAgentProfileBody(id: widget.lastModifiedById));

    dev.log(jsonEncode(response.data));
    if (response.data != null) {
      agent = Agent.fromJson(response.data['UserList'][0]['User']);
    }
  }

  Future<void> getFutureAgents() async {
    var recordID = await SharedPreferenceService().getValue(agentId);
    String userId = await SharedPreferenceService().getValue(loggedInAgentId);
    if (recordID != null) {
      var response = await HttpService()
          .doGet(path: Endpoints.getAssignedAgentList(recordID, userId));
      if (response.data != null) {
        for (var agentJson in response.data['AgentList']) {
          agents.add(AgentList.fromJson(agentJson));
        }
      }
    }
  }

  Future<void> updateTaskDate() async {
    var loogedInUserId = await SharedPreferenceService().getValue(agentId);
    var response = await HttpService().doPost(
        path: Endpoints.postTaskDetails(widget.task.id!),
        body: RequestBody.getUpdateTaskBody(
          recordId: widget.task.id!,
          feedbackDateTime: "",
          feedback: "",
          dueDate: DateFormat('yyyy-MM-dd').format(selectedDate),
          loggedinUserId: loogedInUserId,
        ));
    if (response.data != null) {
      setState(() {
        isChanged = true;
        updatedDate = DateFormat('MMM dd, yyyy').format(
            DateTime.parse(response.data['task']?['LastModifiedDate'])
                .toESTZone());
        updatedModifier = response.data['task']?['LastModifiedBy']?['Name'];
      });
    }
  }

  Future<void> updateTaskAssignee() async {
    var loogedInUserId = await SharedPreferenceService().getValue(agentId);
    var response = await HttpService().doPost(
      path: Endpoints.postTaskDetails(widget.task.id!),
      body: RequestBody.getUpdateTaskBody(
        recordId: widget.task.id!,
        assignee: assigneeId,
        feedback: "",
        feedbackDateTime: "",
        loggedinUserId: loogedInUserId,
      ),
    );
    if (response.data != null) {
      setState(() {
        isChanged = true;
        updatedDate = DateFormat('MMM dd, yyyy').format(
            DateTime.parse(response.data['task']?['LastModifiedDate'])
                .toESTZone());
        updatedModifier = response.data['task']?['LastModifiedBy']?['Name'];
      });
    }
  }

  void onTaskAssigneeClicked(
      int index, List<AgentList> agentList, parentState) async {
    assigneeName = agentList[index].name ?? '--';
    if (agentList[index].id != null) {
      assigneeId = agentList[index].id!;
    }

    if (assigneeId.isNotEmpty) {
      await updateTaskAssignee();
      parentState(() {
        agentList[index].isAssigning = false;
      });

      searchedAgentList.clear();
      Navigator.of(context).pop();
    }
  }

  void onAgentSearch(String idOrName) {
    searchedAgentList.clear();
    hasSearched = true;
    if (idOrName.trim().isEmpty) {
      return;
    }
    for (var agent in agents) {
      if (agent.name != null) {
        var agentName = agent.name!.toLowerCase();
        var searchedNameString = idOrName.toLowerCase();
        if (agentName.contains(searchedNameString)) {
          var searchedStringList = searchedNameString.split('');
          var nameStringList = agentName.split('');
          for (var i = 0; i < searchedStringList.length; i++) {
            if (nameStringList.elementAt(i) ==
                searchedStringList.elementAt(i)) {
              if (searchedAgentList.contains(agent)) {
                return;
              } else {
                searchedAgentList.add(agent);
              }
            }
          }
        }
      }
      if (agent.employeeNumber != null) {
        var agentId = agent.employeeNumber!.toLowerCase();
        var searchedIdString = idOrName.toLowerCase();
        if (agentId.contains(searchedIdString)) {
          var searchedStringList = searchedIdString.split('');
          var nameStringList = agentId.split('');
          for (var i = 0; i < searchedStringList.length; i++) {
            if (nameStringList.elementAt(i) ==
                searchedStringList.elementAt(i)) {
              if (searchedAgentList.contains(agent)) {
                return;
              } else {
                searchedAgentList.add(agent);
              }
            }
          }
        }
      }
    }
  }

  void onStoreSearch(String name) {
    searchedStoreList.clear();
    if (name.trim().isEmpty) {
      return;
    }
    for (var store in stores) {
      if (store.name!.contains(name)) {
        searchedStoreList.add(store);
      }
    }
  }

  Widget showAgentList(List<AgentList> agents, parentState) {
    return hasSearched && searchedAgentList.isEmpty
        ? Text(
            'No data found',
            style: TextStyle(
                fontFamily: kRubik,
                fontSize: SizeSystem.size16,
                color: Theme.of(context).primaryColor),
          )
        : ListView.separated(
            itemCount: agents.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () async {
                  await showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return StatefulBuilder(builder: (context, setChildState) {
                        return CupertinoAlertDialog(
                          title: Text(
                            'Assign Action',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                              'Assigning this action to ${agents[index].name}'),
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
                                  'Assign',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  parentState(() {
                                    agents[index].isAssigning = true;
                                  });

                                  onTaskAssigneeClicked(
                                      index, agents, parentState);
                                  Navigator.of(dialogContext).pop();
                                }),
                          ],
                        );
                      });
                    },
                  );
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agents[index].name ?? '--',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: SizeSystem.size18,
                              fontFamily: kRubik,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            agents[index].employeeNumber ?? '--',
                            style: TextStyle(
                              color: ColorSystem.greyDark,
                              fontSize: SizeSystem.size15,
                              fontFamily: kRubik,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: ColorSystem.lavender),
                            borderRadius:
                                BorderRadius.circular(SizeSystem.size6)),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: agents[index].isAssigning!
                              ? CupertinoActivityIndicator(
                                  color: ColorSystem.lavender3)
                              : Text(
                                  "Assign",
                                  style: TextStyle(
                                    color: ColorSystem.lavender3,
                                    fontSize: SizeSystem.size14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: kRubik,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                height: 2,
                color: Colors.grey.withOpacity(0.3),
              );
            },
          );
  }

  Widget showStoresList(List<Store> stores) {
    return ListView.separated(
      itemCount: stores.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () async {
            await showCupertinoDialog(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text(
                    'Assign Action',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content:
                      Text('Assigning this action to ${stores[index].name}'),
                  actions: [
                    CupertinoButton(
                        child: Text(
                          'Cancel',
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    CupertinoButton(
                        child: Text(
                          'Assign',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          onStoreClicked(index, stores);
                          searchedStoreList.clear();
                          Navigator.of(context).pop();
                        }),
                  ],
                );
              },
            );
          },
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Text(
              stores[index].name ?? '--',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: SizeSystem.size18,
                fontFamily: kRubik,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: double.maxFinite,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          height: 2,
          color: Colors.grey.withOpacity(0.3),
        );
      },
    );
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

//  DateTimeExtension dateTimeExtension = DateTimeExtension();
  @override
  initState() {
    super.initState();
    getAgentProfile();
    if (widget.task.status != 'Completed' && widget.showModifiedBy) {
      if (showingStores) {
        futureStores = getFutureStores();
      } else {
        futureAgents = getFutureAgents();
      }
    }
    assigneeName = widget.assignedToName;

    dueDate = formatDateLarge(widget.dueByDate);
    if (lastModifiedDate != '--') {
      lastModifiedDate = formatDateLarge(widget.modifiedDate);
    }
    selectedDate = widget.dueByDate == "--"
        ? DateTime.now()
        : DateTime.parse(widget.dueByDate);
  }

  String formatDateLarge(String date) {
    try {
      DateTime dateTime =
          DateTime.parse(date.replaceAll("T", " ").replaceAll(".000Z", ""));
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } on FormatException {
      return 'Date not available';
    } catch (e) {
      return 'Date not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    "Assigned to:",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: SizeSystem.size12,
                        fontFamily: kRubik,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 4.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        InkWell(
                            onTap:
                                widget.task.status != 'Completed' &&
                                        widget.showModifiedBy
                                    ? () async {
                                        if (widget.customerId ==
                                            widget.ownerId) {
                                          if (widget.task.status !=
                                                  'Completed' &&
                                              widget.showModifiedBy) {
                                            if (showingStores) {
                                              futureStores = getFutureStores();
                                            } else {
                                              futureAgents = getFutureAgents();
                                            }
                                          }

                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 10),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: StatefulBuilder(
                                                      builder: (BuildContext
                                                              statefulBuilderContext,
                                                          void Function(
                                                                  void
                                                                      Function())
                                                              statefulBuilderSetState) {
                                                        return Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                      maxLines:
                                                                          1,
                                                                      cursorColor:
                                                                          ColorSystem
                                                                              .primary,
                                                                      onChanged:
                                                                          (value) {
                                                                        if (value
                                                                            .isNotEmpty) {
                                                                          if (showingStores) {
                                                                            onStoreSearch(value);
                                                                          } else {
                                                                            onAgentSearch(value);
                                                                          }
                                                                          statefulBuilderSetState(
                                                                              () {});
                                                                        } else if (value
                                                                            .isEmpty) {
                                                                          hasSearched =
                                                                              false;
                                                                          searchedAgentList
                                                                              .clear();
                                                                          searchedStoreList
                                                                              .clear();
                                                                          statefulBuilderSetState(
                                                                              () {});
                                                                        }
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            'Search by Name or ID',
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              ColorSystem.secondary,
                                                                          fontSize:
                                                                              SizeSystem.size18,
                                                                        ),
                                                                        focusedBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                ColorSystem.primary,
                                                                            width:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: SizeSystem
                                                                        .size20,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  FutureBuilder(
                                                                future: showingStores
                                                                    ? futureStores
                                                                    : futureAgents,
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            dynamic>
                                                                        snapshot) {
                                                                  switch (snapshot
                                                                      .connectionState) {
                                                                    case ConnectionState
                                                                        .none:
                                                                    case ConnectionState
                                                                        .waiting:
                                                                    case ConnectionState
                                                                        .active:
                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color:
                                                                              ColorSystem.primary,
                                                                        ),
                                                                      );

                                                                    case ConnectionState
                                                                        .done:
                                                                      if (showingStores) {
                                                                        return searchedStoreList.isNotEmpty
                                                                            ? showStoresList(searchedStoreList)
                                                                            : showStoresList(stores);
                                                                      } else {
                                                                        return searchedAgentList.isNotEmpty
                                                                            ? showAgentList(searchedAgentList,
                                                                                statefulBuilderSetState)
                                                                            : showAgentList(agents,
                                                                                statefulBuilderSetState);
                                                                      }
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then((value) {
                                            hasSearched = false;
                                            searchedAgentList.clear();
                                            searchedStoreList.clear();
                                            setState(() {});
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar(
                                                  "This task is not assigned to you"));
                                        }
                                      }
                                    : null,
                            child: Text(
                              assigneeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.showModifiedBy
                                    ? ColorSystem.lavender3
                                    : Theme.of(context).primaryColor,
                                fontSize: SizeSystem.size12,
                                fontFamily: kRubik,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                        SizedBox(
                          width: 8,
                        ),
                        Transform.rotate(
                          angle: -pi / 2,
                          child: SvgPicture.asset(
                            IconSystem.back,
                            package: 'gc_customer_app',
                            height: 12,
                            width: 16,
                            color: ColorSystem.lavender3,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Text(
                    "Modified by:",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: SizeSystem.size12,
                        fontFamily: kRubik,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              if (widget.showModifiedBy)
                InkWell(
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: agent != null
                      ? () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AgentPopup(
                                agent: agent!,
                              );
                            },
                          );
                        }
                      : null,
                  child: Text.rich(
                    TextSpan(
                      text: isChanged ? updatedModifier : widget.modifiedByName,
                      style: TextStyle(
                          color: ColorSystem.lavender3,
                          fontSize: SizeSystem.size12,
                          fontFamily: kRubik,
                          fontWeight: FontWeight.w600),
                      children: <InlineSpan>[
                        TextSpan(
                          text: ' | ',
                          style: TextStyle(
                              color: Color(0xff2D3142),
                              fontSize: SizeSystem.size12,
                              fontFamily: kRubik,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: isChanged ? updatedDate : lastModifiedDate,
                          style: TextStyle(
                              color: Color(0xff2D3142),
                              fontSize: SizeSystem.size12,
                              fontFamily: kRubik,
                              fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  // ignore: todo
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
