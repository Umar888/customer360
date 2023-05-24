import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/zip_store_list/zip_stores_list.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;

class ZipStorePage extends StatelessWidget {
  final String customerID;
  final CustomerInfoModel? customer;
  final String? orderID;
  final String? orderLineItemId;
  List<GetZipCodeList> getZipCodeListSearch;
  List<GetZipCodeList> getZipCodeList;
  final List<asm.Records> productsInCart;
  final asm.Records records;
  Items? cartItemInfor;

  ZipStorePage(
      {Key? key,
      required this.orderLineItemId,
      required this.getZipCodeList,
      required this.records,
      required this.getZipCodeListSearch,
      required this.orderID,
      required this.customerID,
      this.customer,
      required this.productsInCart,
      this.cartItemInfor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Container(
        color: ColorSystem.culturedGrey,
        child: ZipStoresList(
            customerID: customerID,
            customer: customer,
            orderLineItemId: orderLineItemId,
            getZipCodeList: getZipCodeList,
            getZipCodeListSearch: getZipCodeListSearch,
            orderID: orderID,
            productsInCart: productsInCart,
            cartItemInfor: cartItemInfor,
            records: records),
      ),
    );
  }
}
