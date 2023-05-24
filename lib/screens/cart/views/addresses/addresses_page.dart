import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/search_places/view/search_places_page.dart';
import 'package:intl/intl.dart';

import '../../../../bloc/cart_bloc/cart_bloc.dart';
import '../../../../common_widgets/cart_widgets/custom_switch.dart';
import '../../../../common_widgets/state_city_picker/csc_picker.dart';
import '../../../../intermediate_widgets/input_field_with_validations.dart';
import '../../../../models/cart_model/cart_popup_menu.dart';
import '../../../../primitives/color_system.dart';
import '../../../../primitives/constants.dart';
import '../../../../services/storage/shared_preferences_service.dart';
import '../../../../utils/formatter.dart';
import '../../../store_search_zip_code/store_search_zip_code_page.dart';

class AddressPage extends StatefulWidget {
  final String orderId;
  final String orderLineItemId;
  final String orderNumber;
  final String orderDate;
  final String userName;
  final String userId;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final Function(ScrollMetrics metrics, CartState cartState) onScrollStart;
  final Function(ScrollMetrics metrics, CartState cartState) onScrollEnd;
  final Function(ScrollMetrics metrics, CartState cartState) onUpdateScroll;

  AddressPage(
      {this.email,
      this.phone,
      required this.userId,
      required this.onScrollStart,
      required this.onScrollEnd,
      required this.onUpdateScroll,
      required this.orderLineItemId,
      required this.orderId,
      required this.orderNumber,
      required this.orderDate,
      required this.userName,
      this.firstName,
      this.lastName,
      Key? key})
      : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage>
    with AutomaticKeepAliveClientMixin {
  late Future<void> _futureOrderDetail;
  late void Function(String) _selectState;
  late void Function(String) _selectCity;
  String email = '';
  String phone = '';
  String firstName = '';
  String lastName = '';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late isb.InventorySearchBloc inventorySearchBloc;
  List<OrderDetail> orderDetailModel = [
    OrderDetail(items: [Items(isCartAdding: false, quantity: 0)])
  ];
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController shareEmailController = TextEditingController();
  TextEditingController sharePhoneController = TextEditingController();

  DraggableScrollableController? controller = DraggableScrollableController();

  late BuildContext draggableSheetContext;

  List<CartPopupMenu> cartPopupMenu = [];

  ScrollController scrollController = ScrollController();
  CarouselController carouselController = CarouselController();

  FocusNode address1Node = FocusNode();
  FocusNode address2Node = FocusNode();
  FocusNode zipNode = FocusNode();

//  TextEditingController labelController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  StreamSubscription? subscription;

  GlobalKey<FormState> quoteForm = new GlobalKey();
  GlobalKey<FormState> deleteOrderForm = new GlobalKey();

  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  late CartBloc cartBloc;
  int currentIndexOfAddressSlide = 0;

  @override
  initState() {
    super.initState();
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'AddressesCartScreen');
    cartBloc = context.read<CartBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    cartBloc.add(FetchShippingMethods(
        inventorySearchBloc: inventorySearchBloc, orderId: widget.orderId));
    address1Node.addListener(_onFocusChange);
    //carouselController.an
    //Get information to send tax info
    _getUserInformation();
    subscription = cartBloc.stream.listen((event) {
      if (event.isContactMissing == true) {
        scrollController.animateTo(0,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
      }
    });
  }

  void _onFocusChange() {
    if (address1Node.hasFocus) {
/*
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) =>
              SearchPlacesPage())).then((value) async {
        if (value != null) {
          setState(() {
            cityController.text =
            value[1];
            stateController.text =
            value[2];
            address1Controller
                .text = value[0];
            zipController.text =
            value[3];
            cartBloc.add(
                UpdateSelectedState(
                    value:
                    value[2]));
            cartBloc.add(
                UpdateSelectedCity(
                    value:
                    value[1]));
          });
          SelectState.globalKey.currentState!.onSelectedState(stateController.text);
          await Future.delayed(Duration(seconds: 1));
          SelectState.globalKey.currentState!.onSelectedCity(cityController.text);
          setState(() {});
        }
      });
*/
    }
  }

  @override
  void dispose() {
    // setState(() {
    //   currentIndexOfAddressSlide = -1;
    // });
    subscription?.cancel();
    address1Node.removeListener(_onFocusChange);

    zipNode.dispose();
    address1Node.dispose();
    address2Node.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<CartBloc, CartState>(
        listener: (context, cartState) async {
      String id = await SharedPreferenceService().getValue(agentId);
      if (cartState.cartStatus == CartStatus.successState &&
          !cartState.fetchingAddresses &&
          id.isNotEmpty &&
          cartState.activeStep == 1) {
        await Future.delayed(Duration(milliseconds: 200));
        print("cartState.activeStep ${cartState.activeStep}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          carouselController.animateToPage(cartState.addressModel
                  .where((element) => element.isSelected!)
                  .isNotEmpty
              ? cartState.addressModel.indexOf((cartState.addressModel
                  .firstWhere((element) => element.isSelected!)))
              : 0);
        });
      }
    }, builder: (context, cartState) {
      if (cartState.cartStatus == CartStatus.successState &&
          !cartState.fetchingAddresses) {
        return Stack(
          children: [
            cartState.addAddress
                ? Column(
                    children: [
                      Expanded(
                        child: Material(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                            elevation: 0,
                            color: Color(0xffFDFDFE),
                            borderOnForeground: true,
                            type: MaterialType.canvas,
                            clipBehavior: Clip.hardEdge,
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50.0, vertical: 10),
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (scrollNotification) {
                                    if (scrollNotification
                                        is ScrollStartNotification) {
                                      widget.onScrollStart(
                                          scrollNotification.metrics,
                                          cartState);
                                    } else if (scrollNotification
                                        is ScrollUpdateNotification) {
                                      widget.onUpdateScroll(
                                          scrollNotification.metrics,
                                          cartState);
                                    } else if (scrollNotification
                                        is ScrollEndNotification) {
                                      widget.onScrollEnd(
                                          scrollNotification.metrics,
                                          cartState);
                                    }
                                    return true;
                                  },
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 15),
                                          child: Material(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: 5,
                                            type: MaterialType.card,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                            shadowColor: ColorSystem.shadowGrey,
                                            child: DottedBorder(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                              dashPattern: [9, 4],
                                              radius: Radius.circular(15),
                                              borderType: BorderType.RRect,
                                              child: Container(
                                                height: 160,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15),
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 40),
                                                  child: Center(
                                                    child: Text(
                                                      " + Add Address",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size20,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: ColorSystem
                                                              .primary,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        Text(
                                          "Add Address",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF222222),
                                              fontFamily: kRubik),
                                        ),
                                        SizedBox(height: 20),
                                        Form(
                                          key: addressFormKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // TextFormField(
                                              //   autofocus: false,
                                              //   cursorColor:
                                              //       Theme.of(context).primaryColor,
                                              //   controller: labelController,
                                              //   keyboardType:
                                              //       TextInputType.text,
                                              //   focusNode: labelNode,
                                              //   textCapitalization:
                                              //       TextCapitalization.words,
                                              //   textInputAction:
                                              //       TextInputAction.next,
                                              //   validator: (String? value) {
                                              //     if (value!.isEmpty ||
                                              //         value.length < 3) {
                                              //       return "Please input label of your address";
                                              //     }
                                              //     return null;
                                              //   },
                                              //   onEditingComplete: () {
                                              //     FocusScope.of(context)
                                              //         .requestFocus(
                                              //             address1Node);
                                              //   },
                                              //   decoration:
                                              //       InputDecoration(
                                              //     labelText: 'Label',
                                              //     alignLabelWithHint: false,
                                              //     hintText: "Home # 1",
                                              //     hintStyle: TextStyle(
                                              //       color: ColorSystem.greyDark,
                                              //       fontSize: SizeSystem.size18,
                                              //     ),
                                              //     floatingLabelBehavior:
                                              //         FloatingLabelBehavior
                                              //             .always,
                                              //     constraints: BoxConstraints(),
                                              //     contentPadding:
                                              //         EdgeInsets.symmetric(
                                              //             vertical: 10,
                                              //             horizontal: 0),
                                              //     labelStyle: TextStyle(
                                              //       color: ColorSystem.greyDark,
                                              //     ),
                                              //     errorStyle: TextStyle(
                                              //         color:
                                              //             ColorSystem.lavender3,
                                              //         fontWeight:
                                              //             FontWeight.w400),
                                              //     focusedBorder:
                                              //         UnderlineInputBorder(
                                              //       borderSide: BorderSide(
                                              //         color:
                                              //             ColorSystem.greyDark,
                                              //         width: 1,
                                              //       ),
                                              //     ),
                                              //     border: UnderlineInputBorder(
                                              //       borderSide: BorderSide(
                                              //         color:
                                              //             ColorSystem.greyDark,
                                              //         width: 1,
                                              //       ),
                                              //     ),
                                              //     enabledBorder:
                                              //         UnderlineInputBorder(
                                              //       borderSide: BorderSide(
                                              //         color:
                                              //             ColorSystem.greyDark,
                                              //         width: 1,
                                              //       ),
                                              //     ),
                                              //     errorBorder:
                                              //         UnderlineInputBorder(
                                              //       borderSide: BorderSide(
                                              //         color:
                                              //             ColorSystem.lavender3,
                                              //         width: 1,
                                              //       ),
                                              //     ),
                                              //     focusedErrorBorder:
                                              //         UnderlineInputBorder(
                                              //       borderSide: BorderSide(
                                              //         color:
                                              //             ColorSystem.lavender3,
                                              //         width: 1,
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              // SizedBox(
                                              //   height: 10,
                                              // ),
                                              TextFormField(
                                                autofocus: false,
                                                cursorColor: Theme.of(context)
                                                    .primaryColor,
                                                controller: address1Controller,
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(CupertinoPageRoute(
                                                          builder: (context) =>
                                                              SearchPlacesPage()))
                                                      .then((value) async {
                                                    if (value != null) {
                                                      setState(() {
                                                        cityController.text =
                                                            value[1];
                                                        stateController.text =
                                                            value[2];
                                                        address1Controller
                                                            .text = value[0];
                                                        zipController.text =
                                                            value[3];
                                                        cartBloc.add(
                                                            UpdateSelectedState(
                                                                value:
                                                                    value[2]));
                                                        cartBloc.add(
                                                            UpdateSelectedCity(
                                                                value:
                                                                    value[1]));
                                                      });
                                                      _selectState
                                                          .call(value[2]);
                                                      await Future.delayed(
                                                          Duration(seconds: 1));
                                                      _selectCity
                                                          .call(value[1]);
                                                      setState(() {});
                                                      addressFormKey
                                                          .currentState!
                                                          .validate();
                                                    }
                                                  });
                                                },
                                                readOnly: true,
                                                focusNode: address1Node,
                                                validator: (String? value) {
                                                  if (value!.isEmpty ||
                                                      value.length < 3) {
                                                    return "Please input address line 1";
                                                  }
                                                  return null;
                                                },
                                                textInputAction:
                                                    TextInputAction.next,
                                                onEditingComplete: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          address2Node);
                                                },
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Address Line 1',
                                                  alignLabelWithHint: false,
                                                  hintText: "Address Line 1",
                                                  hintStyle: TextStyle(
                                                    color: ColorSystem.greyDark,
                                                    fontSize: SizeSystem.size18,
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  constraints: BoxConstraints(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 0),
                                                  labelStyle: TextStyle(
                                                    color: ColorSystem.greyDark,
                                                  ),
                                                  errorStyle: TextStyle(
                                                      color:
                                                          ColorSystem.lavender3,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.lavender3,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.lavender3,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
                                                autofocus: false,
                                                cursorColor: Theme.of(context)
                                                    .primaryColor,
                                                controller: address2Controller,
                                                focusNode: address2Node,
                                                validator: (String? value) {
                                                  // if (value!.isEmpty ||
                                                  //     value.length < 3) {
                                                  //   return "Please input address line 2";
                                                  // }
                                                  return null;
                                                },
                                                textInputAction:
                                                    TextInputAction.next,
                                                onEditingComplete: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(zipNode);
                                                },
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Address Line 2',
                                                  hintText: 'Address Line 2',
                                                  hintStyle: TextStyle(
                                                    color: ColorSystem.greyDark,
                                                    fontSize: SizeSystem.size18,
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .auto,
                                                  constraints: BoxConstraints(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 0),
                                                  labelStyle: TextStyle(
                                                    color: ColorSystem.greyDark,
                                                  ),
                                                  errorStyle: TextStyle(
                                                      color:
                                                          ColorSystem.lavender3,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.lavender3,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          ColorSystem.lavender3,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              CSCPicker(
                                                showStates: true,
                                                showCities: true,
                                                builderState:
                                                    (BuildContext context,
                                                        void Function(String)
                                                            selectState) {
                                                  _selectState = selectState;
                                                },
                                                builderCity:
                                                    (BuildContext context,
                                                        void Function(String)
                                                            selectCity) {
                                                  _selectCity = selectCity;
                                                },
                                                cityTextEditingController:
                                                    cityController,
                                                stateTextEditingController:
                                                    stateController,
                                                stateValidator:
                                                    (String? value) {
                                                  if (value!.isEmpty ||
                                                      value ==
                                                          "Choose State/Province") {
                                                    return "Please select your state";
                                                  }
                                                  return null;
                                                },
                                                cityValidator: (String? value) {
                                                  if (value!.isEmpty ||
                                                      value == "Choose City") {
                                                    return "Please select your city";
                                                  }
                                                  return null;
                                                },
                                                flagState: CountryFlag
                                                    .SHOW_IN_DROP_DOWN_ONLY,
                                                countrySearchPlaceholder:
                                                    "Country",
                                                stateSearchPlaceholder: "State",
                                                citySearchPlaceholder: "City",
                                                zipCode: TextFormField(
                                                  autofocus: false,
                                                  cursorColor: Theme.of(context)
                                                      .primaryColor,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .characters,
                                                  controller: zipController,
                                                  onEditingComplete: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                  focusNode: zipNode,
                                                  validator: (String? value) {
                                                    if (value!.isEmpty ||
                                                        value.length < 2) {
                                                      return "Please input your zip code";
                                                    }
                                                    return null;
                                                  },
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  decoration: InputDecoration(
                                                    labelText: 'ZIP Code',
                                                    hintText: 'ZIP Code',
                                                    alignLabelWithHint: false,
                                                    hintStyle: TextStyle(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      fontSize:
                                                          SizeSystem.size18,
                                                    ),
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    constraints:
                                                        BoxConstraints(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 0),
                                                    labelStyle: TextStyle(
                                                      color:
                                                          ColorSystem.greyDark,
                                                    ),
                                                    errorStyle: TextStyle(
                                                        color: ColorSystem
                                                            .lavender3,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .greyDark,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .greyDark,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .greyDark,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    errorBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .lavender3,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    focusedErrorBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .lavender3,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onStateChanged: (value) {
                                                  stateController.text =
                                                      value ?? "";
                                                  cartBloc.add(
                                                      UpdateSelectedState(
                                                          value: value ?? ""));
                                                },
                                                onCityChanged: (value) {
                                                  cityController.text =
                                                      value ?? "";
                                                  cartBloc.add(
                                                      UpdateSelectedCity(
                                                          value: value ?? ""));
                                                },
                                                countryDropdownLabel: "Country",
                                                stateDropdownLabel: "State",
                                                cityDropdownLabel: "City",
                                                defaultCountry:
                                                    CscCountry.United_States,
                                                dropdownHeadingStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                dropdownItemStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                                dropdownDialogRadius: 10.0,
                                                searchBarRadius: 10.0,
                                              ),
/*                                              SelectState(
                                                cityNode: cityNode,
                                                stateNode: stateNode,
                                                stateValidator: (String? value) {
                                                  if (value!.isEmpty ||
                                                      value ==
                                                          "Choose State/Province") {
                                                    return "Please select your state";
                                                  }
                                                  return null;
                                                },
                                                cityValidator: (String? value) {
                                                  if (value!.isEmpty ||
                                                      value == "Choose City") {
                                                    return "Please select your city";
                                                  }
                                                  return null;
                                                },
                                                zipCode: TextFormField(
                                                  autofocus: false,
                                                  cursorColor:
                                                      Theme.of(context).primaryColor,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .characters,
                                                  controller: zipController,
                                                  onEditingComplete: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            stateNode);
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                  focusNode: zipNode,
                                                  validator: (String? value) {
                                                    if (value!.isEmpty ||
                                                        value.length < 2) {
                                                      return "Please input your zip code";
                                                    }
                                                    return null;
                                                  },
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  decoration:
                                                      InputDecoration(
                                                    labelText: 'ZIP Code',
                                                    alignLabelWithHint: false,
                                                    hintText: "94528",
                                                    hintStyle: TextStyle(
                                                      color:
                                                          ColorSystem.greyDark,
                                                      fontSize:
                                                          SizeSystem.size18,
                                                    ),
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    constraints:
                                                        BoxConstraints(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 0),
                                                    labelStyle: TextStyle(
                                                      color:
                                                          ColorSystem.greyDark,
                                                    ),
                                                    errorStyle: TextStyle(
                                                        color: ColorSystem
                                                            .lavender3,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .greyDark,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .greyDark,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .greyDark,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    errorBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .lavender3,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    focusedErrorBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: ColorSystem
                                                            .lavender3,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onStateChanged: (value) {
                                                  cartBloc.add(UpdateSelectedState(value: value));
                                                },
                                                onCityChanged: (value) {
                                                  cartBloc.add(UpdateSelectedCity(value: value));
                                                },
                                              ),*/
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                        "Save as Default Address",
                                                        style: TextStyle(
                                                            fontSize: SizeSystem
                                                                .size18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: ColorSystem
                                                                .greyDark,
                                                            fontFamily:
                                                                kRubik)),
                                                  ),
                                                  CustomSwitch(
                                                    value: cartState
                                                        .isDefaultAddress,
                                                    onChanged: (v) => cartBloc.add(
                                                        UpdateSaveAsDefaultAddress(
                                                            value: v)),
                                                    activeText: Container(
                                                      width: 28,
                                                    ),
                                                    inactiveText: Container(
                                                      width: 28,
                                                    ),
                                                    activeColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    inactiveColor:
                                                        ColorSystem.greyDark,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(ColorSystem
                                                                .primaryTextColor),
                                                    shape: MaterialStateProperty
                                                        .all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ))),
                                                onPressed: () async {
                                                  print("ok");
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  if (addressFormKey
                                                      .currentState!
                                                      .validate()) {
                                                    String recordId =
                                                        await SharedPreferenceService()
                                                            .getValue(agentId);
                                                    cartBloc.add(
                                                        GetRecommendedAddresses(
                                                            orderId:
                                                                widget.orderId,
                                                            recordId: recordId,
                                                            index: -10,
                                                            contactPointAddressId:
                                                                "",
                                                            address1:
                                                                address1Controller
                                                                    .text,
                                                            address2:
                                                                address2Controller
                                                                    .text,
                                                            country: "US",
                                                            city: cartState
                                                                .selectedCity,
                                                            label: "",
                                                            state: cartState
                                                                .selectedState,
                                                            postalCode:
                                                                zipController
                                                                    .text,
                                                            isShipping: true,
                                                            isBilling: false));
                                                  } else {}
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Save',
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: WidgetsBinding.instance.window
                                                      .viewInsets.bottom <=
                                                  0
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.0
                                              : MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.4,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                child: Card(
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                          color: ColorSystem.primaryTextColor,
                                          width: 2)),
                                  elevation: 5,
                                  child: InkWell(
                                    splashColor:
                                        ColorSystem.lavender3.withOpacity(0.1),
                                    highlightColor:
                                        ColorSystem.lavender3.withOpacity(0.1),
                                    hoverColor:
                                        ColorSystem.lavender3.withOpacity(0.1),
                                    onTap: () {
                                      showModalBottomSheet(
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(builder:
                                                (context, bottomState) {
                                              return BlocProvider.value(
                                                value: cartBloc,
                                                child: BlocBuilder<CartBloc,
                                                        CartState>(
                                                    builder:
                                                        (context, cartState) {
                                                  return Padding(
                                                    padding:
                                                        MediaQuery.of(context)
                                                            .viewInsets,
                                                    child: Material(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  40),
                                                          topRight:
                                                              Radius.circular(
                                                                  40),
                                                        ),
                                                        elevation: 20,
                                                        shadowColor: ColorSystem
                                                            .greyDark,
                                                        color:
                                                            Color(0xffFDFDFE),
                                                        borderOnForeground:
                                                            true,
                                                        type: MaterialType.card,
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        30.0,
                                                                    vertical:
                                                                        10),
                                                            child: NotificationListener<
                                                                ScrollNotification>(
                                                              onNotification:
                                                                  (scrollNotification) {
                                                                if (scrollNotification
                                                                    is ScrollStartNotification) {
                                                                  widget.onScrollStart(
                                                                      scrollNotification
                                                                          .metrics,
                                                                      cartState);
                                                                } else if (scrollNotification
                                                                    is ScrollUpdateNotification) {
                                                                  widget.onUpdateScroll(
                                                                      scrollNotification
                                                                          .metrics,
                                                                      cartState);
                                                                } else if (scrollNotification
                                                                    is ScrollEndNotification) {
                                                                  widget.onScrollEnd(
                                                                      scrollNotification
                                                                          .metrics,
                                                                      cartState);
                                                                }
                                                                return true;
                                                              },
                                                              child:
                                                                  SingleChildScrollView(
                                                                controller:
                                                                    scrollController,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                            30),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "Contact Info",
                                                                          style: TextStyle(
                                                                              fontSize: SizeSystem.size20,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Color(0xFF222222),
                                                                              fontFamily: kRubik),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),
                                                                    Form(
                                                                      key:
                                                                          formKey,
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          _phoneEmailInput(),
                                                                          _firstNameInput(),
                                                                          _lastNameInput(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            30),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                  );
                                                }),
                                              );
                                            });
                                          });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.789,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 25),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Contact Info",
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size20,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF222222),
                                                        fontFamily: kRubik)),
                                                Image.asset(
                                                    "assets/images/delivery_info.png",
                                                    package: 'gc_customer_app',
                                                    width: 32)
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Text(cartState.shippingFName,
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF222222),
                                                        fontFamily: kRubik)),
                                                Text(
                                                    " ${cartState.shippingLName}",
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF222222),
                                                        fontFamily: kRubik)),
                                              ],
                                            ),
                                            // SizedBox(height: 3),
                                            Text(cartState.shippingEmail,
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size16,
                                                    color: Color(0xFF222222),
                                                    fontFamily: kRubik)),
                                            // SizedBox(height: 3),
                                            Text(
                                                cartState.shippingPhone
                                                            .length ==
                                                        10
                                                    ? '(' +
                                                        cartState.shippingPhone
                                                            .substring(0, 3) +
                                                        ') ' +
                                                        cartState.shippingPhone
                                                            .substring(3, 6) +
                                                        '-' +
                                                        cartState.shippingPhone
                                                            .substring(6, 10)
                                                    : cartState.shippingPhone,
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size16,
                                                    color: Color(0xFF222222),
                                                    fontFamily: kRubik)),
                                            // SizedBox(height: 10,),
                                            if (cartState.shippingFName.isEmpty ||
                                                cartState
                                                    .shippingLName.isEmpty ||
                                                cartState
                                                    .shippingEmail.isEmpty ||
                                                cartState
                                                    .shippingPhone.isEmpty ||
                                                cartState
                                                        .shippingPhone.length !=
                                                    10 ||
                                                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                    .hasMatch(cartState
                                                        .shippingEmail))
                                              Text(
                                                'Missing Information',
                                                style: TextStyle(
                                                    fontFamily: kRubik,
                                                    color: ColorSystem.pureRed,
                                                    fontSize: 12),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              NotificationListener<ScrollNotification>(
                                onNotification: (scrollNotification) {
                                  if (scrollNotification
                                      is ScrollStartNotification) {
                                    widget.onScrollStart(
                                        scrollNotification.metrics, cartState);
                                  } else if (scrollNotification
                                      is ScrollUpdateNotification) {
                                    widget.onUpdateScroll(
                                        scrollNotification.metrics, cartState);
                                  } else if (scrollNotification
                                      is ScrollEndNotification) {
                                    widget.onScrollEnd(
                                        scrollNotification.metrics, cartState);
                                  }
                                  return true;
                                },
                                child: CarouselSlider(
                                  carouselController: carouselController,
                                  items: cartState.addressModel.map((e) {
                                    if (e.addAddress!) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.0, vertical: 20),
                                        child: InkWell(
                                          onTap: () {
                                            cartBloc.add(
                                                UpdateAddAddress(value: true));

                                            //labelController.clear();
                                            cityController.clear();
                                            stateController.clear();
                                            address1Controller.clear();
                                            address2Controller.clear();
                                            zipController.clear();
                                            cartBloc.add(
                                                UpdateSelectedState(value: ""));
                                            cartBloc.add(
                                                UpdateSelectedCity(value: ""));
                                            cartBloc.add(
                                                UpdateSaveAsDefaultAddress(
                                                    value: true));
                                          },
                                          child: Material(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: 10,
                                            type: MaterialType.card,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                            shadowColor: ColorSystem.shadowGrey,
                                            child: DottedBorder(
                                              color: Colors.black,
                                              strokeWidth: 3,
                                              radius: Radius.circular(15),
                                              borderType: BorderType.RRect,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15),
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 40),
                                                  child: Center(
                                                    child: Text(
                                                      " + Add Address",
                                                      style: TextStyle(
                                                          fontSize:
                                                              SizeSystem.size20,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: ColorSystem
                                                              .primary,
                                                          fontFamily: kRubik),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.0, vertical: 20),
                                        child: InkWell(
                                          onTap: () async {
                                            setState(() {
                                              cityController.text = e.city!;
                                              stateController.text = e.state!;
                                              address1Controller.text =
                                                  e.address1!;
                                              address2Controller.text =
                                                  e.address2!;
                                              zipController.text =
                                                  e.postalCode!;
                                            });

                                            cartBloc.add(
                                                UpdateSaveAsDefaultAddress(
                                                    value:
                                                        e.isPrimary ?? false));
                                            showModalBottomSheet(
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 1000),
                                                      () async {
                                                    _selectState
                                                        .call(e.state ?? "");
                                                    await Future.delayed(
                                                        Duration(seconds: 1));
                                                    _selectCity
                                                        .call(e.city ?? "");
                                                  });

                                                  return StatefulBuilder(
                                                      builder: (context,
                                                          bottomState) {
                                                    return BlocProvider.value(
                                                      value: cartBloc,
                                                      child: BlocBuilder<
                                                              CartBloc,
                                                              CartState>(
                                                          builder: (context,
                                                              cartState) {
                                                        return Padding(
                                                          padding:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .viewInsets,
                                                          child: Material(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        40),
                                                                topRight: Radius
                                                                    .circular(
                                                                        40),
                                                              ),
                                                              elevation: 20,
                                                              shadowColor:
                                                                  ColorSystem
                                                                      .greyDark,
                                                              color: Color(
                                                                  0xffFDFDFE),
                                                              borderOnForeground:
                                                                  true,
                                                              type: MaterialType
                                                                  .card,
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              child: SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          50.0,
                                                                      vertical:
                                                                          10),
                                                                  child: NotificationListener<
                                                                      ScrollNotification>(
                                                                    onNotification:
                                                                        (scrollNotification) {
                                                                      if (scrollNotification
                                                                          is ScrollStartNotification) {
                                                                        widget.onScrollStart(
                                                                            scrollNotification.metrics,
                                                                            cartState);
                                                                      } else if (scrollNotification
                                                                          is ScrollUpdateNotification) {
                                                                        widget.onUpdateScroll(
                                                                            scrollNotification.metrics,
                                                                            cartState);
                                                                      } else if (scrollNotification
                                                                          is ScrollEndNotification) {
                                                                        widget.onScrollEnd(
                                                                            scrollNotification.metrics,
                                                                            cartState);
                                                                      }
                                                                      return true;
                                                                    },
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      controller:
                                                                          scrollController,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 30),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                "Edit Address",
                                                                                style: TextStyle(fontSize: SizeSystem.size20, fontWeight: FontWeight.w500, color: Color(0xFF222222), fontFamily: kRubik),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                              height: 20),
                                                                          Form(
                                                                            key:
                                                                                addressFormKey,
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
/*
                                                                                TextFormField(
                                                                                  autofocus: false,
                                                                                  cursorColor: Theme.of(context).primaryColor,
                                                                                  controller: labelController,
                                                                                  keyboardType: TextInputType.text,
                                                                                  focusNode: labelNode,
                                                                                  textCapitalization: TextCapitalization.words,
                                                                                  textInputAction: TextInputAction.next,
                                                                                  validator: (String? value) {
                                                                                    if (value!.isEmpty || value.length < 3) {
                                                                                      return "Please input label of your address";
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  onEditingComplete: () {
                                                                                    FocusScope.of(context).requestFocus(address1Node);
                                                                                  },
                                                                                  decoration: InputDecoration(
                                                                                    labelText: 'Label',
                                                                                    alignLabelWithHint: false,
                                                                                    hintText: "Home # 1",
                                                                                    hintStyle: TextStyle(
                                                                                      color: ColorSystem.greyDark,
                                                                                      fontSize: SizeSystem.size18,
                                                                                    ),
                                                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                                                    constraints: BoxConstraints(),
                                                                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                                                                    labelStyle: TextStyle(
                                                                                      color: ColorSystem.greyDark,
                                                                                    ),
                                                                                    errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                                    focusedBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    border: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    enabledBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    errorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.lavender3,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    focusedErrorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.lavender3,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
*/
                                                                                TextFormField(
                                                                                  autofocus: false,
                                                                                  onTap: () {
                                                                                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => SearchPlacesPage())).then((value) async {
                                                                                      if (value != null) {
                                                                                        bottomState(() {
                                                                                          cityController.text = value[1];
                                                                                          stateController.text = value[2];
                                                                                          address1Controller.text = value[0];
                                                                                          zipController.text = value[3];
                                                                                        });
                                                                                        _selectState.call(value[2]);
                                                                                        await Future.delayed(Duration(seconds: 1));
                                                                                        _selectCity.call(value[1]);
                                                                                        cartBloc.add(UpdateSelectedState(value: value[2]));
                                                                                        cartBloc.add(UpdateSelectedCity(value: cityController.text));
                                                                                        addressFormKey.currentState!.validate();
                                                                                        bottomState(() {});
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  readOnly: true,
                                                                                  cursorColor: Theme.of(context).primaryColor,
                                                                                  controller: address1Controller,
                                                                                  focusNode: address1Node,
                                                                                  validator: (String? value) {
                                                                                    if (value!.isEmpty || value.length < 3) {
                                                                                      return "Please input address line 1";
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  textInputAction: TextInputAction.next,
                                                                                  onEditingComplete: () {
                                                                                    FocusScope.of(context).requestFocus(address2Node);
                                                                                  },
                                                                                  textCapitalization: TextCapitalization.sentences,
                                                                                  keyboardType: TextInputType.text,
                                                                                  decoration: InputDecoration(
                                                                                    labelText: 'Address Line 1',
                                                                                    alignLabelWithHint: false,
                                                                                    hintText: "Address Line 1",
                                                                                    hintStyle: TextStyle(
                                                                                      color: ColorSystem.greyDark,
                                                                                      fontSize: SizeSystem.size18,
                                                                                    ),
                                                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                                                    constraints: BoxConstraints(),
                                                                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                                                                    labelStyle: TextStyle(
                                                                                      color: ColorSystem.greyDark,
                                                                                    ),
                                                                                    errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                                    focusedBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    border: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    enabledBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    errorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.lavender3,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    focusedErrorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.lavender3,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                TextFormField(
                                                                                  autofocus: false,
                                                                                  readOnly: false,
                                                                                  cursorColor: Theme.of(context).primaryColor,
                                                                                  controller: address2Controller,
                                                                                  focusNode: address2Node,
                                                                                  validator: (String? value) {
                                                                                    // if (value!.isEmpty ||
                                                                                    //     value.length < 3) {
                                                                                    //   return "Please input address line 2";
                                                                                    // }
                                                                                    return null;
                                                                                  },
                                                                                  textInputAction: TextInputAction.next,
                                                                                  onEditingComplete: () {
                                                                                    FocusScope.of(context).requestFocus(zipNode);
                                                                                  },
                                                                                  textCapitalization: TextCapitalization.sentences,
                                                                                  keyboardType: TextInputType.text,
                                                                                  decoration: InputDecoration(
                                                                                    labelText: 'Address Line 2',
                                                                                    hintText: 'Address Line 2',
                                                                                    hintStyle: TextStyle(
                                                                                      color: ColorSystem.greyDark,
                                                                                      fontSize: SizeSystem.size18,
                                                                                    ),
                                                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                                                    constraints: BoxConstraints(),
                                                                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                                                                    labelStyle: TextStyle(
                                                                                      color: ColorSystem.greyDark,
                                                                                    ),
                                                                                    errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                                    focusedBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    border: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    enabledBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.greyDark,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    errorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.lavender3,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                    focusedErrorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: ColorSystem.lavender3,
                                                                                        width: 1,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                CSCPicker(
                                                                                  showStates: true,
                                                                                  showCities: true,
                                                                                  builderState: (BuildContext context, void Function(String) selectState) {
                                                                                    _selectState = selectState;
                                                                                  },
                                                                                  builderCity: (BuildContext context, void Function(String) selectCity) {
                                                                                    _selectCity = selectCity;
                                                                                  },
                                                                                  cityTextEditingController: cityController,
                                                                                  stateTextEditingController: stateController,
                                                                                  stateValidator: (String? value) {
                                                                                    if (value!.isEmpty || value == "Choose State/Province") {
                                                                                      return "Please select your state";
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  cityValidator: (String? value) {
                                                                                    if (value!.isEmpty || value == "Choose City") {
                                                                                      return "Please select your city";
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                                                                                  countrySearchPlaceholder: "Country",
                                                                                  stateSearchPlaceholder: "State",
                                                                                  citySearchPlaceholder: "City",
                                                                                  zipCode: TextFormField(
                                                                                    autofocus: false,
                                                                                    cursorColor: Theme.of(context).primaryColor,
                                                                                    textCapitalization: TextCapitalization.characters,
                                                                                    controller: zipController,
                                                                                    onEditingComplete: () {
                                                                                      FocusScope.of(context).unfocus();
                                                                                    },
                                                                                    keyboardType: TextInputType.text,
                                                                                    focusNode: zipNode,
                                                                                    validator: (String? value) {
                                                                                      if (value!.isEmpty || value.length < 2) {
                                                                                        return "Please input your zip code";
                                                                                      }
                                                                                      return null;
                                                                                    },
                                                                                    textInputAction: TextInputAction.done,
                                                                                    decoration: InputDecoration(
                                                                                      labelText: 'ZIP Code',
                                                                                      hintText: 'ZIP Code',
                                                                                      alignLabelWithHint: false,
                                                                                      hintStyle: TextStyle(
                                                                                        color: ColorSystem.greyDark,
                                                                                        fontSize: SizeSystem.size18,
                                                                                      ),
                                                                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                                                                      constraints: BoxConstraints(),
                                                                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                                                                      labelStyle: TextStyle(
                                                                                        color: ColorSystem.greyDark,
                                                                                      ),
                                                                                      errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                                      focusedBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.greyDark,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      border: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.greyDark,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      enabledBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.greyDark,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      errorBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.lavender3,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      focusedErrorBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.lavender3,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onStateChanged: (value) {
                                                                                    stateController.text = value ?? "";
                                                                                    cartBloc.add(UpdateSelectedState(value: value ?? ""));
                                                                                  },
                                                                                  onCityChanged: (value) {
                                                                                    cityController.text = value ?? "";
                                                                                    cartBloc.add(UpdateSelectedCity(value: value ?? ""));
                                                                                  },
                                                                                  countryDropdownLabel: "Country",
                                                                                  stateDropdownLabel: "State",
                                                                                  cityDropdownLabel: "City",
                                                                                  defaultCountry: CscCountry.United_States,
                                                                                  dropdownHeadingStyle: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
                                                                                  dropdownItemStyle: TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                  dropdownDialogRadius: 10.0,
                                                                                  searchBarRadius: 10.0,
                                                                                ),
/*                                                                                SelectState(
                                                                                  cityNode: cityNode,
                                                                                  stateNode: stateNode,
                                                                                  initCity: e.city!.replaceAll("New York", "New York City"),
                                                                                  initState: e.state,
                                                                                  stateValidator: (String? value) {
                                                                                    if (value!.isEmpty || value == "Choose State/Province") {
                                                                                      return "Please select your state";
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  cityValidator: (String? value) {
                                                                                    if (value!.isEmpty || value == "Choose City") {
                                                                                      return "Please select your city";
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  zipCode: TextFormField(
                                                                                    autofocus: false,
                                                                                    cursorColor: Theme.of(context).primaryColor,
                                                                                    textCapitalization: TextCapitalization.characters,
                                                                                    controller: zipController,
                                                                                    onEditingComplete: () {
                                                                                      FocusScope.of(context).unfocus();
                                                                                      FocusScope.of(context).requestFocus(stateNode);
                                                                                    },
                                                                                    keyboardType: TextInputType.text,
                                                                                    focusNode: zipNode,
                                                                                    validator: (String? value) {
                                                                                      if (value!.isEmpty || value.length < 2) {
                                                                                        return "Please input your zip code";
                                                                                      }
                                                                                      return null;
                                                                                    },
                                                                                    textInputAction: TextInputAction.done,
                                                                                    decoration: InputDecoration(
                                                                                      labelText: 'ZIP Code',
                                                                                      alignLabelWithHint: false,
                                                                                      hintText: "94528",
                                                                                      hintStyle: TextStyle(
                                                                                        color: ColorSystem.greyDark,
                                                                                        fontSize: SizeSystem.size18,
                                                                                      ),
                                                                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                                                                      constraints: BoxConstraints(),
                                                                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                                                                      labelStyle: TextStyle(
                                                                                        color: ColorSystem.greyDark,
                                                                                      ),
                                                                                      errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
                                                                                      focusedBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.greyDark,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      border: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.greyDark,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      enabledBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.greyDark,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      errorBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.lavender3,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      focusedErrorBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: ColorSystem.lavender3,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onStateChanged: (value) {
                                                                                    cartBloc.add(UpdateSelectedState(value: value));
                                                                                  },
                                                                                  onCityChanged: (value) {
                                                                                    cartBloc.add(UpdateSelectedCity(value: value));
                                                                                  },
                                                                                ),*/
                                                                                SizedBox(
                                                                                  height: 30,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text("Save as Default Address", style: TextStyle(fontSize: SizeSystem.size18, fontWeight: FontWeight.w500, color: ColorSystem.greyDark, fontFamily: kRubik)),
                                                                                    ),
                                                                                    CustomSwitch(
                                                                                      value: e.isPrimary!,
                                                                                      onChanged: (v) => cartBloc.add(UpdateSaveAsDefaultAddress(value: v)),
                                                                                      activeText: Container(
                                                                                        width: 28,
                                                                                      ),
                                                                                      inactiveText: Container(
                                                                                        width: 28,
                                                                                      ),
                                                                                      activeColor: Theme.of(context).primaryColor,
                                                                                      inactiveColor: ColorSystem.greyDark,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 30,
                                                                                ),
                                                                                ElevatedButton(
                                                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor), shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)))),
                                                                                  onPressed: () async {
                                                                                    FocusScope.of(context).unfocus();
                                                                                    if (addressFormKey.currentState!.validate()) {
                                                                                      String address1 = address1Controller.text;
                                                                                      String address2 = address2Controller.text;
//                                                                                      String label = labelController.text;
                                                                                      String zip = zipController.text;
                                                                                      print("address1Controller.text ${address1Controller.text}");
                                                                                      print("address2Controller.text ${address2Controller.text}");
//                                                                                      print(labelController.text);
                                                                                      print(e.contactPointAddressId);
                                                                                      String recordId = await SharedPreferenceService().getValue(agentId);
                                                                                      cartBloc.add(GetRecommendedAddresses(orderId: widget.orderId, recordId: recordId, index: -10, address1: address1Controller.text, address2: address2Controller.text, country: "US", city: cartState.selectedCity, label: "", contactPointAddressId: e.contactPointAddressId ?? "", state: cartState.selectedState, postalCode: zipController.text, isShipping: true, isBilling: false));
                                                                                      Navigator.pop(context);
                                                                                    } else {}
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.symmetric(vertical: 15),
                                                                                    child: cartState.savingAddress
                                                                                        ? Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              CupertinoActivityIndicator(
                                                                                                color: Colors.white,
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Text(
                                                                                                'Update Address',
                                                                                                style: TextStyle(fontSize: 18),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )),
                                                        );
                                                      }),
                                                    );
                                                  });
                                                }).whenComplete(() {
                                              // labelController.clear();
                                              cityController.clear();
                                              stateController.clear();
                                              address1Controller.clear();
                                              address2Controller.clear();
                                              zipController.clear();
                                              cartBloc.add(UpdateSelectedState(
                                                  value: ""));
                                              cartBloc.add(UpdateSelectedCity(
                                                  value: ""));
                                              cartBloc.add(UpdateAddAddress(
                                                  value: false));
                                            });
                                          },
                                          child: Material(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: e.isSelected! ? 10 : 0,
                                            type: MaterialType.card,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                            shadowColor: ColorSystem.shadowGrey,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(15),
                                                ),
                                                border: Border.all(
                                                  width: e.isSelected! ? 3 : 0,
                                                  color: e.isSelected!
                                                      ? Colors.black
                                                      : Color(0xffF3F6FA),
                                                  style: BorderStyle.solid,
                                                ),
                                                color: e.isSelected!
                                                    ? Colors.white
                                                    : Color(0xffF3F6FA),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                    vertical: 30),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            e.isPrimary ?? false
                                                                ? "Default Address"
                                                                : "",
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize:
                                                                    SizeSystem
                                                                        .size18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    ColorSystem
                                                                        .primary,
                                                                fontFamily:
                                                                    kRubik),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        SvgPicture.asset(
                                                          IconSystem.shipping,
                                                          package:
                                                              'gc_customer_app',
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(height: 15),
                                                    Flexible(
                                                      child: Text(
                                                        "${e.address1!}, ${e.address2 ?? ""}, ${e.city!}, ${e.state!}, ${e.postalCode ?? ""}",
                                                        textAlign:
                                                            TextAlign.start,
                                                        maxLines: 3,
                                                        style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: SizeSystem
                                                                .size16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: ColorSystem
                                                                .primary,
                                                            fontFamily: kRubik),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }).toList(),
                                  options: CarouselOptions(
                                      height: 210,
                                      enableInfiniteScroll: false,
                                      scrollPhysics: cartState
                                                  .shippingFName.isNotEmpty &&
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
                                                      cartState.shippingEmail)
                                          ? ClampingScrollPhysics()
                                          : NeverScrollableScrollPhysics(),
                                      initialPage: cartState.selectedAddressIndex,
                                      enlargeCenterPage: true,
                                      onPageChanged: (index, e) {
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
                                          setState(() {
                                            cartBloc.add(
                                                ChangeAddressIsSelectedWithAddress(
                                                    addressModel:
                                                        cartState.addressModel[
                                                            index],
                                                    firstName:
                                                        firstNameController
                                                            .text,
                                                    lastName:
                                                        lastNameController.text,
                                                    email: emailController.text,
                                                    phone: phoneNumberController
                                                        .text
                                                        .replaceAll('(', '')
                                                        .replaceAll(')', '')
                                                        .replaceAll('-', '')
                                                        .replaceAll(' ', ''),
                                                    orderID: widget.orderId,
                                                    index: index));
                                          });
                                        }
                                        //  else {
                                        //   showMessage(context: context,message:"Contact Info is missing");
                                        //   scrollController.animateTo(0,
                                        //       duration:
                                        //           Duration(milliseconds: 200),
                                        //       curve: Curves.ease);
                                        // }
                                      },
                                      viewportFraction: 0.8),
                                ),
                              ),
                              SizedBox(height: 10),
                              Material(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40)),
                                  elevation: 20,
                                  shadowColor: ColorSystem.greyDark,
                                  color: Color(0xffFDFDFE),
                                  borderOnForeground: true,
                                  type: MaterialType.card,
                                  clipBehavior: Clip.hardEdge,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30.0, vertical: 0),
                                      child: NotificationListener<
                                          ScrollNotification>(
                                        onNotification: (scrollNotification) {
                                          if (scrollNotification
                                              is ScrollStartNotification) {
                                            widget.onScrollStart(
                                                scrollNotification.metrics,
                                                cartState);
                                          } else if (scrollNotification
                                              is ScrollUpdateNotification) {
                                            widget.onUpdateScroll(
                                                scrollNotification.metrics,
                                                cartState);
                                          } else if (scrollNotification
                                              is ScrollEndNotification) {
                                            widget.onScrollEnd(
                                                scrollNotification.metrics,
                                                cartState);
                                          }
                                          return true;
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 30),
                                            Text(
                                              "Select Delivery",
                                              style: TextStyle(
                                                  fontSize: SizeSystem.size20,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF222222),
                                                  fontFamily: kRubik),
                                            ),
                                            SizedBox(height: 10),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: cartState.deliveryModels
                                                  .map((e) {
                                                if (e.type == "Pick-up") {
                                                  return e.isSelected!
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  if (cartState.shippingFName.isNotEmpty &&
                                                                      cartState
                                                                          .shippingLName
                                                                          .isNotEmpty &&
                                                                      cartState
                                                                          .shippingEmail
                                                                          .isNotEmpty &&
                                                                      cartState
                                                                          .shippingPhone
                                                                          .isNotEmpty &&
                                                                      cartState
                                                                              .shippingPhone
                                                                              .length ==
                                                                          10 &&
                                                                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                                          .hasMatch(
                                                                              cartState.shippingEmail)) {
                                                                    if (cartState
                                                                            .orderDetailModel
                                                                            .first
                                                                            .approvalRequest ==
                                                                        'Approved') {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        content:
                                                                            Text("To change delivery reset/remove shipping override"),
                                                                        duration:
                                                                            Duration(seconds: 1),
                                                                      ));
                                                                      return;
                                                                    }

                                                                    setState(
                                                                        () {
                                                                      e.isPickup =
                                                                          true;
                                                                      var store =
                                                                          cartState
                                                                              .selectedPickupStore;
                                                                      if (store !=
                                                                          null) {
                                                                        e.pickupAddress =
                                                                            '${store.storeAddressC},\n${store.storeCityC}, ${store.stateC}, ${store.postalCodeC}';
                                                                      }
                                                                      cartBloc.add(
                                                                          ChangeDeliveryModelIsSelectedWithDelivery(
                                                                        orderId:
                                                                            widget.orderId,
                                                                        deliveryModel:
                                                                            e,
                                                                        firstName:
                                                                            firstNameController.text,
                                                                        lastName:
                                                                            lastNameController.text,
                                                                        email: emailController
                                                                            .text,
                                                                        phone: phoneNumberController
                                                                            .text
                                                                            .replaceAll('(',
                                                                                '')
                                                                            .replaceAll(')',
                                                                                '')
                                                                            .replaceAll('-',
                                                                                '')
                                                                            .replaceAll(' ',
                                                                                ''),
                                                                      ));
                                                                    });
                                                                  } else {
                                                                    showMessage(
                                                                        context:
                                                                            context,
                                                                        message:
                                                                            "Contact Info is missing");
                                                                    scrollController.animateTo(
                                                                        0,
                                                                        duration: Duration(
                                                                            milliseconds:
                                                                                200),
                                                                        curve: Curves
                                                                            .ease);
                                                                  }
                                                                },
                                                                child: Material(
                                                                  clipBehavior:
                                                                      Clip.hardEdge,
                                                                  elevation: 10,
                                                                  color: Colors
                                                                      .white,
                                                                  type:
                                                                      MaterialType
                                                                          .card,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                  ),
                                                                  shadowColor:
                                                                      ColorSystem
                                                                          .greyDark,
                                                                  child:
                                                                      Container(
//                                                        height: 200,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.9,
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            15),
                                                                      ),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        width:
                                                                            3,
                                                                        color: Colors
                                                                            .black,
                                                                        style: BorderStyle
                                                                            .solid,
                                                                      ),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              30.0,
                                                                          horizontal:
                                                                              30),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    e.type!,
                                                                                    maxLines: 2,
                                                                                    style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size18, fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor, fontFamily: kRubik),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  if (cartState.shippingFName.isNotEmpty && cartState.shippingLName.isNotEmpty && cartState.shippingEmail.isNotEmpty && cartState.shippingPhone.isNotEmpty && cartState.shippingPhone.length == 10 && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(cartState.shippingEmail)) {
                                                                                    Navigator.push(
                                                                                        context,
                                                                                        CupertinoPageRoute(
                                                                                          builder: (context) => StoreSearchZipCodePage(
                                                                                            orderID: widget.orderId,
                                                                                          ),
                                                                                        )).then((value) async {
                                                                                      if (value != null) {
                                                                                        cartBloc.add(UpdatePickUpZip(
                                                                                          searchStoreList: value[0],
                                                                                          searchStoreListInformation: value[1],
                                                                                          orderID: widget.orderId,
                                                                                          firstName: firstNameController.text,
                                                                                          lastName: lastNameController.text,
                                                                                          email: emailController.text,
                                                                                          phone: phoneNumberController.text.replaceAll('(', '').replaceAll(')', '').replaceAll('-', '').replaceAll(' ', ''),
                                                                                        ));
                                                                                      }
                                                                                    });
                                                                                  } else {
                                                                                    showMessage(context: context, message: "Contact Info is missing");
                                                                                    scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.ease);
                                                                                  }
                                                                                },
                                                                                child: Text(
                                                                                  cartState.pickUpZip.isEmpty ? "Search Store" : cartState.pickUpZip,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: cartState.pickUpZip.isEmpty ? 15 : SizeSystem.size18, fontWeight: FontWeight.w400, color: ColorSystem.lavender3, fontFamily: kRubik),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  e.name ?? '',
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size18, fontWeight: FontWeight.w400, color: ColorSystem.greyDark, fontFamily: kRubik),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                e.time!.isNotEmpty ? e.time! + "mil" : "",
                                                                                maxLines: 1,
                                                                                style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size18, fontWeight: FontWeight.w400, color: ColorSystem.greyDark, fontFamily: kRubik),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            if (cartState
                                                                    .deliveryModels
                                                                    .length >
                                                                1)
                                                              Column(
                                                                children: [
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  Text(
                                                                    "Ship To Home",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            SizeSystem
                                                                                .size20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Color(
                                                                            0xFF222222),
                                                                        fontFamily:
                                                                            kRubik),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                ],
                                                              ),
                                                          ],
                                                        )
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  if (cartState.shippingFName.isNotEmpty &&
                                                                      cartState
                                                                          .shippingLName
                                                                          .isNotEmpty &&
                                                                      cartState
                                                                          .shippingEmail
                                                                          .isNotEmpty &&
                                                                      cartState
                                                                          .shippingPhone
                                                                          .isNotEmpty &&
                                                                      cartState
                                                                              .shippingPhone
                                                                              .length ==
                                                                          10 &&
                                                                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                                          .hasMatch(
                                                                              cartState.shippingEmail)) {
                                                                    if (cartState
                                                                            .orderDetailModel
                                                                            .first
                                                                            .approvalRequest ==
                                                                        'Approved') {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        content:
                                                                            Text("To change delivery reset/remove shipping override"),
                                                                        duration:
                                                                            Duration(seconds: 1),
                                                                      ));
                                                                      return;
                                                                    }
                                                                    if (cartState
                                                                            .pickUpZip
                                                                            .isNotEmpty &&
                                                                        cartState.selectedPickupStore !=
                                                                            null) {
                                                                      cartBloc.add(
                                                                          UpdatePickUpZip(
                                                                        orderID:
                                                                            widget.orderId,
                                                                        firstName:
                                                                            firstNameController.text,
                                                                        lastName:
                                                                            lastNameController.text,
                                                                        email: emailController
                                                                            .text,
                                                                        phone: phoneNumberController
                                                                            .text
                                                                            .replaceAll('(',
                                                                                '')
                                                                            .replaceAll(')',
                                                                                '')
                                                                            .replaceAll('-',
                                                                                '')
                                                                            .replaceAll(' ',
                                                                                ''),
                                                                        searchStoreList:
                                                                            cartState.selectedPickupStoreList!,
                                                                        searchStoreListInformation:
                                                                            cartState.selectedPickupStore!,
                                                                      ));
                                                                      setState(
                                                                          () {
                                                                        cartBloc
                                                                            .add(ChangeDeliveryModelIsSelectedWithDelivery(
                                                                          orderId:
                                                                              widget.orderId,
                                                                          deliveryModel:
                                                                              e,
                                                                          firstName:
                                                                              firstNameController.text,
                                                                          lastName:
                                                                              lastNameController.text,
                                                                          email:
                                                                              emailController.text,
                                                                          phone: phoneNumberController
                                                                              .text
                                                                              .replaceAll('(', '')
                                                                              .replaceAll(')', '')
                                                                              .replaceAll('-', '')
                                                                              .replaceAll(' ', ''),
                                                                        ));
                                                                      });
                                                                    }
                                                                  } else {
                                                                    showMessage(
                                                                        context:
                                                                            context,
                                                                        message:
                                                                            "Contact Info is missing");
                                                                    scrollController.animateTo(
                                                                        0,
                                                                        duration: Duration(
                                                                            milliseconds:
                                                                                200),
                                                                        curve: Curves
                                                                            .ease);
                                                                  }
                                                                },
                                                                child: Material(
                                                                  clipBehavior:
                                                                      Clip.hardEdge,
                                                                  elevation: 0,
                                                                  color: ColorSystem
                                                                      .greyDark,
                                                                  type:
                                                                      MaterialType
                                                                          .card,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                  ),
                                                                  shadowColor:
                                                                      ColorSystem
                                                                          .greyDark,
                                                                  child:
                                                                      Container(
//                                                        height: 200,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.9,
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            15),
                                                                      ),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        width:
                                                                            3,
                                                                        color: Color(
                                                                            0xffF3F6FA),
                                                                        style: BorderStyle
                                                                            .solid,
                                                                      ),
                                                                      color: Color(
                                                                          0xffF3F6FA),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              30.0,
                                                                          horizontal:
                                                                              30),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    e.type!,
                                                                                    maxLines: 2,
                                                                                    style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size18, fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor, fontFamily: kRubik),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  if (cartState.shippingFName.isNotEmpty && cartState.shippingLName.isNotEmpty && cartState.shippingEmail.isNotEmpty && cartState.shippingPhone.isNotEmpty && cartState.shippingPhone.length == 10 && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(cartState.shippingEmail)) {
                                                                                    Navigator.push(
                                                                                        context,
                                                                                        CupertinoPageRoute(
                                                                                          builder: (context) => StoreSearchZipCodePage(
                                                                                            orderID: widget.orderId,
                                                                                          ),
                                                                                        )).then((value) async {
                                                                                      if (value != null) {
                                                                                        cartBloc.add(UpdatePickUpZip(
                                                                                          searchStoreList: value[0],
                                                                                          searchStoreListInformation: value[1],
                                                                                          orderID: widget.orderId,
                                                                                          firstName: firstNameController.text,
                                                                                          lastName: lastNameController.text,
                                                                                          email: emailController.text,
                                                                                          phone: phoneNumberController.text.replaceAll('(', '').replaceAll(')', '').replaceAll('-', '').replaceAll(' ', ''),
                                                                                        ));
                                                                                      }
                                                                                    });
                                                                                  } else {
                                                                                    showMessage(context: context, message: "Contact Info is missing");
                                                                                    scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.ease);
                                                                                  }
                                                                                },
                                                                                child: Text(
                                                                                  cartState.pickUpZip.isEmpty ? "Search Store" : cartState.pickUpZip,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: cartState.pickUpZip.isEmpty ? 15 : SizeSystem.size18, fontWeight: FontWeight.w400, color: ColorSystem.lavender3, fontFamily: kRubik),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                e.name ?? '',
                                                                                maxLines: 1,
                                                                                style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size18, fontWeight: FontWeight.w400, color: ColorSystem.greyDark, fontFamily: kRubik),
                                                                              ),
                                                                              Text(
                                                                                e.time!.isNotEmpty ? e.time! + "mil" : "",
                                                                                maxLines: 1,
                                                                                style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size18, fontWeight: FontWeight.w400, color: ColorSystem.greyDark, fontFamily: kRubik),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            if (cartState
                                                                    .deliveryModels
                                                                    .length >
                                                                1)
                                                              Column(
                                                                children: [
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  Text(
                                                                    "Ship To Home",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            SizeSystem
                                                                                .size20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Color(
                                                                            0xFF222222),
                                                                        fontFamily:
                                                                            kRubik),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                ],
                                                              ),
                                                          ],
                                                        );
                                                } else {
                                                  return e.isSelected!
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (cartState.shippingFName.isNotEmpty &&
                                                                  cartState
                                                                      .shippingLName
                                                                      .isNotEmpty &&
                                                                  cartState
                                                                      .shippingEmail
                                                                      .isNotEmpty &&
                                                                  cartState
                                                                      .shippingPhone
                                                                      .isNotEmpty &&
                                                                  cartState
                                                                          .shippingPhone
                                                                          .length ==
                                                                      10 &&
                                                                  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                                      .hasMatch(
                                                                          cartState
                                                                              .shippingEmail)) {
                                                                if (cartState
                                                                        .orderDetailModel
                                                                        .first
                                                                        .approvalRequest ==
                                                                    'Approved') {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                    content: Text(
                                                                        "To change delivery reset/remove shipping override"),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                  ));

                                                                  return;
                                                                }
                                                                print('----1');
                                                                setState(() {
                                                                  cartBloc.add(
                                                                      ChangeDeliveryModelIsSelectedWithDelivery(
                                                                    deliveryModel:
                                                                        e,
                                                                    orderId: widget
                                                                        .orderId,
                                                                    firstName:
                                                                        firstNameController
                                                                            .text,
                                                                    lastName:
                                                                        lastNameController
                                                                            .text,
                                                                    email:
                                                                        emailController
                                                                            .text,
                                                                    phone: phoneNumberController
                                                                        .text
                                                                        .replaceAll(
                                                                            '(', '')
                                                                        .replaceAll(
                                                                            ')', '')
                                                                        .replaceAll(
                                                                            '-',
                                                                            '')
                                                                        .replaceAll(
                                                                            ' ',
                                                                            ''),
                                                                  ));
                                                                });
                                                              } else {
                                                                showMessage(
                                                                    context:
                                                                        context,
                                                                    message:
                                                                        "Contact Info is missing");
                                                                scrollController.animateTo(0,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            200),
                                                                    curve: Curves
                                                                        .ease);
                                                              }
                                                            },
                                                            child: Material(
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              elevation: 10,
                                                              color:
                                                                  Colors.white,
                                                              type: MaterialType
                                                                  .card,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    15),
                                                              ),
                                                              shadowColor:
                                                                  ColorSystem
                                                                      .greyDark,
                                                              child: Container(
//                                                        height: 200,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.9,
                                                                clipBehavior:
                                                                    Clip.hardEdge,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                  ),
                                                                  border: Border
                                                                      .all(
                                                                    width: 3,
                                                                    color: Colors
                                                                        .black,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          40.0,
                                                                      horizontal:
                                                                          30),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Flexible(
                                                                            child:
                                                                                Text(
                                                                              e.address!,
                                                                              maxLines: 2,
                                                                              style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size17, fontWeight: FontWeight.w400, color: ColorSystem.black, fontFamily: kRubik),
                                                                            ),
                                                                          ),
                                                                          /* e.isSelected!
                                                                              ? SvgPicture.asset(IconSystem.greenTick)
                                                                              : SvgPicture.asset(
                                                                                  IconSystem.greenTick,
                                                                                  color: ColorSystem.greyDark,
                                                                                )*/
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (cartState.shippingFName.isNotEmpty &&
                                                                  cartState
                                                                      .shippingLName
                                                                      .isNotEmpty &&
                                                                  cartState
                                                                      .shippingEmail
                                                                      .isNotEmpty &&
                                                                  cartState
                                                                      .shippingPhone
                                                                      .isNotEmpty &&
                                                                  cartState
                                                                          .shippingPhone
                                                                          .length ==
                                                                      10 &&
                                                                  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                                      .hasMatch(
                                                                          cartState
                                                                              .shippingEmail)) {
                                                                if (cartState
                                                                        .addressModel
                                                                        .length <=
                                                                    1) {
                                                                  String name = e
                                                                          .address
                                                                          ?.split(
                                                                              ' - ')
                                                                          .first ??
                                                                      '';
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                    content: Text(
                                                                        "Add Address to select \"$name\" shipping."),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                  ));
                                                                  return;
                                                                }
                                                                if (cartState
                                                                        .orderDetailModel
                                                                        .first
                                                                        .approvalRequest ==
                                                                    'Approved') {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                    content: Text(
                                                                        "To change delivery reset/remove shipping override"),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                  ));

                                                                  return;
                                                                }
                                                                setState(() {
                                                                  cartBloc.add(
                                                                      ChangeDeliveryModelIsSelectedWithDelivery(
                                                                    orderId: widget
                                                                        .orderId,
                                                                    deliveryModel:
                                                                        e,
                                                                    firstName:
                                                                        firstNameController
                                                                            .text,
                                                                    lastName:
                                                                        lastNameController
                                                                            .text,
                                                                    email:
                                                                        emailController
                                                                            .text,
                                                                    phone: phoneNumberController
                                                                        .text
                                                                        .replaceAll(
                                                                            '(', '')
                                                                        .replaceAll(
                                                                            ')', '')
                                                                        .replaceAll(
                                                                            '-',
                                                                            '')
                                                                        .replaceAll(
                                                                            ' ',
                                                                            ''),
                                                                  ));
                                                                });
                                                              } else {
                                                                showMessage(
                                                                    context:
                                                                        context,
                                                                    message:
                                                                        "Contact Info is missing");
                                                                scrollController.animateTo(0,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            200),
                                                                    curve: Curves
                                                                        .ease);
                                                              }
                                                            },
                                                            child: Material(
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              elevation: 0,
                                                              color: ColorSystem
                                                                  .greyDark,
                                                              type: MaterialType
                                                                  .card,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    15),
                                                              ),
                                                              shadowColor:
                                                                  ColorSystem
                                                                      .greyDark,
                                                              child: Container(
//                                                        height: 200,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.9,
                                                                clipBehavior:
                                                                    Clip.hardEdge,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                  ),
                                                                  border: Border
                                                                      .all(
                                                                    width: 0,
                                                                    color: Color(
                                                                        0xffF3F6FA),
                                                                    style: BorderStyle
                                                                        .solid,
                                                                  ),
                                                                  color: Color(
                                                                      0xffF3F6FA),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          40.0,
                                                                      horizontal:
                                                                          30),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
