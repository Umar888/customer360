import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/utils/utils_functions.dart';
import '../../models/task_detail_model/agent.dart';
import '../../primitives/size_system.dart';

class AgentPopup extends StatelessWidget {
  final Agent agent;

  AgentPopup({
    Key? key,
    required this.agent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          padding: EdgeInsets.symmetric(
            vertical: SizeSystem.size16,
            horizontal: SizeSystem.size16,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeSystem.size16)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: SizeSystem.size10,
                      ),
                      Text(
                        agent.name ?? '--',
                        style: TextStyle(
                          fontFamily: kRubik,
                          color: Theme.of(context).primaryColor,
                          fontSize: SizeSystem.size16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: SizeSystem.size10,
                      ),
                      Text(
                        agent.storeName ?? '--',
                        style: TextStyle(
                          fontFamily: kRubik,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff2D3142),
                          fontSize: SizeSystem.size12,
                        ),
                      ),
                      SizedBox(
                        height: SizeSystem.size10,
                      ),
                      Text(
                        agent.profileName ?? '--',
                        style: TextStyle(
                          fontFamily: kRubik,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff2D3142),
                          fontSize: SizeSystem.size12,
                        ),
                      ),
                      SizedBox(
                        height: SizeSystem.size10,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            IconSystem.phone,
                            package: 'gc_customer_app',
                            height: SizeSystem.size20,
                            width: SizeSystem.size20,
                          ),
                          SizedBox(
                            width: SizeSystem.size6,
                          ),
                          InkWell(
                            onTap: agent.phone != null
                                ? () {
                                    makephoneCall(agent.phone!);
                                  }
                                : null,
                            child: Text(
                              agent.phone ?? '--',
                              style: TextStyle(
                                fontFamily: kRubik,
                                fontWeight: agent.phone != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                color: agent.phone != null
                                    ? ColorSystem.lavender3
                                    : Color(0xff2D3142),
                                fontSize: SizeSystem.size12,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: SizeSystem.size10,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            IconSystem.mail,
                            package: 'gc_customer_app',
                            height: SizeSystem.size16,
                            width: SizeSystem.size16,
                          ),
                          SizedBox(
                            width: SizeSystem.size6,
                          ),
                          SizedBox(width: SizeSystem.size6),
                          Text(
                            agent.email ?? '--',
                            style: TextStyle(
                              fontFamily: kRubik,
                              color: Color(0xff2D3142),
                              fontWeight: FontWeight.normal,
                              fontSize: SizeSystem.size12,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
