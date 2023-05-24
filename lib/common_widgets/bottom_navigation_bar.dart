import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as pdb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlp;
import 'package:gc_customer_app/data/reporsitories/customer_look_up_repository/customer_lookup_repository.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/cart/views/cart_page.dart';
import 'package:gc_customer_app/screens/customer_look_up/customer_lookup_widget.dart';
import 'package:gc_customer_app/screens/inventory_search/inventory_search_page.dart';
import 'package:gc_customer_app/screens/my_customer/my_customer_screen.dart';
import 'package:gc_customer_app/screens/order_lookup/order_lookup_screen.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import '../primitives/icon_system.dart';
import '../utils/routes/cart_page_arguments.dart';
import 'notched_bottom_navigation_bar.dart';

class AppBottomNavBar extends StatelessWidget {
  CustomerInfoModel? customerInfoModel;
  Widget? secondWidget;
  String? onPress;
  InventorySearchBloc? inventorySearchBloc;
  pdb.ProductDetailBloc? productDetailBloc;
  zlp.ZipStoreListBloc? zipStoreListBloc;
  final bool isInInventoryLookup;
  final bool isInCustomerLookup;
  final bool isFromMyCustomer;
  AppBottomNavBar(
      [this.customerInfoModel,
      this.onPress,
      this.secondWidget,
      this.inventorySearchBloc,
      this.productDetailBloc,
      this.zipStoreListBloc,
      this.isInInventoryLookup = false,
      this.isInCustomerLookup = false,
      this.isFromMyCustomer = false]);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventorySearchBloc, InventorySearchState>(
        builder: (context, state) {
      return NotchedBottomNavigationBar(
        actions: [
          secondWidget ??
              IconButton(
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () {
                  if (!isInCustomerLookup && !isInInventoryLookup) {
                    showInventoryLookup(context).then((value) {});
                  } else if (isInCustomerLookup && !isInInventoryLookup) {
                    Navigator.pop(context);
                  }
                },
                icon: SvgPicture.asset(
                  IconSystem.bottomBuilding,
                  package: 'gc_customer_app',
                  color: Theme.of(context).primaryColor,
                  width: 24,
                  height: 24,
                ),
              ),
          IconButton(
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () {
              if (!isInCustomerLookup &&
                  !isInInventoryLookup &&
                  !isFromMyCustomer) {
                showCustomerLookup(context).then((value) {});
              } else if ((!isInCustomerLookup && isInInventoryLookup) ||
                  isFromMyCustomer) {
                Navigator.pop(context);
              }
            },
            icon: SvgPicture.asset(
              IconSystem.bottomUser,
              package: 'gc_customer_app',
              color: Theme.of(context).primaryColor,
              width: 24,
              height: 24,
            ),
          ),
          IconButton(
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () {
              if (customerInfoModel != null && !isFromMyCustomer)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyCustomerScreen(
                          customerInfoModel: customerInfoModel),
                    ));
            },
            icon: SvgPicture.asset(
              IconSystem.bottomMyCustomer,
              package: 'gc_customer_app',
              color: Theme.of(context).primaryColor,
              width: 24,
              height: 24,
            ),
          ),
          if (customerInfoModel != null)
            IconButton(
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderLookUpScreen(),
                    ));
              },
              icon: SvgPicture.asset(
                IconSystem.orderLookupIcon,
                package: 'gc_customer_app',
                color: Theme.of(context).primaryColor,
                width: 24,
                height: 24,
              ),
            ),
        ],
        centerButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              if (customerInfoModel != null &&
                  state.productsInCart.isNotEmpty) {
                // if(onPress == "pop"){
                //   Navigator.pop(context);
                // }
                // else{
                Navigator.pushNamed(
                  context,
                  CartPage.routeName,
                  arguments: CartArguments(
                    email: customerInfoModel!.records![0].accountEmailC != null
                        ? customerInfoModel!.records![0].accountEmailC!
                        : customerInfoModel!.records![0].emailC != null
                            ? customerInfoModel!.records![0].emailC!
                            : customerInfoModel!.records![0].personEmail != null
                                ? customerInfoModel!.records![0].personEmail!
                                : "",
                    phone: customerInfoModel!.records![0].accountPhoneC != null
                        ? customerInfoModel!.records![0].accountPhoneC!
                        : customerInfoModel!.records![0].phone != null
                            ? customerInfoModel!.records![0].phone!
                            : customerInfoModel!.records![0].phoneC != null
                                ? customerInfoModel!.records![0].phoneC!
                                : "",
                    orderId: state.orderId,
                    orderLineItemId: state.orderLineItemId,
                    orderNumber: state.orderId,
                    orderDate: DateTime.now().toString(),
                    userName: customerInfoModel!.records?[0].name ?? "",
                    userId: customerInfoModel!.records?[0].id ?? '',
                    customerInfoModel: customerInfoModel!,
                  ),
                ).then((value) {
                  if (inventorySearchBloc != null) {
                    inventorySearchBloc!.add(DoneMessage());
                  }
                  if (state.productsInCart.isNotEmpty) {
                    for (int i = 0; i < state.productsInCart.length; i++) {
                      // if (favoriteItems.wrapperinstance!.records![index].childskus!.first.skuENTId ==
                      //     state.productsInCart[i].childskus!.first.skuENTId) {
                      //   favouriteBrandScreenBloc
                      //       .add(UpdateProduct(
                      //       index: index,
                      //       records: records,
                      //       ifNative: false));
                      // }
                    }
                  }
                });
              }
            },
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Theme.of(context).primaryColorDark,
            )),
        productsInCart: state.itemOfCart,
      );
    });
  }

  Future showCustomerLookup(BuildContext context) async {
    var loggedInUser = await SharedPreferenceService().getValue(agentId);
    if (isInInventoryLookup) {
      Navigator.pop(context);
//      return;
    }

    return showModalBottomSheet(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9),
            isScrollControlled: true,
            context: context,
            useRootNavigator: false,
            builder: (BuildContext context) {
              return BlocProvider<CustomerLookUpBloc>(
                create: (context) =>
                    CustomerLookUpBloc(CustomerLookUpRepository()),
                child: CustomerLookUpWidget(),
              );
            },
            backgroundColor: Colors.transparent)
        .then((value) {
      if (isFromMyCustomer) Navigator.pop(context);
      if (value == true) {
        context.read<LandingScreenBloc>().add(LoadData());
        if (isInInventoryLookup) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
      if (value == null) {
        showInventoryLookup(context);
      }
      return value;
    });
  }

  Future showInventoryLookup(BuildContext context) async {
    var loggedInUser = await SharedPreferenceService().getValue(agentId);
    if (loggedInUser.toString().isEmpty) {
      context.read<LandingScreenBloc>().add(RemoveCustomer());
    }
    if (isInCustomerLookup) {
      Navigator.pop(context);
      //return;
    }

    return showModalBottomSheet(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9),
            isScrollControlled: true,
            context: context,
            useRootNavigator: false,
            builder: (BuildContext context) {
              return InventorySearchPage(
                  customerID: (customerInfoModel?.records ?? []).isEmpty ||
                          loggedInUser.toString().isEmpty
                      ? ""
                      : customerInfoModel?.records?.first.id ?? '',
                  customer: (customerInfoModel?.records == null ||
                          customerInfoModel!.records!.isEmpty ||
                          loggedInUser.toString().isEmpty)
                      ? CustomerInfoModel(records: [Records(id: null)])
                      : customerInfoModel);
            },
            backgroundColor: Colors.transparent)
        .then((value) {
      if (isFromMyCustomer) Navigator.pop(context);
      if (value == true) {
        context.read<LandingScreenBloc>().add(LoadData());
      }
      if (value == null && loggedInUser.toString().isEmpty) {
        showCustomerLookup(context);
      }
      return value;
    });
  }
}
