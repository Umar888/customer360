import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/customer_look_up/create_new_customer_screen.dart';
import 'package:gc_customer_app/screens/customer_look_up/customer_details_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../primitives/size_system.dart';

class SearchByNameScreen extends StatefulWidget {
  SearchByNameScreen({Key? key}) : super(key: key);

  @override
  State<SearchByNameScreen> createState() => _SearchByNameScreenState();
}

class _SearchByNameScreenState extends State<SearchByNameScreen> {
  late CustomerLookUpBloc customerLookUpBloc;
  final TextEditingController nameC = TextEditingController();
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  bool isLoadingData = false;

  List<UserProfile> customers = [];

  Future<List<UserProfile>>? futureCustomers;

  @override
  void initState() {
    super.initState();
    customerLookUpBloc = context.read<CustomerLookUpBloc>();
    _pagingController.addPageRequestListener((pageKey) {
      if (nameC.text.isNotEmpty) {
        customerLookUpBloc.offset += 20;
        customerLookUpBloc.add(SearchCustomer(nameC.text));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        leadingWidth: 50,
        titleSpacing: 0,
        title: Container(
          height: 50,
          margin: EdgeInsets.only(right: 12),
          child: TextFormField(
            controller: nameC,
            keyboardType: TextInputType.text,
            autofocus: true,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: 'Search name...',
            ),
            onChanged: (name) {
              EasyDebounce.cancelAll();
              if (name.isNotEmpty) {
                EasyDebounce.debounce(
                    'search_name_debounce', Duration(seconds: 1), () {
                  customerLookUpBloc.offset = 0;
                  customerLookUpBloc.add(SearchCustomer(name));
                });
              }
            },
          ),
        ),
      ),
      body: BlocConsumer<CustomerLookUpBloc, CustomerLookUpState>(
        listener: (BuildContext context, state) {
          // if(state is SaveCustomerFailure && state.message.isNotEmpty){
          //   Future.delayed(Duration.zero, () {
          //     setState(() {});
          //     ScaffoldMessenger.of(context).showSnackBar(snackBar(state.message));
          //     customerLookUpBloc.add(ClearScafolldMessage());
          //   });
          // }
        },
        builder: (BuildContext context, state) {
          List<UserProfile>? customers;

          if (state is CustomerLookUpProgress) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is SearchSuccess) {
            customers = state.searchModels;
          }
          if ((customers ?? []).isEmpty && nameC.text.isNotEmpty && !kIsWeb) {
            return Padding(
              padding: EdgeInsets.only(top: 10),
              child: CreateNewCustomerScreen(
                emailText: '',
                phoneText: '',
                isFromSearch: true,
              ),
            );
          }
          if (customerLookUpBloc.offset == 0) {
            _pagingController.itemList?.clear();
          }
          if (customers != null && customers.length < 20) {
            _pagingController.appendLastPage(customers);
          }
          if (customers != null && customers.length >= 20) {
            _pagingController.appendPage(
                customers, (customerLookUpBloc.offset / 20).round());
          }
          if (nameC.text.isEmpty) {
            return SizedBox.shrink();
          }

          return PagedListView(
              pagingController: _pagingController,
              padding: EdgeInsets.only(left: 24),
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, item, index) {
                  return CustomerDetailsCard(
                      customer: item as UserProfile, onTap: () async {});
                },
              ));
        },
      ),
    );
  }

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.075,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
