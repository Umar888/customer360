import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/add_commission_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/custom_tab_bar_digital.dart';
import 'package:gc_customer_app/models/add_commission_model/create_commission_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class EmployeeCommissionWidget extends StatefulWidget {
  final CommissionEmployee employee;
  final bool canRemove;
  final Function(double) onSelected;
  EmployeeCommissionWidget(
      {Key? key,
      required this.employee,
      required this.onSelected,
      this.canRemove = true})
      : super(key: key);

  @override
  State<EmployeeCommissionWidget> createState() =>
      _EmployeeCommissionWidgetState();
}

class _EmployeeCommissionWidgetState extends State<EmployeeCommissionWidget>
    with TickerProviderStateMixin {
  late TabController tabController;
  TextEditingController commissionTEC = TextEditingController();
  List<double> listPercentage = [];
  List<double> listPercentageOneTime = [
    0,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
    60,
    65,
    70,
    75,
    80,
    85,
    90,
    95,
    100
  ];

  @override
  void initState() {
    super.initState();
    // commissionTEC.text =
    //     (widget.employee.employeeCommission ?? 0).round().toString();
    for (var i = 0; i < 5; i++) {
      listPercentage.addAll(listPercentageOneTime);
    }
    // int initTabIndex = listPercentage
    //         .indexWhere((e) => e == widget.employee.employeeCommission) +
    //     210;
    tabController = TabController(length: listPercentage.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    commissionTEC.text =
        (widget.employee.employeeCommission ?? 0).round().toString();
    var commission = widget.employee.employeeCommission ?? 0;
    if (listPercentage.any((e) => e % 5 != 0)) {
      var index = listPercentage.indexWhere((e) => e % 5 != 0);
      listPercentage.removeAt(index);
      listPercentage.add(listPercentage.last + 5);
    }
    if (commission % 5 == 0) {
      int initTabIndex = listPercentage
              .indexWhere((e) => e == widget.employee.employeeCommission) +
          43;
      listPercentage.removeWhere((e) => e % 5 != 0);

      tabController.animateTo(initTabIndex - 1);
    } else {
      var a = (commission / 5).floor();
      int initTabIndex = a + 43 + 1;
      listPercentage.removeLast();
      listPercentage.insert(initTabIndex - 1, commission);
      listPercentage[initTabIndex - 1] = commission.toDouble();
      tabController.animateTo(initTabIndex - 1);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.employee.employeeName!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontFamily: kRubik)),
              if (widget.canRemove)
                InkWell(
                  onTap: () {
                    context.read<AddCommissionBloc>().add(
                        ListSelectedEmployeesRemove(
                            selectedEmployeeModel: widget.employee));
                  },
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: ColorSystem.pureRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "-",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: kRubik),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        Row(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: commissionTEC,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).primaryColor,
                  fontFamily: kRubik,
                ),
                cursorColor: ColorSystem.black,
                maxLength: 3,
                decoration: InputDecoration(counter: SizedBox.shrink()),
                onChanged: (value) {
                  widget.onSelected(double.parse(value));
                  // setState(() {
                  widget.employee.employeeCommission = double.parse(value);
                  // });
                },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 70,
            child: CustomTabBarExtendedDigital(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 60,
              containerColor: ColorSystem.greyDark.withOpacity(0.08),
              onTap: (index) {
                widget.onSelected(listPercentage[index]);
                setState(() {
                  widget.employee.employeeCommission = listPercentage[index];
                });
              },
              containerBorderRadius: 20.0,
              tabBorderRadius: 10.0,
              tabs: listPercentage.map<String>((e) {
                // bool isInt = e % 1 == 0;
                String value = e.toString();
                if (listPercentage[tabController.index] == e) value = '$value%';
                // if (isInt)
                value = value.replaceAll('.0', '');
                return value;
              }).toList(),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(0.0, 4.0),
                  blurRadius: 5,
                )
              ],
              tabController: tabController,
              tabColor: Colors.white,
              labelColor: Colors.black,
              unSelectLabelColor: ColorSystem.greyDark,
            ),
          )
        ]),
        SizedBox(height: 15),
        Divider(
            color: ColorSystem.greyDark, height: 1, endIndent: 26, indent: 26),
      ],
    );
  }
}
