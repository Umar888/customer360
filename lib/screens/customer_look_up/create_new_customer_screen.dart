import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/country_state_city_picker/country_state_city_picker.dart';
import 'package:gc_customer_app/intermediate_widgets/input_field_with_validations.dart';
import 'package:gc_customer_app/intermediate_widgets/recommend_address_dialog.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_page.dart';
import 'package:gc_customer_app/screens/search_places/view/search_places_page.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/formatter.dart';

import '../../common_widgets/state_city_picker/csc_picker.dart';
import '../../common_widgets/state_city_picker/dropdown_with_search.dart';
import '../../primitives/size_system.dart';

class CreateNewCustomerScreen extends StatefulWidget {
  final String emailText;
  final String phoneText;
  final bool isFromSearch;
  CreateNewCustomerScreen(
      {Key? key,
      required this.emailText,
      required this.phoneText,
      this.isFromSearch = false})
      : super(key: key);

  @override
  State<CreateNewCustomerScreen> createState() =>
      _CreateNewCustomerScreenState();
}

class _CreateNewCustomerScreenState extends State<CreateNewCustomerScreen> {
  late CustomerLookUpBloc customerLookUpBloc;
  String email = '';
  final _formKey = GlobalKey<FormState>();
  final StreamController<bool> _isOpenAddressController =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<bool> _isOpenCustomerCredentials =
      StreamController<bool>.broadcast()..add(false);
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  late void Function(String) _selectState;
  late void Function(String) _selectCity;

  final FocusNode phoneFN = FocusNode();
  final FocusNode emailFN = FocusNode();
  final FocusNode firstNameFN = FocusNode();
  final FocusNode lastNameFN = FocusNode();
  final FocusNode addressFN = FocusNode();
  final FocusNode addressFN2 = FocusNode();
  final FocusNode zipCodeFN = FocusNode();

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  String state = '';
  bool showOptions = false;
  String city = '';

