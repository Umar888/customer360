import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/models/landing_screen/assigned_agent.dart';
import 'package:gc_customer_app/primitives/constants.dart';

import '../constants/colors.dart';
import '../primitives/color_system.dart';
import '../primitives/icon_system.dart';

class AgentTilesWidget extends StatelessWidget {
  AgentTilesWidget({
    Key? key,
    required this.onTapList,
    required this.isStore,
    required this.isAssigning,
    required this.assignedAgent,
  }) : super(key: key);

  final AssignedAgent? assignedAgent;
  final void Function() onTapList;
  final bool isStore;
  final bool isAssigning;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var initialName = '';
    if (assignedAgent?.agentStore != null &&
        (assignedAgent!.agentStore!.name ?? '').isNotEmpty) {
      if (isStore && (assignedAgent!.agentStore?.name ?? '').isNotEmpty) {
        if (assignedAgent!.agentStore!.name?.trim().contains(' ') == false) {
          initialName = assignedAgent!.agentStore!.name![0];
        } else {
          initialName =
              '${assignedAgent!.agentStore!.name![0]}${assignedAgent!.agentStore!.name!.split(' ').last[0]}';
        }
      } else if ((assignedAgent!.agentCC?.name ?? '').isNotEmpty) {
        if (assignedAgent!.agentCC?.name?.trim().contains(' ') == false) {
          initialName = assignedAgent!.agentCC!.name![0];
        } else {
          initialName =
              '${assignedAgent!.agentCC!.name![0]}${assignedAgent!.agentCC!.name!.split(' ').last[0]}';
        }
      }
    }
    if (isStore) {
      return InkWell(
        onTap: (assignedAgent != null && assignedAgent!.agentStore != null) ||
                kIsWeb
            ? null
            : onTapList,
        child: ListTile(
          contentPadding:
              EdgeInsets.only(left: 0.0, right: size.width * 0.03, top: 0),
          leading: assignedAgent != null && assignedAgent!.agentStore != null
              ? Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorSystem.lavender.withOpacity(0.8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initialName.toUpperCase(),
                    style: TextStyle(
                        fontFamily: kRubik,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                )
              : Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: AppColors.greybackgroundContainer,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: isAssigning
                          ? CupertinoActivityIndicator()
                          : !isStore
                              ? Text("--")
                              : SvgPicture.asset(
                                  IconSystem.addIcon,
                                  package: 'gc_customer_app',
                                  color: Theme.of(context).primaryColor,
                                ),
                    ),
                  ),
                ),
          title: Text(
            assignedAgent != null && assignedAgent!.agentStore != null
                ? assignedAgent!.agentStore!.name!
                : "Assign to yourself",
            style: TextStyle(
                fontFamily: kRubik,
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            assignedAgent != null && assignedAgent!.agentStore != null
                ? assignedAgent!.agentStore!.employeeNumber ?? ''
                : "Unassigned",
            style: TextStyle(fontFamily: kRubik, color: Colors.black87),
          ),
          trailing: kIsWeb ||
                  (assignedAgent != null && assignedAgent!.agentStore != null)
              ? null
              : SvgPicture.asset(IconSystem.gotoArrow,
                  package: 'gc_customer_app', width: 30, height: 30),
        ),
      );
    } else {
      return InkWell(
        onTap: null,
        child: ListTile(
          contentPadding:
              EdgeInsets.only(left: 0.0, right: size.width * 0.03, top: 0),
          leading: assignedAgent != null && assignedAgent!.agentCC != null
              ? Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorSystem.lavender.withOpacity(0.8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initialName,
                    style: TextStyle(
                        fontFamily: kRubik,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                )
              : Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: AppColors.greybackgroundContainer,
                  ),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: isAssigning
                            ? CupertinoActivityIndicator()
                            : Text("--")),
                  ),
                ),
          title: Text(
            assignedAgent != null && assignedAgent!.agentCC != null
                ? assignedAgent!.agentCC!.name!
                : "Unassigned",
            style: TextStyle(
                fontFamily: kRubik,
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            assignedAgent != null && assignedAgent!.agentCC != null
                ? assignedAgent!.agentCC!.email ?? ''
                : "Advisor not assigned",
            style: TextStyle(fontFamily: kRubik, color: Colors.black87),
          ),
          trailing: kIsWeb || !isStore
              ? null
              : SvgPicture.asset(IconSystem.gotoArrow,
                  package: 'gc_customer_app', width: 30, height: 30),
        ),
      );
    }
  }
}
