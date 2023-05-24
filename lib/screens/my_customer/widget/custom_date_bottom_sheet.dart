import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:intl/intl.dart';

import '../../../primitives/color_system.dart';

class CustomDateBottomSheet extends StatefulWidget {
  CustomDateBottomSheet({Key? key}) : super(key: key);

  @override
  State<CustomDateBottomSheet> createState() => _CustomDateBottomSheetState();
}

class _CustomDateBottomSheetState extends State<CustomDateBottomSheet> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 14, vertical: 30).copyWith(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom Date',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: kRubik),
              ),
              CloseButton(),
            ],
          ),
          TextFormField(
            autofocus: false,
            cursorColor: Theme.of(context).primaryColor,
            readOnly: true,
            controller: startDateController,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w400,
                fontSize: 16),
            keyboardType: TextInputType.datetime,
            onTap: () => _selectedDatePopup(startDateController, true),
            decoration: InputDecoration(
              labelText: 'Start Date',
              constraints: BoxConstraints(),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              labelStyle: TextStyle(
                color: ColorSystem.greyDark,
                fontSize: 18,
              ),
              suffixIcon: InkWell(
                onTap: () {
                  _selectedDatePopup(startDateController, true);
                },
                child: Padding(
                  padding: EdgeInsets.all(12.5),
                  child: SvgPicture.asset(
                    IconSystem.calendar,
                    package: 'gc_customer_app',
                    color: ColorSystem.lavender3,
                  ),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.greyDark,
                  width: 1,
                ),
              ),
              errorStyle: TextStyle(
                  color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.lavender3,
                  width: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            autofocus: false,
            cursorColor: Theme.of(context).primaryColor,
            readOnly: true,
            controller: endDateController,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w400,
                fontSize: 16),
            keyboardType: TextInputType.datetime,
            onTap: () => _selectedDatePopup(endDateController, false),
            decoration: InputDecoration(
              labelText: 'End Date',
              constraints: BoxConstraints(),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              labelStyle: TextStyle(
                color: ColorSystem.greyDark,
                fontSize: 18,
              ),
              suffixIcon: InkWell(
                onTap: () async {
                  _selectedDatePopup(endDateController, false);
                },
                child: Padding(
                  padding: EdgeInsets.all(12.5),
                  child: SvgPicture.asset(
                    IconSystem.calendar,
                    package: 'gc_customer_app',
                    color: ColorSystem.lavender3,
                  ),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.greyDark,
                  width: 1,
                ),
              ),
              errorStyle: TextStyle(
                  color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.lavender3,
                  width: 1,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 22,
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
              onPressed: () {
                if (startDateController.text.isEmpty ||
                    endDateController.text.isEmpty) {
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).pop([
                    DateTime.parse(startDateController.text),
                    DateTime.parse(endDateController.text)
                  ]);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: kRubik,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _selectedDatePopup(TextEditingController controller, bool isStart) {
    return showCupertinoModalPopup(
      filter: ImageFilter.blur(
        sigmaX: 4.0,
        sigmaY: 4.0,
      ),
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = controller.text.isEmpty
            ? DateTime.now()
            : DateTime.parse(controller.text);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  minimumDate: DateTime(
                    2018,
                    1,
                    1,
                  ),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (val) {
                    selectedDate = val;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 22,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).primaryColor,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      controller.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        child: Text(
                          'Select',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: kRubik,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
