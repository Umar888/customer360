import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/flutter_switch.dart';
import 'package:gc_customer_app/models/my_customer/customer_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_page.dart';
import 'package:gc_customer_app/screens/my_customer/widget/switcher_filter_widget.dart';
import 'package:gc_customer_app/screens/my_customer/widget/three_switch_widget.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/utils_functions.dart';
import 'package:intl/intl.dart';

class CustomerView extends StatefulWidget {
  final bool isAll;
  final List<MyCustomerModel> clients;
  CustomerView({Key? key, this.isAll = true, required this.clients})
      : super(key: key);

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final StreamController<double> _isToggedController =
      StreamController<double>.broadcast();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      value: 0.0,
      duration: Duration(milliseconds: 600),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _isToggedController.close();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return StreamBuilder<double>(
        stream: _isToggedController.stream,
        initialData: 0,
        builder: (context, snapshot) {
          List<MyCustomerModel> clients = [];
          if (snapshot.data == 0) {
            clients = widget.clients.where((c) => c.priority == 'Low').toList();
          } else if (snapshot.data == 0.5) {
            clients =
                widget.clients.where((c) => c.priority == 'Medium').toList();
          } else {
            clients =
                widget.clients.where((c) => c.priority == 'High').toList();
          }
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ALL : ${widget.clients.length}',
                        style: theme.caption?.copyWith(
                            fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                    ThreeFilterWidget(
                      animationController: _animationController,
                      leftTitle: 'Low',
                      midTitle: 'Medium',
                      rightTitle: 'High',
                      onLeftTapped: () {
                        _animationController.value = 0;
                        _isToggedController.add(0);
                      },
                      onMidTapped: () {
                        _animationController.value = 0.5;
                        _isToggedController.add(0.5);
                      },
                      onRightTapped: () {
                        _animationController.value = 1;
                        _isToggedController.add(1);
                      },
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1.5,
              ),
              SizedBox(height: 8),
              ...clients
                  .map((c) => InkWell(
                        onTap: () async {
                          String id = c.record?.id ?? '';
                          if (id.isNotEmpty) {
                            await SharedPreferenceService()
                                .setKey(key: agentId, value: id);
                          }

                          context.read<InventorySearchBloc>().add(SetCart(
                              itemOfCart: [], records: [], orderId: ''));
                          context.read<LandingScreenBloc>().add(LoadData());
                          Navigator.pop(context);
                          Navigator.of(context).push(CupertinoPageRoute(
                              settings:
                                  RouteSettings(name: 'CustomerLandingScreen'),
                              builder: (context) => CustomerLandingScreen()));
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.record?.name ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: kRubik),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Last Purchase: ${c.record?.lifetimeNetSalesAmountC == null ? 'N/A' : '\$${c.record?.lifetimeNetSalesAmountC!.toStringAsFixed(2)}'}',
                                        style: theme.headline5
                                            ?.copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                IconSystem.badgeIcon,
                                                package: 'gc_customer_app',
                                                color: c.priority == 'High'
                                                    ? ColorSystem
                                                        .additionalGreen
                                                    : c.priority == 'Medium'
                                                        ? Colors.amber
                                                        : ColorSystem.lavender,
                                                height: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                c.priority ?? 'Low',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10,
                                                    color: c.priority == 'High'
                                                        ? ColorSystem
                                                            .additionalGreen
                                                        : c.priority == 'Medium'
                                                            ? Colors.amber
                                                            : ColorSystem
                                                                .lavender,
                                                    fontFamily: kRubik),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            c.record?.lastTransactionDateC ==
                                                    null
                                                ? 'N/A'
                                                : DateFormat('MMM dd, yyyy')
                                                    .format(c.record
                                                            ?.lastTransactionDateC ??
                                                        DateTime.now()),
                                            style: theme.headline5
                                                ?.copyWith(fontSize: 10),
                                          )
                                        ],
                                      ),
                                      if ((c.record?.phone ?? '').isNotEmpty)
                                        IconButton(
                                            onPressed: () {
                                              makephoneCall(c.record!.phone!);
                                            },
                                            icon: Icon(Icons.phone))
                                    ],
                                  )
                                ],
                              ),
                              Divider()
                            ],
                          ),
                        ),
                      ))
                  .toList()
            ],
          );
        });
  }
}
