import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/customer_reminder_bloc/customer_reminder_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/screens/reminder/customer_reminder_item_widget.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class CustomerReminderWebPage extends StatefulWidget {
  CustomerReminderWebPage({Key? key}) : super(key: key);

  @override
  State<CustomerReminderWebPage> createState() =>
      _CustomerReminderWebPageState();
}

class _CustomerReminderWebPageState extends State<CustomerReminderWebPage> {
  @override
  void initState() {
    context.read<CustomerReminderBloc>().add(LoadReminderData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    var theme = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        drawer:
            widthOfScreen.isMobileWebDevice() ? DrawerLandingWidget() : null,
        backgroundColor: ColorSystem.webBackgr,
        appBar: AppBar(
          backgroundColor: ColorSystem.webBackgr,
          centerTitle: true,
          title: Text(customerRemindertxt.toUpperCase(),
              style: TextStyle(
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: 15)),
        ),
        body: BlocBuilder<CustomerReminderBloc, CustomerReminderState>(
            builder: (context, state) {
          if (state is CustomerReminderProgress) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is CustomerReminderSuccess &&
              (state.reminders.allOpenTasks ?? []).isNotEmpty) {
            var reminders = state.reminders.allOpenTasks!;
            return ListView(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  // padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorSystem.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ColorSystem.blue1.withOpacity(0.15),
                        blurRadius: 12.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: reminders.map<Widget>((task) {
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        child: CustomerReminderItemWidget(
                            reminderModel: task,
                            widthOfScreen: constraints.maxWidth),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
          return Container(
              height: double.infinity,
              width: double.infinity,
              color: ColorSystem.white,
              child: Center(child: NoDataFound(fontSize: 14)));
        }),
      );
    });
  }
}
