import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/cart_bloc/order_cards_bloc/order_cards_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/common_widgets/cart_widgets/cart_item.dart';
import 'package:gc_customer_app/common_widgets/cart_widgets/shipping_override_tile.dart';
import 'package:gc_customer_app/common_widgets/scanner_view.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/views/flutter_credit_card.dart';
import 'package:gc_customer_app/intermediate_widgets/stepper/src/dot_stepper/dot_stepper.dart';
import 'package:gc_customer_app/models/address_models/delivery_model.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/cart/views/addresses/addresses_page.dart';
import 'package:gc_customer_app/screens/cart/views/order_payment/order_payment_page.dart';
import 'package:gc_customer_app/screens/cart/views/summary_payment/delivery_panel_widget.dart';
import 'package:gc_customer_app/screens/cart/views/summary_payment/payment_panel_widget.dart';
import 'package:gc_customer_app/screens/cart/views/summary_payment/summary_payment_view.dart';
import 'package:gc_customer_app/screens/order_detail/order_success.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:intl/intl.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../bloc/cart_bloc/add_customer_bloc/add_customer_bloc.dart';
import '../../../bloc/cart_bloc/cart_bloc.dart';
import '../../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart'
    as fbsb;
import '../../../common_widgets/loading_theme.dart';
import '../../../intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import '../../../models/address_models/address_model.dart';
import '../../../models/cart_model/cart_popup_menu.dart';
import '../../../models/cart_model/order_proceed.dart';
import '../../../primitives/color_system.dart';
import '../../../primitives/constants.dart';
import '../../../primitives/padding_system.dart';
import '../../../services/networking/endpoints.dart';
import '../../../services/networking/networking_service.dart';
import '../../../services/networking/request_body.dart';
import '../../../services/storage/shared_preferences_service.dart';
import '../../add_commission/add_commission_page.dart';
import '../../quote_log/quote_log_page.dart';
import 'add_new_customer.dart';

typedef MyBuilder = void Function(
    BuildContext context, void Function() addCustomer);

class CartList extends StatefulWidget {
  final String orderId;
  final String orderLineItemId;
  final String orderNumber;
  final String orderDate;
  final CustomerInfoModel customerInfoModel;
  final String userName;
  final String userId;
  final String email;
  final String phone;
  final bool isFromNotificaiton;

  CartList(
      {required this.email,
      required this.phone,
      required this.userId,
      required this.orderLineItemId,
      required this.orderId,
      required this.customerInfoModel,
      required this.orderNumber,
      required this.orderDate,
      required this.userName,
      this.isFromNotificaiton = false,
      Key? key})
      : super(key: key);

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  late Future<void> _futureOrderDetail;
  StreamSubscription? streamSubscription;
  late void Function() myMethod;

  late isb.InventorySearchBloc inventorySearchBloc;
  PanelController totalPC = PanelController();
  PanelController paymentPC = PanelController();
  PanelController deliveryPC = PanelController();
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController shareEmailController = TextEditingController();
  TextEditingController sharePhoneController = TextEditingController();
  final StreamController<bool> isPaymentExpandSC =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<bool> isDeliveryExpandSC =
      StreamController<bool>.broadcast()..add(false);
  late Future<String> _recordId;

  // DraggableScrollableController? controller = DraggableScrollableController();

  late BuildContext draggableSheetContext;

  List<CartPopupMenu> cartPopupMenu = [];

  ScrollController scrollController = ScrollController();

  proceedOrder(CartState cartState, List<CreditCardModelSave> cards) async {
    cartBloc.add(UpdateProceedingOrder(value: true));
    bool isPickup = cartState.orderDetailModel.first.shippingMethod
            ?.toLowerCase()
            .contains('pick from store') ??
        false;
    cards.forEach((c) {
      c.paymentMethod?.amount =
          (c.availableAmount ?? '0.0').replaceAll(',', '');
      if (c.isSameAsShippingAddress && !isPickup) {
        AddressList? selectedAddress =
            cartState.selectedAddressIndex >= cartState.addressModel.length
                ? null
                : cartState.addressModel[cartState.selectedAddressIndex];
        if (selectedAddress != null) {
          selectedAddress.address1 = cartState.selectedAddress1;
          selectedAddress.address2 = cartState.selectedAddress2;
          selectedAddress.city = cartState.selectedAddressCity;
          selectedAddress.state = cartState.selectedAddressState;
          selectedAddress.postalCode = cartState.selectedAddressPostalCode;
        }
        c.paymentMethod?.address = selectedAddress?.address1 ?? '';
        c.paymentMethod?.address2 = selectedAddress?.address2 ?? '';
        c.paymentMethod?.country = selectedAddress?.country ?? '';
        c.paymentMethod?.city = selectedAddress?.city ?? '';
        c.paymentMethod?.state = selectedAddress?.state ?? '';
        c.paymentMethod?.zipCode = selectedAddress?.postalCode ?? '';
      } else if (isPickup &&
          cartState.selectedPickupStore != null &&
          (c.cardType == PaymentMethodType.cOA ||
              c.cardType == PaymentMethodType.gcGift)) {
        var selectedAddress = cartState.selectedPickupStore;
        c.paymentMethod?.address = selectedAddress!.storeAddressC ?? '';
        c.paymentMethod?.address2 = '';
        c.paymentMethod?.country = selectedAddress!.countryC ?? '';
        c.paymentMethod?.city = selectedAddress!.storeCityC ?? '';
        c.paymentMethod?.state = selectedAddress!.stateC ?? '';
        c.paymentMethod?.zipCode = selectedAddress!.postalCodeC ?? '';
        c.paymentMethod?.firstName =
            cartState.customerInfoModel!.records?.first.firstName ?? '';
        c.paymentMethod?.lastName =
            cartState.customerInfoModel!.records?.first.lastName ?? '';
      }
      c.paymentMethod?.email = cartState.shippingEmail.isNotEmpty
          ? cartState.shippingEmail
          : (cartState.customerInfoModel!.records?.first.accountEmailC ?? '');
      c.paymentMethod?.phone = cartState.shippingPhone.isNotEmpty
          ? cartState.shippingPhone
          : (cartState.customerInfoModel!.records?.first.accountPhoneC ?? '');
    });

    if (!isPickup) {
      completeOrder(cartState, cards, isPickup);
    } else {
      completeOrder(cartState, cards, isPickup);
    }
  }

