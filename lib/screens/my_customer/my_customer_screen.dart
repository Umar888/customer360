import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as plb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlb;
import 'package:gc_customer_app/bloc/my_customer_bloc/my_customer_bloc.dart';
import 'package:gc_customer_app/common_widgets/bottom_navigation_bar.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/my_customer/employee_my_customer_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/my_customer/widget/circular_chart_widget.dart';
import 'package:gc_customer_app/screens/my_customer/widget/client_chart_widget.dart';
import 'package:gc_customer_app/screens/my_customer/widget/contacted_view.dart';
import 'package:gc_customer_app/screens/my_customer/widget/custom_date_bottom_sheet.dart';
import 'package:gc_customer_app/screens/my_customer/widget/customer_view.dart';
import 'package:gc_customer_app/screens/my_customer/widget/purchased_view.dart';
import 'package:gc_customer_app/screens/my_customer/widget/switcher_filter_widget.dart';
import 'package:intl/intl.dart';

enum MyCustomerView { charts, clients, contacted, purchased }

class MyCustomerScreen extends StatefulWidget {
  final CustomerInfoModel? customerInfoModel;
  MyCustomerScreen({Key? key, required this.customerInfoModel})
      : super(key: key);

  @override
  State<MyCustomerScreen> createState() => _MyCustomerScreenState();
}

