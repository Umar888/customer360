import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/add_commission_bloc.dart';
import 'package:gc_customer_app/models/add_commission_model/commissions_employee_model.dart';
import 'package:gc_customer_app/models/add_commission_model/search_employee_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class EmployeeItemWidget extends StatelessWidget {
  final SearchedEmployeeModel employee;

  final bool isSelected;
  EmployeeItemWidget(
      {Key? key, required this.employee, this.isSelected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var addCommissionBloc = context.read<AddCommissionBloc>();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      title: Text('${employee.name} - ${employee.employeeNumber}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: isSelected
                ? ColorSystem.lavender3
                : Theme.of(context).primaryColor,
            fontFamily: kRubik,
          )),
      trailing: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color:
              isSelected ? ColorSystem.lavender3 : Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              addCommissionBloc
                  .add(ListSelectedEmployeesAdd(employee: employee));
            }
          },
          child: Center(
            child: Icon(
              isSelected ? Icons.check : Icons.add,
              color: ColorSystem.white,
            ),
          ),
        ),
      ),
    );
  }
}
