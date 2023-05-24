import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/add_customer_bloc/add_customer_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/country_state_city_picker/country_state_city_picker.dart';
import 'package:gc_customer_app/intermediate_widgets/input_field_with_validations.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/search_places/view/search_places_page.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/formatter.dart';

import '../../../../common_widgets/state_city_picker/csc_picker.dart';
import '../../../../common_widgets/state_city_picker/dropdown_with_search.dart';
import '../../../../primitives/size_system.dart';
import '../add_new_customer.dart';
import '../cart_list.dart';

class CreateNewCustomerScreenCart extends StatefulWidget {
  final CartState state;
  final CartBloc cartBloc;
  final String orderId;
  final String emailText;
  final String phoneText;
  final MyBuilder controller;
  final ValuesBuilder valuesController;
  final bool isFromSearch;
  CreateNewCustomerScreenCart(
      {Key? key,
      required this.emailText,
      required this.state,
      required this.valuesController,
      required this.cartBloc,
      required this.orderId,
      required this.controller,
      required this.phoneText,
      this.isFromSearch = false})
      : super(key: key);

  @override
  State<CreateNewCustomerScreenCart> createState() =>
      _CreateNewCustomerScreenCartState();
}

class _CreateNewCustomerScreenCartState
    extends State<CreateNewCustomerScreenCart> {
  late AddCustomerBloc customerLookUpBloc;
  String email = '';
  final StreamController<bool> _isOpenAddressController =
      StreamController<bool>.broadcast()..add(false);

  final FocusNode phoneFN = FocusNode();
  final FocusNode emailFN = FocusNode();
  final FocusNode firstNameFN = FocusNode();
  final FocusNode lastNameFN = FocusNode();
  final FocusNode addressFN1 = FocusNode();
  final FocusNode addressFN2 = FocusNode();
  final FocusNode zipCodeFN = FocusNode();
  late void Function(String) _selectState;
  late void Function(String) _selectCity;

  TextEditingController cityController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  String state = '';
  String city = '';

  late StreamSubscription<AddCustomerBloc> subscription;
  @override
  void initState() {
    super.initState();
    phoneNumberController.text = widget.phoneText;
    emailController.text = widget.emailText;
    customerLookUpBloc = context.read<AddCustomerBloc>();
    phoneNumberController.addListener(() {
      // var phone = phoneNumberController.text;
      // phone = phone.replaceFirst('(', '');
      // phone = phone.replaceFirst(')', '');
      // phone = phone.replaceFirst(' ', '');
      // phone = phone.replaceFirst('-', '');
      // if (phone.length == 10) {
      //   customerLookUpBloc.add(LoadLookUpData(phone, SearchType.phone));
      // }
//      if (phone.isEmpty) customerLookUpBloc.add(ClearData());
    });

    emailFN.addListener(() {
      // if (!emailFN.hasFocus) {
      //   if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      //     customerLookUpBloc.add(LoadLookUpData(email, SearchType.email));
      //   }
      // }
    });

    addressFN1.addListener(() {
      if (addressFN1.hasFocus) {
        _isOpenAddressController.add(true);
      }
    });
    addressFN2.addListener(() {
      if (addressFN2.hasFocus) {
//        _isOpenAddressController.add(true);
      }
    });
    emailController.addListener(() {
      if (emailController.text.isEmpty) {}
//        customerLookUpBloc.add(ClearData());
    });

    // subscription = customerLookUpBloc.stream.listen((state) {
    //   if (state is SaveCustomerSuccess) {
    //     if ((state.customer.id ?? '').isNotEmpty)
    //       SharedPreferenceService()
    //           .setKey(key: agentId, value: state.customer.id!);
    //     if ((state.customer.accountEmailC ?? '').isNotEmpty)
    //       SharedPreferenceService()
    //           .setKey(key: agentEmail, value: state.customer.accountEmailC!);
    //
    //     Navigator.pop(context, true);
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    //subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.call(context, saveCustomer);
    widget.valuesController.call(context, setValues);

    return _body();
  }

  saveCustomer() {
    print("getting");
    if (!customerLookUpBloc.state.showOption) {
      customerLookUpBloc.add(UpdateShowOptions(true));
    } else {
      if (address1Controller.text.isNotEmpty) {
        customerLookUpBloc.add(GetRecommendedAddressesAddCustomer(
            currentFName: firstNameController.text,
            currentLName: lastNameController.text,
            currentPhone: phoneNumberController.text
                .replaceAll('(', '')
                .replaceAll(')', '')
                .replaceAll('-', '')
                .replaceAll(' ', ''),
            isShipping: true,
            isBilling: false,
            address1: address1Controller.text,
            address2: address2Controller.text,
            city: city,
            cartBloc: widget.cartBloc,
            postalCode: zipCodeController.text,
            state: state,
            country: 'US',
            currentEmail: emailController.text));
      } else {
        customerLookUpBloc.add(SaveCustomer(
            email: emailController.text,
            phone: phoneNumberController.text,
            firstName: firstNameController.text,
            cartBloc: widget.cartBloc,
            index: 0,
            orderId: widget.orderId,
            lastName: lastNameController.text,
            address1: "",
            address2: "",
            city: "",
            state: "",
            zipCode: ""));
      }
    }
  }

  Widget _body() {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: BlocConsumer<AddCustomerBloc, AddCustomerState>(
            listener: (context, state) {
          if (state.message.isNotEmpty) {
            if (state.message != "done") {
              Future.delayed(Duration.zero, () {
                setState(() {});
                ScaffoldMessenger.of(context)
                    .showSnackBar(snackBar(state.message));
              });
            }
            customerLookUpBloc.add(ClearMessage());
          }
        }, builder: (context, state) {
          return Form(
            key: state.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                _phoneEmailInput(),
                _firstNameInput(),
                _lastNameInput(),
                _addressInput1(state),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(-1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child);
                  },
                  child: state.showOption
                      ? Padding(
                          key: ValueKey<bool>(true),
                          padding: EdgeInsets.only(left: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text(
                                "What are your interests?",
                                style: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 10),
                              GridView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                primary: false,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 3.5),
                                children: state.instruments!.map((e) {
                                  return CheckboxListTile(
                                      value:
                                          state.selectedInstruments.contains(e),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      checkColor: ColorSystem.white,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      checkboxShape: StadiumBorder(),
                                      title: Text(
                                        e.toString(),
                                        style: TextStyle(
                                            fontFamily: kRubik,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 14),
                                      ),
                                      onChanged: (value) {
                                        if (value != null && value) {
                                          customerLookUpBloc.add(
                                              SelectPreferredInstrument(e));
                                        } else {
                                          customerLookUpBloc.add(
                                              RemovePreferredInstrument(e));
                                        }
                                      });
                                }).toList(),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "How do you often play?",
                                style: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 10),
                              DropdownWithSearch(
                                textEditingController: null,
                                title: "Play Frequency",
                                placeHolder: "Search frequencies",
                                contentPadding: EdgeInsets.zero,
                                selectedItemStyle: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                validator: null,
                                dropdownHeadingStyle: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                                itemStyle: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                                decoration: null,
                                disabledDecoration: null,
                                disabled: state.frequencies!.length == 0
                                    ? true
                                    : false,
                                dialogRadius: 20,
                                searchBarRadius: 10,
                                label: "Search frequencies",
                                items: state.frequencies!
                                    .map((String? dropDownStringItem) {
                                  return dropDownStringItem;
                                }).toList(),
                                selected: state.selectedFrequency,
                                onChanged: (value) {
                                  if (value != null) {
                                    customerLookUpBloc
                                        .add(SelectPlayFrequency(value));
                                  }
                                },
                              ),
                              SizedBox(height: 20),
                              Text(
                                "What is your proficiency level?",
                                style: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 10),
                              DropdownWithSearch(
                                textEditingController: null,
                                title: "Proficiency Level",
                                placeHolder: "Search Proficiencies",
                                contentPadding: EdgeInsets.zero,
                                selectedItemStyle: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                validator: null,
                                dropdownHeadingStyle: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                                itemStyle: TextStyle(
                                    fontFamily: kRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                                decoration: null,
                                disabledDecoration: null,
                                disabled: state.proficiencies!.length == 0
                                    ? true
                                    : false,
                                dialogRadius: 20,
                                searchBarRadius: 10,
                                label: "Search Proficiencies",
                                items: state.proficiencies!
                                    .map((String? dropDownStringItem) {
                                  return dropDownStringItem;
                                }).toList(),
                                selected: state.selectedProficiency,
                                onChanged: (value) {
                                  if (value != null) {
                                    customerLookUpBloc
                                        .add(SelectProficiencyLevel(value));
                                  }
                                },
                              )
                            ],
                          ),
                        )
                      : SizedBox.shrink(
                          key: ValueKey<bool>(false),
                        ),
                )
              ],
            ),
          );
        }),
      );
    });
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
            if ((value ?? '').isEmpty && emailController.text.trim().isEmpty) {
              return '';
            }
            return null;
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
          onChanged: (email) => this.email = email,
          validator: (value) {
            if ((value ?? '').isEmpty &&
                phoneNumberController.text.trim().isEmpty) {
              return 'Please enter phone or email';
            }
            return null;
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
        textInputAction: TextInputAction.next,
        validator: (value) {
          if ((value ?? '').trim().isEmpty) {
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
        label: 'Last Name',
        validator: (value) {
          if ((value ?? '').trim().isEmpty) {
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

  Widget _addressInput1(AddCustomerState addCustomerState) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: StreamBuilder<bool>(
        stream: _isOpenAddressController.stream,
        initialData: false,
        builder: (context, snapshot) {
          var isOpen = snapshot.data ?? false;
          return AnimatedContainer(
            duration: Duration(milliseconds: 250),
            height: isOpen
                ? MediaQuery.of(context).size.height * 0.3
                : MediaQuery.of(context).size.height * 0.08,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GuitarCentreInputField(
                    focusNode: addressFN1,
                    textEditingController: address1Controller,
                    onChanged: (value) {
                      address1Controller.clear();
                      _isOpenAddressController.add(true);
                      Navigator.of(context)
                          .push(CupertinoPageRoute(
                              builder: (context) => SearchPlacesPage()))
                          .then((value) {
                        if (value != null) {
                          state = value[2];
                          city = value[1];
                          address1Controller.text = value[0];
                          zipCodeController.text = value[3];
                          _selectState.call(value[2]);
                          _selectCity.call(value[1]);
                        }

                        addCustomerState.formKey!.currentState!.validate();
                      });
                    },
                    label: 'Address',
                    hintText: isOpen ? '' : '###',
                    validator: (value) {
                      //   if ((value ?? '').trim().isEmpty) {
                      //     return 'Please enter address';
                      //   }
                      return null;
                    },
                    onTap: () {
                      _isOpenAddressController.add(true);
                      Navigator.of(context)
                          .push(CupertinoPageRoute(
                              builder: (context) => SearchPlacesPage()))
                          .then((value) {
                        if (value != null) {
                          state = value[2];
                          city = value[1];
                          address1Controller.text = value[0];
                          zipCodeController.text = value[3];
                          _selectState.call(value[2]);
                          _selectCity.call(value[1]);
                        }
                        addCustomerState.formKey!.currentState!.validate();
                      });
                    },
                    onFieldSubmitted: (p0) => addressFN1.nextFocus(),
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16),
                  isOpen
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GuitarCentreInputField(
                              focusNode: addressFN2,
                              textEditingController: address2Controller,
                              textInputAction: TextInputAction.done,
                              label: 'Address Line 2',
                              hintText: isOpen ? '' : '###',
                              onFieldSubmitted: (p0) => addressFN2.nextFocus(),
                              textInputType: TextInputType.text,
                              errorStyle: TextStyle(
                                  color: ColorSystem.lavender3,
                                  fontWeight: FontWeight.w400),
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
                            SizedBox(height: 16),
                            CSCPicker(
                              showStates: true,
                              showCities: true,
                              builderState: (BuildContext context,
                                  void Function(String) selectState) {
                                _selectState = selectState;
                              },
                              builderCity: (BuildContext context,
                                  void Function(String) selectCity) {
                                _selectCity = selectCity;
                              },
                              cityTextEditingController: cityController,
                              stateTextEditingController: stateController,
                              stateValidator: (String? value) {
                                // if (value!.isEmpty ||
                                //     value ==
                                //         "Choose State/Province") {
                                //   return "Please select your state";
                                // }
                                return null;
                              },
                              cityValidator: (String? value) {
                                // if (value!.isEmpty ||
                                //     value == "Choose City") {
                                //   return "Please select your city";
                                // }
                                return null;
                              },
                              flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                              countrySearchPlaceholder: "Country",
                              stateSearchPlaceholder: "State",
                              citySearchPlaceholder: "City",
                              zipCode: TextFormField(
                                autofocus: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization:
                                    TextCapitalization.characters,
                                controller: zipCodeController,
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                },
                                keyboardType: TextInputType.text,
                                focusNode: zipCodeFN,
                                validator: (String? value) {
                                  // if (value!.isEmpty ||
                                  //     value.length < 2) {
                                  //   return "Please input your zip code";
                                  // }
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
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  constraints: BoxConstraints(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 0),
                                  labelStyle: TextStyle(
                                    color: ColorSystem.greyDark,
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
                                  errorStyle: TextStyle(
                                      color: ColorSystem.lavender3,
                                      fontWeight: FontWeight.w400),
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
                              ),
                              onStateChanged: (value) {
                                stateController.text = value ?? "";
                                state = value ?? "";
                              },
                              onCityChanged: (value) {
                                cityController.text = value ?? "";
                                city = value ?? "";
                              },
                              countryDropdownLabel: "Country",
                              stateDropdownLabel: "State",
                              cityDropdownLabel: "City",
                              defaultCountry: CscCountry.United_States,
                              dropdownHeadingStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                              dropdownItemStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              dropdownDialogRadius: 10.0,
                              searchBarRadius: 10.0,
                            ),
                          ],
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  setValues(String address1, String address2, String _city, String _state,
      String zip) {
    state = _state;
    city = _city;
    address1Controller.text = address1;
    address2Controller.text = address2;
    zipCodeController.text = zip;
    _selectState.call(_state);
    _selectCity.call(_city);
    setState(() {});
  }
}
