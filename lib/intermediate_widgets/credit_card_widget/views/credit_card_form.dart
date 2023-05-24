import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/common_widgets/state_city_picker/csc_picker.dart';
import 'package:gc_customer_app/intermediate_widgets/country_state_city_picker/country_state_city_picker.dart';
import 'package:gc_customer_app/intermediate_widgets/currency_text_input_formatter.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/screens/search_places/view/search_places_page.dart';
import 'package:intl/intl.dart';
import '../../../common_widgets/cart_widgets/custom_switch.dart';
import '../../../primitives/color_system.dart';
import '../../../primitives/constants.dart';
import '../../../primitives/icon_system.dart';
import '../../../primitives/size_system.dart';
import '../../../utils/formatter.dart';
import '../../input_field_with_validations.dart';
import 'flutter_credit_card.dart';

String realNumber = '';

class CreditCardForm extends StatefulWidget {
  CreditCardForm({
    Key? key,
    required this.cardNumber,
    this.expiryDate = '',
    this.cardHolderName = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.sFName = '',
    this.sLName = '',
    required this.onAmountChange,
    required this.shippingFormKey,
    required this.cardAmount,
    required this.cvvCode,
    this.sameAsBilling = true,
    required this.maxAmount,
    this.isShowMaxAmount = false,
    this.heading = '',
    this.address = '',
    this.address2 = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.obscureCvv = false,
    this.obscureNumber = false,
    required this.onCreditCardModelChange,
    this.onChangeSameAsBillingAddress,
    required this.themeColor,
    this.textColor = Colors.black,
    this.cursorColor,
    this.amountDecoration = const InputDecoration(
      labelText: 'Enter Amount',
    ),
    this.cardHolderDecoration = const InputDecoration(
      labelText: 'Card holder',
    ),
    this.cardNumberDecoration = const InputDecoration(
      labelText: 'Card number',
      hintText: 'XXXX XXXX XXXX XXXX',
    ),
    this.expiryDateDecoration = const InputDecoration(
      labelText: 'Expired Date',
      hintText: 'MM/YY',
    ),
    this.cvvCodeDecoration = const InputDecoration(
      labelText: 'CVV',
      hintText: 'XXX',
    ),
    required this.formKey,
    required this.showEmail,
    required this.cartBloc,
    this.cvvValidationMessage = 'Please input a valid CVV',
    this.dateValidationMessage = 'Please input a valid date',
    this.numberValidationMessage = 'Please input a valid number',
    this.isHolderNameVisible = true,
    this.isCardNumberVisible = true,
    this.isExpiryDateVisible = true,
    this.isSameAddressBillingVisible = true,
    this.isAmountVisible = true,
    this.autovalidateMode,
    this.isCVVHaftWidth = false,
    this.additionalWidget = const SizedBox.shrink(),
    this.isCardHolderNameReadOnly = false,
    this.isCardNumberReadOnly = false,
    this.availableBalanceWidget,
    this.isShowCardNumberSuffixIcon = false,
    this.cVVMaxLength = 4,
    this.isShowHeading = true,
    this.isShowAddress2 = true,
    this.shippingAddress,
  }) : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String firstName;
  final String lastName;
  final String cardAmount;
  final String cvvCode;
  final String maxAmount;
  final bool showEmail;
  final CartBloc cartBloc;

  final String heading;
  final String address;
  final String address2;
  final String city;
  final String state;
  final String zipCode;
  final String email;
  String phone;
  final String sFName;
  final String sLName;
  final GlobalKey<FormState> formKey;
  final String cvvValidationMessage;
  final String dateValidationMessage;
  final String numberValidationMessage;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final void Function(String) onAmountChange;
  final void Function(bool)? onChangeSameAsBillingAddress;
  final Color themeColor;
  final Color textColor;
  final Color? cursorColor;
  final bool obscureCvv;
  final bool obscureNumber;
  final bool isHolderNameVisible;
  final bool sameAsBilling;
  final bool isAmountVisible;
  final bool isCardNumberVisible;
  final bool isExpiryDateVisible;
  final bool isSameAddressBillingVisible;
  final GlobalKey<FormState> shippingFormKey;
  final bool isCVVHaftWidth;
  final bool isShowMaxAmount;
  final bool isCardNumberReadOnly;
  final bool isCardHolderNameReadOnly;

