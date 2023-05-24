import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/bloc/reminder_bloc/reminder_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_reminders.dart';
import 'package:gc_customer_app/models/reminder_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:intl/intl.dart';

class ReminderBottomSheet extends StatefulWidget {
  final AllOpenTasks? reminderModel;
  ReminderBottomSheet({Key? key, this.reminderModel}) : super(key: key);

  @override
  State<ReminderBottomSheet> createState() => _ReminderBottomSheetState();
}

class _ReminderBottomSheetState extends State<ReminderBottomSheet> {
  final format = DateFormat('MMM dd, yyyy');
  TextEditingController textEditingController = TextEditingController();
  late DateTime reminderDate = DateTime.now();
  DateTime selectedDate = DateTime.now(); //Temp
  final StreamController<DateTime> _selectedDateController =
      StreamController<DateTime>.broadcast();
  String alertTitle = 'Call';
  final StreamController<String> _selectedTitleController =
      StreamController<String>.broadcast();
  StreamSubscription? navigatorListener;
  StreamSubscription? reminderBloCListener;

  @override
  void initState() {
    _selectedDateController.sink.add(DateTime.now());
    _selectedTitleController.add('Call');
    if (widget.reminderModel != null) {
      if (!kIsWeb)
        FirebaseAnalytics.instance
            .setCurrentScreen(screenName: 'EditReminderBottomSheet');
      textEditingController.text = widget.reminderModel?.description ?? '';
      _selectedDateController.add(DateTime.parse(
          widget.reminderModel?.activityDate ?? DateTime.now().toString()));
      selectedDate = DateTime.parse(
          widget.reminderModel?.activityDate ?? DateTime.now().toString());
      alertTitle = widget.reminderModel?.subject?.split(' ').first ?? 'Call';
      _selectedTitleController.add(alertTitle);
    } else if (!kIsWeb) {
      // FirebaseAnalytics.instance
      //     .setCurrentScreen(screenName: 'AddReminderBottomSheet');
    }
    if (kIsWeb)
      navigatorListener =
          context.read<NavigatorWebBloC>().selectedTab.listen((event) {
        if (event != 4 && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    reminderBloCListener = context.read<ReminderBloC>().stream.listen((event) {
      if (event.reminderState == ReminderState.successState) {
        Navigator.pop(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _selectedDateController.close();
    _selectedTitleController.close();
    navigatorListener?.cancel();
    reminderBloCListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8.0,
          sigmaY: 8.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraint) => SizedBox(
            height: constraint.maxHeight,
            width: constraint.maxWidth,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Stack(
                children: [
                  closeButton(constraint),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 481,
                        decoration: BoxDecoration(
                          color: ColorSystem.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          children: [
                            title(),
                            noteInputWidgets(constraint),
                            // if (widget.reminderModel == null)
                            doneButton(constraint),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget title() => Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Row(
          children: [
            SvgPicture.asset(
              IconSystem.reminderIcon,
              height: 24,
              package: 'gc_customer_app',
            ),
            SizedBox(width: 8),
            Text(
              '${widget.reminderModel == null ? 'Create ' : ''}Reminder',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget noteInputWidgets(BoxConstraints constraint) {
    Widget titleSelector() => InkWell(
          onTap: () => showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    backgroundColor: Color.fromARGB(242, 242, 242, 242),
                    contentPadding: EdgeInsets.zero,
                    insetPadding:
                        EdgeInsets.symmetric(horizontal: 80, vertical: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    children: [
                      TextButton(
                          onPressed: () {
                            alertTitle = 'Call';
                            _selectedTitleController.add('Call');
                            Navigator.pop(context);
                          },
                          child: Text('Call')),
                      Divider(height: 1),
                      TextButton(
                          onPressed: () {
                            alertTitle = 'Email';
                            _selectedTitleController.add('Email');
                            Navigator.pop(context);
                          },
                          child: Text('Email')),
                    ],
                  )),
          child: Container(
            height: 64,
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorSystem.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Title:',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).primaryColor),
                ),
                StreamBuilder<String>(
                    stream: _selectedTitleController.stream,
                    initialData: alertTitle,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data!,
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontSize: 16),
                      );
                    })
              ],
            ),
          ),
        );

    Widget note() => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 97,
            child: TextField(
              controller: textEditingController,
              cursorColor: ColorSystem.black,
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).primaryColor),
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                hintText: 'Add Reminder Note',
                filled: true,
                fillColor: ColorSystem.white,
              ),
            ),
          ),
        );

    datePicker() => InkWell(
          onTap: () {
            if (reminderDate.isBefore(DateTime.now())) {
              _selectedDateController.sink.add(DateTime.now());
              reminderDate = DateTime.now();
            }

            showModalBottomSheet(
                context: context,
                builder: (context) => SizedBox(
                      height: 300,
                      child: StreamBuilder<DateTime>(
                          stream: _selectedDateController.stream,
                          initialData: reminderDate,
                          builder: (context, snapshot) {
                            return CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              onDateTimeChanged: (date) {
                                _selectedDateController.add(date);
                                reminderDate = date;
                              },
                              initialDateTime: snapshot.data ?? DateTime.now(),
                              minimumDate: (snapshot.data ?? DateTime.now())
                                  .subtract(Duration(milliseconds: 1)),
                            );
                          }),
                    ));
          },
          child: Container(
            height: 64,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorSystem.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Due by:',
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).primaryColor),
                    ),
                    StreamBuilder<DateTime>(
                        stream: _selectedDateController.stream,
                        builder: (context, snapshot) {
                          return Text(
                            format.format(snapshot.data ?? selectedDate),
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(fontSize: 16),
                          );
                        })
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SvgPicture.asset(IconSystem.calendarIcon,
                      package: 'gc_customer_app', height: 24),
                )
              ],
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: ColorSystem.culturedGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          titleSelector(),
          SizedBox(height: 16),
          note(),
          SizedBox(height: 16),
          datePicker(),
        ],
      ),
    );
  }

  Widget doneButton(BoxConstraints constraint) => MaterialButton(
        onPressed: () {
          if (textEditingController.text.isEmpty) {
            showMessage(
                context: context, message: "Please enter a note for reminder");
          } else {
            if (widget.reminderModel == null) {
              context.read<ReminderBloC>().add(SaveReminders(
                  textEditingController.text, reminderDate, alertTitle));
            } else {
              context.read<ReminderBloC>().add(UpdateReminders(
                  textEditingController.text,
                  reminderDate,
                  alertTitle,
                  widget.reminderModel!.id!));
            }
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minWidth: constraint.maxWidth,
        height: 46,
        color: ColorSystem.primaryTextColor,
        child: BlocBuilder<ReminderBloC, ReminderInitial>(
            builder: (context, state) {
          if (state.reminderState == ReminderState.loadState) {
            return CupertinoActivityIndicator(
              color: ColorSystem.white,
            );
          }
          return Text(
            widget.reminderModel == null ? 'DONE' : 'UPDATE',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ColorSystem.white),
          );
        }),
      );

  Widget closeButton(BoxConstraints constraint) => Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: (() => Navigator.pop(context)),
          child: Container(
            alignment: Alignment.topCenter,
            height: constraint.maxHeight - 400,
            width: constraint.maxWidth,
            child: Center(
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorSystem.white,
                ),
                child: Icon(
                  Icons.close,
                  color: ColorSystem.black,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      );
}
