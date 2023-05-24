import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/common_widgets/bottom_navigation_bar.dart';
import 'package:gc_customer_app/common_widgets/scanner_view.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:provider/provider.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as plb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlb;
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../primitives/size_system.dart';
import 'inventory_search_list.dart';

class InventorySearchPage extends StatefulWidget {
  final String? customerID;
  final CustomerInfoModel? customer;
  InventorySearchPage(
      {Key? key, required this.customerID, required this.customer})
      : super(key: key);

  @override
  State<InventorySearchPage> createState() => _InventorySearchPageState();
}

class _InventorySearchPageState extends State<InventorySearchPage> {
  late InventorySearchBloc inventorySearchBloc;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    inventorySearchBloc = context.read<InventorySearchBloc>();
    // inventorySearchBloc.add(PageLoad(name: "", offset: 0, isFirstTime: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    var border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(14),
        bottomLeft: Radius.circular(14),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _closeButton(context),
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(SizeSystem.size32),
                                topRight: Radius.circular(SizeSystem.size32))),
                        child: Container(
                          margin: EdgeInsets.only(top: 40),
                          padding: EdgeInsets.only(top: 20),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                SizedBox(height: 60),
                                Text(
                                  'Inventory Lookup',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 34,
                                    fontFamily: kRubik,
                                  ),
                                ),
                                SizedBox(height: 56),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: formKey,
                                        child: TextFormField(
                                          autofocus: true,
                                          keyboardType: TextInputType.text,
                                          controller: controller,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Search by text or sku',
                                            border: border,
                                            focusedBorder: border,
                                            enabledBorder: border,
                                            errorBorder: border,
                                            focusedErrorBorder: border,
/*                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ScannerView())).then(
                                                      (value) {
                                                    if (value != null) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Scaffold(
                                                              body: SafeArea(
                                                                top: true,
                                                                bottom: false,
                                                                left: false,
                                                                right: false,
                                                                child: InventorySearchList(
                                                                    customerID:
                                                                        widget.customerID ??
                                                                            "",
                                                                    customer: widget
                                                                        .customer,
                                                                    initSearchText:
                                                                        value),
                                                              ),
                                                            ),
                                                            settings: RouteSettings(
                                                                name:
                                                                    'InventorySearchList'),
                                                          ));
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons
                                                      .qr_code_scanner_outlined,
                                                  color: ColorSystem.primary,
                                                )),*/
                                          ),
                                          validator: (value) {
                                            if ((value ?? '').isEmpty) {
                                              return 'Text or sku can not be empty.';
                                            }
                                          },
                                          onFieldSubmitted: (val) {
                                            if ((formKey.currentState
                                                    ?.validate() ??
                                                false))
                                              onSearchPresses(context, val);
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(14),
                                            bottomRight: Radius.circular(14),
                                          ),
                                          color:
                                              Theme.of(context).primaryColor),
                                      child: MaterialButton(
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                        height: 58,
                                        minWidth: 20,
                                        onPressed: () {
                                          if ((formKey.currentState
                                                  ?.validate() ??
                                              false))
                                            onSearchPresses(
                                                context, controller.text);
                                        },
                                        child: Icon(Icons.search,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: BlocProvider.value(
              value: context.read<LandingScreenBloc>(),
              child: AppBottomNavBar(
                  CustomerInfoModel(records: [Records(id: null)]),
                  null,
                  null,
                  context.read<InventorySearchBloc>(),
                  context.read<plb.ProductDetailBloc>(),
                  context.read<zlb.ZipStoreListBloc>(),
                  true,
                  false),
            ),
          )
        ],
      ),
    );
  }

  void onSearchPresses(BuildContext context, String searchText) {
    if (formKey.currentState?.validate() ?? false)
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: SafeArea(
                top: true,
                bottom: false,
                left: false,
                right: false,
                child: InventorySearchList(
                    customerID: widget.customerID ?? "",
                    customer: widget.customer,
                    initSearchText: searchText),
              ),
            ),
            settings: RouteSettings(name: 'InventorySearchList'),
          )).then((value) {});
    //   if (widget.customerID != null && widget.customerID!.isNotEmpty) {
    //   Navigator.pop(context);
    // }
  }

  Widget _closeButton(BuildContext context) => InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(bottom: 24),
          child: Icon(
            Icons.close,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
      );
}
