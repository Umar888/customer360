import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/order_cards_bloc/order_cards_bloc.dart';
import 'package:gc_customer_app/common_widgets/cart_widgets/custom_switch.dart';
import 'package:gc_customer_app/data/reporsitories/profile/addresses_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/views/flutter_credit_card.dart';
import 'package:gc_customer_app/intermediate_widgets/currency_text_input_formatter.dart';
import 'package:gc_customer_app/intermediate_widgets/recommend_address_dialog.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/address_models/delivery_model.dart';
import 'package:gc_customer_app/models/address_models/verification_address_model.dart';
import 'package:gc_customer_app/models/cart_model/financial_type_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/cart/views/order_payment/disclosure_dialog.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:intl/intl.dart';


class AddPaymentMethodWidget extends StatefulWidget {
  final CartState cartState;
  final PaymentMethodType type;
  final CreditCardModelSave? cardEdit;
  final double defaultInputAmount;
  final String orderId;
  final bool isSelectedExistingCard;
  final int? cardIndex;
  AddPaymentMethodWidget({
    Key? key,
    required this.cartState,
    required this.type,
    this.cardEdit,
    this.defaultInputAmount = 0,
    required this.orderId,
    this.isSelectedExistingCard = false,
    this.cardIndex,
  }) : super(key: key);

  @override
  State<AddPaymentMethodWidget> createState() => _AddPaymentMethodWidgetState();
}

