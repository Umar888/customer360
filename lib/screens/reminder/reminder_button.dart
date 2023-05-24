import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/customer_reminder_bloc/customer_reminder_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

import '../../primitives/size_system.dart';
import 'reminder_bottom_sheet.dart';

class ReminderButton extends StatelessWidget {
  final LandingScreenBloc landingScreenBloc;
  ReminderButton({super.key, required this.landingScreenBloc});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierColor: Color.fromARGB(25, 92, 106, 196),
              isScrollControlled: true,
              builder: (context) {
                return ReminderBottomSheet();
              },
            ).then((value) {
              context
                  .read<CustomerReminderBloc>()
                  .add(LoadReminderReloadData());
            }),
        child: Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.04),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: SizeSystem.size16,
                color: ColorSystem.lavender3,
              ),
              SizedBox(
                width: 3,
              ),
              Text(
                "Reminder".toUpperCase(),
                style: TextStyle(
                    fontSize: SizeSystem.size17,
                    fontFamily: kRubik,
                    fontWeight: FontWeight.w600,
                    color: ColorSystem.lavender3),
              )
            ],
          ),
        ));
  }
}
