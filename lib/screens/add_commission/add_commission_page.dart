import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/search_employees_bloc/search_employees_bloc.dart';

import '../../bloc/add_commission_bloc/add_commission_bloc.dart';
import '../../data/data_sources/add_commission_data_source/add_commission_data_source.dart';
import '../../data/reporsitories/add_commission_repository/add_commission_repository.dart';
import 'add_commission_list.dart';

class AddCommissionPage extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  final String orderDate;
  final String userName;
  final String userId;

  AddCommissionPage(
      {required this.userId,
      required this.orderNumber,
      required this.orderId,
      required this.orderDate,
      required this.userName,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          left: true,
          top: true,
          right: true,
          bottom: false,
          child: BlocProvider(
            create: (context) {
              return AddCommissionBloc(
                addCommissionRepository: AddCommissionRepository(
                    addCommissionDataSource: AddCommissionDataSource()),
              );
            },
            child: AddCommissionList(
              orderId: orderId,
              orderNumber: orderNumber,
              orderDate: orderDate,
              userId: userId,
              userName: userName,
            ),
          ),
        ),
      ),
    );
  }
}
