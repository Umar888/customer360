import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/add_commission_bloc.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/models/add_commission_model/commission_log_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:intl/intl.dart';

class CommissionLogScreen extends StatelessWidget {
  final String orderId;
  CommissionLogScreen({Key? key, required this.orderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var subtitleStyle =
        Theme.of(context).textTheme.headline5?.copyWith(fontSize: 12);
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        title: Text('COMMISSION LOG',
            style: TextStyle(
                fontFamily: kRubik,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                fontSize: 15)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<CommissionLogModel>>(
        future: context.read<AddCommissionBloc>().getCommissionLog(orderId),
        initialData: [],
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if ((snapshot.data ?? []).isEmpty) {
            return Center(child: NoDataFound(fontSize: 14));
          }
          List<CommissionLogModel> logs = snapshot.data!;
          return ListView.separated(
            padding: EdgeInsets.only(top: 8, bottom: 80, left: 18, right: 18),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              DateTime? date;
              String? time;
              if (logs[index] != null) {
                var dateTimeSplit = logs[index].createdDate!.split(' ');
                var dateSplit = dateTimeSplit.first.split('/');
                date = DateTime(int.parse(dateSplit.last),
                    int.parse(dateSplit.first), int.parse(dateSplit[1]));

                time = '${dateTimeSplit[1]} ${dateTimeSplit[2]}';
              } else {
                date = null;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...logs[index]
                              .commissionWrapperList
                              ?.map<Widget>((e) => Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${e.employeeId ?? ''} - ${e.employeeName}: ${e.employeeCommission}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          ?.copyWith(
                                              fontWeight: FontWeight.w400),
                                    ),
                                  ))
                              .toList() ??
                          [],
                      SizedBox(height: 4),
                      Text(
                        'By: ${logs[index].createdBy ?? ''}',
                        style: subtitleStyle,
                      ),
                    ],
                  ),
                  date != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(DateFormat('MMM dd, yyyy').format(date),
                                style: subtitleStyle),
                            SizedBox(height: 2),
                            Text(time!, style: subtitleStyle),
                          ],
                        )
                      : SizedBox.shrink(),
                ],
              );
            },
            separatorBuilder: (context, index) =>
                Divider(color: ColorSystem.whiteEE, height: 16),
          );
        },
      ),
    );
  }
}
