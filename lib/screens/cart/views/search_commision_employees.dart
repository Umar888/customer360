import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/add_commission_bloc.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/search_employees_bloc/search_employees_bloc.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/screens/add_commission/employee_item_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:gc_customer_app/models/add_commission_model/selected_employee_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

class SearchCommissionUsers extends StatefulWidget {
  SearchCommissionUsers({Key? key}) : super(key: key);

  @override
  State<SearchCommissionUsers> createState() => _SearchCommissionUsersState();
}

class _SearchCommissionUsersState extends State<SearchCommissionUsers>
    with TickerProviderStateMixin {
  final TextEditingController nameC = TextEditingController();

  int offset = 0;
  bool isLoadingData = false;
  List<SelectedEmployeeModel> listSelectedEmployees = [];

  late SearchEmployeesBloc searchEmployeesBloc;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    searchEmployeesBloc = context.read<SearchEmployeesBloc>();
    _pagingController.addPageRequestListener((pageKey) {
      if (nameC.text.isNotEmpty) {
        // customerLookUpBloc.offset += 20;
        // customerLookUpBloc.add(SearchCustomer(nameC.text));
        searchEmployeesBloc
            .add(SearchEmployees(keySearch: nameC.text, isPaging: false));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(listSelectedEmployees);
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorSystem.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: SizeSystem.size20,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 30,
                right: 40,
                top: 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop(listSelectedEmployees);
                    },
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: SvgPicture.asset(
                      IconSystem.back,
                      package: 'gc_customer_app',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  SizedBox(
                    width: SizeSystem.size20,
                  ),
                  Expanded(
                    child: TextFormField(
                      autofocus: true,
                      cursorColor: Theme.of(context).primaryColor,
                      onChanged: (name) {
                        EasyDebounce.cancelAll();
                        if (name.isNotEmpty) {
                          EasyDebounce.debounce(
                              'search_name_debounce', Duration(seconds: 1), () {
                            searchEmployeesBloc.offset = 0;
                            searchEmployeesBloc.add(SearchEmployees(
                                keySearch: name, isPaging: false));
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Employee',
                        hintStyle: TextStyle(
                          color: ColorSystem.secondary,
                          fontSize: SizeSystem.size18,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AddCommissionBloc, AddCommissionState>(
                  builder: (context, commissionState) {
                var selectedEmployees = commissionState.listSelectedEmployees;
                return BlocBuilder<SearchEmployeesBloc, SearchEmployeesState>(
                    builder: (context, state) {
                  if (state is SearchEmployeesSuccess &&
                      (state.employees ?? []).isNotEmpty) {
                    var searchEmployees = state.employees!;
                    return ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: searchEmployees.length,
                      itemBuilder: (context, index) {
                        return BlocProvider.value(
                          value: context.read<AddCommissionBloc>(),
                          child: EmployeeItemWidget(
                            employee: searchEmployees[index],
                            isSelected: selectedEmployees
                                .where((e) =>
                                    e.employeeId ==
                                    searchEmployees[index].employeeNumber)
                                .isNotEmpty,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(
                          color: ColorSystem.whiteEE,
                          height: 1,
                          endIndent: 26,
                          indent: 26),
                    );
                  }
                  if (state is SearchEmployeesProgress)
                    return Center(child: CircularProgressIndicator());
                  if (state is SearchEmployeesFailure)
                    return Center(child: NoDataFound(fontSize: 18));
                  return SizedBox.shrink();
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
