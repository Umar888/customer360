import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/input_field_with_validations.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/cart/views/cart_list.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/formatter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../bloc/cart_bloc/add_customer_bloc/add_customer_bloc.dart';
import 'add_new_customer/add_new_customer_widget.dart';
import 'add_new_customer/create_new_customer_screen_cart.dart';

typedef ValuesBuilder = void Function(
    BuildContext context, void Function(String address1, String address2, String city, String state, String zip) setValues);

class AddNewCustomer extends StatefulWidget {
  final MyBuilder controller;
  final CartState state;
  final CartBloc cartBloc;
  final String orderId;
  final bool isNoUser;
  final void Function() function;

  AddNewCustomer(
      {Key? key,
      this.isNoUser = false,
      required this.function,
      required this.cartBloc,
      required this.orderId,
      required this.state,
      required this.controller})
      : super(key: key);

  @override
  State<AddNewCustomer> createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  late AddCustomerBloc addCustomerBloc;

  String email = '';

  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  late void Function(String address1, String address2, String city, String state, String zip) myMethod;
  StreamController<String> streamControllerPhone = StreamController();
  StreamController<String> streamControllerEmail = StreamController();

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void callApiToSearchEmail(BuildContext context) {
    emailFocusNode.unfocus();

    addCustomerBloc.add(LoadLookUpData(emailController.text, SearchType.email));
  }

  void callApiToSearchPhone(BuildContext context) {
    var phone = phoneNumberController.text;
    phone = phone.replaceFirst('(', '');
    phone = phone.replaceFirst(')', '');
    phone = phone.replaceFirst(' ', '');
    phone = phone.replaceFirst('-', '');
    if (phone.length == 10) {
      phoneFocusNode.unfocus();
      addCustomerBloc.add(LoadLookUpData(phone, SearchType.phone));
    }
  }

  @override
  void initState() {
    super.initState();

//    context.read<ApprovalProcessBloC>().add(LoadApprovalProcesss());
    addCustomerBloc = context.read<AddCustomerBloc>();
    addCustomerBloc.add(LoadFormKey());
    print("fetch user option");
    addCustomerBloc.add(FetchUserOptions());
    addCustomerBloc.add(ChangeCustomerType(true));

    if (mounted) {
      streamControllerEmail.stream.debounceTime(Duration(milliseconds: 600)).listen((s) => callApiToSearchEmail(context));
      streamControllerPhone.stream.debounceTime(Duration(milliseconds: 600)).listen((s) => callApiToSearchPhone(context));
    }

    phoneNumberController.addListener(() {
      // var phone = phoneNumberController.text;
      // phone = phone.replaceFirst('(', '');
      // phone = phone.replaceFirst(')', '');
      // phone = phone.replaceFirst(' ', '');
      // phone = phone.replaceFirst('-', '');
      // if (phone.length == 10) {
      //   addCustomerBloc.add(LoadLookUpData(phone, SearchType.phone));
      // }
      // if (phone.isEmpty) addCustomerBloc.add(ResetData());
    });

    emailFocusNode.addListener(() {
      // if (!emailFocusNode.hasFocus) {
      //   if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      //     addCustomerBloc.add(LoadLookUpData(email, SearchType.email));
      //   }
      // }
    });

    emailController.addListener(() {
      if (emailController.text.isEmpty) addCustomerBloc.add(ResetData());
    });

    setEmailController();
  }