  final InputDecoration cardNumberDecoration;
  final InputDecoration amountDecoration;
  final InputDecoration cardHolderDecoration;
  final InputDecoration expiryDateDecoration;
  final InputDecoration cvvCodeDecoration;
  final AutovalidateMode? autovalidateMode;
  final Widget additionalWidget;
  final Widget? availableBalanceWidget;
  final bool isShowCardNumberSuffixIcon;
  final int cVVMaxLength;
  final bool isShowHeading;
  final bool isShowAddress2;
  final AddressList? shippingAddress;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String firstName;
  late String lastName;
  late String cardAmount;
  late String cvvCode;
  late String heading;
  late String address;
  late String address2;
  late String city;
  late String state;
  late String zipCode;

  bool isCvvFocused = false;
  late Color themeColor;

  late void Function(CreditCardModel) onCreditCardModelChange;
  late CreditCardModel creditCardModel;

  late final TextEditingController _cardNumberController =
      TextEditingController();
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '00000000');

  TextEditingController labelController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  FocusNode cvvFocusNode = FocusNode();
  FocusNode expiryDateNode = FocusNode();
  FocusNode cardHolderNode = FocusNode();
  FocusNode firstNameNode = FocusNode();
  FocusNode lastNameNode = FocusNode();
  FocusNode amountNode = FocusNode();
  FocusNode labelNode = FocusNode();
  // FocusNode cityNode = FocusNode();
  // FocusNode stateNode = FocusNode();
  FocusNode addressNode = FocusNode();
  FocusNode address2Node = FocusNode();
  FocusNode zipNode = FocusNode();
  StreamSubscription? cardNumberSubs;
  void Function(String)? _selectState;
  void Function(String)? _selectCity;

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber;
    expiryDate = widget.expiryDate;
    cardHolderName = widget.cardHolderName;
    firstName = widget.firstName;
    lastName = widget.lastName;
    cardAmount = widget.cardAmount;
    cvvCode = widget.cvvCode;
    heading = widget.heading;
    address = widget.address;
    address2 = widget.address2;
    city = widget.city;
    state = widget.state;
    zipCode = widget.zipCode;

    creditCardModel = CreditCardModel(
        cardNumber,
        expiryDate,
        cardHolderName,
        cvvCode,
        cardAmount,
        isCvvFocused,
        address,
        address2,
        heading,
        city,
        state,
        zipCode,
        firstName,
        lastName);
  }

  initializeStateCity() async {
    await Future.delayed(Duration(seconds: 1));
    _selectState?.call(widget.state);
    await Future.delayed(Duration(seconds: 1));
    _selectCity?.call(widget.city);
  }

  @override
  void initState() {
    super.initState();
    realNumber = '';
    createCreditCardModel();

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);
    _cardNumberController.text = cardNumber;
    if (cardNumber.isNotEmpty) {
      // String newVal = '';
      // for (var i = 0; i < cardNumber.length; i++) {
      //   if (i < 14)
      //     newVal += cardNumber[i] == ' ' ? ' ' : '*';
      //   else
      //     newVal += cardNumber[i];
      // }
      _cardNumberController.text = cardNumber;
    }
    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = widget.isShowCardNumberSuffixIcon
            ? _cardNumberController.text.isNotEmpty && realNumber.length < 16
                ? realNumber +
                    '${_cardNumberController.text[_cardNumberController.text.length - 1]}'
                : realNumber
            : cardNumber;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.text = expiryDate;
    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.text = cardHolderName;
    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });
    if (cardHolderName != '') isOpenCardholderNameSC.add(true);

    _firstNameController.text = firstName;
    _firstNameController.addListener(() {
      setState(() {
        firstName = _firstNameController.text;
        creditCardModel.firstName = firstName;
        onCreditCardModelChange(creditCardModel);
      });
    });
    if (widget.phone.length == 10) {
      widget.phone = '(' +
          widget.phone.substring(0, 3) +
          ') ' +
          widget.phone.substring(3, 6) +
          '-' +
          widget.phone.substring(6, 10);
    }
    emailController.text = widget.email;
    phoneNumberController.text = widget.phone;

    _lastNameController.text = lastName;
    _lastNameController.addListener(() {
      setState(() {
        lastName = _lastNameController.text;
        creditCardModel.lastName = lastName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _amountController.text = cardAmount;
    _amountController.addListener(() {
      setState(() {
        cardAmount = _amountController.text;
        creditCardModel.cardAmount = cardAmount;
        onCreditCardModelChange(creditCardModel);
      });
    });

    if (!widget.sameAsBilling) {
      initializeStateCity();
    }

    zipController.text = zipCode;
    zipController.addListener(() {
      setState(() {
        zipCode = zipController.text;
        creditCardModel.zipCode = zipCode;
        onCreditCardModelChange(creditCardModel);
      });
    });

    addressController.text = address;
    addressController.addListener(() {
      setState(() {
        address = addressController.text;
        creditCardModel.address = address;
        onCreditCardModelChange(creditCardModel);
      });
    });

    address2Controller.text = address2;
    address2Controller.addListener(() {
      setState(() {
        address2 = address2Controller.text;
        creditCardModel.address2 = address2;
        onCreditCardModelChange(creditCardModel);
      });
    });

    cityController.text = city;
    cityController.addListener(() {
      setState(() {
        city = cityController.text;
        creditCardModel.city = city;
        onCreditCardModelChange(creditCardModel);
      });
    });

    stateController.text = state;
    stateController.addListener(() {
      setState(() {
        state = stateController.text;
        creditCardModel.state = state;
        onCreditCardModelChange(creditCardModel);
      });
    });

    labelController.addListener(() {
      setState(() {
        heading = labelController.text;
        creditCardModel.heading = heading;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.text = cvvCode;
    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
      });
    });

    cardNumberSubs = isShowCardNumberController.stream.listen((event) {
      var currentText = '';
      if (event) {
        for (var i = 0; i < realNumber.length; i++) {
          if (i > 0 && i % 4 == 0) {
            currentText += ' ';
          }
          currentText += realNumber[i];
        }
      } else {
        for (var i = 0; i < realNumber.length; i++) {
          if (i > 0 && i % 4 == 0) {
            currentText += ' ';
          }
          if (i == realNumber.length - 1) {
            currentText += realNumber[i];
          } else {
            currentText += '*';
          }
        }
      }
      _cardNumberController.text = currentText;
      _cardNumberController.selection = TextSelection(
          baseOffset: currentText.length, extentOffset: currentText.length);
    });

    // Future.delayed(
    //   Duration(milliseconds: 200),
    //   () {
    //     if (state.isNotEmpty) {
    //       SelectState.globalKey.currentState?.onSelectedState(state);
    //     }
    //     if (city.isNotEmpty) {
    //       SelectState.globalKey.currentState?.onSelectedCity(city);
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    firstNameNode.dispose();
    lastNameNode.dispose();
    amountNode.dispose();
    cvvFocusNode.dispose();
    expiryDateNode.dispose();
    labelNode.dispose();
    // cityNode.dispose();
    // stateNode.dispose();
    zipNode.dispose();
    addressNode.dispose();
    address2Node.dispose();
    cardNumberSubs?.cancel();
    isOpenCardholderNameSC.close();
    isShowCardNumberController.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor;
    super.didChangeDependencies();
  }

  final StreamController<bool> isShowCardNumberController =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<bool> isOpenCardholderNameSC =
      StreamController<bool>.broadcast()..add(false);

  @override
  Widget build(BuildContext context) {
    // if (widget.isCardNumberVisible) {
    //   _cardNumberController.text = realNumber;
    // } else {
    //   var currentText = '';
    //   for (var i = 0; i < realNumber.length; i++) {
    //     if (i > 0 && i % 5 == 0) {
    //       currentText += ' ';
    //     }
    //     currentText += realNumber[i];
    //     _cardNumberController.text = currentText;
    //   }
    // }

    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 8),
              margin: EdgeInsets.only(left: 16, right: 16),
              child: StreamBuilder<bool>(
                  stream: isShowCardNumberController.stream,
                  initialData: !widget.isShowCardNumberSuffixIcon,
                  builder: (context, snapshot) {
                    bool isShowCardNumber =
                        snapshot.data ?? !widget.isShowCardNumberSuffixIcon;
                    return TextFormField(
                      controller: _cardNumberController,
                      // obscureText: !widget.isCardNumberVisible,
                      // obscuringCharacter: '*',
                      cursorColor: widget.cursorColor ?? themeColor,
                      onEditingComplete: () {
                        isOpenCardholderNameSC.add(true);
                        FocusScope.of(context).requestFocus(cardHolderNode);
                      },
                      readOnly: widget.isCardNumberReadOnly,
                      enabled: !widget.isCardNumberReadOnly,
                      style: TextStyle(
                          color: widget.isCardNumberReadOnly
                              ? ColorSystem.secondary
                              : widget.textColor),
                      decoration: widget.cardNumberDecoration.copyWith(
                        suffixIcon: widget.isShowCardNumberSuffixIcon
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // IconButton(
                                  //   onPressed: () async {
                                  //     final CardDetails? cardDetails =
                                  //         await CardScanner.scanCard(
                                  //             scanOptions: CardScanOptions(
                                  //                 enableLuhnCheck: true,
                                  //                 scanExpiryDate: true,
                                  //                 scanCardHolderName: true,
                                  //                 validCardsToScanBeforeFinishingScan:
                                  //                     6,
                                  //                 initialScansToDrop: 1));
                                  //
                                  //     var cn = cardDetails?.cardNumber ?? '';
                                  //     cn = cn.replaceAll(' ', '');
                                  //     var newCN = '';
                                  //     for (var i = 0; i < cn.length; i++) {
                                  //       newCN += cn[i];
                                  //       if (i > 0 && (i + 1) % 4 == 0) {
                                  //         newCN += ' ';
                                  //       }
                                  //     }
                                  //     setState(() {
                                  //       realNumber = cn;
                                  //       _cardNumberController.text =
                                  //           newCN.trim();
                                  //       _lastNameController.text = cardDetails
                                  //               ?.cardHolderName
                                  //               .split(' ')
                                  //               .last ??
                                  //           '';
                                  //       _firstNameController.text = cardDetails
                                  //               ?.cardHolderName
                                  //               .replaceAll(
                                  //                   _lastNameController.text,
                                  //                   '')
                                  //               .trim() ??
                                  //           '';
                                  //       isOpenCardholderNameSC.add(true);
                                  //       _expiryDateController.text =
                                  //           cardDetails?.expiryDate ?? '';
                                  //     });
                                  //   },
                                  //   icon: Icon(Icons.qr_code_scanner_outlined,
                                  //       color: ColorSystem.secondary),
                                  // ),
                                  IconButton(
                                    onPressed: () {
                                      isShowCardNumberController
                                          .add(!isShowCardNumber);
                                    },
                                    icon: Icon(
                                        isShowCardNumber
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: ColorSystem.secondary),
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(19),
                        // FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.allow(RegExp("[0-9*]")),
                        CardNumberFormatter(isShowCardNumber)
                      ],
                      // autofillHints: <String>[AutofillHints.creditCardNumber],
                      // autovalidateMode: widget.autovalidateMode,
                      validator: (String? value) {
                        // Validate less that 16 digits +3 white spaces
                        if (value!.isEmpty || value.length < 19) {
                          return widget.numberValidationMessage;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        var newString = value.replaceAll(' ', '');
                        if (newString.length - realNumber.length > 4) {
                          realNumber = newString;
                        } else {
                          if (newString.trim().length > realNumber.length) {
                            realNumber +=
                                newString.trim()[newString.length - 1];
                          } else if (newString.trim().length <=
                              realNumber.length) {
                            realNumber =
                                realNumber.substring(0, realNumber.length - 1);
                          }
                        }
                      },
                    );
                  }),
            ),
            Visibility(
              visible: widget.isHolderNameVisible,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                margin: EdgeInsets.only(left: 16, top: 8, right: 16),
                child: StreamBuilder<bool>(
                    stream: isOpenCardholderNameSC.stream,
                    initialData: cardHolderName.isNotEmpty,
                    builder: (context, snapshot) {
                      var isOpenCardholderName = snapshot.data ?? false;
                      return Column(
                        children: [
                          TextFormField(
                            controller: isOpenCardholderName == true
                                ? _firstNameController
                                : _cardHolderNameController,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: widget.cursorColor ?? themeColor,
                            focusNode: cardHolderNode,
                            readOnly: widget.isCardNumberReadOnly,
                            enabled: !widget.isCardNumberReadOnly,
                            onTap: () {
                              isOpenCardholderNameSC.add(true);
                              // FocusScope.of(context).requestFocus(firstNameNode);
                            },
                            style: TextStyle(
                                color: widget.isCardNumberReadOnly
                                    ? ColorSystem.secondary
                                    : widget.textColor),
                            decoration: widget.cardHolderDecoration.copyWith(
                                labelText:
                                    isOpenCardholderName ? 'First Name' : null),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autofillHints: <String>[
                              AutofillHints.creditCardName
                            ],
                            validator: (String? value) {
                              // Validate less that 13 digits +3 white spaces
                              if (value!.isEmpty || value.length < 2) {
                                return "Please input ${isOpenCardholderName == true ? 'first' : 'cardholder'} name";
                              }
                              return null;
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(lastNameNode);
                            },
                          ),
                          if (isOpenCardholderName == true)
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: TextFormField(
                                controller: _lastNameController,
                                textCapitalization: TextCapitalization.words,
                                cursorColor: widget.cursorColor ?? themeColor,
                                focusNode: lastNameNode,
                                readOnly: widget.isCardNumberReadOnly,
                                enabled: !widget.isCardNumberReadOnly,
                                style: TextStyle(
                                    color: widget.isCardNumberReadOnly
                                        ? ColorSystem.secondary
                                        : widget.textColor),
                                decoration: widget.cardHolderDecoration
                                    .copyWith(labelText: 'Last Name'),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                autofillHints: <String>[
                                  AutofillHints.creditCardName
                                ],
                                validator: (String? value) {
                                  // Validate less that 13 digits +3 white spaces
                                  if (value!.isEmpty || value.length < 2) {
                                    return "Please input last name";
                                  }
                                  return null;
                                },
                                onEditingComplete: () {
                                  FocusScope.of(context)
                                      .requestFocus(expiryDateNode);
                                },
                              ),
                            ),
                        ],
                      );
                      // return Column(
                      //   children: [
                      //     TextFormField(
                      //       controller: _firstNameController,
                      //       textCapitalization: TextCapitalization.words,
                      //       cursorColor: widget.cursorColor ?? themeColor,
                      //       focusNode: firstNameNode,
                      //       autofocus: true,
                      //       readOnly: widget.isCardNumberReadOnly,
                      //       enabled: !widget.isCardNumberReadOnly,
                      //       style: TextStyle(
                      //           color: widget.isCardNumberReadOnly
                      //               ? ColorSystem.secondary
                      //               : widget.textColor),
                      //       decoration: widget.cardHolderDecoration
                      //           .copyWith(labelText: 'First Name'),
                      //       keyboardType: TextInputType.text,
                      //       textInputAction: TextInputAction.next,
                      //       autofillHints: <String>[
                      //         AutofillHints.creditCardName
                      //       ],
                      //       validator: (String? value) {
                      //         // Validate less that 13 digits +3 white spaces
                      //         if (value!.isEmpty || value.length < 2) {
                      //           return "Please input first name";
                      //         }
                      //         return null;
                      //       },
                      //       onEditingComplete: () {
                      //         FocusScope.of(context)
                      //             .requestFocus(expiryDateNode);
                      //       },
                      //     ),
                      //     SizedBox(height: 16),
                      //     TextFormField(
                      //       controller: _lastNameController,
                      //       textCapitalization: TextCapitalization.words,
                      //       cursorColor: widget.cursorColor ?? themeColor,
                      //       focusNode: lastNameNode,
                      //       readOnly: widget.isCardNumberReadOnly,
                      //       enabled: !widget.isCardNumberReadOnly,
                      //       style: TextStyle(
                      //           color: widget.isCardNumberReadOnly
                      //               ? ColorSystem.secondary
                      //               : widget.textColor),
                      //       decoration: widget.cardHolderDecoration
                      //           .copyWith(labelText: 'Last Name'),
                      //       keyboardType: TextInputType.text,
                      //       textInputAction: TextInputAction.next,
                      //       autofillHints: <String>[
                      //         AutofillHints.creditCardName
                      //       ],
                      //       validator: (String? value) {
                      //         // Validate less that 13 digits +3 white spaces
                      //         if (value!.isEmpty || value.length < 2) {
                      //           return "Please input last name";
                      //         }
                      //         return null;
                      //       },
                      //       onEditingComplete: () {
                      //         FocusScope.of(context)
                      //             .requestFocus(expiryDateNode);
                      //       },
                      //     ),
                      //   ],
                      // );
                    }),
              ),
            ),
            Row(
              children: <Widget>[
                Visibility(
                  visible: widget.isExpiryDateVisible,
                  child: Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      margin: EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: TextFormField(
                        controller: _expiryDateController,
                        cursorColor: widget.cursorColor ?? themeColor,
                        focusNode: expiryDateNode,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(cvvFocusNode);
                        },
                        style: TextStyle(
                          color: widget.textColor,
                        ),
                        decoration: widget.expiryDateDecoration,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autofillHints: <String>[
                          AutofillHints.creditCardExpirationDate
                        ],
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return widget.dateValidationMessage;
                          }
                          final DateTime now = DateTime.now();
                          final List<String> date = value.split(RegExp(r'/'));
                          final int month = int.parse(date.first);
                          final int year = int.parse('20${date.last}');
                          final DateTime cardDate = DateTime(year, month);

                          if (cardDate.isBefore(now) ||
                              month > 12 ||
                              month == 0) {
                            return widget.dateValidationMessage;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    margin: EdgeInsets.only(left: 16, top: 8, right: 16),
                    child: TextFormField(
                      obscureText: widget.obscureCvv,
                      focusNode: cvvFocusNode,
                      controller: _cvvCodeController,
                      cursorColor: widget.cursorColor ?? themeColor,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(amountNode);
                      },
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                      maxLength: widget.cVVMaxLength,
                      decoration: widget.cvvCodeDecoration,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      autofillHints: <String>[
                        AutofillHints.creditCardSecurityCode
                      ],
                      onChanged: (String text) {
                        setState(() {
                          cvvCode = text;
                        });
                      },
                      validator: (String? value) {
                        if (value!.isEmpty || value.length < 3) {
                          return widget.cvvValidationMessage;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                if (widget.availableBalanceWidget != null)
                  widget.availableBalanceWidget!
              ],
            ),
            Visibility(
              visible: widget.isAmountVisible,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                margin: EdgeInsets.only(left: 16, top: 8, right: 16),
                child: TextFormField(
                  controller: _amountController,
                  cursorColor: widget.cursorColor ?? themeColor,
                  focusNode: amountNode,
                  maxLength: 18,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.textColor,
                  ),
                  decoration: widget.amountDecoration,
                  onChanged: widget.onAmountChange,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyTextInputFormatter(
                        name: '', symbol: '', decimalDigits: 2),
                    FilteringTextInputFormatter.allow(RegExp("[0-9.,\$]")),
                  ],
                  validator: (String? value) {
                    // Validate less that 13 digits +3 white spaces
                    if ((value ?? '').isEmpty ||
                        double.parse((value ?? '').replaceAll(',', '')) <
                            0.01) {
                      return "Please input amount";
                    } else if (widget.maxAmount.isNotEmpty &&
                        double.parse(value?.replaceAll(',', '') ?? '0.0') >
                            double.parse(widget.maxAmount)) {
                      return "You cannot add more than ${widget.maxAmount}";
                    }
                    return null;
                  },
                  textInputAction: widget.sameAsBilling
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onEditingComplete: () {
                    if (widget.sameAsBilling) {
                      FocusScope.of(context).unfocus();
                      onCreditCardModelChange(creditCardModel);
                    } else {
                      FocusScope.of(context).requestFocus(labelNode);
                    }
                  },
                ),
              ),
            ),
            widget.additionalWidget,
            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: 20,horizontal: 13),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Text(
            //             "Save Card Details",
            //             style: TextStyle(
            //                 fontSize: SizeSystem.size19,
            //                 fontWeight: FontWeight.w500,
            //                 color: ColorSystem.greyDark,
            //                 fontFamily: kRubik)
            //         ),
            //       ),

            //       CustomSwitch(
            //         value: true,
            //         onChanged: (v) => setState((){}),
            //         activeText: Container(width: 20,),
            //         inactiveText: Container(width: 20,),
            //         activeColor: Theme.of(context).primaryColor,
            //         inactiveColor: ColorSystem.greyDark,
            //       ),
            //     ],
            //   ),
            // ),
            if (widget.isSameAddressBillingVisible)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Same Address for Billing",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: ColorSystem.greyDark,
                                  fontFamily: kRubik)),
                          if (widget.sameAsBilling &&
                              widget.shippingAddress != null &&
                              widget.shippingAddress?.address1 != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text('${widget.shippingAddress!.address1},',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: ColorSystem.primary,
                                        fontFamily: kRubik)),
                                Text(
                                    '${(widget.shippingAddress!.address2 ?? '').isEmpty ? '' : '${widget.shippingAddress!.address2}, '}${widget.shippingAddress!.city}, ${widget.shippingAddress!.state}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: ColorSystem.primary,
                                        fontFamily: kRubik)),
                                Text(widget.shippingAddress!.postalCode ?? '',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: ColorSystem.primary,
                                        fontFamily: kRubik)),
                              ],
                            )
                        ],
                      ),
                    ),
                    CustomSwitch(
                      value: widget.sameAsBilling,
                      onChanged: (val) {
                        if (widget.onChangeSameAsBillingAddress != null) {
                          widget.onChangeSameAsBillingAddress!(val);
                        }
                        if (_selectState == null && widget.sameAsBilling) {
                          initializeStateCity();
                        }
                      },
                      activeText: Container(width: 20),
                      inactiveText: Container(width: 20),
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: ColorSystem.greyDark,
                    ),
                  ],
                ),
              ),
            widget.showEmail ? _phoneEmailInput() : SizedBox.shrink(),
            SizedBox(height: 5),
            if (!widget.sameAsBilling)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isShowHeading)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: TextFormField(
                        autofocus: false,
                        cursorColor: Theme.of(context).primaryColor,
                        controller: labelController,
                        focusNode: labelNode,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (String? value) {
                          if (!widget.sameAsBilling &&
                              (value!.isEmpty || value.length < 3)) {
                            return "Please input label of your address";
                          }
                          return null;
                        },
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(addressNode);
                        },
                        decoration: InputDecoration(
                          labelText: 'Label',
                          constraints: BoxConstraints(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          labelStyle: TextStyle(
                            color: ColorSystem.greyDark,
                            fontSize: 17,
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
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    margin: EdgeInsets.only(left: 16, top: 8, right: 16),
                    child: TextFormField(
                      autofocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: Theme.of(context).primaryColor,
                      controller: addressController,
                      keyboardType: TextInputType.text,
                      focusNode: addressNode,
                      onTap: () {
                        Navigator.of(context)
                            .push(CupertinoPageRoute(
                                builder: (context) => SearchPlacesPage()))
                            .then((value) {
                          if (value != null) {
                            state = value[2];
                            city = value[1];
                            addressController.text = value[0];
                            zipController.text = value[3];
                            CSCPicker.globalKey.currentState!
                                .onSelectedState(value[2]);
                            CSCPicker.globalKey.currentState!
                                .onSelectedCity(value[1]);
                          }
                        });
                      },
                      validator: (String? value) {
                        if (!widget.sameAsBilling &&
                            (value!.isEmpty || value.length < 3)) {
                          return "Please input your street address";
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(zipNode);
                      },
                      decoration: InputDecoration(
                        labelText: 'Billing Address',
                        constraints: BoxConstraints(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        labelStyle: TextStyle(
                          color: ColorSystem.greyDark,
                          fontSize: 17,
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
                    ),
                  ),
                  if (widget.isShowAddress2)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      margin: EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: TextFormField(
                        autofocus: false,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Theme.of(context).primaryColor,
                        controller: address2Controller,
                        keyboardType: TextInputType.text,
                        focusNode: address2Node,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(zipNode);
                        },
                        decoration: InputDecoration(
                          labelText: 'Billing Address 2',
                          constraints: BoxConstraints(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          labelStyle: TextStyle(
                            color: ColorSystem.greyDark,
                            fontSize: 17,
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
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    margin: EdgeInsets.only(
                        left: 16, top: 8, right: 16, bottom: 14),
                    child: CSCPicker(
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
                        if (value!.isEmpty ||
                            value == "Choose State/Province") {
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
                          alignLabelWithHint: false,
                          hintStyle: TextStyle(
                            color: ColorSystem.greyDark,
                            fontSize: SizeSystem.size18,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          constraints: BoxConstraints(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 9, horizontal: 0),
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
                        state = value ?? "";
                        creditCardModel.state = state;
                        // FocusScope.of(context).requestFocus(cityNode);

                        FocusScope.of(context).unfocus();
                        onCreditCardModelChange(creditCardModel);
                      },
                      onCityChanged: (value) {
                        cityController.text = value ?? "";
                        city = value ?? "";
                        creditCardModel.city = city;

                        // FocusScope.of(context).unfocus();
                        onCreditCardModelChange(creditCardModel);
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
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final FocusNode phoneFN = FocusNode();
  final FocusNode emailFN = FocusNode();

  Widget _phoneEmailInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GuitarCentreInputField(
          focusNode: phoneFN,
          textEditingController: phoneNumberController,
          label: 'Billing Phone',
          hintText: '(123) 456-7890',
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            widget.cartBloc.add(SetShippingCredential(
                shippingFormKey: widget.shippingFormKey,
                shippingFName: widget.sFName,
                shippingLName: widget.sLName,
                shippingPhone: value
                    .replaceAll('(', '')
                    .replaceAll(')', '')
                    .replaceAll('-', '')
                    .replaceAll(' ', ''),
                shippingEmail: emailController.text));
          },
          leadingIconColor: Colors.black87,
          errorStyle: TextStyle(
              color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.complimentary,
              width: 1,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.complimentary,
              width: 1,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.black,
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

              return 'Please enter phone number';
            }
          },
        ),
        GuitarCentreInputField(
          focusNode: emailFN,
          textEditingController: emailController,
          label: 'Billing Email',
          hintText: 'abc@xyz.com',
          leadingIconColor: Colors.black87,
          errorStyle: TextStyle(
              color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.complimentary,
              width: 1,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.complimentary,
              width: 1,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ColorSystem.black,
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
            widget.cartBloc.add(SetShippingCredential(
                shippingFormKey: widget.shippingFormKey,
                shippingFName: widget.sFName,
                shippingLName: widget.sLName,
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
              return "Please enter your valid email";
            }
          },
        )
      ],
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  final bool isVisible;
  CardNumberFormatter(this.isVisible);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    var inputText = nextValue.text;
    if (inputText.length - realNumber.length > 4) {
      realNumber = inputText;
    }
    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = new StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      if (i < inputText.length - 1 &&
          inputText[i] != ' ' &&
          !isVisible &&
          i < 12) {
        bufferString.write('*');
      } else
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
