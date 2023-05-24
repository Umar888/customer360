import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/my_customer_bloc/my_customer_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/flutter_switch.dart';
import 'package:gc_customer_app/models/my_customer/customer_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_page.dart';
import 'package:gc_customer_app/screens/my_customer/widget/switcher_filter_widget.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:gc_customer_app/utils/utils_functions.dart';
import 'package:intl/intl.dart';

class PurchasedView extends StatefulWidget {
  final bool isAll;
  final List<MyCustomerModel> purchaseds;
  final String filter;
  final DateTime startDate;
  final DateTime endDate;
  PurchasedView(
      {Key? key,
      this.isAll = true,
      required this.purchaseds,
      required this.filter,
      required this.startDate,
      required this.endDate})
      : super(key: key);

  @override
  State<PurchasedView> createState() => _PurchasedViewState();
}

class _PurchasedViewState extends State<PurchasedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final StreamController<bool> _isPurchasedController =
      StreamController<bool>.broadcast();
  bool isPurchasedVal = false;
  final StreamController<bool> _isToggedController =
      StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: 0.0,
      duration: Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _isToggedController.close();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Column(
      children: [
        SwitcherFilterWidget(
          animationController: _animationController,
          leftTitle: 'NOT PURCHASED',
          rightTitle: 'PURCHASED',
          onLeftTapped: () {
            _isPurchasedController.add(false);
            isPurchasedVal = false;
            _animationController.value = 0;
          },
          onRightTapped: () {
            _isPurchasedController.add(true);
            isPurchasedVal = true;
            _animationController.value = 1;
          },
        ),
        Expanded(
          child: StreamBuilder<bool>(
              stream: _isToggedController.stream,
              initialData: false,
              builder: (context, snapshot) {
                var purchaseds = widget.purchaseds.toList();
                bool isContacted = snapshot.data ?? false;
                if (snapshot.data == true) {
                  purchaseds.removeWhere((c) => c.contacted != 'Contacted');
                }
                return Container(
                  margin: EdgeInsets.only(top: 24),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: ColorSystem.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10,
                            color: Color.fromARGB(255, 210, 210, 210),
                            offset: Offset(0, 0))
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    children: [
                      SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StreamBuilder<bool>(
                                stream: _isPurchasedController.stream,
                                initialData: isPurchasedVal,
                                builder: (context, snapshot) {
                                  return Text(
                                      '${snapshot.data == true ? '' : 'NOT '}PURCHASED',
                                      style: theme.caption?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2));
                                }),
                            Row(
                              children: [
                                Text('Contacted',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                        fontFamily: kRubik)),
                                SizedBox(width: 5),
                                FlutterSwitch(
                                  value: snapshot.data ?? false,
                                  onToggle: (value) {
                                    _isToggedController.add(value);
                                  },
                                  height: 18,
                                  width: 35,
                                  activeSwitchBorder: Border.all(
                                    color: ColorSystem.additionalGreen,
                                    width: 2,
                                  ),
                                  inactiveSwitchBorder: Border.all(
                                    color: ColorSystem.lavender2,
                                    width: 2,
                                  ),
                                  activeColor: ColorSystem.white,
                                  inactiveColor: ColorSystem.white,
                                  activeToggleColor:
                                      ColorSystem.additionalGreen,
                                  inactiveToggleColor: ColorSystem.lavender2,
                                  toggleSize: 13,
                                  padding: 2,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1.5,
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: FutureBuilder(
                          future: context
                              .read<MyCustomerBloC>()
                              .myCustomerRepo
                              .getPurchasedList(
                                  context.read<MyCustomerBloC>().recordIds,
                                  widget.startDate,
                                  widget.endDate,
                                  widget.filter,
                                  snapshot.data),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return Center(child: CircularProgressIndicator());
                            var purchaseds = snapshot.data!.purchaseds;
                            return StreamBuilder<bool>(
                                stream: _isPurchasedController.stream,
                                initialData: isPurchasedVal,
                                builder: (context, snapshot) {
                                  bool isPurchased =
                                      snapshot.data ?? isPurchasedVal;
                                  var purchasedsWithFilter =
                                      (purchaseds ?? []).toList();
                                  // if (snapshot.data != false) {
                                  //   purchasedsWithFilter.removeWhere(
                                  //       (c) => c.purchased != 'Purchased');
                                  // } else {
                                  //   purchasedsWithFilter.removeWhere(
                                  //       (c) => c.purchased != 'Not Purchased');
                                  // }
                                  purchasedsWithFilter.removeWhere((c) =>
                                      c.purchased !=
                                      (isPurchased
                                          ? 'Purchased'
                                          : 'Not Purchased'));
                                  purchasedsWithFilter.removeWhere((c) =>
                                      c.contacted !=
                                      (isContacted
                                          ? 'Contacted'
                                          : 'Not Contacted'));

                                  return ListView.builder(
                                    itemCount: purchasedsWithFilter.length,
                                    itemBuilder: (context, index) {
                                      var c = purchasedsWithFilter[index];
                                      c.priority = getCustomerLevel(c.record
                                                  ?.lifetimeNetSalesAmountC ??
                                              0)
                                          .capitalize();
                                      return InkWell(
                                        onTap: () async {
                                          String id = c.record?.id ?? '';
                                          if (id.isNotEmpty) {
                                            await SharedPreferenceService()
                                                .setKey(
                                                    key: agentId, value: id);
                                          }

                                          context
                                              .read<InventorySearchBloc>()
                                              .add(SetCart(
                                                  itemOfCart: [],
                                                  records: [],
                                                  orderId: ''));
                                          context
                                              .read<LandingScreenBloc>()
                                              .add(LoadData());
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  settings: RouteSettings(
                                                      name:
                                                          'CustomerLandingScreen'),
                                                  builder: (context) =>
                                                      CustomerLandingScreen()));
                                        },
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        c.record?.name ?? '',
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily: kRubik),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        'Last Purchase: ${c.record?.lifetimeNetSalesAmountC == null ? 'N/A' : '\$${c.record?.lifetimeNetSalesAmountC!.toStringAsFixed(2)}'}',
                                                        style: theme.headline5
                                                            ?.copyWith(
                                                                fontSize: 10),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              IconSystem
                                                                  .badgeIcon,
                                                              package:
                                                                  'gc_customer_app',
                                                              color: c.priority ==
                                                                      'High'
                                                                  ? ColorSystem
                                                                      .additionalGreen
                                                                  : c.priority ==
                                                                          'Medium'
                                                                      ? Colors
                                                                          .amber
                                                                      : ColorSystem
                                                                          .lavender,
                                                              height: 12,
                                                            ),
                                                            SizedBox(width: 2),
                                                            Text(
                                                              c.priority ??
                                                                  'Low',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 10,
                                                                  color: c.priority ==
                                                                          'High'
                                                                      ? ColorSystem
                                                                          .additionalGreen
                                                                      : c.priority ==
                                                                              'Medium'
                                                                          ? Colors
                                                                              .amber
                                                                          : ColorSystem
                                                                              .lavender,
                                                                  fontFamily:
                                                                      kRubik),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          c.record?.lastTransactionDateC ==
                                                                  null
                                                              ? 'N/A'
                                                              : DateFormat(
                                                                      'MMM dd, yyyy')
                                                                  .format(c
                                                                          .record
                                                                          ?.lastTransactionDateC ??
                                                                      DateTime
                                                                          .now()),
                                                          style: theme.headline5
                                                              ?.copyWith(
                                                                  fontSize: 10),
                                                        )
                                                      ],
                                                    ),
                                                    if ((c.record?.phone ?? '')
                                                        .isNotEmpty)
                                                      IconButton(
                                                          onPressed: () {
                                                            makephoneCall(c
                                                                .record!
                                                                .phone!);
                                                          },
                                                          icon:
                                                              Icon(Icons.phone))
                                                  ],
                                                )
                                              ],
                                            ),
                                            Divider()
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                });
                          },
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