  late StreamSubscription<CustomerLookUpState> subscription;
  ScrollController scrollController = ScrollController();
  final StreamController<String> showingTitleSC =
      StreamController<String>.broadcast();
  bool isAddressOpen = false;

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
  void initState() {
    super.initState();
    phoneNumberController.text = widget.phoneText;
    emailController.text = widget.emailText;
    customerLookUpBloc = context.read<CustomerLookUpBloc>();
    phoneNumberController.addListener(() {
      // var phone = phoneNumberController.text;
      // phone = phone.replaceFirst('(', '');
      // phone = phone.replaceFirst(')', '');
      // phone = phone.replaceFirst(' ', '');
      // phone = phone.replaceFirst('-', '');
      // if (phone.length == 10) {
      //   customerLookUpBloc.add(LoadLookUpData(phone, SearchType.phone));
      // }
      // if (phone.isEmpty) customerLookUpBloc.add(ClearData());
    });

    emailFN.addListener(() {
      if (!emailFN.hasFocus) {
        // if (RegExp(
        //         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        //     .hasMatch(email)) {
        //   customerLookUpBloc.add(LoadLookUpData(email, SearchType.email));
        // }
      }
    });

    emailController.addListener(() {
//      if (emailController.text.isEmpty)
//        customerLookUpBloc.add(ClearData());
    });

    subscription = customerLookUpBloc.stream.listen((state) {
      if (state is SaveCustomerSuccess) {
        if ((state.customer.id ?? '').isNotEmpty)
          SharedPreferenceService()
              .setKey(key: agentId, value: state.customer.id!);
        if ((state.customer.accountEmailC ?? '').isNotEmpty)
          SharedPreferenceService()
              .setKey(key: agentEmail, value: state.customer.accountEmailC!);

        Navigator.pop(context, true);
        Navigator.of(context).push(CupertinoPageRoute(
            settings: RouteSettings(name: 'CustomerLandingScreen'),
            builder: (context) => CustomerLandingScreen()));
      } else if (state is SaveCustomerProgress &&
          state.isShowOptions == true &&
          state.isShowDialog == false) {
        setState(() {
          showOptions = true;
        });
        if (state.message!.isNotEmpty) {
          customerLookUpBloc.add(EmptyProgressMessage());
        }
      } else if (state is SaveCustomerProgress && state.isShowDialog == true) {
        if (state.message!.isNotEmpty) {
          customerLookUpBloc.add(EmptyProgressMessage());
        }
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => RecommendAddressDialog(
              enteredAddress: state.enteredAddress!,
              recommendAddress: state.recommendAddress!),
        ).then((value) {
          var selectAddress =
              value == true ? state.recommendAddress : state.enteredAddress;
          customerLookUpBloc.add(SaveCustomer(
              email: emailController.text,
              customerLookUpState: state,
              phone: phoneNumberController.text
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll('-', '')
                  .replaceAll(' ', ''),
              firstName: firstNameController.text,
              proficiencyLevel: state.selectedProficiency,
              playFrequency: state.selectedFrequency,
              playInstruments: state.selectedInstruments.join(",").toString(),
              lastName: lastNameController.text,
              address: selectAddress?.addressline1 ?? '',
              address2: selectAddress?.addressline2 ?? '',
              city: selectAddress?.city ?? '',
              zipCode: selectAddress?.postalcode ?? '',
              state: selectAddress?.state ?? ''));
        });
      } else if (state is SaveCustomerFailure && state.message!.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          setState(() {});
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBar(state.message ?? ""));
          customerLookUpBloc.add(ClearScafolldMessage());
        });
      }
    });

    showingTitleSC.add('Add Customer');
    scrollController.addListener(() {
      late double boundaryValue;
      if (isAddressOpen) {
        boundaryValue = 510;
      } else {
        boundaryValue = 300;
      }
      if (scrollController.offset < boundaryValue) {
        showingTitleSC.add('Add Customer');
      }
      if (scrollController.offset > boundaryValue) {
        showingTitleSC.add('Customer Interest');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    showingTitleSC.close();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFromSearch) return _body();
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<String>(
            stream: showingTitleSC.stream,
            initialData: 'Add Customer',
            builder: (context, snapshot) {
              return Text(snapshot.data ?? '',
                  style: TextStyle(
                      fontFamily: kRubik,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      fontSize: 18));
            }),
        centerTitle: true,
        leading: BackButton(color: ColorSystem.black),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return LayoutBuilder(builder: (context, constraints) {
      return Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: BlocBuilder<CustomerLookUpBloc, CustomerLookUpState>(
              builder: (context, state) {
            if (state is SaveCustomerProgress && state.isShowOptions == true) {
              scrollController.animateTo(isAddressOpen ? 520 : 310,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut);
            }
            return Stack(
              children: [
                ListView(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: constraints.maxWidth / 8)
                          .copyWith(bottom: 100),
                  children: [
                    if (widget.isFromSearch) SizedBox(height: 50),
                    _phoneEmailInput(),
                    _firstNameInput(),
                    _lastNameInput(),
                    _addressInput(),
                    if (state is SaveCustomerProgress)
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
                        child: state.isShowOptions!
                            ? Column(
                                key: ValueKey<bool>(true),
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
                                            childAspectRatio: 3),
                                    children: state.instruments!.map((e) {
                                      return CheckboxListTile(
                                          value: state.selectedInstruments
                                              .contains(e),
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
                                                color: Theme.of(context)
                                                    .primaryColor,
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
                              )
                            : SizedBox.shrink(
                                key: ValueKey<bool>(false),
                              ),
                      ),
                    _saveButton(state),
                  ],
                ),
                // if (state is SaveCustomerProgress)
                //   Container(
                //     color: Colors.transparent,
                //     height: constraints.maxHeight,
                //     width: constraints.maxWidth,
                //     child: Center(
                //       child: CircularProgressIndicator(),
                //     ),
                //   )
                if (widget.isFromSearch)
                  StreamBuilder<String>(
                      stream: showingTitleSC.stream,
                      initialData: 'Add Customer',
                      builder: (context, snapshot) {
                        return Container(
                          width: double.infinity,
                          height: 50,
                          color: Colors.white,
                          // alignment: Alignment.center,
                          child: Text(snapshot.data ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: kRubik,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  fontSize: 18)),
                        );
                      })
              ],
            );
          }),
        ),
      );
    });
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
          textInputType: TextInputType.number,
          inputFormatters: [PhoneInputFormatter(mask: '(###) ###-####')],
          leadingIcon: IconSystem.phone,
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
              color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
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
          textInputType: TextInputType.emailAddress,
          leadingIcon: IconSystem.messageOutline,
          onChanged: (email) => this.email = email,
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
              color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
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
    return GuitarCentreInputField(
      focusNode: firstNameFN,
      textEditingController: firstNameController,
      label: 'First Name',
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
      errorStyle:
          TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Please enter first name';
        }
        return null;
      },
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _lastNameInput() {
    return GuitarCentreInputField(
      focusNode: lastNameFN,
      textEditingController: lastNameController,
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
      errorStyle:
          TextStyle(color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
      label: 'Last Name',
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Please enter last name';
        }
        return null;
      },
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _addressInput() {
    return StreamBuilder<bool>(
      stream: _isOpenAddressController.stream,
      initialData: isAddressOpen,
      builder: (context, snapshot) {
        isAddressOpen = snapshot.data ?? false;
        return AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: isAddressOpen ? 280 : 60,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GuitarCentreInputField(
                  focusNode: addressFN,
                  textEditingController: addressController,
                  onChanged: (value) {
                    addressController.clear();
                    _isOpenAddressController.add(true);
                    isAddressOpen = true;
                    Navigator.of(context)
                        .push(CupertinoPageRoute(
                            builder: (context) => SearchPlacesPage()))
                        .then((value) {
                      if (value != null) {
                        state = value[2];
                        city = value[1];
                        addressController.text = value[0];
                        zipCodeController.text = value[3];
                        _selectState.call(value[2]);
                        _selectCity.call(value[1]);
                      }

                      _formKey.currentState!.validate();
                    });
                  },
                  label: 'Address',
                  hintText: isAddressOpen ? '' : '###',
                  validator: (value) {
                    //   if ((value ?? '').trim().isEmpty) {
                    //     return 'Please enter address';
                    //   }
                    return null;
                  },
                  onTap: () {
                    _isOpenAddressController.add(true);
                    isAddressOpen = true;
                    Navigator.of(context)
                        .push(CupertinoPageRoute(
                            builder: (context) => SearchPlacesPage()))
                        .then((value) {
                      if (value != null) {
                        state = value[2];
                        city = value[1];
                        addressController.text = value[0];
                        zipCodeController.text = value[3];
                        _selectState.call(value[2]);
                        _selectCity.call(value[1]);
                      }
                      _formKey.currentState!.validate();
                    });
                  },
                  onFieldSubmitted: (p0) => addressFN.nextFocus(),
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16),
                isAddressOpen
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GuitarCentreInputField(
                            focusNode: addressFN2,
                            textEditingController: address2Controller,
                            textInputAction: TextInputAction.done,
                            label: 'Address Line 2',
                            hintText: isAddressOpen ? '' : '###',
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
                              textCapitalization: TextCapitalization.characters,
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
    );
  }

  Widget _saveButton(CustomerLookUpState customerLookUpState) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ))),
        onPressed: (customerLookUpState is SaveCustomerProgress &&
                customerLookUpState.isLoading!)
            ? null
            : () {
                if (!_formKey.currentState!.validate()) {
                  return;
                } else {
                  // _isOpenAddressController.add(false);
                  // isAddressOpen = false;
                  if (!showOptions) {
                    customerLookUpBloc.add(VerificationAddressNewCustomer(
                        email: emailController.text,
                        phone: phoneNumberController.text
                            .replaceAll('(', '')
                            .replaceAll(')', '')
                            .replaceAll('-', '')
                            .replaceAll(' ', ''),
                        firstName: firstNameController.text,
                        hasOptions: false,
                        lastName: lastNameController.text,
                        customerLookUpState: customerLookUpState,
                        address: addressController.text,
                        city: city,
                        zipCode: zipCodeController.text,
                        state: state,
                        address2: address2Controller.text));
                  } else {
                    if (addressController.text.isEmpty) {
                      customerLookUpBloc.add(SaveCustomer(
                        email: emailController.text,
                        phone: phoneNumberController.text
                            .replaceAll('(', '')
                            .replaceAll(')', '')
                            .replaceAll('-', '')
                            .replaceAll(' ', ''),
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        customerLookUpState: customerLookUpState,
                        playInstruments:
                            (customerLookUpState is SaveCustomerProgress)
                                ? customerLookUpState.selectedInstruments
                                    .join(",")
                                    .toString()
                                : "",
                        playFrequency: (customerLookUpState
                                is SaveCustomerProgress)
                            ? customerLookUpState.selectedFrequency.toString()
                            : "",
                        proficiencyLevel: (customerLookUpState
                                is SaveCustomerProgress)
                            ? customerLookUpState.selectedProficiency.toString()
                            : "",
                        address: "",
                        city: "",
                        address2: "",
                        zipCode: "",
                        state: "",
                      ));
                    } else {
                      customerLookUpBloc.add(VerificationAddressNewCustomer(
                          email: emailController.text,
                          hasOptions: true,
                          phone: phoneNumberController.text
                              .replaceAll('(', '')
                              .replaceAll(')', '')
                              .replaceAll('-', '')
                              .replaceAll(' ', ''),
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          customerLookUpState: customerLookUpState,
                          address: addressController.text,
                          city: city,
                          zipCode: zipCodeController.text,
                          state: state,
                          address2: address2Controller.text));
                    }
                  }
                }
              },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (customerLookUpState is SaveCustomerProgress &&
                      customerLookUpState.isLoading!)
                  ? CupertinoActivityIndicator(color: Colors.white)
                  : Text(
                      customerLookUpState is SaveCustomerProgress
                          ? 'Save'
                          : 'Next',
                      style: TextStyle(fontSize: 18),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
