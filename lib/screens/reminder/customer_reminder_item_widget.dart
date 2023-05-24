import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/customer_reminder_bloc/customer_reminder_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/reminder_bloc/reminder_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_reminders.dart';
import 'package:gc_customer_app/models/reminder_model.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/reminder/reminder_bottom_sheet.dart';
import 'package:intl/intl.dart';

class CustomerReminderItemWidget extends StatelessWidget {
  final AllOpenTasks reminderModel;
  final double widthOfScreen;
  CustomerReminderItemWidget(
      {Key? key, required this.reminderModel, required this.widthOfScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM dd, yyyy');
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 14, right: 10, left: 5),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Color.fromARGB(25, 92, 106, 196),
          isScrollControlled: true,
          builder: (context) {
            return ReminderBottomSheet(
              reminderModel: reminderModel,
            );
          },
        ).then((value) {
          // context.read<LandingScreenBloc>().add(ReloadReminders());
          context.read<CustomerReminderBloc>().add(LoadReminderReloadData());
        }),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    IconSystem.notificationAlert,
                    package: 'gc_customer_app',
                  ),
                  SizedBox(
                    width: widthOfScreen * 0.05,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${reminderModel.subject}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        SizedBox(height: 4),
                        Text(
                          format.format(DateTime.parse(
                              reminderModel.activityDate ??
                                  DateTime.now().toString())),
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: widthOfScreen * 0.02),
              child: SvgPicture.asset(
                IconSystem.gotoArrow,
                package: 'gc_customer_app',
              ),
            )
          ],
        ),
      ),
    );
  }
}