  Future completeOrder(CartState cartState, List<CreditCardModelSave> cards,
      bool isPickup) async {
    print(RequestBody.getOrderProceedBody(
      creditModel: cards,
      orderID: widget.orderId,
      store: isPickup ? cartState.selectedPickupStore : null,
      discount: cartState.appliedCouponDiscount,
    ).toString().substring(0, 500));
    print(RequestBody.getOrderProceedBody(
      creditModel: cards,
      orderID: widget.orderId,
      store: isPickup ? cartState.selectedPickupStore : null,
      discount: cartState.appliedCouponDiscount,
    ).toString().substring(500));
    
    FirebaseAnalytics.instance.logEvent(
          name: 'place_order', parameters: RequestBody.getOrderProceedBody(
      creditModel: cards,
      orderID: widget.orderId,
      store: isPickup ? cartState.selectedPickupStore : null,
      discount: cartState.appliedCouponDiscount,
    ));

    var response = await HttpService().doPost(
        path: Endpoints.orderProceed(),
        body: RequestBody.getOrderProceedBody(
          creditModel: cards,
          orderID: widget.orderId,
          store: isPickup ? cartState.selectedPickupStore : null,
          discount: cartState.appliedCouponDiscount,
        ),
        tokenRequired: true);
    if (response.data == null) {
      cartBloc.add(UpdateProceedingOrder(value: false));
      return;
    }
    OrderProceed orderProceed =
        OrderProceed.fromJson(jsonDecode(response.data));

    if (orderProceed.message!.contains("Success")) {
      cartBloc.add(UpdateProceedingOrder(value: false));
      cartBloc.add(ClearRecommendedAddresses());

      bool isNotLoggedIn = (cartState.customerInfoModel!.records == null ||
          cartState.customerInfoModel!.records!.isEmpty ||
          cartState.customerInfoModel!.records!.first.id == null);

      if (isNotLoggedIn) {
        await SharedPreferenceService().setKey(key: agentId, value: "");
        await SharedPreferenceService().setKey(key: agentEmail, value: "");
        await SharedPreferenceService().setKey(key: savedAgentName, value: "");
        await SharedPreferenceService().setKey(key: agentIndex, value: "");
        await SharedPreferenceService().setKey(key: agentPhone, value: "");
      }
      if (widget.isFromNotificaiton) {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderSuccess(
                successMsg: orderProceed.message ?? '',
                orderId: widget.orderId,
                proceedOrder: RequestBody.getOrderProceedBody(
                  creditModel: cards,
                  orderID: widget.orderId,
                  store: isPickup ? cartState.selectedPickupStore : null,
                  discount: cartState.appliedCouponDiscount,
                ),
                orderDetail: cartState.orderDetailModel.first,
                isFromNotification: widget.isFromNotificaiton,
                isSelectedAgent: !isNotLoggedIn,
              ),
            ));
      } else {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderSuccess(
                successMsg: orderProceed.message ?? '',
                orderId: widget.orderId,
                proceedOrder: RequestBody.getOrderProceedBody(
                  creditModel: cards,
                  orderID: widget.orderId,
                  store: isPickup ? cartState.selectedPickupStore : null,
                  discount: cartState.appliedCouponDiscount,
                ),
                orderDetail: cartState.orderDetailModel.first,
                isFromNotification: widget.isFromNotificaiton,
                isSelectedAgent: !isNotLoggedIn,
              ),
            ));
      }
    } else {
      showMessage(message: orderProceed.message ?? "", context: context);
      //showMessage(context: context,message:orderProceed.message!);
      cartBloc.add(UpdateProceedingOrder(value: false));
      cartBloc.add(ClearRecommendedAddresses());
    }
  }

  late AddCustomerBloc addCustomerBloc;
  FocusNode labelNode = FocusNode();
  FocusNode cityNode = FocusNode();
  FocusNode stateNode = FocusNode();
  FocusNode addressNode = FocusNode();
  FocusNode zipNode = FocusNode();

  TextEditingController labelController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  GlobalKey<FormState> quoteForm = new GlobalKey();
  GlobalKey<FormState> deleteOrderForm = new GlobalKey();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  late CartBloc cartBloc;
  BuildContext? couponDialogContext;

  @override
  initState() {
    super.initState();
    // if (!kIsWeb)
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'CartScreen');
    cartBloc = context.read<CartBloc>();
    addCustomerBloc = context.read<AddCustomerBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    cartBloc.add(PageLoad(
      customerId:widget.customerInfoModel,
        orderID: widget.orderId,
        inventorySearchBloc: inventorySearchBloc));
    setRecordId();
    streamSubscription = cartBloc.stream.listen((state) {
      if (state.isCouponSubmitDone == true) {
        Navigator.pop(context);
      }
    });
  }

  Widget getAppBar(List<Items> e, CartState cartState) {
    return Padding(
      padding: EdgeInsets.only(
        left: PaddingSystem.padding10,
        right: PaddingSystem.padding5,
        top: PaddingSystem.padding10,
        bottom: PaddingSystem.padding10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (cartState.isUpdating) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          snackBar("Please wait until cart update"));
                    } else {
                      addCustomerBloc.add(ResetData());
                      addCustomerBloc.add(ClearMessage());
                      addCustomerBloc.add(UpdateShowOptions(false));

                      if (e
                              .where((element) => element.quantity! > 0)
                              .isNotEmpty &&
                          e.where((element) => element.isCartAdding!).isEmpty) {
                        totalPC.close();
                        deliveryPC.close();
                        paymentPC.close();
                        if (cartState.addAddress) {
                          cartBloc.add(UpdateAddAddress(value: false));
                        } else if (cartState.showAddCard) {
                          cartBloc.add(UpdateShowAddCard(value: false));
                        } else {
                          cartBloc
                              .add((ChangeIsExpandedBottomSheet(value: false)));
                          if (cartState.activeStep == 4) {
                            cartBloc.add(UpdateActiveStep(value: 3));
                          }
                          if (cartState.activeStep == 3) {
                            cartBloc.add(UpdateActiveStep(value: 2));
                          } else if (cartState.activeStep == 2) {
                            cartBloc.add(UpdateActiveStep(value: 1));
                          } else if (cartState.activeStep == 1) {
                            cartBloc.add(UpdateActiveStep(value: 0));
                          } else {
                            if (cartState.customerInfoModel!.records == null ||
                                cartState.customerInfoModel!.records!.isEmpty ||
                                cartState.customerInfoModel!.records!.first.id ==
                                    null) {
                              await SharedPreferenceService()
                                  .setKey(key: agentId, value: "");
                              await SharedPreferenceService()
                                  .setKey(key: agentEmail, value: "");
                              await SharedPreferenceService()
                                  .setKey(key: savedAgentName, value: "");
                              await SharedPreferenceService()
                                  .setKey(key: agentIndex, value: "");
                              await SharedPreferenceService()
                                  .setKey(key: agentPhone, value: "");
                            }
                            Navigator.of(context).pop(e);
                          }
                        }
                      } else {
                        if (cartState.customerInfoModel!.records == null ||
                            cartState.customerInfoModel!.records!.isEmpty ||
                            cartState.customerInfoModel!.records!.first.id ==
                                null) {
                          await SharedPreferenceService()
                              .setKey(key: agentId, value: "");
                          await SharedPreferenceService()
                              .setKey(key: agentEmail, value: "");
                          await SharedPreferenceService()
                              .setKey(key: savedAgentName, value: "");
                          await SharedPreferenceService()
                              .setKey(key: agentIndex, value: "");
                          await SharedPreferenceService()
                              .setKey(key: agentPhone, value: "");
                        }
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Icon(
                    Icons.close,
                    size: SizeSystem.size28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder(
                    future: SharedPreferenceService().getValue(savedAgentName),
                    builder: (context, text) {
                      if (text.hasData) {
                        return Text(
                          "${text.data!}${text.data!.isNotEmpty ? "'s " : ""}CART (${cartState.cartStatus == CartStatus.successState ? e.length : "0"})",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        );
                      } else {
                        return Text(
                          "${widget.userName}${widget.userName.isNotEmpty ? "'s " : ""}CART (${cartState.cartStatus == CartStatus.successState ? e.length : "0"})",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        );
                      }
                    }),
                SizedBox(
                  height: cartState.orderDetailModel != null &&
                          cartState.orderDetailModel.isNotEmpty &&
                          cartState.orderDetailModel[0].orderNumber != null
                      ? 5
                      : 0,
                ),
                cartState.orderDetailModel != null &&
                        cartState.orderDetailModel.isNotEmpty &&
                        cartState.orderDetailModel[0].orderNumber != null
                    ? Text(
                        cartState.orderDetailModel[0].orderNumber!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: SizeSystem.size15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik),
                      )
                    : SizedBox.shrink()
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    var recordID =
                        await SharedPreferenceService().getValue(agentId);
                    // if(recordID.isEmpty){
                    //   showMessage(context: context,message:"Please select a customer");
                    // }
                    // else{
                    if (e
                            .where((element) => element.quantity! > 0)
                            .isNotEmpty &&
                        e.where((element) => element.isCartAdding!).isEmpty) {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => AddCommissionPage(
                              orderId: widget.orderId,
                              orderNumber: widget.orderNumber,
                              orderDate: widget.orderDate,
                              userName: widget.userName,
                              userId: widget.userId,
                            ),
                          ));
                    }
                    //}
                  },
                  child: SvgPicture.asset(IconSystem.percentage,
                      package: 'gc_customer_app',
                      color: Theme.of(context).primaryColor),
                ),
                IconButton(
                    onPressed: () async {
                      var recordID =
                          await SharedPreferenceService().getValue(agentId);

                      showCupertinoDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext dialogContext) {
                          if (recordID.isEmpty) {
                            return BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 8.0,
                                sigmaY: 8.0,
                              ),
                              child: CupertinoAlertDialog(
                                actions: [
                                  Material(
                                    color: Colors.white30,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20.0),
                                            child: Text(
                                              "More Options",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.black54,
                                            height: 1,
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: SvgPicture.asset(
                                                    IconSystem.cart,
                                                    package: 'gc_customer_app',
                                                    width: 24,
                                                    color: ColorSystem.black),
                                                onTap: () {
                                                  Navigator.pop(dialogContext);

                                                  showCupertinoDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (BuildContext
                                                        dialogContext) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                          sigmaX: 8.0,
                                                          sigmaY: 8.0,
                                                        ),
                                                        child:
                                                            BlocProvider.value(
                                                          value: cartBloc,
                                                          child: BlocBuilder<
                                                                  CartBloc,
                                                                  CartState>(
                                                              builder: (_context,
                                                                  stateCart) {
                                                            return CupertinoAlertDialog(
                                                              title: Text(
                                                                "Clear Cart",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize:
                                                                        19,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              content: Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    Text(
                                                                      "Are you sure, you want to clear the cart?",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      "OK"),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop();
                                                                    if (cartBloc
                                                                        .state
                                                                        .orderDetailModel
                                                                        .first
                                                                        .items!
                                                                        .isNotEmpty) {
                                                                      bool isNotLoggedIn = (cartState.customerInfoModel!.records ==
                                                                              null ||
                                                                          cartState.customerInfoModel!
                                                                              .records!
                                                                              .isEmpty ||
                                                                          cartState.customerInfoModel!.records!.first.id ==
                                                                              null);
                                                                      if (isNotLoggedIn) {
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentId,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentEmail,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                savedAgentName,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentIndex,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentPhone,
                                                                            value:
                                                                                "");
                                                                      }

                                                                      addCustomerBloc
                                                                          .add(
                                                                              ResetData());
                                                                      addCustomerBloc
                                                                          .add(
                                                                              ClearMessage());
                                                                      addCustomerBloc.add(
                                                                          UpdateShowOptions(
                                                                              false));
                                                                      cartBloc.add(
                                                                          ClearWholeCart(
                                                                        inventorySearchBloc:
                                                                            inventorySearchBloc,
                                                                        customerID:
                                                                            widget.userId,
                                                                        orderID:
                                                                            widget.orderId,
                                                                        e: cartBloc
                                                                            .state
                                                                            .orderDetailModel
                                                                            .first
                                                                            .items!,
                                                                        onCompleted: () => Navigator.pop(
                                                                            context,
                                                                            "isDel"),
                                                                      ));

                                                                      if (inventorySearchBloc
                                                                          .state
                                                                          .productsInCart
                                                                          .where((element) =>
                                                                              element.childskus!.first.skuENTId ==
                                                                              cartBloc.state.orderDetailModel.first.items![0].itemNumber)
                                                                          .isNotEmpty) {
                                                                        inventorySearchBloc.add(isb.RemoveFromCart(
                                                                            favouriteBrandScreenBloc:
                                                                                context.read<fbsb.FavouriteBrandScreenBloc>(),
                                                                            records: inventorySearchBloc.state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == cartBloc.state.orderDetailModel.first.items![0].itemNumber),
                                                                            customerID: widget.userId,
                                                                            quantity: -2,
                                                                            productId: cartBloc.state.orderDetailModel.first.items![0].productId!,
                                                                            orderID: widget.orderId));
                                                                      }
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              _context)
                                                                          .showSnackBar(
                                                                              snackBar("Cart is already empty"));
                                                                    }
                                                                  },
                                                                ),
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      "CANCEL"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          }),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                title: Text(
                                                  "Clear Cart",
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black54,
                                                height: 1,
                                              ),
                                              ListTile(
                                                leading: SvgPicture.asset(
                                                    IconSystem.closedLost,
                                                    package: 'gc_customer_app',
                                                    width: 24,
                                                    color: ColorSystem.black),
                                                onTap: () {
                                                  Navigator.pop(dialogContext);
                                                  cartBloc
                                                      .add(GetDeleteReasons());
                                                  showCupertinoDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (BuildContext
                                                        dialogContext) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                          sigmaX: 8.0,
                                                          sigmaY: 8.0,
                                                        ),
                                                        child:
                                                            BlocProvider.value(
                                                          value: cartBloc,
                                                          child: BlocBuilder<
                                                                  CartBloc,
                                                                  CartState>(
                                                              builder:
                                                                  (buildContext,
                                                                      stateCart) {
                                                            return Form(
                                                              key:
                                                                  deleteOrderForm,
                                                              child:
                                                                  CupertinoAlertDialog(
                                                                title: Text(
                                                                  "Delete Order",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          19,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                content:
                                                                    Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black54,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Text(
                                                                        "Are you sure, you no longer need this order?",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black87,
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      stateCart
                                                                              .fetchingReason
                                                                          ? InputDecorator(
                                                                              decoration: InputDecoration(
                                                                                  labelText: 'Please wait...',
                                                                                  hintText: 'Reason',
                                                                                  alignLabelWithHint: true,
                                                                                  constraints: BoxConstraints(),
                                                                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                                                  labelStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  helperStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: ColorSystem.greyDark,
                                                                                      width: 1,
                                                                                    ),
                                                                                  )),
                                                                              isEmpty: true,
                                                                              child: DropdownButton<String>(
                                                                                hint: Text('', style: TextStyle(color: Theme.of(context).primaryColor)),
                                                                                icon: Padding(
                                                                                  padding: EdgeInsets.only(right: 2.0),
                                                                                  child: Icon(Icons.expand_more_outlined, color: Theme.of(context).primaryColor),
                                                                                ),
                                                                                underline: Container(),
                                                                                isExpanded: true,
                                                                                isDense: true,
                                                                                items: <String>[].map((String value) {
                                                                                  return DropdownMenuItem<String>(
                                                                                    value: value,
                                                                                    child: Text(
                                                                                      value,
                                                                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                                                                    ),
                                                                                  );
                                                                                }).toList(),
                                                                                onChanged: (_) async {},
                                                                              ),
                                                                            )
                                                                          : DropdownButtonFormField<
                                                                              String>(
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return "Please select delete reason";
                                                                                }
                                                                                return null;
                                                                              },
                                                                              decoration: InputDecoration(
                                                                                  labelText: 'Select Delete Reason',
                                                                                  hintText: 'Reason',
                                                                                  alignLabelWithHint: true,
                                                                                  constraints: BoxConstraints(),
                                                                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                                                  labelStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  helperStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                                  errorBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: ColorSystem.lavender3,
                                                                                      width: 1,
                                                                                    ),
                                                                                  ),
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: ColorSystem.greyDark,
                                                                                      width: 1,
                                                                                    ),
                                                                                  )),
                                                                              hint: Text(stateCart.selectedReason.isEmpty ? "Select Delete Reason" : stateCart.selectedReason, style: TextStyle(color: Theme.of(context).primaryColor)),
                                                                              icon: Padding(
                                                                                padding: EdgeInsets.only(right: 2.0),
                                                                                child: Icon(Icons.expand_more_outlined, color: Theme.of(context).primaryColor),
                                                                              ),
                                                                              isExpanded: true,
                                                                              isDense: true,
                                                                              items: stateCart.reasonList.map((String value) {
                                                                                return DropdownMenuItem<String>(
                                                                                  value: value,
                                                                                  child: Text(
                                                                                    value,
                                                                                    style: TextStyle(color: Theme.of(context).primaryColor),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (_) async {
                                                                                cartBloc.add(ChangeDeleteReason(reason: _ ?? ""));
                                                                              },
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                        "OK"),
                                                                    onPressed: stateCart
                                                                            .fetchingReason
                                                                        ? null
                                                                        : () async {
                                                                            final formState =
                                                                                deleteOrderForm.currentState;
                                                                            if (formState!.validate()) {
                                                                              formState.save();
                                                                              bool isNotLoggedIn = (cartState.customerInfoModel!.records == null || cartState.customerInfoModel!.records!.isEmpty || cartState.customerInfoModel!.records!.first.id == null);
                                                                              if (isNotLoggedIn) {
                                                                                await SharedPreferenceService().setKey(key: agentId, value: "");
                                                                                await SharedPreferenceService().setKey(key: agentEmail, value: "");
                                                                                await SharedPreferenceService().setKey(key: savedAgentName, value: "");
                                                                                await SharedPreferenceService().setKey(key: agentIndex, value: "");
                                                                                await SharedPreferenceService().setKey(key: agentPhone, value: "");
                                                                              }
                                                                              addCustomerBloc.add(ResetData());
                                                                              addCustomerBloc.add(ClearMessage());
                                                                              addCustomerBloc.add(UpdateShowOptions(false));
                                                                              cartBloc.add(DeleteOrder(
                                                                                orderId: widget.orderId,
                                                                                reason: stateCart.selectedReason,
                                                                                inventorySearchBloc: inventorySearchBloc,
                                                                                onSuccess: () => Navigator.pop(context, "isDel"),
                                                                              ));
                                                                              if (inventorySearchBloc.state.productsInCart.where((element) => element.childskus!.first.skuENTId == cartBloc.state.orderDetailModel.first.items![0].itemNumber).isNotEmpty) {
                                                                                inventorySearchBloc.add(isb.RemoveFromCart(favouriteBrandScreenBloc: context.read<fbsb.FavouriteBrandScreenBloc>(), records: inventorySearchBloc.state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == cartBloc.state.orderDetailModel.first.items![0].itemNumber), customerID: widget.userId, quantity: -2, productId: cartBloc.state.orderDetailModel.first.items![0].productId!, orderID: widget.orderId));
                                                                              }
                                                                              Navigator.of(dialogContext).pop();
                                                                            }
                                                                          },
                                                                  ),
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                        "CANCEL"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              dialogContext)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) {
                                                    cartBloc.add(
                                                        ChangeDeleteReason(
                                                            reason: ""));
                                                  });
                                                },
                                                title: Text(
                                                  "Delete Order",
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 8.0,
                                sigmaY: 8.0,
                              ),
                              child: CupertinoAlertDialog(
                                actions: [
                                  Material(
                                    color: Colors.white30,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20.0),
                                            child: Text(
                                              "More Options",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.black54,
                                            height: 1,
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: SvgPicture.asset(
                                                    IconSystem.quote,
                                                    package: 'gc_customer_app',
                                                    width: 24,
                                                    color: ColorSystem.black),
                                                onTap: () {
                                                  Navigator.pop(dialogContext);
                                                  setState(() {
                                                    shareEmailController.text =
                                                        widget.email;
                                                  });
                                                  showModalBottomSheet(
                                                      clipBehavior: Clip
                                                          .antiAliasWithSaveLayer,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30.0),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext
                                                          context) {
                                                        return BlocProvider
                                                            .value(
                                                          value: cartBloc,
                                                          child: BlocBuilder<
                                                                  CartBloc,
                                                                  CartState>(
                                                              builder: (context,
                                                                  stateCart) {
                                                            return BackdropFilter(
                                                              filter:
                                                                  ImageFilter
                                                                      .blur(
                                                                sigmaX: 4.0,
                                                                sigmaY: 4.0,
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                        .all(
                                                                            30.0)
                                                                    .copyWith(
                                                                        bottom: MediaQuery.of(context).viewInsets.bottom +
                                                                            30),
                                                                child: Form(
                                                                  key:
                                                                      quoteForm,
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text("Share Quote to",
                                                                                maxLines: 1,
                                                                                style: TextStyle(fontSize: SizeSystem.size20, overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor, fontFamily: kRubik)),
                                                                          ),
                                                                          IconButton(
                                                                              onPressed: () {
                                                                                Navigator.push(
                                                                                    context,
                                                                                    CupertinoPageRoute(
                                                                                      builder: (context) => QuoteLogPage(orderId: widget.orderId, orderDate: widget.orderDate, cartState: cartState),
                                                                                    ));
                                                                              },
                                                                              icon: SvgPicture.asset(
                                                                                IconSystem.quote,
                                                                                package: 'gc_customer_app',
                                                                                width: 24,
                                                                              ))
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              "${e.length} Items",
                                                                              maxLines: 1,
                                                                              style: TextStyle(fontSize: SizeSystem.size19, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor, fontFamily: kRubik)),
                                                                          Text(
                                                                              r"$" + amountFormatting(stateCart.orderDetailModel[0].subtotal!),
                                                                              maxLines: 1,
                                                                              style: TextStyle(fontSize: SizeSystem.size19, overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor, fontFamily: kRubik)),
                                                                        ],
                                                                      ),
                                                                      stateCart
                                                                              .currentQuoteID
                                                                              .isNotEmpty
                                                                          ? SizedBox(
                                                                              height:
                                                                                  10)
                                                                          : SizedBox
                                                                              .shrink(),
                                                                      stateCart
                                                                              .currentQuoteID
                                                                              .isNotEmpty
                                                                          ? Text(
                                                                              "#${stateCart.currentQuoteID}",
                                                                              maxLines: 1,
                                                                              style: TextStyle(fontSize: SizeSystem.size19, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500, color: ColorSystem.greyDark, fontFamily: kRubik))
                                                                          : SizedBox.shrink(),
                                                                      SizedBox(
                                                                          height:
                                                                              20),
                                                                      TextFormField(
                                                                        autofocus:
                                                                            false,
                                                                        cursorColor:
                                                                            Theme.of(context).primaryColor,
                                                                        readOnly:
                                                                            true,
                                                                        controller:
                                                                            expirationDateController,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: 16),
                                                                        validator:
                                                                            (value) {
                                                                          if (value!.length <
                                                                              3) {
                                                                            return "Please enter quote expiration date";
                                                                          }
                                                                          return null;
                                                                        },
                                                                        keyboardType:
                                                                            TextInputType.datetime,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Expiration',
                                                                          constraints:
                                                                              BoxConstraints(),
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                              vertical: 0,
                                                                              horizontal: 0),
                                                                          labelStyle:
                                                                              TextStyle(
                                                                            color:
                                                                                ColorSystem.greyDark,
                                                                            fontSize:
                                                                                SizeSystem.size18,
                                                                          ),
                                                                          suffixIcon:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              DateTime now = DateTime.now();
                                                                              DateTime date = DateTime(now.year, now.month, now.day);
                                                                              await showCupertinoModalPopup(
                                                                                filter: ImageFilter.blur(
                                                                                  sigmaX: 4.0,
                                                                                  sigmaY: 4.0,
                                                                                ),
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  DateTime selectedDate = date;
                                                                                  return Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.white,
                                                                                      borderRadius: BorderRadius.only(
                                                                                        topLeft: Radius.circular(SizeSystem.size20),
                                                                                        topRight: Radius.circular(SizeSystem.size20),
                                                                                      ),
                                                                                    ),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          height: 200,
                                                                                          child: CupertinoDatePicker(
                                                                                            mode: CupertinoDatePickerMode.date,
                                                                                            initialDateTime: DateTime.now(),
                                                                                            minimumDate: DateTime(
                                                                                              DateTime.now().year,
                                                                                              DateTime.now().month,
                                                                                              DateTime.now().day,
                                                                                            ),
                                                                                            onDateTimeChanged: (val) {
                                                                                              selectedDate = val;
                                                                                              // setState(() {
                                                                                              //   expirationDateController.text = getFormattedDate(date);
                                                                                              // });
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.symmetric(
                                                                                            horizontal: SizeSystem.size40,
                                                                                            vertical: SizeSystem.size22,
                                                                                          ),
                                                                                          child: ElevatedButton(
                                                                                            style: ButtonStyle(
                                                                                              backgroundColor: MaterialStateProperty.all(
                                                                                                ColorSystem.primary,
                                                                                              ),
                                                                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                                                RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            onPressed: () {
                                                                                              setState(() {
                                                                                                expirationDateController.text = getFormattedDate(selectedDate);
                                                                                              });
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.symmetric(
                                                                                                    vertical: SizeSystem.size16,
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    'Done',
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 16,
                                                                                                      fontFamily: kRubik,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(12.5),
                                                                              child: SvgPicture.asset(
                                                                                IconSystem.calendar,
                                                                                package: 'gc_customer_app',
                                                                                color: ColorSystem.lavender3,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          focusedBorder:
                                                                              UnderlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: ColorSystem.greyDark,
                                                                              width: 1,
                                                                            ),
                                                                          ),
                                                                          errorStyle: TextStyle(
                                                                              color: ColorSystem.lavender3,
                                                                              fontWeight: FontWeight.w400),
                                                                          errorBorder:
                                                                              UnderlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: ColorSystem.lavender3,
                                                                              width: 1,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                      ),
                                                                      TextFormField(
                                                                        autofocus:
                                                                            false,
                                                                        cursorColor:
                                                                            Theme.of(context).primaryColor,
                                                                        controller:
                                                                            shareEmailController,
                                                                        keyboardType:
                                                                            TextInputType.emailAddress,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: 16),
                                                                        onChanged:
                                                                            (text) {
                                                                          cartBloc
                                                                              .add(UpdateSubmitQuoteDone(value: false));
                                                                        },
                                                                        validator:
                                                                            (value) {
                                                                          if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                                              .hasMatch(value!)) {
                                                                            return null;
                                                                          } else {
                                                                            return "Please enter your valid email";
                                                                          }
                                                                        },
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Email ID',
                                                                          constraints:
                                                                              BoxConstraints(),
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                              vertical: 0,
                                                                              horizontal: 0),
                                                                          labelStyle:
                                                                              TextStyle(
                                                                            color:
                                                                                ColorSystem.greyDark,
                                                                            fontSize:
                                                                                SizeSystem.size18,
                                                                          ),
                                                                          enabled:
                                                                              !stateCart.submittingQuote,
                                                                          suffixIcon: stateCart.submittingQuote
                                                                              ? CupertinoActivityIndicator(color: ColorSystem.lavender3)
                                                                              : stateCart.submitQuoteDone
                                                                                  ? Padding(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                      child: SvgPicture.asset(
                                                                                        IconSystem.checkmark,
                                                                                        package: 'gc_customer_app',
                                                                                        color: ColorSystem.additionalGreen,
                                                                                      ),
                                                                                    )
                                                                                  : InkWell(
                                                                                      onTap: () {
                                                                                        final formState = quoteForm.currentState;
                                                                                        if (formState!.validate()) {
                                                                                          formState.save();
                                                                                          cartBloc.add(SubmitQuote(email: shareEmailController.text, phone: sharePhoneController.text.isEmpty ? "" : sharePhoneController.text, expiration: expirationDateController.text, subtotal: (stateCart.orderDetailModel[0].subtotal ?? 0.0).toStringAsFixed(2), orderId: widget.orderId));
                                                                                        }
                                                                                      },
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.all(12.5),
                                                                                        child: SvgPicture.asset(
                                                                                          IconSystem.send,
                                                                                          package: 'gc_customer_app',
                                                                                          color: ColorSystem.lavender3,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                          errorStyle: TextStyle(
                                                                              color: ColorSystem.lavender3,
                                                                              fontWeight: FontWeight.w400),
                                                                          errorBorder:
                                                                              UnderlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: ColorSystem.lavender3,
                                                                              width: 1,
                                                                            ),
                                                                          ),
                                                                          focusedBorder:
                                                                              UnderlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: ColorSystem.greyDark,
                                                                              width: 1,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      stateCart
                                                                              .showMessageField
                                                                          ? SizedBox(
                                                                              height: 30,
                                                                            )
                                                                          : SizedBox
                                                                              .shrink(),
                                                                      // stateCart
                                                                      //         .showMessageField
                                                                      //     ? TextFormField(
                                                                      //         autofocus:
                                                                      //             false,
                                                                      //         cursorColor:
                                                                      //             Theme.of(context).primaryColor,
                                                                      //         controller:
                                                                      //             sharePhoneController,
                                                                      //         keyboardType:
                                                                      //             TextInputType.phone,
                                                                      //         inputFormatters: <TextInputFormatter>[
                                                                      //           FilteringTextInputFormatter.digitsOnly
                                                                      //         ],
                                                                      //         validator:
                                                                      //             (value) {
                                                                      //           if (stateCart.showMessageField && value!.length < 3) {
                                                                      //             return "Please enter your phone number";
                                                                      //           }
                                                                      //           return null;
                                                                      //         },
                                                                      //         decoration:
                                                                      //             InputDecoration(
                                                                      //           labelText: 'Phone Number',
                                                                      //           constraints: BoxConstraints(),
                                                                      //           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                                      //           labelStyle: TextStyle(
                                                                      //             color: ColorSystem.greyDark,
                                                                      //             fontSize: SizeSystem.size18,
                                                                      //           ),
                                                                      //           // suffixIcon: InkWell(
                                                                      //           //   onTap: () {},
                                                                      //           //   child: Padding(
                                                                      //           //     padding: EdgeInsets.all(12.5),
                                                                      //           //     child: SvgPicture.asset(
                                                                      //           //       IconSystem.send,
                                                                      //           //       color: ColorSystem.lavender3,
                                                                      //           //     ),
                                                                      //           //   ),
                                                                      //           // ),
                                                                      //           focusedBorder: UnderlineInputBorder(
                                                                      //             borderSide: BorderSide(
                                                                      //               color: ColorSystem.greyDark,
                                                                      //               width: 1,
                                                                      //             ),
                                                                      //           ),
                                                                      //           errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                      //           errorBorder: UnderlineInputBorder(
                                                                      //             borderSide: BorderSide(
                                                                      //               color: ColorSystem.lavender3,
                                                                      //               width: 1,
                                                                      //             ),
                                                                      //           ),
                                                                      //         ),
                                                                      //       )
                                                                      //     : SizedBox
                                                                      //         .shrink(),
                                                                      SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      // Center(
                                                                      //   child: InkWell(
                                                                      //       onTap: () {
                                                                      //         cartBloc.add(UpdateShowMessageField(value: stateCart.showMessageField == true ? false : true));
                                                                      //       },
                                                                      //       child: Image.asset(
                                                                      //         "assets/icons/messagePic.png",
                                                                      //         width:
                                                                      //             40,
                                                                      //         fit:
                                                                      //             BoxFit.cover,
                                                                      //       )),
                                                                      // ),
                                                                      SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                        );
                                                      }).then((value) {
                                                    setState(() {
                                                      expirationDateController
                                                          .clear();
                                                      shareEmailController
                                                          .clear();
                                                      cartBloc.add(
                                                          UpdateSubmitQuoteDone(
                                                              value: false));
                                                      cartBloc.add(
                                                          UpdateCurrentQuote(
                                                              value: ""));
                                                    });
                                                  });
                                                },
                                                title: Text(
                                                  "Quote",
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black54,
                                                height: 1,
                                              ),
                                              ListTile(
                                                leading: SvgPicture.asset(
                                                    IconSystem.cart,
                                                    package: 'gc_customer_app',
                                                    width: 24,
                                                    color: ColorSystem.black),
                                                onTap: () {
                                                  Navigator.pop(dialogContext);

                                                  showCupertinoDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (BuildContext
                                                        dialogContext) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                          sigmaX: 8.0,
                                                          sigmaY: 8.0,
                                                        ),
                                                        child:
                                                            BlocProvider.value(
                                                          value: cartBloc,
                                                          child: BlocBuilder<
                                                                  CartBloc,
                                                                  CartState>(
                                                              builder: (_context,
                                                                  stateCart) {
                                                            return CupertinoAlertDialog(
                                                              title: Text(
                                                                "Clear Cart",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize:
                                                                        19,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              content: Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    Text(
                                                                      "Are you sure, you want to clear the cart?",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      "OK"),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop();
                                                                    if (cartBloc
                                                                        .state
                                                                        .orderDetailModel
                                                                        .first
                                                                        .items!
                                                                        .isNotEmpty) {
                                                                      bool isNotLoggedIn = (cartState.customerInfoModel!.records ==
                                                                              null ||
                                                                          cartState.customerInfoModel!
                                                                              .records!
                                                                              .isEmpty ||
                                                                          cartState.customerInfoModel!.records!.first.id ==
                                                                              null);
                                                                      if (isNotLoggedIn) {
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentId,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentEmail,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                savedAgentName,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentIndex,
                                                                            value:
                                                                                "");
                                                                        await SharedPreferenceService().setKey(
                                                                            key:
                                                                                agentPhone,
                                                                            value:
                                                                                "");
                                                                      }

                                                                      addCustomerBloc
                                                                          .add(
                                                                              ResetData());
                                                                      addCustomerBloc
                                                                          .add(
                                                                              ClearMessage());
                                                                      addCustomerBloc.add(
                                                                          UpdateShowOptions(
                                                                              false));
                                                                      cartBloc.add(
                                                                          ClearWholeCart(
                                                                        inventorySearchBloc:
                                                                            inventorySearchBloc,
                                                                        customerID:
                                                                            widget.userId,
                                                                        orderID:
                                                                            widget.orderId,
                                                                        e: cartBloc
                                                                            .state
                                                                            .orderDetailModel
                                                                            .first
                                                                            .items!,
                                                                        onCompleted: () => Navigator.pop(
                                                                            context,
                                                                            "isDel"),
                                                                      ));

                                                                      if (inventorySearchBloc
                                                                          .state
                                                                          .productsInCart
                                                                          .where((element) =>
                                                                              element.childskus!.first.skuENTId ==
                                                                              cartBloc.state.orderDetailModel.first.items![0].itemNumber)
                                                                          .isNotEmpty) {
                                                                        inventorySearchBloc.add(isb.RemoveFromCart(
                                                                            favouriteBrandScreenBloc:
                                                                                context.read<fbsb.FavouriteBrandScreenBloc>(),
                                                                            records: inventorySearchBloc.state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == cartBloc.state.orderDetailModel.first.items![0].itemNumber),
                                                                            customerID: widget.userId,
                                                                            quantity: -2,
                                                                            productId: cartBloc.state.orderDetailModel.first.items![0].productId!,
                                                                            orderID: widget.orderId));
                                                                      }
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              _context)
                                                                          .showSnackBar(
                                                                              snackBar("Cart is already empty"));
                                                                    }
                                                                  },
                                                                ),
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      "CANCEL"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          }),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                title: Text(
                                                  "Clear Cart",
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black54,
                                                height: 1,
                                              ),
                                              ListTile(
                                                leading: SvgPicture.asset(
                                                    IconSystem.closedLost,
                                                    package: 'gc_customer_app',
                                                    width: 24,
                                                    color: ColorSystem.black),
                                                onTap: () {
                                                  Navigator.pop(dialogContext);
                                                  cartBloc
                                                      .add(GetDeleteReasons());
                                                  showCupertinoDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (BuildContext
                                                        dialogContext) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                          sigmaX: 8.0,
                                                          sigmaY: 8.0,
                                                        ),
                                                        child:
                                                            BlocProvider.value(
                                                          value: cartBloc,
                                                          child: BlocBuilder<
                                                                  CartBloc,
                                                                  CartState>(
                                                              builder:
                                                                  (buildContext,
                                                                      stateCart) {
                                                            return Form(
                                                              key:
                                                                  deleteOrderForm,
                                                              child:
                                                                  CupertinoAlertDialog(
                                                                title: Text(
                                                                  "Delete Order",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          19,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                content:
                                                                    Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Divider(
                                                                        color: Colors
                                                                            .black54,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Text(
                                                                        "Are you sure, you no longer need this order?",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black87,
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      stateCart
                                                                              .fetchingReason
                                                                          ? InputDecorator(
                                                                              decoration: InputDecoration(
                                                                                  labelText: 'Please wait...',
                                                                                  hintText: 'Reason',
                                                                                  alignLabelWithHint: true,
                                                                                  constraints: BoxConstraints(),
                                                                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                                                  labelStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  helperStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: ColorSystem.greyDark,
                                                                                      width: 1,
                                                                                    ),
                                                                                  )),
                                                                              isEmpty: true,
                                                                              child: DropdownButton<String>(
                                                                                hint: Text('', style: TextStyle(color: Theme.of(context).primaryColor)),
                                                                                icon: Padding(
                                                                                  padding: EdgeInsets.only(right: 2.0),
                                                                                  child: Icon(Icons.expand_more_outlined, color: Theme.of(context).primaryColor),
                                                                                ),
                                                                                underline: Container(),
                                                                                isExpanded: true,
                                                                                isDense: true,
                                                                                items: <String>[].map((String value) {
                                                                                  return DropdownMenuItem<String>(
                                                                                    value: value,
                                                                                    child: Text(
                                                                                      value,
                                                                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                                                                    ),
                                                                                  );
                                                                                }).toList(),
                                                                                onChanged: (_) async {},
                                                                              ),
                                                                            )
                                                                          : DropdownButtonFormField<
                                                                              String>(
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return "Please select delete reason";
                                                                                }
                                                                                return null;
                                                                              },
                                                                              decoration: InputDecoration(
                                                                                  labelText: 'Select Delete Reason',
                                                                                  hintText: 'Reason',
                                                                                  alignLabelWithHint: true,
                                                                                  constraints: BoxConstraints(),
                                                                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                                                  labelStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  helperStyle: TextStyle(
                                                                                    color: ColorSystem.greyDark,
                                                                                    fontSize: SizeSystem.size16,
                                                                                  ),
                                                                                  errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                                  errorBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: ColorSystem.lavender3,
                                                                                      width: 1,
                                                                                    ),
                                                                                  ),
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: ColorSystem.greyDark,
                                                                                      width: 1,
                                                                                    ),
                                                                                  )),
                                                                              hint: Text(stateCart.selectedReason.isEmpty ? "Select Delete Reason" : stateCart.selectedReason, style: TextStyle(color: Theme.of(context).primaryColor)),
                                                                              icon: Padding(
                                                                                padding: EdgeInsets.only(right: 2.0),
                                                                                child: Icon(Icons.expand_more_outlined, color: Theme.of(context).primaryColor),
                                                                              ),
                                                                              isExpanded: true,
                                                                              isDense: true,
                                                                              items: stateCart.reasonList.map((String value) {
                                                                                return DropdownMenuItem<String>(
                                                                                  value: value,
                                                                                  child: Text(
                                                                                    value,
                                                                                    style: TextStyle(color: Theme.of(context).primaryColor),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (_) async {
                                                                                cartBloc.add(ChangeDeleteReason(reason: _ ?? ""));
                                                                              },
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                        "OK"),
                                                                    onPressed: stateCart
                                                                            .fetchingReason
                                                                        ? null
                                                                        : () async {
                                                                            final formState =
                                                                                deleteOrderForm.currentState;
                                                                            if (formState!.validate()) {
                                                                              formState.save();
                                                                              bool isNotLoggedIn = (cartState.customerInfoModel!.records == null || cartState.customerInfoModel!.records!.isEmpty || cartState.customerInfoModel!.records!.first.id == null);
                                                                              if (isNotLoggedIn) {
                                                                                await SharedPreferenceService().setKey(key: agentId, value: "");
                                                                                await SharedPreferenceService().setKey(key: agentEmail, value: "");
                                                                                await SharedPreferenceService().setKey(key: savedAgentName, value: "");
                                                                                await SharedPreferenceService().setKey(key: agentIndex, value: "");
                                                                                await SharedPreferenceService().setKey(key: agentPhone, value: "");
                                                                              }
                                                                              addCustomerBloc.add(ResetData());
                                                                              addCustomerBloc.add(ClearMessage());
                                                                              addCustomerBloc.add(UpdateShowOptions(false));
                                                                              cartBloc.add(DeleteOrder(
                                                                                orderId: widget.orderId,
                                                                                reason: stateCart.selectedReason,
                                                                                inventorySearchBloc: inventorySearchBloc,
                                                                                onSuccess: () => Navigator.pop(context, "isDel"),
                                                                              ));
                                                                              if (inventorySearchBloc.state.productsInCart.where((element) => element.childskus!.first.skuENTId == cartBloc.state.orderDetailModel.first.items![0].itemNumber).isNotEmpty) {
                                                                                inventorySearchBloc.add(isb.RemoveFromCart(favouriteBrandScreenBloc: context.read<fbsb.FavouriteBrandScreenBloc>(), records: inventorySearchBloc.state.productsInCart.firstWhere((element) => element.childskus!.first.skuENTId == cartBloc.state.orderDetailModel.first.items![0].itemNumber), customerID: widget.userId, quantity: -2, productId: cartBloc.state.orderDetailModel.first.items![0].productId!, orderID: widget.orderId));
                                                                              }
                                                                              Navigator.of(dialogContext).pop();
                                                                            }
                                                                          },
                                                                  ),
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                        "CANCEL"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              dialogContext)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) {
                                                    cartBloc.add(
                                                        ChangeDeleteReason(
                                                            reason: ""));
                                                  });
                                                },
                                                title: Text(
                                                  "Delete Order",
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    },
                    iconSize: 36,
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(IconSystem.checkoutMoreOptions,
                        package: 'gc_customer_app',
                        color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasChanges = false;

  CachedNetworkImage _imageContainer(String imageUrl, double width) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(0),
            color: Colors.transparent,
          ),
          child: Image(
            image: imageProvider,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    labelNode.dispose();
    cityNode.dispose();
    stateNode.dispose();
    zipNode.dispose();
    addressNode.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SizedBox(height: 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<CartBloc, CartState>(listener: (context, cartState) {
        if (cartState.message.isNotEmpty && cartState.message != "done") {
          if (cartState.message == "Override Request Submitted" ||
              cartState.message == "Override Request Deleted" ||
              cartState.message ==
                  "Shipping & Handling Override Request Deleted" ||
              cartState.message ==
                  "Shipping & Handling Override Request Submitted") {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.8),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 90, vertical: 0),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(IconSystem.overrideAccepted,
                          package: 'gc_customer_app', width: 100, height: 100),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        cartState.message,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (cartState.message == "Override Request Declined" ||
              cartState.message ==
                  "Shipping & Handling Override Request Declined" ||
              cartState.message ==
                  "Shipping & Handling Delete Request Declined" ||
              cartState.message == "Delete Request Declined") {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.8),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 120, vertical: 0),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(IconSystem.overrideRejected,
                          package: 'gc_customer_app', width: 100, height: 100),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        cartState.message,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (cartState.message.contains('Coupon Applied')) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                couponDialogContext = context;
                return SizedBox(
                  width: 100,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.symmetric(
                        horizontal:
                            (MediaQuery.of(context).size.width / 2) - 70),
                    elevation: 0,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: ColorSystem.white.withOpacity(0.9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: ColorSystem.additionalGreen,
                            size: 80,
                          ),
                          SizedBox(height: 6),
                          Text(
                            cartState.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                color: ColorSystem.black,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
            Future.delayed(Duration(milliseconds: 1000), () {
              if (couponDialogContext != null)
                Navigator.pop(couponDialogContext!);
            });
          } else if (cartState.message.contains('Invalid\nCoupon code.')) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                couponDialogContext = context;
                return SizedBox(
                  width: 100,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.symmetric(
                        horizontal:
                            (MediaQuery.of(context).size.width / 2) - 70),
                    elevation: 0,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: ColorSystem.white.withOpacity(0.9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Icon(
                            Icons.cancel_outlined,
                            color: ColorSystem.pureRed,
                            size: 80,
                          ),
                          SizedBox(height: 10),
                          Text(
                            cartState.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                color: ColorSystem.black,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
            Future.delayed(Duration(milliseconds: 1000), () {
              if (couponDialogContext != null)
                Navigator.pop(couponDialogContext!);
            });
          } else if (cartState.message
              .contains('Recommended address not found')) {
            cartBloc.add(EmptyMessage());
            if (cartState.showRecommendedDialog) {
              cartBloc.add(HideRecommendedDialog());
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    backgroundColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    insetPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    title: Text(
                      "Confirmation",
                      textAlign: TextAlign.center,
                    ),
                    content: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Recommended address not found. Do you want to proceed with existing address?",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Existing Address",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: kRubik)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        cartState.recommendedAddressLine1 +
                                            ", " +
                                            cartState.recommendedAddressLine2 +
                                            ", " +
                                            cartState
                                                .recommendedAddressLineCity +
                                            ", " +
                                            cartState
                                                .recommendedAddressLineState +
                                            ", " +
                                            cartState
                                                .recommendedAddressLineZipCode,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontFamily: kRubik)),
                                  ],
                                ),
                              )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        ColorSystem.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                                color: ColorSystem
                                                    .primaryTextColor)))),
                                onPressed: () {
                                  Navigator.pop(context, "no");
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).primaryColor),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ))),
                                onPressed: () {
                                  Navigator.pop(context, "yes");
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Yes',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ).then((value) {
//                if(cartState.shippingFormKey != null && cartState.shippingFormKey!.currentState != null && cartState.shippingFormKey!.currentState!.validate()) {
                if (value == "yes") {
                  if (cartState.updateIndex == -10) {
                    cartBloc.add(SaveAddressesData(
                        isDefault: cartState.isDefaultAddress,
                        orderId: widget.orderId,
                        firstName: cartState.shippingFName,
                        lastName: cartState.shippingLName,
                        email: cartState.shippingEmail,
                        phone: cartState.shippingPhone,
                        addressModel: AddressList(
                            address1: cartState.recommendedAddressLine1,
                            address2: cartState.recommendedAddressLine2,
                            city: cartState.recommendedAddressLineCity,
                            state: cartState.recommendedAddressLineState,
                            postalCode: cartState.recommendedAddressLineZipCode,
                            addressLabel: cartState.recommendedLabel,
                            addAddress: false,
                            isPrimary: cartState.isDefaultAddress,
                            contactPointAddressId:
                                cartState.recommendedContactPointAddressId,
                            isSelected: false)));
                  } else {
                    cartBloc.add(SetSelectedAddress(
                      address1: cartState.recommendedAddressLine1,
                      address2: cartState.recommendedAddressLine2,
                      city: cartState.recommendedAddressLineCity,
                      postalCode: cartState.recommendedAddressLineZipCode,
                      state: cartState.recommendedAddressLineState,
                    ));
                    cartBloc
                        .add(UpdateActiveStep(value: cartState.updateIndex));
                  }
                }
                //              }
              });
            } else {
              //          if(cartState.shippingFormKey != null && cartState.shippingFormKey!.currentState != null && cartState.shippingFormKey!.currentState!.validate()) {
              if (cartState.updateIndex == -10) {
                cartBloc.add(SaveAddressesData(
                    isDefault: cartState.isDefaultAddress,
                    orderId: widget.orderId,
                    firstName: cartState.shippingFName,
                    lastName: cartState.shippingLName,
                    email: cartState.shippingEmail,
                    phone: cartState.shippingPhone,
                    addressModel: AddressList(
                        address1: cartState.recommendedAddressLine1,
                        address2: cartState.recommendedAddressLine2,
                        city: cartState.recommendedAddressLineCity,
                        state: cartState.recommendedAddressLineState,
                        postalCode: cartState.recommendedAddressLineZipCode,
                        addressLabel: cartState.recommendedLabel,
                        addAddress: false,
                        isPrimary: cartState.isDefaultAddress,
                        contactPointAddressId:
                            cartState.recommendedContactPointAddressId,
                        isSelected: false)));
              } else {
                cartBloc.add(UpdateActiveStep(value: cartState.updateIndex));
              }
              //        }
            }
          } else {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context)
                .showSnackBar(snackBar(cartState.message));
          }
        }
        if (cartState.recommendedAddress.isNotEmpty &&
            cartState.showRecommendedDialog) {
          cartBloc.add(HideRecommendedDialog());
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                backgroundColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                title: Text(
                  "Confirmation",
                  textAlign: TextAlign.center,
                ),
                content: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Do you want to change the address?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Existing",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: kRubik)),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(cartState.orderAddress,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontFamily: kRubik)),
                              ],
                            ),
                          )),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Recommended",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: kRubik)),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(cartState.recommendedAddress,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontFamily: kRubik)),
                              ],
                            ),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    ColorSystem.white),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: ColorSystem
                                                .primaryTextColor)))),
                            onPressed: () {
                              Navigator.pop(context, "no");
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            onPressed: () {
                              Navigator.pop(context, "yes");
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Yes',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ).then((value) {
//            if(cartState.shippingFormKey != null && cartState.shippingFormKey!.currentState != null && cartState.shippingFormKey!.currentState!.validate()){
            if (value == "no") {
              if (cartState.updateIndex == -10) {
                print(
                    "cartState.recommendedContactPointAddressId ${cartState.recommendedContactPointAddressId}");
                cartBloc.add(SaveAddressesData(
                    isDefault: cartState.isDefaultAddress,
                    orderId: widget.orderId,
                    firstName: cartState.shippingFName,
                    lastName: cartState.shippingLName,
                    email: cartState.shippingEmail,
                    phone: cartState.shippingPhone,
                    addressModel: AddressList(
                        address1: cartState.orderAddressLine1,
                        address2: cartState.orderAddressLine2,
                        city: cartState.orderAddressLineCity,
                        state: cartState.orderAddressLineState,
                        postalCode: cartState.orderAddressLineZipCode,
                        addressLabel: cartState.orderLabel,
                        contactPointAddressId:
                            cartState.orderContactPointAddressId,
                        addAddress: false,
                        isPrimary: cartState.isDefaultAddress,
                        isSelected: false)));
              } else {
                cartBloc.add(UpdateActiveStep(value: cartState.updateIndex));
              }
            } else if (value == "yes") {
              print("selecting address ${cartState.updateIndex}");

              if (cartState.updateIndex == -10) {
                cartBloc.add(SaveAddressesData(
                    isDefault: cartState.isDefaultAddress,
                    orderId: widget.orderId,
                    firstName: cartState.shippingFName,
                    lastName: cartState.shippingLName,
                    email: cartState.shippingEmail,
                    phone: cartState.shippingPhone,
                    addressModel: AddressList(
                        address1: cartState.recommendedAddressLine1,
                        address2: cartState.recommendedAddressLine2,
                        city: cartState.recommendedAddressLineCity,
                        state: cartState.recommendedAddressLineState,
                        postalCode: cartState.recommendedAddressLineZipCode,
                        addressLabel: cartState.recommendedLabel,
                        addAddress: false,
                        isPrimary: cartState.isDefaultAddress,
                        contactPointAddressId:
                            cartState.recommendedContactPointAddressId,
                        isSelected: false)));
              } else {
                cartBloc.add(SetSelectedAddress(
                  address1: cartState.recommendedAddressLine1,
                  address2: cartState.recommendedAddressLine2,
                  city: cartState.recommendedAddressLineCity,
                  postalCode: cartState.recommendedAddressLineZipCode,
                  state: cartState.recommendedAddressLineState,
                ));
                cartBloc.add(ChangeRecommendedAddress(
                    address: cartState.recommendedAddress,
                    orderID: widget.orderId,
                    firstName: cartState.shippingFName,
                    lastName: cartState.shippingLName,
                    email: cartState.shippingEmail,
                    phone: cartState.shippingPhone,
                    index: cartState.updateIndex));
              }
            }
            //           }
          });
        }
        if (cartState.callCompleteOrder) {
          cartBloc.add(UpdateCompleteOrder(value: false));
          if (cartState.updateIndex == -10) {
            print(
                "cartState.recommendedContactPointAddressId ${cartState.recommendedContactPointAddressId}");
          } else {
            cartBloc.add(UpdateActiveStep(value: cartState.updateIndex));
          }
        }
        if (cartState.deleteDone) {
          cartBloc.add(UpdateDeleteDone(value: false));
        }
        cartBloc.add(EmptyMessage());
      }, builder: (context, cartState) {
        bool isSummaryUI = (cartState.activeStep == 3);
        if (cartState.cartStatus == CartStatus.successState) {
          if (cartState.orderDetailModel.isNotEmpty &&
              cartState.orderDetailModel[0].items!
                  .where((element) => element.quantity! > 0)
                  .isNotEmpty) {
            return Stack(
              children: [
                SlidingUpPanel(
                  //Total Slider
                  controller: totalPC,
                  maxHeight: MediaQuery.of(context).viewInsets.bottom == 0 &&
                          !cartState.addAddress &&
                          !cartState.showAddCard &&
                          cartState.orderDetailModel[0].items!
                              .where((element) => element.quantity! > 0)
                              .isNotEmpty &&
                          WidgetsBinding.instance.window.viewInsets.bottom <=
                              0.0
                      ? 320
                      : 0,
                  minHeight: MediaQuery.of(context).viewInsets.bottom == 0 &&
                          !cartState.addAddress &&
                          !cartState.showAddCard &&
                          cartState.orderDetailModel[0].items!
                              .where((element) => element.quantity! > 0)
                              .isNotEmpty &&
                          WidgetsBinding.instance.window.viewInsets.bottom <=
                              0.0
                      ? 160
                      : 0,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(26, 45, 49, 66),
                        blurRadius: 30,
                        offset: Offset(0, -5))
                  ],
                  onPanelOpened: () {
                    deliveryPC.close();
                    paymentPC.close();
                    cartBloc.add(ChangeIsExpandedBottomSheet(value: true));
                  },
                  onPanelClosed: () {
                    cartBloc.add(ChangeIsExpandedBottomSheet(value: false));
                  },
                  body: StreamBuilder<bool>(
                      stream: isPaymentExpandSC.stream,
                      initialData: false,
                      builder: (context, snapshot) {
                        bool isPaymentExpand = snapshot.data ?? false;
                        return SlidingUpPanel(
                            //Payment Slider
                            controller: paymentPC,
                            maxHeight: 500,
                            minHeight: isSummaryUI
                                ? cartState.isExpanded
                                    ? 475
                                    : 315
                                : 0,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(26, 45, 49, 66),
                                  blurRadius: 30,
                                  offset: Offset(0, -5))
                            ],
                            onPanelClosed: () {
                              // totalPC.close();
                              // cartBloc
                              //     .add(ChangeIsExpandedBottomSheet(value: false));
                              isPaymentExpandSC.add(false);
                            },
                            onPanelOpened: () {
                              totalPC.close();
                              deliveryPC.close();
                              cartBloc.add(
                                  ChangeIsExpandedBottomSheet(value: false));
                              isPaymentExpandSC.add(true);
                            },
                            body: StreamBuilder<bool>(
                                stream: isDeliveryExpandSC.stream,
                                initialData: false,
                                builder: (context, snapshot) {
                                  bool isDeliveryExpand =
                                      snapshot.data ?? false;
                                  return SlidingUpPanel(
                                    //Delivery Slider
                                    controller: deliveryPC,
                                    maxHeight: 590,
                                    minHeight: isSummaryUI
                                        ? cartState.isExpanded
                                            ? 580
                                            : isPaymentExpand
                                                ? 580
                                                : 390
                                        : 0,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromARGB(26, 45, 49, 66),
                                          blurRadius: 30,
                                          offset: Offset(0, -5))
                                    ],
                                    onPanelClosed: () {
                                      isDeliveryExpandSC.add(false);
                                    },
                                    onPanelOpened: () {
                                      totalPC.close();
                                      paymentPC.close();
                                      isDeliveryExpandSC.add(true);
                                    },
                                    body: _body(cartState),
                                    panel: FutureBuilder<String>(
                                        future: recordId(),
                                        builder: (context, recordID) {
                                          if (recordID.hasData) {
                                            if (cartState.activeStep == 3 &&
                                                (recordID.data != null &&
                                                    recordID
                                                        .data!.isNotEmpty)) {
                                              return GestureDetector(
                                                onTap: () {
                                                  if (deliveryPC
                                                      .isPanelClosed) {
                                                    deliveryPC.open();
                                                  } else {
                                                    deliveryPC.close();
                                                  }
                                                },
                                                child: DeliveryPanelWidget(
                                                  cartState: cartState,
                                                  isDeliveryExpand:
                                                      isDeliveryExpand,
                                                  onTapEdit: () {
                                                    paymentPC.close();
                                                    deliveryPC.close();
                                                  },
                                                ),
                                              );
                                            }
                                          }
                                          return SizedBox.shrink();
                                        }),
                                  );
                                }),
                            panel: FutureBuilder<String>(
                                future: recordId(),
                                builder: (context, recordID) {
                                  if (recordID.hasData) {
                                    if (cartState.activeStep == 3 &&
                                        (recordID.data != null &&
                                            recordID.data!.isNotEmpty)) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (paymentPC.isPanelClosed) {
                                            paymentPC.open();
                                          } else {
                                            paymentPC.close();
                                          }
                                        },
                                        child: PaymentPanelWidget(
                                          isPaymentExpand: isPaymentExpand,
                                          onTapEdit: () {
                                            paymentPC.close();
                                            deliveryPC.close();
                                          },
                                        ),
                                      );
                                    }
                                  }
                                  return SizedBox.shrink();
                                }));
                      }),
                  panel: MediaQuery.of(context).viewInsets.bottom == 0 &&
                          !cartState.addAddress &&
                          !cartState.showAddCard &&
                          cartState.orderDetailModel[0].items!
                              .where((element) => element.quantity! > 0)
                              .isNotEmpty &&
                          WidgetsBinding.instance.window.viewInsets.bottom <=
                              0.0
                      ? FutureBuilder<String>(
                          future: recordId(),
                          builder: (context, record) {
                            if (record.hasData) {
                              if (record.data != null &&
                                  record.data!.isNotEmpty) {
                                return _draggableScrollableSheetBuilder(
                                    context, cartState, true);
                              }
                            }
                            return _draggableScrollableSheetBuilder(
                                context, cartState, false);
                          })
                      : SizedBox.shrink(),
                ),
                if (cartState.proceedingOrder || cartState.savingAddress)
                  LoadingTheme()
              ],
            );
          } else {
            return Column(
              children: [
                getAppBar([], cartState),
                SizedBox(height: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        IconSystem.noDataFound,
                        package: 'gc_customer_app',
                      ),
                      SizedBox(
                        height: SizeSystem.size24,
                      ),
                      Text(
                        'NO DATA FOUND!',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: kRubik,
                          fontSize: SizeSystem.size20,
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }
        } else if (cartState.cartStatus == CartStatus.failedState) {
          return Column(
            children: [
              getAppBar(
                  cartState.orderDetailModel.isNotEmpty
                      ? cartState.orderDetailModel[0].items!
                      : [],
                  cartState),
              SizedBox(height: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      IconSystem.noDataFound,
                      package: 'gc_customer_app',
                    ),
                    SizedBox(
                      height: SizeSystem.size24,
                    ),
                    Text(
                      'NO DATA FOUND!',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: kRubik,
                        fontSize: SizeSystem.size20,
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        } else if (cartState.cartStatus == CartStatus.loadState) {
          return Column(
            children: [
              getAppBar(
                  cartState.orderDetailModel.isNotEmpty
                      ? cartState.orderDetailModel[0].items!
                      : [],
                  cartState),
              SizedBox(height: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    )),
                  ],
                ),
              )
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: SizeSystem.size50,
                    ),
                    Center(
                        child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    )),
                    SizedBox(
                      height: SizeSystem.size50,
                    ),
                  ],
                ),
              )
            ],
          );
        }
      }),
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

  void onCreditCardModelChange(
      CreditCardModel? creditCardModel, CartState cartState) {
    if (cartState.sameAsBilling) {
      cartBloc.add(UpdateCardNumber(value: creditCardModel!.cardNumber));
      cartBloc.add(
          UpdateExpiryMonth(value: creditCardModel.expiryDate.split("/")[0]));
      cartBloc.add(UpdateExpiryYear(
          value: creditCardModel.expiryDate.split("/").length > 1
              ? creditCardModel.expiryDate.split("/")[1]
              : ""));
      cartBloc.add(UpdateCardHolderName(value: creditCardModel.cardHolderName));
      cartBloc.add(UpdateCvvCode(value: creditCardModel.cvvCode));
      cartBloc.add(UpdateCardAmount(value: creditCardModel.cardAmount));
      cartBloc.add(UpdateIsCvvFocused(value: creditCardModel.isCvvFocused));
    } else {
      cartBloc.add(UpdateCardNumber(value: creditCardModel!.cardNumber));
      cartBloc.add(
          UpdateExpiryMonth(value: creditCardModel.expiryDate.split("/")[0]));
      cartBloc.add(UpdateExpiryYear(
          value: creditCardModel.expiryDate.split("/").length > 1
              ? creditCardModel.expiryDate.split("/")[1]
              : ""));
      cartBloc.add(UpdateCardHolderName(value: creditCardModel.cardHolderName));
      cartBloc.add(UpdateCvvCode(value: creditCardModel.cvvCode));
      cartBloc.add(UpdateCardAmount(value: creditCardModel.cardAmount));
      cartBloc.add(UpdateIsCvvFocused(value: creditCardModel.isCvvFocused));
      cartBloc.add(UpdateIsCvvFocused(value: creditCardModel.isCvvFocused));
      cartBloc.add(UpdateHeading(value: creditCardModel.heading));
      cartBloc.add(UpdateState(value: creditCardModel.state));
      cartBloc.add(UpdateAddress(value: creditCardModel.address));
      cartBloc.add(UpdateZipCode(value: creditCardModel.zipCode));
      cartBloc.add(UpdateCity(value: creditCardModel.city));
    }
  }

  void _onStartScroll(ScrollMetrics metrics, CartState cartState) {
    animatedHide(cartState);
  }

  void _onUpdateScroll(ScrollMetrics metrics, CartState cartState) {
    animatedHide(cartState);
  }

  void _onEndScroll(ScrollMetrics metrics, CartState cartState) {
    animatedHide(cartState);
  }

  String getFormattedDate(DateTime date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return formattedDate;
  }

  void animatedHide(CartState cartState) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {

//     if (cartState.isExpanded) {
// //      if(controller != null) {
//       // controller!.animateTo(
//       //   cartState.minExtent,
//       //   duration: Duration(milliseconds: 200),
//       //   curve: Curves.easeOutBack,
//       // );
//       cartBloc.add(ChangeIsExpandedBottomSheet(
//           value: cartState.isExpanded ? false : true));
//       DraggableScrollableActuator.reset(draggableSheetContext);
//       //    }
//     }
    //});
  }

  Widget _draggableScrollableSheetBuilder(
      BuildContext context, CartState cartState, bool hasData) {
    draggableSheetContext = context;
    return GestureDetector(
      onTap: () {
        if (totalPC.isPanelClosed) {
          totalPC.open();
        } else {
          totalPC.close();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Container(
                height: 30,
                width: 30,
                child: AnimatedRotation(
                  turns: cartState.isExpanded ? 0 : 0.5,
                  duration: Duration(milliseconds: 500),
                  child: IconButton(
                      onPressed: () {},
                      constraints: BoxConstraints(),
                      icon: SvgPicture.asset(
                        IconSystem.expansion,
                        package: 'gc_customer_app',
                        width: 24,
                      )),
                ),
              ),
              innerBottomSheet(cartState, context, hasData),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _proceedButtonInPayment(CartState cartState, bool hasId) {
    bool isNotLoggedIn = (cartState.customerInfoModel!.records == null ||
        cartState.customerInfoModel!.records!.isEmpty ||
        cartState.customerInfoModel!.records!.first.id == null);

    return BlocBuilder<OrderCardsBloc, OrderCardsState>(
        builder: (context, state) {
      var addedValueInCards = 0.0;
      state.orderCardsModel?.forEach((e) {
        addedValueInCards += double.parse(
            e.availableAmount?.replaceAll(',', '').replaceAll('\$', '') ??
                '0.0');
      });

      var totalCartAmount = cartState.orderDetailModel[0].total ?? 0;
      bool isAddedValueInCardsEnough = addedValueInCards.toStringAsFixed(2) ==
          totalCartAmount.toStringAsFixed(2);
      bool isAddedCard = (state.orderCardsModel ?? []).isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAddedValueInCardsEnough && isAddedCard)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                  'Identified Price Mismatch between Total Amount & Paid Amount',
                  style: TextStyle(fontSize: 11, color: Colors.red)),
            ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    isAddedValueInCardsEnough
                        ? Theme.of(context).primaryColor
                        : ColorSystem.greyLight),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ))),
            onPressed: isAddedValueInCardsEnough
                ? () {
                    totalPC.close();
                    cartBloc.add(UpdateAddAddress(value: false));
                    cartBloc.add(UpdateSameAsBilling(value: true));
                    cartBloc.add(UpdateSaveAsDefaultAddress(value: true));
                    cartBloc.add(UpdateActiveStep(
                        value: isNotLoggedIn && !hasId ? 4 : 3));
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future _addCouponBottomSheet(BuildContext context, CartState cartState) {
    TextEditingController _couponController = TextEditingController();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
            value: cartBloc,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                height: 230,
                margin: MediaQuery.of(context).viewInsets,
                decoration: BoxDecoration(
                    color: ColorSystem.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32))),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        Text(
                          'Apply Coupon',
                          style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                        SizedBox(height: 19),
                        TextFormField(
                          controller: _couponController,
                          cursorColor: ColorSystem.black,
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorSystem.black,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            labelStyle: TextStyle(
                              color: ColorSystem.greyDark,
                              fontSize: 16,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorSystem.greyDark,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                            ),
                            labelText: 'Enter the Coupon Code',
                            suffixIcon: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ScannerView(
                                                  fromSearchInv: false)))
                                      .then((value) {
                                    if (value != null) {
                                      _couponController.text = value;
                                    }
                                  });
                                },
                                icon: Icon(
                                  Icons.qr_code_scanner_outlined,
                                  color: ColorSystem.primary,
                                )),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: 30),
                        BlocBuilder<CartBloc, CartState>(
                            builder: (context, state) {
                          return ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ))),
                              onPressed: () {
                                if (!state.isOverrideSubmitting)
                                  cartBloc.add(AddCoupon(
                                      couponId: _couponController.text,
                                      orderId: widget.orderId));
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: state.isOverrideSubmitting
                                      ? CupertinoActivityIndicator(
                                          color: ColorSystem.white,
                                        )
                                      : Text('Apply Coupon',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline1
                                              ?.copyWith(
                                                fontSize: 17,
                                                color: ColorSystem.white,
                                              )),
                                ),
                              ));
                        }),
                      ]),
                ),
              ),
            ));
      },
    );
  }

  _body(CartState cartState) {
    bool isNotLoggedIn = (cartState.customerInfoModel!.records == null ||
        cartState.customerInfoModel!.records!.isEmpty ||
        cartState.customerInfoModel!.records!.first.id == null);
    return SwipeDetector(
      onSwipe: (direction, offset) {
        if (kDebugMode) {
          print("swiping");
        }
        animatedHide(cartState);
      },
      onSwipeUp: (offset) {
        animatedHide(cartState);
      },
      onSwipeDown: (offset) {
        animatedHide(cartState);
      },
      onSwipeLeft: (offset) {
        animatedHide(cartState);
      },
      onSwipeRight: (offset) {
        animatedHide(cartState);
      },
      child: GestureDetector(
        onTap: () {
          animatedHide(cartState);
        },
        child: Column(
          children: [
            SizedBox(height: 10),
            getAppBar(cartState.orderDetailModel[0].items!, cartState),
            FutureBuilder<String>(
                future: recordId(),
                builder: (context, record) {
                  if (record.hasData) {
                    return DotStepper(
                      dotCount: isNotLoggedIn &&
                              (record.data == null || record.data!.isEmpty)
                          ? 5
                          : 4,
                      texts: isNotLoggedIn &&
                              (record.data == null || record.data!.isEmpty)
                          ? [
                              "Cart",
                              "Customer",
                              "Address",
                              "Payments",
                              "Summary"
                            ]
                          : ["Cart", "Address", "Payments", "Summary"],
                      dotRadius: 6,
                      activeStep: cartState.activeStep,
                      lineConnectorsEnabled: true,
                      tappingEnabled: false,
                      shape: Shape.circle,
                      spacing: 40,
                      indicator: Indicator.slide,
                      onDotTapped: (tappedDotIndex) {
                        cartBloc.add(UpdateActiveStep(value: tappedDotIndex));
                        cartBloc.add(UpdateAddAddress(value: false));
                        cartBloc.add(UpdateShowAddCard(value: false));
                        cartBloc.add(UpdateSaveAsDefaultAddress(value: true));
                        cartBloc.add(UpdateSameAsBilling(value: true));
                      },
                      fixedDotDecoration: FixedDotDecoration(
                          color: Colors.grey.shade50,
                          strokeColor: ColorSystem.greyDark,
                          strokeWidth: 2),
                      indicatorDecoration: IndicatorDecoration(
                        color: Colors.black,
                      ),
                      lineConnectorDecoration: LineConnectorDecoration(
                        color: ColorSystem.greyDark,
                        linePadding: 40,
                        strokeWidth: 1,
                      ),
                    );
                  } else {
                    return DotStepper(
                      dotCount: isNotLoggedIn ? 5 : 4,
                      texts: isNotLoggedIn
                          ? [
                              "Cart",
                              "Customer",
                              "Address",
                              "Payments",
                              "Summary"
                            ]
                          : ["Cart", "Address", "Payments", "Summary"],
                      dotRadius: 6,
                      activeStep: cartState.activeStep,
                      lineConnectorsEnabled: true,
                      tappingEnabled: false,
                      shape: Shape.circle,
                      spacing: 40,
                      indicator: Indicator.slide,
                      onDotTapped: (tappedDotIndex) {
                        cartBloc.add(UpdateAddAddress(value: false));
                        cartBloc.add(UpdateShowAddCard(value: false));
                        cartBloc.add(UpdateActiveStep(value: tappedDotIndex));
                        cartBloc.add(UpdateSaveAsDefaultAddress(value: true));
                        cartBloc.add(UpdateSameAsBilling(value: true));
                      },
                      fixedDotDecoration: FixedDotDecoration(
                          color: Colors.grey.shade50,
                          strokeColor: ColorSystem.greyDark,
                          strokeWidth: 2),
                      indicatorDecoration: IndicatorDecoration(
                        color: Colors.black,
                      ),
                      lineConnectorDecoration: LineConnectorDecoration(
                        color: ColorSystem.greyDark,
                        linePadding: 40,
                        strokeWidth: 1,
                      ),
                    );
                  }
                }),
            SizedBox(height: 10),
            // Text(cartState.activeStep.toString()),
            cartState.activeStep == 0
                ? Expanded(
                    child: Stack(
                    children: [
                      (cartState.orderDetailModel.isNotEmpty &&
                              cartState.orderDetailModel[0] != null &&
                              cartState.orderDetailModel[0].items != null &&
                              cartState.orderDetailModel[0].items!.isNotEmpty)
                          ? cartState.orderDetailModel[0].items!
                                  .where((element) => element.quantity! > 0)
                                  .isNotEmpty
                              ? NotificationListener<ScrollNotification>(
                                  onNotification: (scrollNotification) {
                                    if (scrollNotification
                                        is ScrollStartNotification) {
                                      _onStartScroll(scrollNotification.metrics,
                                          cartState);
                                    } else if (scrollNotification
                                        is ScrollUpdateNotification) {
                                      _onUpdateScroll(
                                          scrollNotification.metrics,
                                          cartState);
                                    } else if (scrollNotification
                                        is ScrollEndNotification) {
                                      _onEndScroll(scrollNotification.metrics,
                                          cartState);
                                    }
                                    return true;
                                  },
                                  child: SingleChildScrollView(
                                    child: Column(children: [
                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: cartState
                                              .orderDetailModel[0].items!
                                              .where((element) =>
                                                  element.quantity! > 0)
                                              .map((e) {
                                            //return SizedBox.shrink();
                                            return SwipeActionCell(
                                              trailingActions: <SwipeAction>[
                                                SwipeAction(
                                                  performsFirstActionWithFullSwipe:
                                                      false,
                                                  widthSpace:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.3,
                                                  closeOnTap: true,
                                                  title: "Remove from cart",
                                                  style: TextStyle(
                                                      fontSize:
                                                          SizeSystem.size12,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      fontFamily: kRubik),
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.white,
                                                    size: 32,
                                                  ),
                                                  onTap: (CompletionHandler
                                                      handler) async {
                                                    if (cartState.updateID !=
                                                            e.itemId &&
                                                        cartState.isUpdating) {
                                                      showMessage(
                                                          context: context,
                                                          message:
                                                              "Please wait until previous item update");
                                                    } else {
                                                      cartBloc.add(RemoveFromCart(
                                                          records: e,
                                                          inventorySearchBloc:
                                                              inventorySearchBloc,
                                                          customerID:
                                                              widget.userId,
                                                          orderID:
                                                              widget.orderId,
                                                          quantity: 0));
                                                      if (inventorySearchBloc
                                                          .state.productsInCart
                                                          .where((element) =>
                                                              element
                                                                  .childskus!
                                                                  .first
                                                                  .skuENTId ==
                                                              e.itemNumber)
                                                          .isNotEmpty) {
                                                        inventorySearchBloc.add(isb.RemoveFromCart(
                                                            favouriteBrandScreenBloc:
                                                                context.read<
                                                                    fbsb
                                                                        .FavouriteBrandScreenBloc>(),
                                                            records: inventorySearchBloc
                                                                .state
                                                                .productsInCart
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .childskus!
                                                                        .first
                                                                        .skuENTId ==
                                                                    e
                                                                        .itemNumber),
                                                            customerID:
                                                                widget.userId,
                                                            quantity: 0,
                                                            productId:
                                                                e.productId!,
                                                            orderID:
                                                                widget.userId));
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                              key: ObjectKey(e.productId),
                                              child: CartItem(
                                                cartBloc: cartBloc,
                                                userID: widget.userId,
                                                customerInfoModel:
                                                    cartState.customerInfoModel!,
                                                orderLineItemID: e.itemId!,
                                                orderID: widget.orderId,
                                                items: e,
                                              ),
                                            );
                                          }).toList()),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                      )
                                    ]),
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        IconSystem.noDataFound,
                                        package: 'gc_customer_app',
                                      ),
                                      SizedBox(
                                        height: SizeSystem.size24,
                                      ),
                                      Text(
                                        'NO ITEMS IN CART!',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: kRubik,
                                          fontSize: SizeSystem.size20,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    IconSystem.noDataFound,
                                    package: 'gc_customer_app',
                                  ),
                                  SizedBox(
                                    height: SizeSystem.size24,
                                  ),
                                  Text(
                                    'NO ITEMS IN CART!',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: kRubik,
                                      fontSize: SizeSystem.size20,
                                    ),
                                  )
                                ],
                              ),
                            ),
                      cartState.loadingScreen || cartState.isOverrideSubmitting
                          ? SizedBox.expand(
                              child: Container(
                                  color: Colors.black38,
                                  child: Center(
                                      child: CircularProgressIndicator())),
                            )
                          : SizedBox.shrink()
                    ],
                  ))
                : FutureBuilder<String>(
                    future: recordId(),
                    builder: (context, record) {
                      if (record.hasData) {
                        if (record.data != null && record.data!.isNotEmpty) {
                          return innerBody(cartState, true);
                        } else {
                          return innerBody(cartState, false);
                        }
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
            SizedBox(
                height: totalPC.isPanelClosed
                    ? (MediaQuery.of(context).size.height * 0.1)
                    : MediaQuery.of(context).size.height * 0.25)
          ],
        ),
      ),
    );
  }

  Widget innerBody(CartState cartState, bool hasId) {
    bool isNotLoggedIn = (cartState.customerInfoModel!.records == null ||
        cartState.customerInfoModel!.records!.isEmpty ||
        cartState.customerInfoModel!.records!.first.id == null);
    if (isNotLoggedIn && !hasId) {
      print("nots");
      return cartState.activeStep == 1
          ? Expanded(
              child: BlocProvider.value(
                value: cartBloc,
                child: BlocProvider.value(
                  value: addCustomerBloc,
                  child: AddNewCustomer(
                    state: cartState,
                    cartBloc: cartBloc,
                    orderId: widget.orderId,
                    function: setStateBuild,
                    controller:
                        (BuildContext context, void Function() methodA) {
                      myMethod = methodA;
                    },
                  ),
                ),
              ),
            )
          : cartState.activeStep == 2
              ? Expanded(
                  child: BlocProvider.value(
                  value: cartBloc,
                  child: AddressPage(
                    orderId: widget.orderId,
                    orderLineItemId: widget.orderLineItemId,
                    orderNumber: widget.orderNumber,
                    orderDate: widget.orderDate,
                    userName: widget.userName,
                    onScrollEnd: _onEndScroll,
                    onScrollStart: _onStartScroll,
                    onUpdateScroll: _onUpdateScroll,
                    userId: widget.userId,
                    email: widget.email,
                    phone: widget.phone,
                  ),
                ))
              : cartState.activeStep == 3
                  ? OrderPaymentPage(
                      cartState: cartState,
                      onScroll: () => animatedHide(cartState),
                      orderId: widget.orderId,
                      userId: widget.userId,
                      email: widget.email,
                      phone: widget.phone)
                  : cartState.activeStep == 4
                      ? BlocProvider.value(
                          value: cartBloc,
                          child: SummaryPaymentPage(
                              onScroll: () => animatedHide(cartState),
                              cartState: cartState,
                              orderId: widget.orderId,
                              userId: widget.userId,
                              customerInfoModel: cartState.customerInfoModel!),
                        )
                      : Container(
                          color: Colors.pink,
                        );
    }
    else {
      return cartState.activeStep == 1
          ? Expanded(
              child: BlocProvider.value(
              value: cartBloc,
              child: AddressPage(
                orderId: widget.orderId,
                orderLineItemId: widget.orderLineItemId,
                orderNumber: widget.orderNumber,
                orderDate: widget.orderDate,
                userName: widget.userName,
                onScrollEnd: _onEndScroll,
                onScrollStart: _onStartScroll,
                onUpdateScroll: _onUpdateScroll,
                userId: widget.userId,
                email: widget.email,
                phone: widget.phone,
                firstName:
                    cartState.customerInfoModel!.records?.first.firstName ?? '',
                lastName:
                    cartState.customerInfoModel!.records?.first.lastName ?? '',
              ),
            ))
          : cartState.activeStep == 2
              ? OrderPaymentPage(
                  cartState: cartState,
                  onScroll: () => animatedHide(cartState),
                  orderId: widget.orderId,
                  userId: widget.userId,
                  email: widget.email,
                  phone: widget.phone)
              : cartState.activeStep == 3
                  ? BlocProvider.value(
                      value: cartBloc,
                      child: SummaryPaymentPage(
                          onScroll: () => animatedHide(cartState),
                          cartState: cartState,
                          orderId: widget.orderId,
                          userId: widget.userId,
                          customerInfoModel: cartState.customerInfoModel!),
                    )
                  : Container(
                      color: Colors.pink,
                    );
    }
  }

  innerBottomSheet(CartState cartState, BuildContext context, bool hasData) {
    bool isNotLoggedIn = (cartState.customerInfoModel!.records == null ||
        cartState.customerInfoModel!.records!.isEmpty ||
        cartState.customerInfoModel!.records!.first.id == null);
    bool isCouponApplied = (cartState.orderDetailModel[0].discount ?? 0) > 0;
    if (isNotLoggedIn && !hasData) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isCouponApplied || cartState.activeStep < 2
              ? SizedBox(height: cartState.isExpanded ? 0 : 25)
              : Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      _addCouponBottomSheet(context, cartState);
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        child: Text(
                          'Apply Coupon',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorSystem.lavender),
                        )),
                  ),
                ),
          cartState.isExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pro Coverages:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"$" + cartState.proCoverage.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    BlocProvider.value(
                      value: cartBloc,
                      child: ShippingOverrideTile(
                          cartBloc: cartBloc,
                          userID: widget.userId,
                          orderID: widget.orderId,
                          orderLineItemID: widget.orderLineItemId),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cartState.proCoverage == 0
                            ? Text(
                                "Subtotal:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: kRubik),
                              )
                            : Text(
                                "Subtotal\n(incl. pro-coverages):",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: kRubik),
                              ),
                        Text(
                          r"$" +
                              amountFormatting(
                                  cartState.orderDetailModel[0].subtotal!),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Coupon Discount:",
                              style: TextStyle(
                                  fontSize: SizeSystem.size15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                  fontFamily: kRubik),
                            ),
                            Text(
                              r"-$" +
                                  cartState.orderDetailModel[0].discount!
                                      .toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                  fontFamily: kRubik),
                            ),
                          ],
                        ),
                        if (isCouponApplied)
                          InkWell(
                            onTap: () => cartBloc
                                .add(RemoveCoupon(orderId: widget.orderId)),
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 16,
                                      color: ColorSystem.lavender3,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Remove coupon',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: ColorSystem.lavender3),
                                    ),
                                  ],
                                )),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Override Discount:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"-$" +
                              amountFormatting(cartState
                                      .orderDetailModel[0].totalLineDiscount ??
                                  0),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Taxes:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"$" +
                              cartState.orderDetailModel[0].tax!
                                  .toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    (cartState.orderDetailModel[0].shippingFee ?? 0) > 0
                        ? SizedBox(height: 8)
                        : SizedBox.shrink(),
                    (cartState.orderDetailModel[0].shippingFee ?? 0) > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CO Delivery Fee:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    cartState.orderDetailModel[0].shippingFee!
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    (cartState.orderDetailModel[0].shippingTax ?? 0) > 0
                        ? SizedBox(height: 8)
                        : SizedBox.shrink(),
                    (cartState.orderDetailModel[0].shippingTax ?? 0) > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CO Delivery Fee Tax:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    cartState.orderDetailModel[0].shippingTax!
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                )
              : SizedBox.shrink(),
          if (cartState.isExpanded) SizedBox(height: 10),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total:",
                    style: TextStyle(
                        fontSize: SizeSystem.size16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                  Text(
                    r"$" +
                        // (((cartState.subtotal +
                        //                 cartState.proCoverage +
                        //                 cartState.orderDetailModel[0]
                        //                     .tax! +
                        //                 cartState
                        //                     .orderDetailModel[0]
                        //                     .orderDetail!
                        //                     .shippingAdjustment!) -
                        //             cartState.overrideDiscount) -
                        //         cartState.orderDetailModel[0].orderDetail!
                        //             .discount!)
                        //     .toStringAsFixed(2),
                        amountFormatting(
                            cartState.orderDetailModel.first.total ?? 0),
                    style: TextStyle(
                        fontSize: SizeSystem.size19,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          cartState.activeStep != 3
              ? BlocBuilder<AddCustomerBloc, AddCustomerState>(
                  builder: (context, addCustomerState) {
                  return BlocBuilder<OrderCardsBloc, OrderCardsState>(
                      builder: (context, orderPaymentState) {
                    var addedValueInCards = 0.0;
                    orderPaymentState.orderCardsModel?.forEach((e) {
                      addedValueInCards += double.parse(e.availableAmount
                              ?.replaceAll(',', '')
                              .replaceAll('\$', '') ??
                          '0.0');
                    });
                    var totalValue = cartState.orderDetailModel[0].total ?? 0;
                    return FutureBuilder<String>(
                        future: recordId(),
                        builder: (context, record) {
                          if (record.hasData) {
                            return ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: cartState.activeStep == 0 ||
                                          (cartState.activeStep > 0 &&
                                              record.data!.isNotEmpty) ||
                                          (addCustomerState
                                                  .customerLookUpStatus ==
                                              CustomerLookUpStatus.failure)
                                      ? MaterialStateProperty.all(
                                          Theme.of(context).primaryColor)
                                      : null,
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ))),
                              onPressed: cartState.activeStep == 0 ||
                                      (cartState.activeStep > 0 &&
                                          record.data!.isNotEmpty) ||
                                      (addCustomerState.customerLookUpStatus ==
                                          CustomerLookUpStatus.failure)
                                  ? () async {
                                      cartBloc
                                          .add(UpdateAddAddress(value: false));
                                      cartBloc.add(
                                          UpdateSameAsBilling(value: true));
                                      cartBloc.add(UpdateSaveAsDefaultAddress(
                                          value: true));
                                      cartBloc.add(ChangeIsExpandedBottomSheet(
                                          value: false));
                                      totalPC.close();
                                      print(
                                          "cartState.activeStep ${cartState.activeStep}");
                                      if (cartState.activeStep == 0) {
                                        bool isNotLoggedIn =
                                            (cartState.customerInfoModel!.records ==
                                                    null ||
                                                cartState.customerInfoModel!
                                                    .records!.isEmpty ||
                                                cartState.customerInfoModel!
                                                        .records!.first.id ==
                                                    null);
                                        cartBloc
                                            .add(UpdateActiveStep(value: 1));
                                        context.read<OrderCardsBloc>().add(
                                            LoadCardsData(
                                                widget.orderId, totalValue,
                                                isNeedToLoadCOA:
                                                    !isNotLoggedIn));
                                      } else if (cartState.activeStep == 1) {
                                        if (addCustomerState
                                                .customerLookUpStatus ==
                                            CustomerLookUpStatus.failure) {
                                          bool validForm = addCustomerState
                                              .formKey!.currentState!
                                              .validate();
                                          if (validForm) {
                                            myMethod.call();
                                            return;
                                          }
                                        } else {
                                          cartBloc
                                              .add(UpdateActiveStep(value: 2));
                                        }
                                      } else if (cartState.activeStep == 2) {
                                        if (cartState.shippingFName.isNotEmpty &&
                                            cartState
                                                .shippingLName.isNotEmpty &&
                                            cartState
                                                .shippingEmail.isNotEmpty &&
                                            cartState
                                                .shippingPhone.isNotEmpty &&
                                            cartState.shippingPhone.length ==
                                                10 &&
                                            RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                .hasMatch(
                                                    cartState.shippingEmail)) {
                                          if (cartState.addressModel
                                                  .where((element) =>
                                                      element.isSelected!)
                                                  .isEmpty &&
                                              cartState.deliveryModels
                                                  .where((element) =>
                                                      element.isSelected!)
                                                  .isEmpty) {
                                            showMessage(
                                                context: context,
                                                message:
                                                    "⚠️ Please select Shipping Address along with shipping method or Pickup Store");
                                          } else if (cartState.deliveryModels
                                                  .where((element) =>
                                                      element.isSelected! &&
                                                      element.type == "Pick-up")
                                                  .isNotEmpty &&
                                              cartState.pickUpZip.isEmpty) {
                                            showMessage(
                                                context: context,
                                                message:
                                                    "⚠️ Please select a pick-up store");
                                          } else {
                                            bool isNotLoggedIn = (cartState
                                                        .customerInfoModel!
                                                        .records ==
                                                    null ||
                                                cartState.customerInfoModel!
                                                    .records!.isEmpty ||
                                                cartState.customerInfoModel!
                                                        .records!.first.id ==
                                                    null);
                                            bool isPickup = cartState
                                                    .orderDetailModel
                                                    .first
                                                    .shippingMethod
                                                    ?.toLowerCase()
                                                    .contains(
                                                        'pick from store') ??
                                                false;
//                                            if (!isPickup) {
                                            String recordId =
                                                await SharedPreferenceService()
                                                    .getValue(agentId);
                                            cartBloc.add(GetRecommendedAddresses(
                                                orderId: widget.orderId,
                                                recordId: recordId,
                                                index: 3,
                                                address1:
                                                    cartState.selectedAddress1,
                                                address2:
                                                    cartState.selectedAddress2,
                                                country: cartState.addressModel
                                                        .firstWhere((element) =>
                                                            element.isSelected!)
                                                        .country ??
                                                    "",
                                                city: cartState
                                                    .selectedAddressCity,
                                                state: cartState
                                                    .selectedAddressState,
                                                postalCode: cartState
                                                    .selectedAddressPostalCode,
                                                isShipping: true,
                                                isBilling: false));
                                            // } else {
                                            //   cartBloc.add(UpdateActiveStep(value: 3));
                                            // }
                                          }
                                        } else {
                                          showMessage(
                                              context: context,
                                              message:
                                                  "Shipping information is missing");
                                        }
                                      } else if (cartState.activeStep == 3) {
                                        cartBloc
                                            .add(UpdateActiveStep(value: 4));
                                      } else if (cartState.activeStep == 4) {
                                        if (addedValueInCards
                                                .toStringAsFixed(2) !=
                                            totalValue.toStringAsFixed(2)) {
                                          showMessage(
                                              context: context,
                                              message:
                                                  "⚠️ Identified Price Mismatch between Total Amount & Paid Amount");
                                        } else {
                                          proceedOrder(
                                              cartState,
                                              orderPaymentState
                                                  .orderCardsModel!);
                                        }
                                      } else {
                                        if (addedValueInCards
                                                .toStringAsFixed(2) !=
                                            totalValue.toStringAsFixed(2)) {
                                          showMessage(
                                              message:
                                                  "⚠️ Identified Price Mismatch between Total Amount & Paid Amount",
                                              context: context);
                                          //showMessage(context: context,message:"⚠️ Identified Price Mismatch between Total Amount & Paid Amount");
                                          cartBloc
                                              .add(UpdateActiveStep(value: 3));
                                        } else {
                                          proceedOrder(
                                              cartState,
                                              orderPaymentState
                                                  .orderCardsModel!);
                                        }
                                      }
                                    }
                                  : null,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    cartState.proceedingOrder
                                        ? CupertinoActivityIndicator(
                                            color: Colors.white,
                                          )
                                        : (addCustomerState
                                                        .saveCustomerStatus ==
                                                    SaveCustomerStatus.saving ||
                                                cartState.saveCustomerStatus ==
                                                    CartSaveCustomerStatus
                                                        .saving)
                                            ? CupertinoActivityIndicator(
                                                color: Colors.white,
                                              )
                                            : Text(
                                                cartState.activeStep == 0
                                                    ? 'Select Customer'
                                                    : cartState.activeStep ==
                                                                1 &&
                                                            addCustomerState
                                                                    .customerLookUpStatus ==
                                                                CustomerLookUpStatus
                                                                    .failure &&
                                                            (addCustomerState
                                                                        .users ??
                                                                    [])
                                                                .isEmpty
                                                        ? "Add Customer & Proceed"
                                                        : cartState.activeStep ==
                                                                    1 &&
                                                                addCustomerState
                                                                        .customerLookUpStatus !=
                                                                    CustomerLookUpStatus
                                                                        .failure
                                                            ? "Select Address"
                                                            : cartState.activeStep ==
                                                                    4
                                                                ? 'Place Order'
                                                                : 'Proceed',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        });
                  });
                })
              : _proceedButtonInPayment(cartState, hasData),
        ],
      );
    }
    else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isCouponApplied
              ? SizedBox(height: cartState.isExpanded ? 0 : 25)
              : Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      _addCouponBottomSheet(context, cartState);
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        child: Text(
                          'Apply Coupon',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorSystem.lavender),
                        )),
                  ),
                ),
          cartState.isExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pro Coverages:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"$" + amountFormatting(cartState.proCoverage),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    BlocProvider.value(
                      value: cartBloc,
                      child: ShippingOverrideTile(
                          cartBloc: cartBloc,
                          userID: widget.userId,
                          orderID: widget.orderId,
                          orderLineItemID: widget.orderLineItemId),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cartState.proCoverage == 0
                            ? Text(
                                "Subtotal:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: kRubik),
                              )
                            : Text(
                                "Subtotal\n(incl. pro-coverages):",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: kRubik),
                              ),
                        Text(
                          r"$" +
                              amountFormatting(
                                  cartState.orderDetailModel[0].subtotal!),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Coupon Discount:",
                              style: TextStyle(
                                  fontSize: SizeSystem.size15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                  fontFamily: kRubik),
                            ),
                            Text(
                              r"-$" +
                                  amountFormatting(
                                      cartState.orderDetailModel[0].discount!),
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                  fontFamily: kRubik),
                            ),
                          ],
                        ),
                        if (isCouponApplied)
                          InkWell(
                            onTap: () => cartBloc
                                .add(RemoveCoupon(orderId: widget.orderId)),
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 16,
                                      color: ColorSystem.lavender3,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Remove coupon',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: ColorSystem.lavender3),
                                    ),
                                  ],
                                )),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Override Discount:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"-$" +
                              amountFormatting(cartState
                                      .orderDetailModel[0].totalLineDiscount ??
                                  0),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Taxes:",
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: kRubik),
                        ),
                        Text(
                          r"$" +
                              amountFormatting(
                                  cartState.orderDetailModel[0].tax!),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                    (cartState.orderDetailModel[0].shippingFee ?? 0) > 0
                        ? SizedBox(height: 8)
                        : SizedBox.shrink(),
                    (cartState.orderDetailModel[0].shippingFee ?? 0) > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CO Delivery Fee:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    cartState.orderDetailModel[0].shippingFee!
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    (cartState.orderDetailModel[0].shippingTax ?? 0) > 0
                        ? SizedBox(height: 8)
                        : SizedBox.shrink(),
                    (cartState.orderDetailModel[0].shippingTax ?? 0) > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CO Delivery Fee Tax:",
                                style: TextStyle(
                                    fontSize: SizeSystem.size15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                              Text(
                                r"$" +
                                    cartState.orderDetailModel[0].shippingTax!
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily: kRubik),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                )
              : SizedBox.shrink(),
          if (cartState.isExpanded) SizedBox(height: 10),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total:",
                    style: TextStyle(
                        fontSize: SizeSystem.size16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                  Text(
                    r"$" +
                        // (((cartState.subtotal +
                        //                 cartState.proCoverage +
                        //                 cartState.orderDetailModel[0]
                        //                     .tax! +
                        //                 cartState
                        //                     .orderDetailModel[0]
                        //                     .orderDetail!
                        //                     .shippingAdjustment!) -
                        //             cartState.overrideDiscount) -
                        //         cartState.orderDetailModel[0].orderDetail!
                        //             .discount!)
                        //     .toStringAsFixed(2),
                        amountFormatting(
                            cartState.orderDetailModel.first.total ?? 0),
                    style: TextStyle(
                        fontSize: SizeSystem.size19,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          cartState.activeStep != 2
              ? BlocBuilder<OrderCardsBloc, OrderCardsState>(
                  builder: (context, orderPaymentState) {
                  var addedValueInCards = 0.0;
                  orderPaymentState.orderCardsModel?.forEach((e) {
                    addedValueInCards += double.parse(e.availableAmount
                            ?.replaceAll(',', '')
                            .replaceAll('\$', '') ??
                        '0.0');
                  });
                  var totalValue = cartState.orderDetailModel[0].total ?? 0;

                  return ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                    onPressed: () async {
                      cartBloc.add(UpdateAddAddress(value: false));
                      cartBloc.add(UpdateSameAsBilling(value: true));
                      cartBloc.add(UpdateSaveAsDefaultAddress(value: true));
                      cartBloc.add(ChangeIsExpandedBottomSheet(value: false));
                      totalPC.close();
                      bool isNotLoggedIn = (cartState.customerInfoModel!.records ==
                              null ||
                          cartState.customerInfoModel!.records!.isEmpty ||
                          cartState.customerInfoModel!.records!.first.id == null);
                      if (cartState.activeStep == 0) {
                        cartBloc.add(UpdateActiveStep(value: 1));
                      } else if (cartState.activeStep == 1) {
                        if (cartState.shippingFName.isNotEmpty &&
                            cartState.shippingLName.isNotEmpty &&
                            cartState.shippingEmail.isNotEmpty &&
                            cartState.shippingPhone.isNotEmpty &&
                            cartState.shippingPhone.length == 10 &&
                            RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(cartState.shippingEmail)) {
                          if (cartState.addressModel
                                  .where((element) => element.isSelected!)
                                  .isEmpty &&
                              cartState.deliveryModels
                                  .where((element) => element.isSelected!)
                                  .isEmpty) {
                            showMessage(
                                context: context,
                                message:
                                    "⚠️ Please select Shipping Address along with shipping method or Pickup Store");
                          } else if (cartState.deliveryModels
                                  .where((element) =>
                                      element.isSelected! &&
                                      element.type == "Pick-up")
                                  .isNotEmpty &&
                              cartState.pickUpZip.isEmpty) {
                            showMessage(
                                context: context,
                                message: "⚠️ Please select a pick-up store");
                          } else {
                            bool isPickup = cartState.deliveryModels
                                    .firstWhere(
                                        (element) => element.isSelected!,
                                        orElse: () =>
                                            DeliveryModel(address: ''))
                                    .type
                                    ?.toLowerCase()
                                    .contains('pick-up') ??
                                false;

                            //Update card billing address when user have address and select pick-up
                            if (isPickup && cartState.addressModel.length > 1) {
                              context.read<OrderCardsBloc>().add(
                                  UpdateCardAddress(cartState.addressModel[1]));
                            }
                            // if (!isPickup) {
                            String recordId = await SharedPreferenceService()
                                .getValue(agentId);
                            cartBloc.add(GetRecommendedAddresses(
                                orderId: widget.orderId,
                                recordId: recordId,
                                index: 2,
                                address1: cartState.selectedAddress1,
                                address2: cartState.selectedAddress2,
                                country: cartState.addressModel
                                        .firstWhere(
                                            (element) => element.isSelected!,
                                            orElse: () => AddressList())
                                        .country ??
                                    "",
                                city: cartState.selectedAddressCity,
                                state: cartState.selectedAddressState,
                                postalCode: cartState.selectedAddressPostalCode,
                                isShipping: true,
                                isBilling: false));
                            // } else {
                            //   cartBloc.add(UpdateActiveStep(value: 2));
                            // }
                          }
                          context.read<OrderCardsBloc>().add(LoadCardsData(
                              widget.orderId, totalValue,
                              isNeedToLoadCOA: !isNotLoggedIn));
                        } else {
                          showMessage(
                              context: context,
                              message: "Contact Info is missing");
                          cartBloc.add(NotifyContactIsMissing());
                        }
                      } else if (cartState.activeStep == 2) {
                        cartBloc.add(UpdateActiveStep(value: 3));
                      } else if (cartState.activeStep == 3) {
                        if (addedValueInCards.toStringAsFixed(2) !=
                            totalValue.toStringAsFixed(2)) {
                          showMessage(
                              context: context,
                              message:
                                  "⚠️ Identified Price Mismatch between Total Amount & Paid Amount");
                        } else {
                          proceedOrder(
                              cartState, orderPaymentState.orderCardsModel!);
                        }
                      } else {
                        if (addedValueInCards.toStringAsFixed(2) !=
                            totalValue.toStringAsFixed(2)) {
                          showMessage(
                              context: context,
                              message:
                                  "⚠️ Identified Price Mismatch between Total Amount & Paid Amount");
                          cartBloc.add(UpdateActiveStep(value: 3));
                        } else {
                          proceedOrder(
                              cartState, orderPaymentState.orderCardsModel!);
                        }
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          cartState.proceedingOrder
                              ? CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  cartState.activeStep == 0
                                      ? 'Select Address'
                                      : cartState.activeStep == 3
                                          ? 'Place Order'
                                          : 'Proceed',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ],
                      ),
                    ),
                  );
                })
              : _proceedButtonInPayment(cartState, hasData),
        ],
      );
    }
  }

  Future<String> recordId() async {
    var recordID = await SharedPreferenceService().getValue(agentId);
    return recordID;
  }

  void setStateBuild() {
    setState(() {});
  }

  Future<void> setRecordId() async {
    _recordId = recordId();
  }
}
