import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/search_employees_bloc/search_employees_bloc.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/models/add_commission_model/create_commission_model.dart';
import 'package:gc_customer_app/screens/add_commission/commission_log_screen.dart';
import 'package:gc_customer_app/screens/add_commission/employee_commission_widget.dart';
import 'package:gc_customer_app/screens/add_commission/employee_item_widget.dart';
import 'package:intl/intl.dart';

import '../../bloc/add_commission_bloc/add_commission_bloc.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/padding_system.dart';
import '../../primitives/size_system.dart';
import '../cart/views/search_commision_employees.dart';

class AddCommissionList extends StatefulWidget {
  final String orderId;
  final String orderNumber;
  final String orderDate;
  final String userName;
  final String userId;

  AddCommissionList(
      {required this.userId,
      required this.orderNumber,
      required this.orderId,
      required this.orderDate,
      required this.userName,
      Key? key})
      : super(key: key);

  @override
  State<AddCommissionList> createState() => _AddCommissionListState();
}

class _AddCommissionListState extends State<AddCommissionList> {
  late AddCommissionBloc addCommissionBloc;

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  @override
  initState() {
    super.initState();
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'AddCommissionOrderScreen');
    addCommissionBloc = context.read<AddCommissionBloc>();
    // searchEmployeesBloc.add(GetDefaultEmployees(orderId: widget.orderId));
    addCommissionBloc.add(PageLoad(widget.orderId));
    // addCommissionBloc.add(PageLoad());
  }

  Widget getAppBar(AddCommissionState state) {
    return Padding(
      padding: EdgeInsets.only(left: PaddingSystem.padding20, right: 8, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: SizeSystem.size28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                // state.listSelectedEmployees.isEmpty
                //     ? Container()
                //     : InkWell(
                //         onTap: () {
                //           addCommissionBloc.add(ChangeShowDel(
                //               showDel: state.showDel ? false : true));
                //         },
                //         child: Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 20.0),
                //           child: SvgPicture.asset(IconSystem.deleteTrash,
                //               color: Theme.of(context).primaryColor),
                //         ),
                //       ),
              ],
            ),
          ),
          Text('ADD COMMISSION',
              style: TextStyle(
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  fontSize: 15)),
          state.addCommissionStatus == AddCommissionStatus.failedState
              ? SizedBox.shrink()
              : SizedBox(
                  width: MediaQuery.of(context).size.width * 0.26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: addCommissionBloc,
                                    child: CommissionLogScreen(
                                      orderId: widget.orderId,
                                    ),
                                  ),
                                ));
                          },
                          icon: SvgPicture.asset(IconSystem.commissionLog,
                              package: 'gc_customer_app',
                              color: Theme.of(context).primaryColor)),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              addCommissionBloc
                                  .add(DivideSelectedEmployeeCommission());
                            });
                          },
                          icon: SvgPicture.asset(IconSystem.commissionDivide,
                              package: 'gc_customer_app',
                              color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCommissionBloc, AddCommissionState>(
        builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: state.addCommissionStatus == AddCommissionStatus.failedState
            ? Column(
                children: [
                  getAppBar(state),
                  Center(child: NoDataFound(fontSize: 18)),
                ],
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getAppBar(state),
                        SizedBox(height: 20),
                        if (state.listSelectedEmployees.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            child: Column(
                              // primary: false,
                              // shrinkWrap: true,
                              children: state.listSelectedEmployees.map((e) {
                                return BlocProvider.value(
                                  value: addCommissionBloc,
                                  child: EmployeeCommissionWidget(
                                    employee: e,
                                    canRemove: state.listSelectedEmployees
                                            .indexOf(e) !=
                                        0,
                                    onSelected: (p0) {},
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        SizedBox(height: 16),
                        _searchEmployeeWidget(
                            state.listSelectedEmployees, state),
                        SizedBox(height: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView.separated(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: state.listEmployeesSameStore.length,
                              itemBuilder: (context, index) {
                                var employee =
                                    state.listEmployeesSameStore[index];
                                return BlocProvider.value(
                                  value: addCommissionBloc,
                                  child: EmployeeItemWidget(
                                    employee: employee,
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                  color: ColorSystem.whiteEE,
                                  height: 1,
                                  endIndent: 26,
                                  indent: 26),
                            ),
                          ],
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                      onPressed: state.showSubmissionLoading
                          ? () {}
                          : () {
                              var sum = 0.0;
                              state.listSelectedEmployees.forEach((e) {
                                sum += (e.employeeCommission ?? 0);
                              });
                              if (sum != 100) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title:
                                        Text('The total commission is not 100'),
                                    actions: [
                                      CupertinoActionSheetAction(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('OK'))
                                    ],
                                  ),
                                );
                              } else {
                                addCommissionBloc.add(SaveCommission(
                                    selectedEmployeesModel:
                                        state.listSelectedEmployees,
                                    orderID: widget.orderId,
                                    context: context));
                              }
                            },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            !state.showSubmissionLoading
                                ? Text(
                                    'Save',
                                    style: TextStyle(fontSize: 18),
                                  )
                                : CupertinoActivityIndicator(
                                    color: Colors.white,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  String getFormattedDate(DateTime date) {
    String formattedDate = DateFormat('dd-MMM-yyyy').format(date);
    return formattedDate;
  }

  Widget _searchEmployeeWidget(
      List<CommissionEmployee> employees, AddCommissionState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => SearchEmployeesBloc(),
                  child: BlocProvider.value(
                    value: addCommissionBloc,
                    child: SearchCommissionUsers(),
                  ),
                ),
              ));
        },
        child: TextFormField(
          enabled: false,
          cursorColor: Theme.of(context).primaryColor,
          style: TextStyle(
              fontSize: 17, color: Color(0xFF222222), fontFamily: kRubik),
          decoration: InputDecoration(
            constraints: BoxConstraints(),
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            hintText: 'Search by Name or ID',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
            hintStyle: TextStyle(
              color: ColorSystem.secondary,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