class _MyCustomerScreenState extends State<MyCustomerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final StreamController<String> _selectedFilterController =
      StreamController<String>.broadcast();
  final StreamController<String> _customStringController =
      StreamController<String>.broadcast();
  final StreamController<MyCustomerView> _viewController =
      StreamController<MyCustomerView>.broadcast();
  final StreamController<bool> _isAllSelected =
      StreamController<bool>.broadcast();
  final _selectedEmplTEC = TextEditingController();
  late MyCustomerBloC myCustomerBloC;
  late InventorySearchBloc inventorySearchBloc;
  late plb.ProductDetailBloc productDetailBloc;
  late zlb.ZipStoreListBloc zipStoreListBloc;
  late String filter;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    filter = 'All';
    var now = DateTime.now();
    startDate =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 14));
    endDate = now;
    myCustomerBloC = context.read<MyCustomerBloC>();
    myCustomerBloC.selectedEmployeeId = '';
    myCustomerBloC.add(LoadMyCustomerInformation(filter, startDate, endDate));
    inventorySearchBloc = context.read<InventorySearchBloc>();
    productDetailBloc = context.read<plb.ProductDetailBloc>();
    zipStoreListBloc = context.read<zlb.ZipStoreListBloc>();
    _animationController = AnimationController(
      vsync: this,
      value: 0.0,
      duration: Duration(milliseconds: 600),
    );
  }

  var border = OutlineInputBorder(
    borderSide: BorderSide(color: ColorSystem.secondary),
    borderRadius: BorderRadius.circular(12),
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return BlocBuilder<MyCustomerBloC, MyCustomerState>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 45,
          leading: StreamBuilder<MyCustomerView>(
              stream: _viewController.stream,
              initialData: MyCustomerView.charts,
              builder: (context, snapshot) {
                var isMainScreen = snapshot.data;
                return IconButton(
                  onPressed: () {
                    if (isMainScreen == MyCustomerView.charts)
                      Navigator.pop(context);
                    else
                      _viewController.add(MyCustomerView.charts);
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: ColorSystem.black,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                );
              }),
          centerTitle: true,
          title: StreamBuilder<MyCustomerView>(
              stream: _viewController.stream,
              initialData: MyCustomerView.charts,
              builder: (context, snapshot) {
                snapshot.data;
                var title = 'MY CUSTOMERS';
                switch (snapshot.data) {
                  case MyCustomerView.clients:
                    title = 'CLIENTS';
                    break;
                  case MyCustomerView.contacted:
                    title = 'CONTACTED';
                    break;
                  case MyCustomerView.purchased:
                    title = 'PURCHASED';
                    break;
                  default:
                }
                return Text(title,
                    style: TextStyle(
                        fontFamily: kRubik,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontSize: 16));
              }),
          actions: [],
        ),
        bottomNavigationBar: AppBottomNavBar(
            widget.customerInfoModel,
            null,
            null,
            inventorySearchBloc,
            productDetailBloc,
            zipStoreListBloc,
            false,
            false,
            true),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  StreamBuilder<MyCustomerView>(
                      stream: _viewController.stream,
                      initialData: MyCustomerView.charts,
                      builder: (context, snapshot) {
                        var isMainScreen =
                            snapshot.data == MyCustomerView.charts;
                        if (isMainScreen != true) return SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hi ${state.loggedInUserName == null ? '' : ', ${state.loggedInUserName}'}',
                                  maxLines: 2,
                                  style: theme.caption?.copyWith(fontSize: 28),
                                ),
                                StreamBuilder<bool>(
                                    stream: _isAllSelected.stream,
                                    initialData: true,
                                    builder: (context, snapshot) {
                                      if (snapshot.data == true)
                                        return SizedBox.shrink();
                                      return _timeFilter(state);
                                    }),
                              ],
                            ),
                            StreamBuilder<String>(
                                stream: _customStringController.stream,
                                builder: (_, snapshot) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if ((snapshot.data ?? '').isNotEmpty)
                                        Text(snapshot.data ?? ''),
                                    ],
                                  );
                                })
                          ],
                        );
                      }),
                  if (state.isManager == true && state.employees != null)
                    Column(
                      children: [
                        SizedBox(height: 8),
                        DropdownSearch<EmployeeMyCustomerModel>(
                          clearButtonProps: ClearButtonProps(
                              isVisible: state.isShowAllUsers ?? true),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            showSelectedItems: true,
                            searchFieldProps: TextFieldProps(
                                controller: _selectedEmplTEC,
                                decoration: InputDecoration(
                                  constraints: BoxConstraints(maxHeight: 40),
                                  border: border,
                                  focusedBorder: border,
                                  enabledBorder: border,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                )),
                            constraints: BoxConstraints(maxHeight: 240),
                            itemBuilder: (context, infor, isSelected) =>
                                Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                '${infor.firstName} ${infor.lastName}',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          items: state.employees!,
                          compareFn: (item1, item2) => item1.id == item2.id,
                          filterFn: (infor, filter) =>
                              '${infor.firstName} ${infor.lastName}'
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                          dropdownBuilder: (context, selectedItem) {
                            if (selectedItem == null) {
                              return ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Row(
                                  children: [
                                    Icon(Icons.search,
                                        color: ColorSystem.secondary),
                                    SizedBox(width: 8),
                                    Text(
                                      "Search Employee",
                                      style: TextStyle(
                                          color: ColorSystem.secondary),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text(
                                  '${selectedItem.firstName} ${selectedItem.lastName}'),
                            );
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            textAlign: TextAlign.center,
                            baseStyle: TextStyle(color: Colors.black),
                            dropdownSearchDecoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                              border: border,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              focusedBorder: border,
                              enabledBorder: border,
                              constraints: BoxConstraints(maxHeight: 50),
                            ),
                          ),
                          selectedItem: (state.isShowAllUsers ?? true)
                              ? null
                              : state.employees!
                                          .firstWhere(
                                            (e) => e.id == state.loggedInUserId,
                                            orElse: () =>
                                                EmployeeMyCustomerModel(),
                                          )
                                          .id !=
                                      null
                                  ? state.employees!.firstWhere(
                                      (e) => e.id == state.loggedInUserId,
                                      orElse: () => EmployeeMyCustomerModel(),
                                    )
                                  : null,
                          onChanged: (value) async {
                            if (value != null) {
                              myCustomerBloC.selectedEmployeeId =
                                  value.id ?? '';
                              myCustomerBloC.add(LoadEmployeeInformation(
                                  filter, startDate, endDate, value.id ?? ''));
                            } else {
                              myCustomerBloC.selectedEmployeeId = '';
                              myCustomerBloC.add(LoadMyCustomerInformation(
                                  filter, startDate, endDate));
                            }
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<MyCustomerView>(
                        stream: _viewController.stream,
                        initialData: MyCustomerView.charts,
                        builder: (context, snapshot) {
                          var view = snapshot.data;
                          if (view != MyCustomerView.charts) {
                            Widget ui = SizedBox.shrink();
                            switch (view) {
                              case MyCustomerView.clients:
                                ui = CustomerView(clients: state.clients ?? []);
                                break;
                              case MyCustomerView.contacted:
                                ui = ContactedView(
                                  contacteds: state.contacteds ?? [],
                                  filter: filter,
                                  startDate: startDate,
                                  endDate: endDate,
                                );
                                break;
                              case MyCustomerView.purchased:
                                ui = PurchasedView(
                                  purchaseds: state.purchaseds ?? [],
                                  filter: filter,
                                  startDate: startDate,
                                  endDate: endDate,
                                );
                                break;
                              default:
                            }
                            if (view != MyCustomerView.clients) return ui;
                            return Column(
                              children: [
                                SwitcherFilterWidget(
                                  animationController: _animationController,
                                  leftTitle:
                                      'ALL ${state.allCount == null ? '' : ': ${state.allCount}'}',
                                  rightTitle:
                                      'NEW ${state.newCount == null ? '' : ': ${state.newCount}'}',
                                  onLeftTapped: () {
                                    filter = 'All';
                                    _isAllSelected.add(true);
                                    if (myCustomerBloC
                                        .selectedEmployeeId.isEmpty) {
                                      myCustomerBloC.add(
                                          LoadMyCustomerInformation(
                                              filter, startDate, endDate));
                                    } else {
                                      myCustomerBloC.add(
                                          LoadEmployeeInformation(
                                              filter,
                                              startDate,
                                              endDate,
                                              myCustomerBloC
                                                  .selectedEmployeeId));
                                    }
                                    _animationController.value = 0;
                                  },
                                  onRightTapped: () {
                                    _isAllSelected.add(false);
                                    filter = 'New';
                                    if (myCustomerBloC
                                        .selectedEmployeeId.isEmpty) {
                                      myCustomerBloC.add(
                                          LoadMyCustomerInformation(
                                              filter, startDate, endDate));
                                    } else {
                                      myCustomerBloC.add(
                                          LoadEmployeeInformation(
                                              filter,
                                              startDate,
                                              endDate,
                                              myCustomerBloC
                                                  .selectedEmployeeId));
                                    }
                                    _animationController.value = 1;
                                  },
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 24),
                                    decoration: BoxDecoration(
                                        color: ColorSystem.white,
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 10,
                                              color: Color.fromARGB(
                                                  255, 210, 210, 210),
                                              offset: Offset(0, 0))
                                        ],
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    child: ui,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              SwitcherFilterWidget(
                                animationController: _animationController,
                                leftTitle:
                                    'ALL ${state.allCount == null ? '' : ': ${state.allCount}'}',
                                rightTitle:
                                    'NEW ${state.newCount == null ? '' : ': ${state.newCount}'}',
                                onLeftTapped: () {
                                  _isAllSelected.add(true);
                                  filter = 'All';
                                  if (myCustomerBloC
                                      .selectedEmployeeId.isEmpty) {
                                    myCustomerBloC.add(
                                        LoadMyCustomerInformation(
                                            filter, startDate, endDate));
                                  } else {
                                    myCustomerBloC.add(LoadEmployeeInformation(
                                        filter,
                                        startDate,
                                        endDate,
                                        myCustomerBloC.selectedEmployeeId));
                                  }
                                  _animationController.value = 0;
                                },
                                onRightTapped: () {
                                  _isAllSelected.add(false);
                                  filter = 'New';
                                  if (myCustomerBloC
                                      .selectedEmployeeId.isEmpty) {
                                    myCustomerBloC.add(
                                        LoadMyCustomerInformation(
                                            filter, startDate, endDate));
                                  } else {
                                    myCustomerBloC.add(LoadEmployeeInformation(
                                        filter,
                                        startDate,
                                        endDate,
                                        myCustomerBloC.selectedEmployeeId));
                                  }
                                  _animationController.value = 1;
                                },
                              ),
                              Expanded(
                                child: ListView(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  children: [
                                    if (state.clients != null)
                                      _chart(
                                          'CLIENTS',
                                          [
                                            state.high ?? 0,
                                            state.medium ?? 0,
                                            state.low ?? 0
                                          ],
                                          ['High', 'Medium', 'Low'],
                                          true,
                                          state),
                                    if (state.contacteds != null)
                                      _chart(
                                          'CONTACTED',
                                          [
                                            state.contactedCount ?? 0,
                                            state.notContactedCount ?? 0
                                          ],
                                          ['Contacted', 'Not Contacted'],
                                          false,
                                          state),
                                    if (state.purchaseds != null)
                                      _chart(
                                          'PURCHASED',
                                          [
                                            state.purchasedCount ?? 0,
                                            state.notPurchasedCount ?? 0
                                          ],
                                          ['Purchased', 'Not Purchased'],
                                          false,
                                          state),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
            if (state.isLoading == true)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    });
  }

  Widget _chart(String title, List<int> value, List<String> valueName,
      bool isPieChart, MyCustomerState state) {
    var theme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        switch (title) {
          case 'CLIENTS':
            _viewController.add(MyCustomerView.clients);
            break;
          case 'CONTACTED':
            _viewController.add(MyCustomerView.contacted);
            break;
          case 'PURCHASED':
            _viewController.add(MyCustomerView.purchased);
            break;
          default:
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
            color: ColorSystem.lavender.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              style: theme.caption?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.4),
            ),
          ),
          Row(
            children: [
              // isPieChart
              //     ? ClientsChartWidget(
              //         data: value,
              //         onChartTapped: () {
              //           _viewController.add(MyCustomerView.clients);
              //         })
              //     // ? ClientsLineChartWidget(
              //     //     data: state.clients!,
              //     //     onChartTapped: () {
              //     //       _viewController.add(MyCustomerView.clients);
              //     //     })
              //     :
              CircularChartWidget(
                data: value,
                dataName: valueName,
                isHaveThreeValue: isPieChart,
                onChartTapped: () {
                  _viewController.add(title == 'CLIENTS'
                      ? MyCustomerView.clients
                      : title == 'CONTACTED'
                          ? MyCustomerView.contacted
                          : MyCustomerView.purchased);
                },
              ),
              SizedBox(width: 14),
              Expanded(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 12,
                  children: value.asMap().entries.map((e) {
                    bool isFirst = e.key == 0;
                    bool isSecond = e.key == 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.value.toString(),
                          style: TextStyle(
                              fontFamily: kRubik,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: isPieChart
                                  ? isFirst
                                      ? ColorSystem.additionalGreen
                                      : isSecond
                                          ? Colors.amber
                                          : ColorSystem.lavender
                                  : isFirst
                                      ? ColorSystem.lavender
                                      : ColorSystem.greyDark.withOpacity(0.8)),
                        ),
                        Text(
                          isFirst
                              ? valueName.first
                              : isSecond
                                  ? valueName[1]
                                  : valueName.last,
                          style: TextStyle(),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }

  Future dateCustomBottomSheet() {
    return showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return CustomDateBottomSheet();
      },
    );
  }

  Widget _timeFilter(MyCustomerState state) {
    return StreamBuilder<String>(
        stream: _selectedFilterController.stream,
        initialData: '2 Weeks',
        builder: (context, snapshot) {
          return DropdownButton(
            borderRadius: BorderRadius.circular(12),
            value: snapshot.data,
            items: [
              '2 Weeks',
              'Month',
              '3 Months',
              '6 Months',
              '9 Months',
              'Year',
              'Custom'
            ]
                .map((e) => DropdownMenuItem(
                      child: Text(e),
                      value: e,
                    ))
                .toList(),
            onChanged: (value) async {
              _selectedFilterController.add(value ?? '2 Weeks');
              if (value == 'Custom') {
                var resp = await dateCustomBottomSheet();
                if (resp == null) {
                  _selectedFilterController.add('2 Weeks');
                  value = '2 Weeks';
                } else {
                  _customStringController.add(
                      '${DateFormat('MMM dd, yyyy').format(resp[0])} - ${DateFormat('MMM dd, yyyy').format(resp[1])}');
                  if (myCustomerBloC.selectedEmployeeId.isEmpty) {
                    myCustomerBloC.add(
                        LoadMyCustomerInformation(filter, resp[0], resp[1]));
                  } else {
                    myCustomerBloC.add(LoadEmployeeInformation(filter, resp[0],
                        resp[1], myCustomerBloC.selectedEmployeeId));
                  }
                  return;
                }
              }
              _customStringController.add('');
              var now = DateTime.now();

              switch (value) {
                case '2 Weeks':
                  startDate = DateTime(now.year, now.month, now.day)
                      .subtract(Duration(days: 14));
                  break;
                case 'Month':
                  startDate = DateTime(now.year, now.month - 1, now.day);
                  break;
                case '3 Months':
                  startDate = DateTime(now.year, now.month - 3, now.day);
                  break;
                case '6 Months':
                  startDate = DateTime(now.year, now.month - 6, now.day);
                  break;
                case '9 Months':
                  startDate = DateTime(now.year, now.month - 9, now.day);
                  break;
                case 'Year':
                  startDate = DateTime(now.year - 1, now.month, now.day);
                  break;
                default:
                  startDate = DateTime(now.year, now.month, now.day)
                      .subtract(Duration(days: 14));
              }
              if (myCustomerBloC.selectedEmployeeId.isEmpty) {
                myCustomerBloC
                    .add(LoadMyCustomerInformation(filter, startDate, endDate));
              } else {
                myCustomerBloC.add(LoadEmployeeInformation(filter, startDate,
                    endDate, myCustomerBloC.selectedEmployeeId));
              }
            },
          );
        });
  }
}