class _AddPaymentMethodWidgetState extends State<AddPaymentMethodWidget> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late CartBloc cartBloc;
  late OrderCardsBloc cardsBloc;
  final StreamController<bool> isShowCardNumberController =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<bool> isSameAsBillingController =
      StreamController<bool>.broadcast()..add(true);
  bool isSameAsBillingVal = true;
  final StreamController<bool> isShowFinancingErrorController =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<bool> isAddingCardController =
      StreamController<bool>.broadcast()..add(false);
  var _forcusedBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: ColorSystem.primary,
      width: 1,
    ),
  );
  var _border = UnderlineInputBorder(
    borderSide: BorderSide(
      color: ColorSystem.greyDark,
      width: 1,
    ),
  );
  var _labelStyle = TextStyle(
    color: ColorSystem.greyDark,
    fontSize: 16,
  );
  String cardNumber = '';
  String cardHolderName = '';
  String firstName = '';
  String lastName = '';
  String expiryMonth = '';
  String expiryYear = '';
  String cVV = '';
  String amount = '';
  String maxAmount = '0';
  String state = '';
  String city = '';
  String zipCode = '';
  String address = '';
  String address2 = '';
  String heading = '';
  String title = '';
  bool isUseFullBalance = true;
  FinancialTypeModel? financialTypeModel;
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _securityController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  late StreamSubscription listener;

  void _addEditCardInformation() {
    if (!cardNumber.contains(' ')) {
      for (var i = 0; i < widget.cardEdit!.cardNumber.length; i++) {
        if (i > 0 && i % 4 == 0) {
          cardNumber += ' ';
        }
        cardNumber += widget.cardEdit!.cardNumber[i];
        _cardNumberController.text = cardNumber;
      }
    } else {
      cardNumber = widget.cardEdit!.cardNumber;
    }

    cardHolderName = widget.cardEdit!.cardHolderName;
    firstName = widget.cardEdit!.paymentMethod?.firstName ?? '';
    lastName = widget.cardEdit!.paymentMethod?.lastName ?? '';
    expiryMonth = widget.cardEdit!.expiryMonth;
    expiryYear = widget.cardEdit!.expiryYear;
    cVV = widget.cardEdit!.cvvCode;
    amount = widget.cardEdit!.availableAmount?.replaceAll('\$', '') ?? '';
    _amountController.text =
        widget.cardEdit!.availableAmount?.replaceAll('\$', '') ?? '';
    financialTypeModel = widget.cardEdit!.financialTypeModel;
    state = widget.cardEdit!.paymentMethod?.state ?? '';
    city = widget.cardEdit!.paymentMethod?.city ?? '';
    zipCode = widget.cardEdit!.paymentMethod?.zipCode ?? '';
    address = widget.cardEdit!.paymentMethod?.address ?? '';
    address2 = widget.cardEdit!.paymentMethod?.address2 ?? '';
    heading = widget.cardEdit!.paymentMethod?.heading ?? '';
    isSameAsBillingVal = widget.cardEdit!.isSameAsShippingAddress;
    isSameAsBillingController.add(widget.cardEdit!.isSameAsShippingAddress);
    if (widget.cardEdit!.cardType == PaymentMethodType.gcGift) {
      cardsBloc.add(GetGiftCardBalance(cardNumber, cVV));
    }
  }

  @override
  void initState() {
    cartBloc = context.read<CartBloc>();
    cardsBloc = context.read<OrderCardsBloc>();

    if (widget.defaultInputAmount != 0) {
      amount = widget.defaultInputAmount.toStringAsFixed(2);
      if (widget.type == PaymentMethodType.cOA) {
        _amountController.text = widget.defaultInputAmount.toStringAsFixed(2);
      }
    }
    firstName = cardsBloc.firstName;
    lastName = cardsBloc.lastName;
    if (widget.cardEdit != null) _addEditCardInformation();

    switch (widget.type) {
      case PaymentMethodType.credit:
        title = 'Credit Card Details';
        break;
      case PaymentMethodType.gcEssentials:
        title = 'Essential Card Details';
        break;
      case PaymentMethodType.gcGear:
        title = 'Gear Card Details';
        break;
      case PaymentMethodType.gcGift:
        title = 'Gift Card Details';
        break;
      default:
        title = 'COA Card Details';
    }
    cardsBloc = context.read<OrderCardsBloc>();
    BuildContext? dialogContext;
    listener = cardsBloc.stream.listen((state) {
      // bool isExistingCreditCard = widget.cardEdit?.availableAmount == '';
      if (state.isAddedNewCardFail) {
        showMessage(context: context,message:'This card has already been added.');
      }
      if (state.isAddedNewCard || state.isUpdatedCard) {
        Future.delayed(
          Duration(milliseconds: 500),
          () {
            if (dialogContext != null) Navigator.pop(dialogContext!);
          },
        );
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            dialogContext = context;
            return SizedBox(
              width: 80,
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.symmetric(
                    horizontal: (MediaQuery.of(context).size.width / 2) - 70),
                elevation: 0,
                child: Container(
                  height: 140,
                  width: 140,
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
                        'Card ${state.isUpdatedCard ? 'Updated' : 'Added'}',
                        style:
                            TextStyle(fontSize: 17, color: ColorSystem.black),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ).then((value) => Navigator.pop(context));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  double _getWidgetSize() {
    var size = 500.0;
    switch (widget.type) {
      case PaymentMethodType.gcEssentials:
        size = 600.0;
        break;
      case PaymentMethodType.gcGear:
        size = 670.0;
        break;
      case PaymentMethodType.gcGift:
      case PaymentMethodType.cOA:
        size = 430.0;
        break;

      default:
        size = 500.0;
    }
    return size;
  }

  @override
  Widget build(BuildContext context) {
    bool isPickup = widget.cartState.deliveryModels
            .firstWhere(
              (element) => element.isSelected!,
              orElse: () => DeliveryModel(address: ''),
            )
            .type
            ?.toLowerCase()
            .contains('pick-up') ??
        false;
    AddressList? shippingAddress = widget.cartState.selectedAddressIndex >=
            widget.cartState.addressModel.length
        ? null
        : widget.cartState.addressModel[widget.cartState.selectedAddressIndex];
    if (shippingAddress != null) {
      shippingAddress.address1 = widget.cartState.selectedAddress1;
      shippingAddress.address2 = widget.cartState.selectedAddress2;
      shippingAddress.city = widget.cartState.selectedAddressCity;
      shippingAddress.state = widget.cartState.selectedAddressState;
      shippingAddress.postalCode = widget.cartState.selectedAddressPostalCode;
    }
    if (shippingAddress?.address1 == null) shippingAddress = null;
    // if (widget.cardEditwidget.cartState.addressModel.isNotEmpty) {
    //   AddressList defaultAddress = widget.cartState.addressModel.first;
    //   address = defaultAddress.address1 ?? '';
    // }
    return StreamBuilder<bool>(
        stream: isSameAsBillingController.stream,
        initialData: isSameAsBillingVal,
        builder: (context, snapshot) {
          bool isSameAsBilling = snapshot.data ?? true;
          return Container(
            height: _getWidgetSize(),
            decoration: BoxDecoration(
                color: ColorSystem.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32))),
            child: ListView(
              padding:
                  EdgeInsets.symmetric(horizontal: 14).copyWith(bottom: 80),
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                            fontFamily: kRubik),
                      ),
                      Row(
                        children: [
                          if (widget.cardEdit != null &&
                              !widget.isSelectedExistingCard)
                            InkWell(
                              onTap: () {
                                if (widget.cardEdit != null) {
                                  cardsBloc.add(DeleteCard(widget.cardEdit!));
                                  Navigator.pop(context);
                                }
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    IconSystem.deleteIcon,
                                    package: 'gc_customer_app',
                                    color: ColorSystem.lavender3,
                                    height: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: ColorSystem.lavender3,
                                      fontSize: 17,
                                      fontFamily: kRubik,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 12)
                                ],
                              ),
                            ),
                          // if (widget.cardEdit == null &&
                          //     widget.type == PaymentMethodType.credit)
                          //   InkWell(
                          //     onTap: () {
                          //       scanCard();
                          //     },
                          //     child: Row(
                          //       children: [
                          //         Icon(
                          //           Icons.qr_code_scanner_outlined,
                          //           color: ColorSystem.lavender3,
                          //         ),
                          //         SizedBox(width: 4),
                          //         Text(
                          //           'Scan Card',
                          //           style: TextStyle(
                          //             color: ColorSystem.lavender3,
                          //             fontSize: 17,
                          //             fontFamily: kRubik,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //         SizedBox(width: 12)
                          //       ],
                          //     ),
                          //   ),
                          CloseButton()
                        ],
                      )
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  builder: (context, snapshot) {
                    switch (widget.type) {
                      case PaymentMethodType.credit:
                        return creditBody(
                            isSameAsBilling, isPickup, shippingAddress);
                      case PaymentMethodType.gcEssentials:
                        return essentialBody(
                            isSameAsBilling, isPickup, shippingAddress);
                      case PaymentMethodType.gcGear:
                        return gearBody(
                            isSameAsBilling, isPickup, shippingAddress);
                      case PaymentMethodType.gcGift:
                        return giftBody();
                      default:
                        return coaBody();
                    }
                  },
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14).copyWith(bottom: 60),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ))),
                    onPressed: () async {
                      var userInfor = widget.cartState.orderDetailModel.first;

                      if ((widget.type == PaymentMethodType.gcEssentials ||
                              widget.type == PaymentMethodType.gcGear) &&
                          financialTypeModel == null) {
                        isShowFinancingErrorController.add(true);
                        return;
                      } else {
                        isShowFinancingErrorController.add(false);
                      }
                      if (formKey.currentState?.validate() ?? false) {
                        if (amount == '\$') {
                          amount = '\$0.0';
                        }
                        if (widget.cardEdit != null &&
                            !widget.isSelectedExistingCard) {
                          var card = CreditCardModelSave(
                            cardNumber: cardNumber,
                            cardHolderName: '$firstName $lastName',
                            cvvCode: cVV,
                            expiryMonth: expiryMonth,
                            expiryYear: expiryYear,
                            availableAmount: amount,
                            cardType: widget.cardEdit!.cardType,
                            financialTypeModel: financialTypeModel,
                            // widget.cardEdit!.financialTypeModel,
                            isSameAsShippingAddress: isSameAsBilling,
                            maxAmount: maxAmount,
                            isUseFullBalance: isUseFullBalance,
                            paymentMethod: PaymentMethod(
                              address: address,
                              address2: address2,
                              city: city,
                              country: 'US',
                              zipCode: zipCode,
                              state: state,
                              heading: heading,
                              amount: amount,
                              orderID: widget.orderId,
                              firstName: firstName,
                              lastName: lastName,
                              email: widget.cartState.shippingEmail,
                              phone: widget.cartState.shippingPhone,
                            ),
                          );
                          var isAccepted =
                              await _checkFinancialPaymentAccepted(card);
                          card.paymentMethod = await _checkBillingAddress(card);
                          isAddingCardController.add(false);
                          if (isAccepted)
                            cardsBloc.add(UpdateCard(card, widget.cardIndex!));
                        } else {
                          var card = CreditCardModelSave(
                            cardNumber: cardNumber,
                            cardHolderName: '$firstName $lastName',
                            cvvCode: cVV,
                            expiryMonth: expiryMonth,
                            expiryYear: expiryYear,
                            availableAmount: amount,
                            cardType: widget.type,
                            financialTypeModel: financialTypeModel,
                            maxAmount: maxAmount,
                            isUseFullBalance: isUseFullBalance,
                            isSameAsShippingAddress: isSameAsBilling,
                            isExistingCard: widget.isSelectedExistingCard,
                            paymentMethod: PaymentMethod(
                              address: address,
                              address2: address2,
                              city: city,
                              country: 'US',
                              zipCode: zipCode,
                              state: state,
                              heading: heading,
                              amount: amount,
                              orderID: widget.orderId,
                              firstName: firstName,
                              lastName: lastName,
                              email: widget.cartState.shippingEmail,
                              phone: widget.cartState.shippingPhone,

                              // phone: userInfor?.phone ?? '',
                              // email: userInfor?.billingEmail ??
                              //     userInfor?.shippingEmail ??
                              //     '',
                            ),
                          );
                          var isAccepted =
                              await _checkFinancialPaymentAccepted(card);
                          card.paymentMethod = await _checkBillingAddress(card);
                          isAddingCardController.add(false);
                          if (isAccepted)
                            cardsBloc.add(AddNewCard(
                                card,
                                widget.cartState.orderDetailModel.first.total ??
                                    0.0));
                        }
                      }
                    },
                    child: StreamBuilder<bool>(
                        stream: isAddingCardController.stream,
                        initialData: false,
                        builder: (context, snapshot) {
                          var isAdding = snapshot.data ?? false;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: isAdding
                                ? CupertinoActivityIndicator(
                                    color: ColorSystem.white,
                                  )
                                : Text(
                                    widget.cardEdit != null &&
                                            !widget.isSelectedExistingCard
                                        ? 'Update Card'
                                        : 'Add Card',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        ?.copyWith(
                                          fontSize: 17,
                                          color: ColorSystem.white,
                                        )),
                          );
                        }),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void onCreditCardModelChange(
      CreditCardModel? creditCardModel, CartState cartState) {
    cardNumber = (creditCardModel?.cardNumber ?? '').replaceAll(' ', '');
    cardHolderName = creditCardModel?.cardHolderName ?? '';
    firstName = creditCardModel?.firstName ?? '';
    lastName = creditCardModel?.lastName ?? '';
    expiryMonth = creditCardModel?.expiryDate.split('/').first ?? '';
    expiryYear = creditCardModel?.expiryDate.split('/').last ?? '';
    cVV = creditCardModel?.cvvCode ?? '';
    amount = creditCardModel?.cardAmount ?? '';
    address = creditCardModel?.address ?? '';
    address2 = creditCardModel?.address2 ?? '';
    city = creditCardModel?.city ?? '';
    state = creditCardModel?.state ?? '';
    zipCode = creditCardModel?.zipCode ?? '';
    heading = creditCardModel?.heading ?? '';
  }

  Widget creditBody(
      bool isSameAsBilling, bool isPickup, AddressList? shippingAddress) {
    return CreditCardForm(
      maxAmount: '',
      formKey: formKey,
      showEmail: true,
      themeColor: ColorSystem.black,
      onCreditCardModelChange: (model) {
        onCreditCardModelChange(model, widget.cartState);
      },
      shippingFormKey: widget.cartState.shippingFormKey!,
      cartBloc: cartBloc,
      email: widget.cartState.shippingEmail,
      phone: widget.cartState.shippingPhone,
      sFName: widget.cartState.shippingFName,
      sLName: widget.cartState.shippingLName,

      obscureCvv: false,
      sameAsBilling: isPickup ? false : isSameAsBilling,
      isSameAddressBillingVisible: !isPickup,
      shippingAddress: shippingAddress,
      cardHolderName: cardHolderName,
      firstName: firstName,
      lastName: lastName,
      state: state,
      city: city,
      zipCode: zipCode,
      address: address,
      heading: heading,
      isShowHeading: false,
      address2: address2,
      onChangeSameAsBillingAddress: (v) {
        // setState(() {
        //   cartBloc.add(UpdateSameAsBilling(value: v));
        //   FocusScope.of(context).unfocus();
        // });
        isSameAsBillingController.add(!isSameAsBilling);
        isSameAsBillingVal = !isSameAsBilling;
      },
      expiryDate: "${expiryMonth}/${expiryYear}",
      cardNumber: cardNumber,
      cardAmount: amount,
      onAmountChange: (value) {
        if (value.isNotEmpty) {
          cartBloc.add(UpdateShowAmount(value: true));
          cartBloc.add(UpdateAddCardAmount(value: value));
        } else {
          cartBloc.add(UpdateShowAmount(value: false));
          cartBloc.add(UpdateAddCardAmount(value: ""));
        }
      },
      cvvCode: cVV,
      isHolderNameVisible: true,
      // isCardNumberVisible: true,
      isExpiryDateVisible: true,
      isCardNumberReadOnly: widget.cardEdit?.isExistingCard == true ||
          widget.isSelectedExistingCard,
      isCardHolderNameReadOnly: widget.cardEdit != null,
      isShowCardNumberSuffixIcon: widget.cardEdit == null,
      cardNumberDecoration: InputDecoration(
        constraints: BoxConstraints(),
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        suffixIconColor: ColorSystem.secondary,
        // suffixIcon: IconButton(
        //   onPressed: () {
        //     isShowCardNumberController.add(!isShowCardNumber);
        //   },
        //   icon: Icon(
        //       isShowCardNumber
        //           ? Icons.visibility_off_outlined
        //           : Icons.visibility_outlined,
        //       color: ColorSystem.secondary),
        // ),
        border: _border,
        labelText: 'Card number',
        hintText: '**** **** **** ****',
      ),
      cardHolderDecoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        border: _border,
        labelText: 'Cardholder Name',
      ),
      amountDecoration: InputDecoration(
        constraints: BoxConstraints(),
        counterText: "",
        prefix: Text(
          '\$',
          style: TextStyle(
              fontFamily: kRubik, color: Theme.of(context).primaryColor),
        ),
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        border: _border,
        focusedBorder: _forcusedBorder,
        labelText: 'Enter Amount',
      ),
      expiryDateDecoration: InputDecoration(
        constraints: BoxConstraints(),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorSystem.greyDark,
            width: 1,
          ),
        ),
        labelText: 'Expiry Date',
        hintText: '  /  ',
      ),
      cVVMaxLength: 4,
      cvvCodeDecoration: InputDecoration(
        constraints: BoxConstraints(),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        border: _border,
        labelText: 'CVV',
        hintText: '****',
        counterText: "",
      ),
    );
  }

  Widget essentialBody(
      bool isSameAsBilling, bool isPickup, AddressList? shippingAddress) {
    final StreamController<String> isFinanceController =
        StreamController<String>.broadcast()..add('7');

    if (widget.cardEdit != null) {
      isFinanceController.add(widget.cardEdit!.financialTypeModel?.rank ?? '7');
    }
    return CreditCardForm(
      maxAmount: '',
      formKey: formKey,
      showEmail: true,
      themeColor: ColorSystem.black,
      onCreditCardModelChange: (model) {
        onCreditCardModelChange(model, widget.cartState);
      },
      shippingFormKey: widget.cartState.shippingFormKey!,
      cartBloc: cartBloc,
      email: widget.cartState.shippingEmail,
      phone: widget.cartState.shippingPhone,
      sFName: widget.cartState.shippingFName,
      sLName: widget.cartState.shippingLName,
      obscureCvv: false,
      sameAsBilling: isPickup ? false : isSameAsBilling,
      isSameAddressBillingVisible: !isPickup,
      shippingAddress: shippingAddress,
      cardHolderName: cardHolderName,
      firstName: firstName,
      lastName: lastName,
      state: state,
      city: city,
      zipCode: zipCode,
      address: address,
      heading: heading,
      isShowHeading: false,
      address2: address2,
      onChangeSameAsBillingAddress: (v) {
        isSameAsBillingController.add(!isSameAsBilling);
        isSameAsBillingVal = !isSameAsBilling;
      },
      cardNumber: cardNumber,
      cardAmount: amount,
      onAmountChange: (value) {},
      cvvCode: cVV,
      isCVVHaftWidth: true,
      isHolderNameVisible: true,
      isExpiryDateVisible: false,
      isCardHolderNameReadOnly: widget.cardEdit != null,
      cardNumberDecoration: InputDecoration(
        constraints: BoxConstraints(),
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        suffixIconColor: ColorSystem.secondary,
        // suffixIcon: IconButton(
        //   onPressed: () {
        //     isShowCardNumberController.add(!isShowCardNumber);
        //   },
        //   icon: Icon(
        //       isShowCardNumber
        //           ? Icons.visibility_off_outlined
        //           : Icons.visibility_outlined,
        //       color: ColorSystem.secondary),
        // ),
        border: _border,
        labelText: 'Essential Card Number',
        hintText: '**** **** **** ****',
      ),
      amountDecoration: InputDecoration(
        constraints: BoxConstraints(),
        counterText: "",
        prefix: Text(
          '\$',
          style: TextStyle(
              fontFamily: kRubik, color: Theme.of(context).primaryColor),
        ),
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        border: _border,
        focusedBorder: _forcusedBorder,
        labelText: 'Enter Amount',
      ),
      cVVMaxLength: 4,
      cardHolderDecoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        border: _border,
        labelText: 'Cardholder Name',
      ),
      cvvCodeDecoration: InputDecoration(
        constraints: BoxConstraints(),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        border: _border,
        labelText: 'Security Code',
        hintText: '****',
        counterText: '',
      ),
      additionalWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'Your purchase qualifies for the following financing Plan,\nPlease select the option you prefer',
              style:
                  Theme.of(context).textTheme.headline5?.copyWith(fontSize: 11),
            ),
          ),
          BlocBuilder<OrderCardsBloc, OrderCardsState>(
              builder: (context, state) {
            var essentialFinances = state.essentialFinance;
            return StreamBuilder<String>(
                stream: isFinanceController.stream,
                initialData: widget.cardEdit?.financialTypeModel?.rank,
                builder: (context, snapshot) {
                  var value = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: essentialFinances?.map<Widget>(
                          (ef) {
                            return RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              value: ef.rank,
                              groupValue: value,
                              onChanged: (value) {
                                isFinanceController.add(ef.rank ?? '1');
                                financialTypeModel = ef;
                              },
                              title: Text(ef.promoTitle ?? ''),
                              // subtitle: value == ef.rank
                              //     ? Text(ef.promoDescription ?? '')
                              //     : null,
                              activeColor: ColorSystem.black,
                            );
                          },
                        ).toList() ??
                        [],
                  );
                });
          }),
          StreamBuilder(
            stream: isShowFinancingErrorController.stream,
            initialData: false,
            builder: (_, snapshot) {
              if (snapshot.data == true)
                return Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Please select a financing plan',
                    style: TextStyle(
                        fontFamily: kRubik,
                        color: ColorSystem.pureRed,
                        fontSize: 12),
                  ),
                );
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget gearBody(
      bool isSameAsBilling, bool isPickup, AddressList? shippingAddress) {
    final StreamController<String> isFinanceController =
        StreamController<String>.broadcast();

    return CreditCardForm(
      maxAmount: '',
      formKey: formKey,
      showEmail: true,
      themeColor: ColorSystem.black,
      onCreditCardModelChange: (model) {
        onCreditCardModelChange(model, widget.cartState);
      },
      shippingFormKey: widget.cartState.shippingFormKey!,
      cartBloc: cartBloc,
      email: widget.cartState.shippingEmail,
      phone: widget.cartState.shippingPhone,
      sFName: widget.cartState.shippingFName,
      sLName: widget.cartState.shippingLName,
      obscureCvv: false,
      sameAsBilling: isPickup ? false : isSameAsBilling,
      isSameAddressBillingVisible: !isPickup,
      shippingAddress: shippingAddress,
      cardHolderName: cardHolderName,
      firstName: firstName,
      lastName: lastName,
      state: state,
      city: city,
      zipCode: zipCode,
      address: address,
      heading: heading,
      isShowHeading: false,
      address2: address2,
      onChangeSameAsBillingAddress: (v) {
        isSameAsBillingController.add(!isSameAsBilling);
        isSameAsBillingVal = !isSameAsBilling;
      },
      cardNumber: cardNumber,
      cardAmount: amount,
      onAmountChange: (value) {},
      cvvCode: cVV,
      isCVVHaftWidth: true,
      isHolderNameVisible: true,
      isExpiryDateVisible: false,
      isCardHolderNameReadOnly: widget.cardEdit != null,
      cardNumberDecoration: InputDecoration(
        constraints: BoxConstraints(),
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        suffixIconColor: ColorSystem.secondary,
        // suffixIcon: IconButton(
        // onPressed: () {
        //   isShowCardNumberController.add(!isShowCardNumber);
        // },
        // icon: Icon(
        //     isShowCardNumber
        //         ? Icons.visibility_off_outlined
        //         : Icons.visibility_outlined,
        //     color: ColorSystem.secondary),
        // ),
        border: _border,
        labelText: 'Gear Card number',
        hintText: '**** **** **** ****',
      ),
      cardHolderDecoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        border: _border,
        labelText: 'Cardholder Name',
      ),
      amountDecoration: InputDecoration(
        constraints: BoxConstraints(),
        counterText: "",
        prefix: Text(
          '\$',
          style: TextStyle(
              fontFamily: kRubik, color: Theme.of(context).primaryColor),
        ),
        contentPadding: EdgeInsets.zero,
        labelStyle: _labelStyle,
        border: _border,
        focusedBorder: _forcusedBorder,
        labelText: 'Enter Amount',
      ),
      cVVMaxLength: 4,
      cvvCodeDecoration: InputDecoration(
        constraints: BoxConstraints(),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        labelStyle: _labelStyle,
        focusedBorder: _forcusedBorder,
        border: _border,
        labelText: 'Security Code',
        hintText: '****',
        counterText: '',
      ),
      additionalWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'Your purchase qualifies for the following financing Plan,\nPlease select the option you prefer',
              style:
                  Theme.of(context).textTheme.headline5?.copyWith(fontSize: 11),
            ),
          ),
          BlocBuilder<OrderCardsBloc, OrderCardsState>(
              builder: (context, state) {
            var gearFinances = state.gearFinance;
            return Container(
              child: StreamBuilder<String>(
                  stream: isFinanceController.stream,
                  initialData: financialTypeModel?.rank,
                  builder: (context, snapshot) {
                    var value = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: gearFinances?.map<Widget>(
                            (gf) {
                              return RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                value: gf.rank,
                                groupValue: value,
                                onChanged: (value) {
                                  isFinanceController.add(gf.rank ?? '1');
                                  financialTypeModel = gf;
                                },
                                title: Text(gf.promoTitle ?? ''),
                                // subtitle: value == gf.rank
                                //     ? Text(gf.promoDescription ?? '')
                                //     : null,
                                activeColor: ColorSystem.black,
                              );
                            },
                          ).toList() ??
                          [],
                    );
                  }),
            );
          }),
          StreamBuilder(
            stream: isShowFinancingErrorController.stream,
            initialData: false,
            builder: (_, snapshot) {
              if (snapshot.data == true)
                return Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Please select a financing plan',
                    style: TextStyle(
                        fontFamily: kRubik,
                        color: ColorSystem.pureRed,
                        fontSize: 12),
                  ),
                );
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget giftBody() {
    final StreamController<bool> isUseAllBalanceController =
        StreamController<bool>.broadcast()..add(true);

    return BlocBuilder<OrderCardsBloc, OrderCardsState>(
        builder: (context, state) {
      var availableBalance = state.giftCardAvailableBalance;
      maxAmount = availableBalance;
      amount = maxAmount;
      return CreditCardForm(
        maxAmount: availableBalance,
        showEmail: false,
        isShowMaxAmount: true,
        formKey: formKey,
        themeColor: ColorSystem.black,
        onCreditCardModelChange: (model) {
          onCreditCardModelChange(model, widget.cartState);
          if (model.cvvCode.length == 8) {
            cardsBloc.add(GetGiftCardBalance(model.cardNumber, model.cvvCode));
          }
        },
        shippingFormKey: widget.cartState.shippingFormKey!,
        cartBloc: cartBloc,
        email: widget.cartState.shippingEmail,
        phone: widget.cartState.shippingPhone,
        sFName: widget.cartState.shippingFName,
        sLName: widget.cartState.shippingLName,
        obscureCvv: false,
        cardNumber: cardNumber,
        cardAmount: amount,
        onAmountChange: (value) {},
        cvvCode: cVV,
        isCVVHaftWidth: true,
        isHolderNameVisible: false,
        isExpiryDateVisible: false,
        isAmountVisible: false,
        isSameAddressBillingVisible: false,
        isCardHolderNameReadOnly: widget.cardEdit != null,
        cardNumberDecoration: InputDecoration(
          constraints: BoxConstraints(),
          contentPadding: EdgeInsets.zero,
          labelStyle: _labelStyle,
          focusedBorder: _forcusedBorder,
          suffixIconColor: ColorSystem.secondary,
          // suffixIcon: IconButton(
          //   onPressed: () {
          //     isShowCardNumberController.add(!isShowCardNumber);
          //   },
          //   icon: Icon(
          //       isShowCardNumber
          //           ? Icons.visibility_off_outlined
          //           : Icons.visibility_outlined,
          //       color: ColorSystem.secondary),
          // ),
          border: _border,
          labelText: 'Gift Card number',
          hintText: '**** **** **** ****',
        ),
        amountDecoration: InputDecoration(
          constraints: BoxConstraints(),
          counterText: "",
          prefix: Text(
            '\$',
            style: TextStyle(
                fontFamily: kRubik, color: Theme.of(context).primaryColor),
          ),
          contentPadding: EdgeInsets.zero,
          labelStyle: _labelStyle,
          border: _border,
          focusedBorder: _forcusedBorder,
          labelText: 'Enter Amount',
        ),
        cVVMaxLength: 8,
        cvvCodeDecoration: InputDecoration(
          constraints: BoxConstraints(),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          labelStyle: _labelStyle,
          focusedBorder: _forcusedBorder,
          border: _border,
          labelText: 'Pin',
          hintText: '********',
          counterText: '',
        ),
        availableBalanceWidget: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontSize: 11),
              ),
              Text(
                '\$${NumberFormat.decimalPattern().format(double.parse(availableBalance))}',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
              )
            ],
          ),
        ),
        additionalWidget: StreamBuilder<bool>(
            stream: isUseAllBalanceController.stream,
            initialData: widget.cardEdit?.isUseFullBalance ?? true,
            builder: (context, snapshot) {
              var isUseAllBalance =
                  snapshot.data ?? widget.cardEdit?.isUseFullBalance ?? true;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use Balance',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: ColorSystem.greyDark,
                                  fontFamily: kRubik),
                            ),
                            if (!isUseAllBalance)
                              Text(
                                'or',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorSystem.greyDark,
                                    fontFamily: kRubik),
                              )
                          ],
                        ),
                        CustomSwitch(
                          value: isUseAllBalance,
                          onChanged: (value) {
                            isUseAllBalanceController.add(value);
                            isUseFullBalance = value;
                            if (value) {
                              amount = availableBalance;
                            } else {
                              _amountController.text = '0';
                            }
                          },
                          activeText: Container(width: 20),
                          inactiveText: Container(width: 20),
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: ColorSystem.greyDark,
                        ),
                      ],
                    ),
                    if (!isUseAllBalance)
                      TextFormField(
                        controller: _amountController,
                        cursorColor: ColorSystem.black,
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorSystem.black,
                        ),
                        decoration: InputDecoration(
                          constraints: BoxConstraints(),
                          counterText: "",
                          prefix: Text(
                            '\$',
                            style: TextStyle(
                                fontFamily: kRubik,
                                color: Theme.of(context).primaryColor),
                          ),
                          contentPadding: EdgeInsets.zero,
                          labelStyle: _labelStyle,
                          border: _border,
                          focusedBorder: _forcusedBorder,
                          labelText: 'Enter Amount',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyTextInputFormatter(
                              name: '', symbol: '', decimalDigits: 2),
                          FilteringTextInputFormatter.allow(
                              RegExp("[0-9.,\$]")),
                        ],
                        validator: (String? value) {
                          // Validate less that 13 digits +3 white spaces
                          if (double.parse(
                                  (value ?? '0.0').replaceAll(',', '')) >
                              double.parse(availableBalance)) {
                            return "You cannot add more than \$${availableBalance}";
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (value) => amount = value,
                      ),
                    SizedBox(height: 14)
                  ],
                ),
              );
            }),
      );
    });
  }

  Widget coaBody() {
    return BlocBuilder<OrderCardsBloc, OrderCardsState>(
        builder: (context, state) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (MediaQuery.of(context).size.width / 2) - 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontSize: 11),
                  ),
                  Text(
                    '\$${state.coaCreditBalance?.availableAmount ?? '0.0'}',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Form(
              key: formKey,
              child: TextFormField(
                controller: _amountController,
                cursorColor: ColorSystem.black,
                style: TextStyle(
                  fontSize: 16,
                  color: ColorSystem.black,
                ),
                decoration: InputDecoration(
                  constraints: BoxConstraints(),
                  counterText: "",
                  prefix: Text(
                    '\$',
                    style: TextStyle(
                        fontFamily: kRubik,
                        color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: EdgeInsets.zero,
                  labelStyle: _labelStyle,
                  border: _border,
                  focusedBorder: _forcusedBorder,
                  labelText: 'Enter Amount',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyTextInputFormatter(
                      name: '', symbol: '', decimalDigits: 2),
                  FilteringTextInputFormatter.allow(RegExp("[0-9.,\$]")),
                ],
                validator: (String? value) {
                  if (double.parse((value ?? '0.0').replaceAll(',', '')) >
                      double.parse(
                          state.coaCreditBalance?.availableAmount ?? '0.0')) {
                    return "Amount cannot add more than \$${state.coaCreditBalance?.availableAmount ?? '0.0'}";
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onChanged: (value) => amount = value,
              ),
            ),
            SizedBox(height: 30)
          ],
        ),
      );
    });
  }

  Future<bool> _checkFinancialPaymentAccepted(CreditCardModelSave card) async {
    if (widget.cardEdit != null &&
        card.financialTypeModel == widget.cardEdit?.financialTypeModel &&
        card.cardNumber == widget.cardEdit?.cardNumber &&
        (card.cardType == PaymentMethodType.gcEssentials ||
            card.cardType == PaymentMethodType.gcGear)) {
      return true;
    }
    if (card.cardType == PaymentMethodType.gcEssentials ||
        card.cardType == PaymentMethodType.gcGear) {
      isAddingCardController.add(true);
      Map jsonResponse;
      String message = '';
      if (card.cardType == PaymentMethodType.gcGear) {
        if (card.financialTypeModel == null) {
          await errorDialog("You have to select a financing plan to add card.");
        }
        jsonResponse = await cardsBloc
            .getGearFinanceMessage(widget.orderId, card)
            .catchError((err) {
          isAddingCardController.add(false);
          return {};
        });
      } else {
        jsonResponse = await cardsBloc
            .getEssentialFinanceMessage(widget.orderId, card)
            .catchError((err) async {
          await errorDialog(err.toString().replaceAll('Exception: ', ''));
          isAddingCardController.add(false);
          return {};
        });
      }
      if (jsonResponse['StatusCode'] == null ||
          (jsonResponse['StatusCode'] < 200 &&
              jsonResponse['StatusCode'] > 299)) {
        errorDialog(jsonResponse['message']);
        isAddingCardController.add(false);
        return false;
      } else if (jsonResponse['Status'].toString().toLowerCase() != 'success') {
        errorDialog(jsonResponse['message'], true);
        isAddingCardController.add(false);
        return false;
      } else {
        message = jsonResponse['message'];
      }
      if (message.isEmpty) return true;

      bool isInvalid = message
              .toLowerCase()
              .contains('Invalid Card Number'.toLowerCase()) ||
          message.toLowerCase().contains('Internal Server Error'.toLowerCase());

      if (isInvalid) {
        await errorDialog(message);
      }

      bool? isAccepted = await openDisclosureDialog(message);

      return isAccepted ?? false;
    }
    return Future.value(true);
  }

  Future<bool?> openDisclosureDialog(String message) async {
    var isAccepted = await showDialog(
      context: context,
      builder: (context) => DisclosureDialog(message: message),
    );

    if (isAccepted != true) {
      return await openRejectedDisclosureDialog(message);
    }

    if (isAccepted == 'invalid') {
      Navigator.pop(context);
    }

    return isAccepted;
  }

  Future<bool?> openRejectedDisclosureDialog(String message) async {
    bool? isCloseDisclosure = await showDialog(
      context: context,
      builder: (context) => RejectedDisclosureDialog(),
    );

    if (isCloseDisclosure == true) {
      return await openDisclosureDialog(message);
    }
  }

  Future<void> errorDialog(String errorText, [bool showTitle = false]) async {
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          showTitle ? errorText : 'Error',
          style: TextStyle(
              fontSize: 17, fontFamily: kRubik, fontWeight: FontWeight.w600),
        ),
        content: showTitle
            ? null
            : Text(
                errorText,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 13, fontFamily: kRubik, height: 1.3),
              ),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    isAddingCardController.add(false);
    throw Exception();
  }

  Future<PaymentMethod?> _checkBillingAddress(CreditCardModelSave card) async {
    if (card.isSameAsShippingAddress) return card.paymentMethod;
    String? loggedInUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);
    var enteredAddress = VerifyAddress(
        state: state,
        postalcode: card.paymentMethod?.zipCode,
        isShipping: false,
        isBilling: true,
        country: 'US',
        city: card.paymentMethod?.city,
        addressline2: card.paymentMethod?.address2,
        addressline1: card.paymentMethod?.address);
    var resp = await AddressesRepository()
        .verificationAddress(loggedInUserId, enteredAddress);
    if (resp.hasDifference &&
        resp.recommendedAddress.isSuccess != null &&
        resp.recommendedAddress.isSuccess!) {
      var response = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RecommendAddressDialog(
            enteredAddress: enteredAddress,
            recommendAddress: resp.recommendedAddress),
      );
      return response
          ? PaymentMethod(
              address: resp.recommendedAddress.addressline1 ?? '',
              address2: resp.recommendedAddress.addressline2 ?? '',
              city: resp.recommendedAddress.city ?? '',
              country: 'US',
              zipCode: resp.recommendedAddress.postalcode ?? '',
              state: resp.recommendedAddress.state ?? '',
              heading: card.paymentMethod?.heading ?? '',
              amount: card.paymentMethod?.amount ?? '',
              orderID: card.paymentMethod?.orderID ?? '',
              firstName: card.paymentMethod?.firstName ?? '',
              lastName: card.paymentMethod?.lastName ?? '',
              email: widget.cartState.shippingEmail,
              phone: widget.cartState.shippingPhone,
              // phone: card.paymentMethod?.phone ?? '',
              // email: card.paymentMethod?.email ?? '',
            )
          : card.paymentMethod;
    } else {
      return card.paymentMethod;
    }
  }

  Future<void> scanCard() async {
    // final CardDetails? cardDetails = await CardScanner.scanCard(
    //     scanOptions: CardScanOptions(
    //         enableLuhnCheck: true,
    //         scanExpiryDate: true,
    //         scanCardHolderName: true,
    //         validCardsToScanBeforeFinishingScan: 6));
    // if (!mounted || cardDetails == null) return;
    // print('----detail: ${cardDetails.cardHolderName}');
    // print('----detail: ${cardDetails.cardNumber}');
    // print('----detail: ${cardDetails.expiryDate}');
    print('-----scan');
    setState(() {
      cardNumber = '4111 1111 1111 1111'; // cardDetails.cardNumber;
      firstName =
          //cardDetails.cardHolderName
          'PHU HUNG TRAN'.split(' ').first;
      lastName = //cardDetails.cardHolderName
          'PHU HUNG TRAN'.replaceAll(firstName, '').trim();
      expiryMonth = //cardDetails.expiryDate
          '12/34'.split('/').first;
      expiryYear = //cardDetails.expiryDate
          '12/34'.split('/').last;
    });
    setState(() {});
  }
}

