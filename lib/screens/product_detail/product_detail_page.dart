import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/common_models/child_sku_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart'
    as cim;
import 'package:gc_customer_app/screens/product_detail/product_detail_list.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import '../../bloc/product_detail_bloc/product_detail_bloc.dart';
import '../../data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import '../../models/inventory_search/add_search_model.dart';
import '../../primitives/color_system.dart';

class ProductDetailPage extends StatelessWidget {
  final String customerID;
  final cim.CustomerInfoModel? customer;
  Warranties warranties;
  String? orderId;
  String? highPrice;
  String? warrantyId;
  bool fromInventory;
  String? orderLineItemId;
  String previousPage;
  List<Records> productsInCart;
  List<Childskus>? childskus;
  Items? cartItemInfor;
  final String skUID;

  ProductDetailPage(
      {Key? key,
      required this.skUID,
      required this.orderLineItemId,
      this.highPrice = "",
      this.previousPage = "",
      required this.warranties,
      required this.orderId,
      required this.customerID,
      this.customer,
      this.fromInventory = false,
      this.warrantyId = "",
      required this.productsInCart,
      this.childskus,
      this.cartItemInfor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorSystem.culturedGrey,
      child: SafeArea(
        bottom: false,
        child: ProductDetailList(
            customerID: customerID,
            customer: customer,
            highPrice: highPrice,
            previousPage: previousPage,
            fromInventory: fromInventory,
            warrantyId: warrantyId,
            warranties: warranties,
            orderLineItemId: orderLineItemId,
            orderId: orderId,
            productsInCart: productsInCart,
            cartItemInfor: cartItemInfor,
            childskus: childskus,
            skUEntId: skUID),
      ),
    );
  }
}
