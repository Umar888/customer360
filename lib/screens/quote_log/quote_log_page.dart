import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/screens/quote_log/quote_log_list.dart';
import '../../bloc/quote_log_bloc/quote_log_bloc.dart';
import '../../data/data_sources/quote_log_data_source/quote_log_data_source.dart';
import '../../data/reporsitories/quote_log_reporsitory/quote_log_repository.dart';

class QuoteLogPage extends StatefulWidget {
  final String orderId;
  final String orderDate;
  final CartState cartState;

  QuoteLogPage(
      {Key? key,
      required this.orderId,
      required this.orderDate,
      required this.cartState})
      : super(key: key);

  @override
  State<QuoteLogPage> createState() => _QuoteLogPageState();
}

class _QuoteLogPageState extends State<QuoteLogPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Container(
        color: Colors.grey.shade50,
        child: SafeArea(
          left: true,
          top: true,
          right: true,
          bottom: false,
          child: BlocProvider(
            create: (context) {
              return QuoteLogBloc(
                quoteLogRepository: QuoteLogRepository(
                    quoteLogDataSource: QuoteLogDataSource()),
              );
            },
            child: QuoteLogList(
              orderId: widget.orderId,
              orderDate: widget.orderDate,
              cartState: widget.cartState,
            ),
          ),
        ),
      ),
    );
  }
}
