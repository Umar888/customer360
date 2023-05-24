import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/customer_reminder_bloc/customer_reminder_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/reminder/customer_reminder_item_widget.dart';

class CustomerReminderWidget extends StatefulWidget {
  CustomerReminderWidget({Key? key}) : super(key: key);

  @override
  State<CustomerReminderWidget> createState() => _CustomerReminderWidgetState();
}

class _CustomerReminderWidgetState extends State<CustomerReminderWidget> {
  @override
  void initState() {
    context.read<CustomerReminderBloc>().add(LoadReminderData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerReminderBloc, CustomerReminderState>(
        builder: (context, state) {
      if (state is CustomerReminderSuccess &&
          (state.reminders.allOpenTasks ?? []).isNotEmpty) {
        var reminder = state.reminders.allOpenTasks!;
        reminder.sort(
          (a, b) => DateTime.parse(b.activityDate ?? DateTime.now().toString())
                  .isAfter(DateTime.parse(
                      a.activityDate ?? DateTime.now().toString()))
              ? 1
              : 0,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerRemindertxt,
              style: TextStyle(
                  color: ColorSystem.blueGrey,
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            SizedBox(height: 10),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reminder
                    .map<Widget>((reminder) => BlocProvider.value(
                          value: context.read<CustomerReminderBloc>(),
                          child: CustomerReminderItemWidget(
                              reminderModel: reminder,
                              widthOfScreen: MediaQuery.of(context).size.width),
                        ))
                    .toList()),
            SizedBox(height: 25),
          ],
        );
      }
      if (state is CustomerReminderProgress) {
        return Center(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: CircularProgressIndicator(),
        ));
      }
      return SizedBox(
          // height: MediaQuery.of(context).size.height * 0.15,
          //     child: Center(child: Text(" No Reminders by Customer")),
          );
    });
  }
}