  @override
  void dispose() {
    super.dispose();
    streamControllerEmail.close();
    streamControllerPhone.close();
    phoneNumberController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCustomerBloc, AddCustomerState>(listener: (context, state) {
      if (state.message.isNotEmpty) {
        if (state.message.contains('Recommended address not found')) {
          addCustomerBloc.add(ClearMessage());
          if (state.showRecommendedDialog) {
            addCustomerBloc.add(HideRecommendedDialogAddCustomer());
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  backgroundColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                        Text("Recommended address not found. Do you want to proceed with existing address?",
                            textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: kRubik)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      state.recommendedAddressLine1 +
                                          ", " +
                                          state.recommendedAddressLine2 +
                                          ", " +
                                          state.recommendedAddressLineCity +
                                          ", " +
                                          state.recommendedAddressLineState +
                                          ", " +
                                          state.recommendedAddressLineZipCode,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.normal, fontFamily: kRubik)),
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
                                  backgroundColor: MaterialStateProperty.all(ColorSystem.white),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: ColorSystem.primaryTextColor)))),
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
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
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
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
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
              if (value == "yes") {
                myMethod.call(state.recommendedAddressLine1, state.recommendedAddressLine2, state.recommendedAddressLineCity,
                    state.recommendedAddressLineState, state.recommendedAddressLineZipCode);
                addCustomerBloc.add(SaveCustomer(
                    email: state.currentEmail,
                    phone: state.currentPhone,
                    firstName: state.currentFName,
                    cartBloc: widget.cartBloc,
                    index: 0,
                    orderId: widget.orderId,
                    lastName: state.currentLName,
                    address1: state.currentAddress1,
                    address2: state.currentAddress2,
                    city: state.currentCity,
                    state: state.currentState,
                    zipCode: state.currentZip));
              }
            });
          } else {
            addCustomerBloc.add(SaveCustomer(
                email: state.currentEmail,
                phone: state.currentPhone,
                firstName: state.currentFName,
                cartBloc: widget.cartBloc,
                index: 0,
                orderId: widget.orderId,
                lastName: state.currentLName,
                address1: state.currentAddress1,
                address2: state.currentAddress2,
                city: state.currentCity,
                state: state.currentState,
                zipCode: state.currentZip));
          }
        }
      }
      if (state.recommendedAddress.isNotEmpty && state.showRecommendedDialog) {
        addCustomerBloc.add(HideRecommendedDialogAddCustomer());
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                    Text("Do you want to change the address?", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
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
                              Text("Existing", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: kRubik)),
                              SizedBox(
                                height: 10,
                              ),
                              Text(state.orderAddress,
                                  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontFamily: kRubik)),
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
                              Text("Recommended", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: kRubik)),
                              SizedBox(
                                height: 10,
                              ),
                              Text(state.recommendedAddress,
                                  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontFamily: kRubik)),
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
                              backgroundColor: MaterialStateProperty.all(ColorSystem.white),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: Theme.of(context).primaryColor)))),
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
                                  style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
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
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
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
          if (value == "no") {
            addCustomerBloc.add(SaveCustomer(
                email: state.currentEmail,
                phone: state.currentPhone,
                firstName: state.currentFName,
                cartBloc: widget.cartBloc,
                index: 0,
                orderId: widget.orderId,
                lastName: state.currentLName,
                address1: state.currentAddress1,
                address2: state.currentAddress2,
                city: state.currentCity,
                state: state.currentState,
                zipCode: state.currentZip));
          } else if (value == "yes") {
            myMethod.call(state.recommendedAddressLine1, state.recommendedAddressLine2, state.recommendedAddressLineCity,
                state.recommendedAddressLineState, state.recommendedAddressLineZipCode);
            addCustomerBloc.add(SaveCustomer(
                email: state.currentEmail,
                phone: state.currentPhone,
                firstName: state.currentFName,
                cartBloc: widget.cartBloc,
                index: 0,
                orderId: widget.orderId,
                lastName: state.currentLName,
                address1: state.recommendedAddressLine1,
                address2: state.recommendedAddressLine2,
                city: state.recommendedAddressLineCity,
                state: state.recommendedAddressLineState,
                zipCode: state.recommendedAddressLineZipCode));
          }
        });
      }
    }, builder: (context, state) {
      // List<UserProfile>? customers;
      // SearchType? type;
      // if (state.customerLookUpStatus is CustomerLookUpSuccess) {
      //   customers = state.users ?? [];
      //   type = state.type;
      // }

      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          addCustomerBloc.add(ChangeCustomerType(true));
                          phoneFocusNode.unfocus();
                          emailFocusNode.requestFocus();
                          emailController.clear();
                          phoneNumberController.clear();
                          addCustomerBloc.add(ResetData());
                          setEmailController();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: state.addCustomerType == AddCustomerType.email ? Theme.of(context).primaryColor : null,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Theme.of(context).primaryColor)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: Text(
                                  "Email",
                                  style: TextStyle(
                                    fontFamily: kRubik,
                                    fontSize: 16,
                                    color: state.addCustomerType == AddCustomerType.email ? ColorSystem.white : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          addCustomerBloc.add(ChangeCustomerType(false));
                          emailFocusNode.unfocus();
                          phoneFocusNode.requestFocus();
                          emailController.clear();
                          phoneNumberController.clear();
                          addCustomerBloc.add(ResetData());
                          setPhoneController();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: state.addCustomerType == AddCustomerType.phone ? Theme.of(context).primaryColor : null,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Theme.of(context).primaryColor)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: Text(
                                  "Phone",
                                  style: TextStyle(
                                    fontFamily: kRubik,
                                    fontSize: 16,
                                    color: state.addCustomerType == AddCustomerType.phone ? ColorSystem.white : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: 10),
                  state.addCustomerType == AddCustomerType.email
                      ? TextFormField(
                          focusNode: emailFocusNode,
                          textInputAction: TextInputAction.done,
                          controller: emailController,
                          enabled: true,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            if (val.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)) {
                              EasyDebounce.cancelAll();
                              setState(() {});
                              EasyDebounce.debounce('search_name_debounce', Duration(milliseconds: 300), () {
                                streamControllerEmail.add(val);
                              });
                            } else if (val.isEmpty) {
                              EasyDebounce.cancelAll();
                              setState(() {});
                              EasyDebounce.debounce('search_name_debounce', Duration(milliseconds: 300), () {
                                addCustomerBloc.add(ResetData());
                              });
                            }
                          },
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
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
                            hintText: 'Search Email',
                            errorText: (state.customerLookUpStatus == CustomerLookUpStatus.failure && state.addCustomerType == AddCustomerType.email)
                                ? 'No data found'
                                : null,
                            suffixIcon: state.customerLookUpStatus == CustomerLookUpStatus.loading
                                ? CupertinoActivityIndicator()
                                : state.customerLookUpStatus == CustomerLookUpStatus.success &&
                                        state.users != null &&
                                        state.addCustomerType == AddCustomerType.email &&
                                        state.users!.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: SvgPicture.asset(
                                          IconSystem.checkmark,
                                          package: 'gc_customer_app',
                                          color: ColorSystem.additionalGreen,
                                          height: 24,
                                        ),
                                      )
                                    : (state.customerLookUpStatus == CustomerLookUpStatus.failure && state.addCustomerType == AddCustomerType.email)
                                        ? InkWell(
                                            onTap: () {
                                              emailController.clear();
                                              addCustomerBloc.add(ResetData());
                                            },
                                            child: Icon(
                                              CupertinoIcons.clear,
                                              color: ColorSystem.complimentary,
                                            ),
                                          )
                                        : (state.customerLookUpStatus == CustomerLookUpStatus.initial &&
                                                state.addCustomerType == AddCustomerType.email &&
                                                emailController.text.isNotEmpty)
                                            ? InkWell(
                                                onTap: () {
                                                  emailController.clear();
                                                  addCustomerBloc.add(ResetData());
                                                },
                                                child: Icon(
                                                  CupertinoIcons.clear,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                            hintStyle: TextStyle(
                              color: ColorSystem.secondary,
                              fontSize: SizeSystem.size18,
                            ),
                          ),
                        )
                      : TextFormField(
                          focusNode: phoneFocusNode,
                          controller: phoneNumberController,
                          enabled: true,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.phone,
                          cursorColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            print(val.length);
                            if (val.isNotEmpty && val.length == 14) {
                              EasyDebounce.cancelAll();
                              setState(() {});
                              EasyDebounce.debounce('search_name_debounce', Duration(milliseconds: 300), () {
                                streamControllerPhone.add(val);
                              });
                            } else if (val.isEmpty) {
                              EasyDebounce.cancelAll();
                              setState(() {});
                              EasyDebounce.debounce('search_name_debounce', Duration(milliseconds: 300), () {
                                addCustomerBloc.add(ResetData());
                              });
                            }
                          },
                          inputFormatters: [PhoneInputFormatter(mask: '(###) ###-####')],
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
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
                            errorText: (state.customerLookUpStatus == CustomerLookUpStatus.failure &&
                                    (state.users ?? []).isEmpty &&
                                    state.addCustomerType == AddCustomerType.phone)
                                ? 'No data found'
                                : null,
                            suffixIcon: state.customerLookUpStatus == CustomerLookUpStatus.loading
                                ? CupertinoActivityIndicator()
                                : state.customerLookUpStatus == CustomerLookUpStatus.success &&
                                        state.users != null &&
                                        state.addCustomerType == AddCustomerType.phone &&
                                        state.users!.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: SvgPicture.asset(
                                          IconSystem.checkmark,
                                          package: 'gc_customer_app',
                                          color: ColorSystem.additionalGreen,
                                          height: 24,
                                        ),
                                      )
                                    : (state.customerLookUpStatus == CustomerLookUpStatus.failure && state.addCustomerType == AddCustomerType.phone)
                                        ? InkWell(
                                            onTap: () {
                                              phoneNumberController.clear();
                                              addCustomerBloc.add(ResetData());
                                            },
                                            child: Icon(
                                              CupertinoIcons.clear,
                                              color: ColorSystem.complimentary,
                                            ),
                                          )
                                        : (state.customerLookUpStatus == CustomerLookUpStatus.initial &&
                                                state.addCustomerType == AddCustomerType.phone &&
                                                phoneNumberController.text.isNotEmpty)
                                            ? InkWell(
                                                onTap: () {
                                                  phoneNumberController.clear();
                                                  addCustomerBloc.add(ResetData());
                                                },
                                                child: Icon(
                                                  CupertinoIcons.clear,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                            hintText: 'Search Phone',
                            hintStyle: TextStyle(
                              color: ColorSystem.secondary,
                              fontSize: SizeSystem.size18,
                            ),
                          ),
                        ),
                  if (state.customerLookUpStatus == CustomerLookUpStatus.success && (state.users ?? []).isNotEmpty)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: state.users!.map((e) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: state.users!.indexOf(e) == 0 ? 20 : 15),
                            BlocProvider.value(
                              value: widget.cartBloc,
                              child: BlocProvider.value(
                                value: addCustomerBloc,
                                child: AddNewCustomerWidget(
                                  customer: e,
                                  orderId: widget.orderId,
                                  cartBloc: widget.cartBloc,
                                  state: widget.state,
                                  function: widget.function,
                                  addCustomerBloc: addCustomerBloc,
                                  index: state.users!.indexOf(e),
                                  isNameSearch: false,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(
                              height: state.users!.indexOf(e) == state.users!.length - 1 ? 0 : 1,
                              color: Colors.black38,
                            )
                          ],
                        );
                      }).toList(),
                    ),
                  if (state.customerLookUpStatus == CustomerLookUpStatus.failure && (state.users ?? []).isEmpty)
                    BlocProvider.value(
                      value: widget.cartBloc,
                      child: BlocProvider.value(
                        value: addCustomerBloc,
                        child: CreateNewCustomerScreenCart(
                          controller: widget.controller,
                          state: widget.state,
                          cartBloc: widget.cartBloc,
                          orderId: widget.orderId,
                          phoneText: phoneNumberController.text.isNotEmpty ? phoneNumberController.text : "",
                          emailText: emailController.text.isNotEmpty ? emailController.text : "",
                          isFromSearch: false,
                          valuesController: (BuildContext context, void Function(String, String, String, String, String) setValues) {
                            myMethod = setValues;
                          },
                        ),
                      ),
                    ),
                  SizedBox(
                    height: WidgetsBinding.instance.window.viewInsets.bottom <= 0
                        ? MediaQuery.of(context).size.height * 0.2
                        : MediaQuery.of(context).size.height * 0.4,
                  )
                ],
              ),
            ),
          ),
          widget.state.loadingScreen
              ? SizedBox.expand(
                  child: Container(color: Colors.black38, child: Center(child: CircularProgressIndicator())),
                )
              : SizedBox.shrink()
        ],
      );
    });
  }

  Widget _phoneEmailInput(List<UserProfile>? customers, SearchType? type) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: GuitarCentreInputField(
            focusNode: phoneFocusNode,
            textEditingController: phoneNumberController,
            label: 'Phone',
            textInputAction: TextInputAction.done,
            hintText: '(123) 456-7890',
            textInputType: TextInputType.number,
            inputFormatters: [PhoneInputFormatter(mask: '(###) ###-####')],
            leadingIcon: IconSystem.phone,
            errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
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
            errorText: (customers ?? []).isEmpty && type == SearchType.phone ? 'No data found.' : null,
            suffixIcon: customers != null && type == SearchType.phone
                ? customers.isNotEmpty
                    ? SvgPicture.asset(
                        IconSystem.checkmark,
                        package: 'gc_customer_app',
                        color: ColorSystem.additionalGreen,
                        height: 24,
                      )
                    : InkWell(
                        onTap: () {
                          phoneNumberController.clear();
                          addCustomerBloc.add(ResetData());
                        },
                        child: Icon(
                          CupertinoIcons.clear,
                          color: ColorSystem.complimentary,
                        ),
                      )
                : SizedBox.shrink(),
          ),
        ),
        if (!((customers ?? []).isNotEmpty && type == SearchType.phone))
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: GuitarCentreInputField(
              focusNode: emailFocusNode,
              textEditingController: emailController,
              label: 'Email',
              hintText: 'abc@xyz.com',
              textInputType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              leadingIcon: IconSystem.messageOutline,
              onChanged: (email) {
                if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
                  addCustomerBloc.add(LoadLookUpData(email, SearchType.email));
                }
              },
              errorStyle: TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
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
              errorText: ((customers ?? []).isEmpty && type == SearchType.email) ? 'No data found' : null,
              suffixIcon: customers != null && type == SearchType.email
                  ? customers.isNotEmpty
                      ? SvgPicture.asset(
                          IconSystem.checkmark,
                          package: 'gc_customer_app',
                          color: ColorSystem.additionalGreen,
                          height: 24,
                        )
                      : InkWell(
                          onTap: () {
                            emailController.clear();
                            addCustomerBloc.add(ResetData());
                          },
                          child: Icon(
                            CupertinoIcons.clear,
                            color: ColorSystem.complimentary,
                          ),
                        )
                  : SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  Future<void> setEmailController() async {
    var agentEmails = await SharedPreferenceService().getValue(agentEmail);
    if (agentEmails != null && agentEmails.isNotEmpty) {
      addCustomerBloc.add(ChangeCustomerType(true));
      setState(() {
        emailController.text = agentEmails;
        streamControllerEmail.add(agentEmails);
      });
    }
  }

  Future<void> setPhoneController() async {
    var agentPhones = await SharedPreferenceService().getValue(agentPhone);
    if (agentPhones != null && agentPhones.isNotEmpty) {
      addCustomerBloc.add(ChangeCustomerType(false));
      var phone = agentPhones;
      if (phone.length == 10) {
        phone = '(' + phone.substring(0, 3) + ') ' + phone.substring(3, 6) + '-' + phone.substring(6, 10);
      }
      setState(() {
        phoneNumberController.text = phone;
        streamControllerPhone.add(agentPhones);
      });
    }
  }
}
