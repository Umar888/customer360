import 'dart:async';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/address_bloc/address_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/country_state_city_picker/country_state_city_picker.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/search_places/view/search_places_page.dart';

import '../../../common_widgets/state_city_picker/csc_picker.dart';
import '../../../primitives/size_system.dart';

class AddAddressBottomSheet extends StatefulWidget {
  final AddressList? addressModel;
  AddAddressBottomSheet({Key? key, this.addressModel}) : super(key: key);

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  var _saveAsDefaultVal = true;
  final StreamController<bool> _saveAsDefaultController =
      StreamController<bool>.broadcast()..add(true);
  var address2TEC = TextEditingController();
  var addressTEC = TextEditingController();
  var addressLabelTEC = TextEditingController();
  var zipCodeTEC = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  late void Function(String) _selectState;
  late void Function(String) _selectCity;
  final FocusNode zipCodeFN = FocusNode();

  var city = '';
  var state = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.addressModel != null) {
      addressLabelTEC.text = widget.addressModel!.addressLabel!;
      address2TEC.text = widget.addressModel!.address2!;
      addressTEC.text = widget.addressModel!.address1!;
      zipCodeTEC.text = widget.addressModel!.postalCode!;
      city = widget.addressModel!.city!;
      state = widget.addressModel!.state!;
      initializeStateCity();
      _saveAsDefaultVal = widget.addressModel!.isPrimary!;
      _saveAsDefaultController.add(_saveAsDefaultVal);
      if (!kIsWeb)
        FirebaseAnalytics.instance
            .setCurrentScreen(screenName: 'EditNewAddressProfileScreen');
    } else if (!kIsWeb) {
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'AddNewAddressProfileScreen');
    }

    super.initState();
  }

  initializeStateCity() async {
    await Future.delayed(Duration(seconds: 1));
    _selectState.call(widget.addressModel!.state!);
    await Future.delayed(Duration(seconds: 1));
    _selectCity.call(widget.addressModel!.city!);
  }

  @override
  Widget build(BuildContext context) {
    double bottomSheetHeight = MediaQuery.of(context).size.height / 1.9;
    var underLineBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: ColorSystem.greyDark,
        width: 1,
      ),
    );
    var errorUnderLineBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    );
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: LayoutBuilder(
        builder: (context, constraint) {
          double addAddressWidth = constraint.maxWidth * 0.7;
          return Form(
            key: _formKey,
            child: Container(
              height: constraint.maxHeight,
              width: constraint.maxWidth,
              color: ColorSystem.white,
              child: Stack(
                children: [
                  Container(
                    height: constraint.maxHeight - bottomSheetHeight,
                    width: constraint.maxWidth,
                    alignment: Alignment.center,
                    child: Material(
                      clipBehavior: Clip.hardEdge,
                      elevation: 5,
                      type: MaterialType.card,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      shadowColor: ColorSystem.greyDark,
                      child: DottedBorder(
                        color: Colors.black,
                        strokeWidth: 3,
                        radius: Radius.circular(15),
                        borderType: BorderType.RRect,
                        child: Container(
                          height: 150,
                          width: addAddressWidth,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 30.0, horizontal: 40),
                            child: Center(
                              child: Text(
                                " ${widget.addressModel != null ? 'Edit' : '+ Add'} Address",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: bottomSheetHeight,
                      child: Container(
                          decoration: BoxDecoration(
                              color: ColorSystem.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorSystem.greyDark,
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                ),
                              ]),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // TextFormField(
                                    //   controller: addressLabelTEC,
                                    //   autofocus: false,
                                    //   cursorColor: Theme.of(context).primaryColor,
                                    //   keyboardType: TextInputType.text,
                                    //   validator: (value) {
                                    //     if ((value ?? '').isEmpty) {
                                    //       return 'Please enter address label';
                                    //     }
                                    //     return null;
                                    //   },
                                    //   decoration: InputDecoration(
                                    //     labelText: 'Address Label',
                                    //     constraints:
                                    //         BoxConstraints(maxHeight: 45),
                                    //     contentPadding: EdgeInsets.zero,
                                    //     labelStyle: TextStyle(
                                    //       color: ColorSystem.greyDark,
                                    //       fontSize: 16,
                                    //     ),
                                    //     focusedBorder: underLineBorder,
                                    //     border: underLineBorder,
                                    //     enabledBorder: underLineBorder,
                                    //     errorBorder: errorUnderLineBorder,
                                    //     focusedErrorBorder:
                                    //         errorUnderLineBorder,
                                    //   ),
                                    // ),
                                    // SizedBox(height: 10),
                                    TextFormField(
                                      controller: addressTEC,
                                      autofocus: false,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if ((value ?? '').isEmpty) {
                                          return 'Please enter address';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        addressTEC.clear();
                                        Navigator.of(context)
                                            .push(CupertinoPageRoute(
                                                builder: (context) =>
                                                    SearchPlacesPage()))
                                            .then((value) {
                                          if (value != null) {
                                            state = value[2];
                                            city = value[1];
                                            addressTEC.text = value[0];
                                            zipCodeTEC.text = value[3];
                                            _selectState.call(value[2]);
                                            _selectCity.call(value[1]);
                                          }
                                          _formKey.currentState!.validate();
                                        });
                                      },
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(CupertinoPageRoute(
                                                builder: (context) =>
                                                    SearchPlacesPage()))
                                            .then((value) {
                                          if (value != null) {
                                            state = value[2];
                                            city = value[1];
                                            addressTEC.text = value[0];
                                            zipCodeTEC.text = value[3];
                                            _selectState.call(value[2]);
                                            _selectCity.call(value[1]);
                                          }
                                          _formKey.currentState!.validate();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Address 1',
                                        constraints:
                                            BoxConstraints(maxHeight: 45),
                                        contentPadding: EdgeInsets.zero,
                                        labelStyle: TextStyle(
                                          color: ColorSystem.greyDark,
                                          fontSize: 16,
                                        ),
                                        focusedBorder: underLineBorder,
                                        border: underLineBorder,
                                        enabledBorder: underLineBorder,
                                        errorBorder: errorUnderLineBorder,
                                        focusedErrorBorder:
                                            errorUnderLineBorder,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      autofocus: false,
                                      controller: address2TEC,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        labelText: 'Address 2',
                                        constraints:
                                            BoxConstraints(maxHeight: 45),
                                        contentPadding: EdgeInsets.zero,
                                        labelStyle: TextStyle(
                                          color: ColorSystem.greyDark,
                                          fontSize: 16,
                                        ),
                                        focusedBorder: underLineBorder,
                                        border: underLineBorder,
                                        enabledBorder: underLineBorder,
                                        errorBorder: errorUnderLineBorder,
                                        focusedErrorBorder:
                                            errorUnderLineBorder,
                                      ),
                                    ),
                                    SizedBox(height: 10),
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
                                      stateTextEditingController:
                                          stateController,
                                      stateValidator: (String? value) {
                                        if (value!.isEmpty ||
                                            value == "Choose State/Province") {
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
                                      flagState:
                                          CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                                      countrySearchPlaceholder: "Country",
                                      stateSearchPlaceholder: "State",
                                      citySearchPlaceholder: "City",
                                      zipCode: TextFormField(
                                        autofocus: false,
                                        cursorColor:
                                            Theme.of(context).primaryColor,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        controller: zipCodeTEC,
                                        onEditingComplete: () {
                                          FocusScope.of(context).unfocus();
                                        },
                                        keyboardType: TextInputType.text,
                                        focusNode: zipCodeFN,
                                        validator: (String? value) {
                                          if (value!.isEmpty ||
                                              value.length < 2) {
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
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          constraints: BoxConstraints(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 0),
                                          labelStyle: TextStyle(
                                            color: ColorSystem.greyDark,
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
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: ColorSystem.lavender3,
                                              width: 1,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: ColorSystem.lavender3,
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
/*
                                    SelectState(
                                      stateValidator: (value) {
                                        if ((value ?? '').isEmpty ||
                                            value == 'Choose State/Province') {
                                          return 'Please select state';
                                        }
                                        return null;
                                      },
                                      cityValidator: (value) {
                                        if ((value ?? '').isEmpty ||
                                            value == 'Choose City') {
                                          return 'Please select city';
                                        }
                                        return null;
                                      },
                                      cityNode: FocusNode(),
                                      stateNode: FocusNode(),
                                      zipCode: TextFormField(
                                        controller: zipCodeTEC,
                                        autofocus: false,
                                        cursorColor: Theme.of(context).primaryColor,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if ((value ?? '').isEmpty) {
                                            return 'Please enter ZIP Code';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'ZIP Code',
                                          constraints: BoxConstraints(
                                              maxHeight: 45),
                                          contentPadding: EdgeInsets.zero,
                                          labelStyle: TextStyle(
                                            color: ColorSystem.greyDark,
                                            fontSize: 16,
                                          ),
                                          focusedBorder: underLineBorder,
                                          border: underLineBorder,
                                          enabledBorder: underLineBorder,
                                          errorBorder: errorUnderLineBorder,
                                          focusedErrorBorder:
                                              errorUnderLineBorder,
                                        ),
                                      ),
                                      onStateChanged: (value) {
                                        state = value;
                                      },
                                      onCityChanged: (value) {
                                        city = value;
                                      },
                                      initCity: city.isEmpty
                                          ? widget.addressModel?.city
                                          : city,
                                      initState: state.isEmpty
                                          ? widget.addressModel?.state
                                          : state,
                                    ),
*/
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text("Save as Default Address",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: ColorSystem.greyDark)),
                                        ),
                                        StreamBuilder<bool>(
                                            stream:
                                                _saveAsDefaultController.stream,
                                            initialData: _saveAsDefaultVal,
                                            builder: (context, snapshot) {
                                              return CupertinoSwitch(
                                                value: snapshot.data!,
                                                onChanged: (v) {
                                                  _saveAsDefaultVal = v;
                                                  _saveAsDefaultController
                                                      .add(_saveAsDefaultVal);
                                                },
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                trackColor:
                                                    ColorSystem.greyDark,
                                              );
                                            }),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    ColorSystem
                                                        .primaryTextColor),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ))),
                                        onPressed: () {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }
                                          context.read<AddressBloc>().add(
                                              VerificationAddressProfile(
                                                  addressModel: AddressList(
                                                      address1: addressTEC.text,
                                                      addressLabel:
                                                          addressLabelTEC.text,
                                                      address2:
                                                          address2TEC.text,
                                                      city: city,
                                                      state: state,
                                                      postalCode:
                                                          zipCodeTEC.text,
                                                      contactPointAddressId: widget
                                                          .addressModel
                                                          ?.contactPointAddressId,
                                                      isPrimary: widget
                                                          .addressModel
                                                          ?.isPrimary),
                                                  isDefault:
                                                      _saveAsDefaultVal));
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Save',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                  Positioned(top: 40, left: 10, child: BackButton())
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget title() => Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Row(
          children: [
            Text(
              'Enter Your Credit Card Details',
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget closeButton(BoxConstraints constraint) => Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: (() => Navigator.pop(context)),
          child: Container(
            alignment: Alignment.topCenter,
            height: constraint.maxHeight - 400,
            width: constraint.maxWidth,
            child: Center(
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorSystem.white,
                ),
                child: Icon(
                  Icons.close,
                  color: ColorSystem.black,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      );

  void animatedHide() {
    // if (isExpanded) {
    //   controller.animateTo(
    //     minExtent,
    //     duration: Duration(milliseconds: 100),
    //     curve: Curves.easeOutBack,
    //   );
    //   setState(() {
    //     initialExtent = isExpanded ? minExtent : maxExtent;
    //     isExpanded = !isExpanded;
    //   });
    //   DraggableScrollableActuator.reset(draggableSheetContext);
    // }
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = new StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write(' ');
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: new TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';

    for (int i = 0; i < newValueString.length; i++) {
      if (newValueString[i] != '/') valueToReturn += newValueString[i];
      var nonZeroIndex = i + 1;
      final contains = valueToReturn.contains(RegExp(r'\/'));
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != newValueString.length &&
          !(contains)) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}