/*
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .start,
                                                                        children: [
                                                                          Text(
                                                                            e.type!,
                                                                            maxLines:
                                                                                2,
                                                                            style: TextStyle(
                                                                                overflow:
                                                                                    TextOverflow.ellipsis,
                                                                                fontSize: SizeSystem.size18,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Theme.of(context).primaryColor,
                                                                                fontFamily: kRubik),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
*/
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Flexible(
                                                                            child:
                                                                                Text(
                                                                              e.address!,
                                                                              maxLines: 2,
                                                                              style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: SizeSystem.size17, fontWeight: FontWeight.w400, color: ColorSystem.black, fontFamily: kRubik),
                                                                            ),
                                                                          ),
                                                                          /*e.isSelected!
                                                                              ? SvgPicture.asset(IconSystem.greenTick)
                                                                              : SvgPicture.asset(
                                                                                  IconSystem.greenTick,
                                                                                  color: ColorSystem.greyDark,
                                                                                )*/
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                }
                                              }).toList(),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.2,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
          ],
        );
      } else {
        return Center(
            child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ));
      }
      return SizedBox.shrink();
    });
  }

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final FocusNode phoneFN = FocusNode();
  final FocusNode emailFN = FocusNode();
  final FocusNode firstNameFN = FocusNode();
  final FocusNode lastNameFN = FocusNode();

  Widget _phoneEmailInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GuitarCentreInputField(
          focusNode: phoneFN,
          textEditingController: phoneNumberController,
          label: 'Phone',
          hintText: '(123) 456-7890',
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            cartBloc.add(SetShippingCredential(
                shippingFormKey: formKey,
                shippingFName: firstNameController.text,
                shippingLName: lastNameController.text,
                shippingPhone: value
                    .replaceAll('(', '')
                    .replaceAll(')', '')
                    .replaceAll('-', '')
                    .replaceAll(' ', ''),
                shippingEmail: emailController.text));
          },
          errorStyle: TextStyle(
              color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.lavender3,
              width: 1,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
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
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.greyDark,
              width: 1,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.greyDark,
              width: 1,
            ),
          ),
          textInputType: TextInputType.number,
          inputFormatters: [PhoneInputFormatter(mask: '(###) ###-####')],
          leadingIcon: IconSystem.phone,
          validator: (value) {
            if (value!.isNotEmpty && value.length == 14) {
              return null;
            } else {
              phoneFN.requestFocus();
              scrollController.animateTo(0.0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300));

              return 'Please enter phone number';
            }
          },
        ),
        GuitarCentreInputField(
          focusNode: emailFN,
          textEditingController: emailController,
          label: 'Email',
          hintText: 'abc@xyz.com',
          errorStyle: TextStyle(
              color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.lavender3,
              width: 1,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
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
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.greyDark,
              width: 1,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.greyDark,
              width: 1,
            ),
          ),
          textInputType: TextInputType.emailAddress,
          leadingIcon: IconSystem.messageOutline,
          onChanged: (email) {
            cartBloc.add(SetShippingCredential(
                shippingFormKey: formKey,
                shippingFName: firstNameController.text,
                shippingLName: lastNameController.text,
                shippingPhone: phoneNumberController.text
                    .replaceAll('(', '')
                    .replaceAll(')', '')
                    .replaceAll('-', '')
                    .replaceAll(' ', ''),
                shippingEmail: email));
          },
          validator: (value) {
            if (RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value!)) {
              return null;
            } else {
              emailFN.requestFocus();
              scrollController.animateTo(0.0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300));
              return "Please enter your valid email";
            }
          },
        )
      ],
    );
  }

  Widget _firstNameInput() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: GuitarCentreInputField(
        focusNode: firstNameFN,
        textEditingController: firstNameController,
        label: 'First Name',
        onChanged: (value) {
          cartBloc.add(SetShippingCredential(
              shippingFormKey: formKey,
              shippingFName: value,
              shippingLName: lastNameController.text,
              shippingPhone: phoneNumberController.text
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll('-', '')
                  .replaceAll(' ', ''),
              shippingEmail: emailController.text));
        },
        textInputAction: TextInputAction.next,
        validator: (value) {
          if ((value ?? '').trim().isEmpty) {
            firstNameFN.requestFocus();
            scrollController.animateTo(0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300));
            // Focus.of(context).requestFocus(firstNameFN);
            return 'Please enter first name';
          }
          return null;
        },
        textInputType: TextInputType.text,
        errorStyle: TextStyle(
            color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorSystem.lavender3,
            width: 1,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
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
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorSystem.greyDark,
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorSystem.greyDark,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _lastNameInput() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: GuitarCentreInputField(
        focusNode: lastNameFN,
        textEditingController: lastNameController,
        onChanged: (value) {
          cartBloc.add(SetShippingCredential(
              shippingFormKey: formKey,
              shippingFName: firstNameController.text,
              shippingLName: value,
              shippingPhone: phoneNumberController.text
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll('-', '')
                  .replaceAll(' ', ''),
              shippingEmail: emailController.text));
        },
        label: 'Last Name',
        validator: (value) {
          if ((value ?? '').trim().isEmpty) {
            lastNameFN.requestFocus();
            scrollController.animateTo(0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300));

            // Focus.of(context).requestFocus(lastNameFN);
            return 'Please enter last name';
          }
          return null;
        },
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
        errorStyle: TextStyle(
            color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorSystem.lavender3,
            width: 1,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
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
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorSystem.greyDark,
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorSystem.greyDark,
            width: 1,
          ),
        ),
      ),
    );
  }

  String getFormattedDate(DateTime date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return formattedDate;
  }

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  Future<void> _getUserInformation() async {
    email = (widget.email ?? '').isNotEmpty
        ? widget.email!
        : await SharedPreferenceService().getValue(agentEmail);
    phone = (widget.phone ?? '').isNotEmpty
        ? widget.phone!
        : await SharedPreferenceService().getValue(agentPhone);
    firstName = (widget.firstName ?? '').isNotEmpty
        ? widget.firstName!
        : await SharedPreferenceService().getValue(savedAgentFirstName);
    lastName = (widget.lastName ?? '').isNotEmpty
        ? widget.lastName!
        : await SharedPreferenceService().getValue(savedAgentLastName);
    setState(() {});
    if (phone.length == 10) {
      phone = '(' +
          phone.substring(0, 3) +
          ') ' +
          phone.substring(3, 6) +
          '-' +
          phone.substring(6, 10);
    }

    phoneNumberController.text = cartBloc.state.shippingPhone.isNotEmpty
        ? '(' +
            cartBloc.state.shippingPhone.substring(0, 3) +
            ') ' +
            cartBloc.state.shippingPhone.substring(3, 6) +
            '-' +
            cartBloc.state.shippingPhone.substring(6, 10)
        : (cartBloc.state.orderDetailModel.first.phone ?? "").isNotEmpty
            ? '(' +
                cartBloc.state.orderDetailModel.first.phone!.substring(0, 3) +
                ') ' +
                cartBloc.state.orderDetailModel.first.phone!.substring(3, 6) +
                '-' +
                cartBloc.state.orderDetailModel.first.phone!.substring(6, 10)
            : phone;

    emailController.text = cartBloc.state.shippingEmail.isNotEmpty
        ? cartBloc.state.shippingEmail
        : (cartBloc.state.orderDetailModel.first.shippingEmail ?? "").isNotEmpty
            ? cartBloc.state.orderDetailModel.first.shippingEmail ?? ""
            : email;

    firstNameController.text = cartBloc.state.shippingFName.isNotEmpty
        ? cartBloc.state.shippingFName
        : (cartBloc.state.orderDetailModel.first.firstName ?? "").isNotEmpty
            ? cartBloc.state.orderDetailModel.first.firstName ?? ""
            : firstName;

    lastNameController.text = cartBloc.state.shippingLName.isNotEmpty
        ? cartBloc.state.shippingLName
        : (cartBloc.state.orderDetailModel.first.lastname ?? "").isNotEmpty
            ? cartBloc.state.orderDetailModel.first.lastname ?? ""
            : lastName;

    phoneNumberController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneNumberController.text.length),
    );
    emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: emailController.text.length),
    );
    lastNameController.selection = TextSelection.fromPosition(
      TextPosition(offset: lastNameController.text.length),
    );
    firstNameController.selection = TextSelection.fromPosition(
      TextPosition(offset: firstNameController.text.length),
    );
    setState(() {});
    cartBloc.add(SetShippingCredential(
        shippingFormKey: formKey,
        shippingFName: cartBloc.state.shippingFName.isNotEmpty
            ? cartBloc.state.shippingFName
            : (cartBloc.state.orderDetailModel.first.firstName ?? "").isNotEmpty
                ? cartBloc.state.orderDetailModel.first.firstName!
                : firstNameController.text,
        shippingLName: cartBloc.state.shippingLName.isNotEmpty
            ? cartBloc.state.shippingLName
            : (cartBloc.state.orderDetailModel.first.lastname ?? "").isNotEmpty
                ? cartBloc.state.orderDetailModel.first.lastname!
                : lastNameController.text,
        shippingPhone: cartBloc.state.shippingPhone.isNotEmpty
            ? cartBloc.state.shippingPhone
            : (cartBloc.state.orderDetailModel.first.phone ?? "").isNotEmpty
                ? cartBloc.state.orderDetailModel.first.phone!
                : phoneNumberController.text
                    .replaceAll('(', '')
                    .replaceAll(')', '')
                    .replaceAll('-', '')
                    .replaceAll(' ', ''),
        shippingEmail: cartBloc.state.shippingEmail.isNotEmpty
            ? cartBloc.state.shippingEmail
            : (cartBloc.state.orderDetailModel.first.shippingEmail ?? "")
                    .isNotEmpty
                ? cartBloc.state.orderDetailModel.first.shippingEmail!
                : emailController.text));
  }
}
