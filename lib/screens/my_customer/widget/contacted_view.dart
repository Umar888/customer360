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

class ContactedView extends StatefulWidget {
  final bool isAll;
  final List<MyCustomerModel> contacteds;
  final String filter;
  final DateTime startDate;
  final DateTime endDate;
  ContactedView(
      {Key? key,
      this.isAll = true,
      required this.contacteds,
      required this.filter,
      required this.startDate,
      required this.endDate})
      : super(key: key);

  @override
  State<ContactedView> createState() => _ContactedViewState();
}

class _ContactedViewState extends State<ContactedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final StreamController<bool> _isContactedController =
      StreamController<bool>.broadcast();
  bool contactedVal = false;
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
          leftTitle: 'NOT CONTACTED',
          rightTitle: 'CONTACTED',
          onLeftTapped: () {
            _isContactedController.add(false);
            contactedVal = false;
            _animationController.value = 0;
          },
          onRightTapped: () {
            _isContactedController.add(true);
            contactedVal = true;
            _animationController.value = 1;
          },
        ),
        Expanded(
          child: StreamBuilder<bool>(
              stream: _isToggedController.stream,
              initialData: false,
              builder: (context, snapshot) {
                var contacteds = widget.contacteds.toList();
                bool isPurchased = snapshot.data ?? false;
                if (snapshot.data == true) {
                  contacteds.removeWhere((c) => c.purchased != 'Purchased');
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
                                stream: _isContactedController.stream,
                                initialData: contactedVal,
                                builder: (context, snapshot) {
                                  return Text(
                                      '${snapshot.data == true ? '' : 'NOT '}CONTACTED',
                                      style: theme.caption?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2));
                                }),
                            Row(
                              children: [
                                Text('Purchased',
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
                      Divider(height: 1, thickness: 1.5),
                      SizedBox(height: 8),
                      Expanded(
                          child: FutureBuilder(
                              future: context
                                  .read<MyCustomerBloC>()
                                  .myCustomerRepo
                                  .getContactedList(
                                      context.read<MyCustomerBloC>().recordIds,
                                      widget.startDate,
                                      widget.endDate,
                                      widget.filter,
                                      snapshot.data),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return Center(
                                      child: CircularProgressIndicator());
                                var contacteds = snapshot.data!.contacteds;
                                return StreamBuilder<bool>(
                                    stream: _isContactedController.stream,
                                    initialData: contactedVal,
                                    builder: (context, snapshot) {
                                      bool isContacted =
                                          snapshot.data ?? contactedVal;
                                      var contactedsWithFilter =
                                          (contacteds ?? []).toList();
                                      contactedsWithFilter.removeWhere((c) =>
                                          c.contacted !=
                                          (isContacted
                                              ? 'Contacted'
                                              : 'Not Contacted'));
                                      contactedsWithFilter.removeWhere((c) =>
                                          c.purchased !=
                                          (isPurchased
                                              ? 'Purchased'
                                              : 'Not Purchased'));
                                      return ListView.builder(
                                        itemCount: contactedsWithFilter.length,
                                        itemBuilder: (context, index) {
                                          var c = contactedsWithFilter[index];
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
                                                        key: agentId,
                                                        value: id);
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
                                                            c.record?.name ??
                                                                '',
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    kRubik),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Last Purchase: ${c.record?.lifetimeNetSalesAmountC == null ? 'N/A' : '\$${c.record?.lifetimeNetSalesAmountC!.toStringAsFixed(2)}'}',
                                                            style: theme
                                                                .headline5
                                                                ?.copyWith(
                                                                    fontSize:
                                                                        10),
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
                                                                SvgPicture
                                                                    .asset(
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
                                                                SizedBox(
                                                                    width: 2),
                                                                Text(
                                                                  c.priority ??
                                                                      'Low',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 10,
                                                                      color: c.priority == 'High'
                                                                          ? ColorSystem.additionalGreen
                                                                          : c.priority == 'Medium'
                                                                              ? Colors.amber
                                                                              : ColorSystem.lavender,
                                                                      fontFamily: kRubik),
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              c.record?.lastTransactionDateC ==
                                                                      null
                                                                  ? 'N/A'
                                                                  : DateFormat('MMM dd, yyyy').format(c
                                                                          .record
                                                                          ?.lastTransactionDateC ??
                                                                      DateTime
                                                                          .now()),
                                                              style: theme
                                                                  .headline5
                                                                  ?.copyWith(
                                                                      fontSize:
                                                                          10),
                                                            )
                                                          ],
                                                        ),
                                                        if ((c.record?.phone ??
                                                                '')
                                                            .isNotEmpty)
                                                          IconButton(
                                                              onPressed: () {
                                                                makephoneCall(c
                                                                    .record!
                                                                    .phone!);
                                                              },
                                                              icon: Icon(
                                                                  Icons.phone))
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
                              }))
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
