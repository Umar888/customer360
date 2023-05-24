import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/views/credit_card_form.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/widgets/credit_card_widget.dart';
import 'package:gc_customer_app/models/cart_model/order_user_information.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class PaymentPage extends StatefulWidget {
  final CartState cartState;
  final Function onScroll;
  final OrderUserInformation orderInfo;
  PaymentPage(
      {Key? key,
      required this.cartState,
      required this.onScroll,
      required this.orderInfo})
      : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late CartBloc cartBloc;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    cartBloc = context.read<CartBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:
          // widget.cartState.showAddCard
          //     ?
          //         Column(
          //   children: [
          //     SizedBox(height: 20),
          //     // widget.cartState.sameAsBilling
          //     //     ?
          //         CreditCardWidget(
          //             obscureCardNumber: true,
          //             obscureCardCvv: false,
          //             showChip: true,
          //             showAmount: widget.cartState.showAmount,
          //             amount: widget.cartState.addCardAmount,
          //             isHolderNameVisible: true,
          //             isSwipeGestureEnabled: true,
          //             height: 280,
          //             width: MediaQuery.of(context).size.width,
          //             backgroundImage: "assets/icons/credit_card_background.png",
          //             glassmorphismConfig: null,
          //             cardHolderName: widget.cartState.cardHolderName,
          //             expiryMonth: widget.cartState.expiryMonth,
          //             expiryYear: widget.cartState.expiryYear,
          //             cardNumber: widget.cartState.cardNumber,
          //             cvvCode: widget.cartState.cvvCode,
          //             showBackView: widget.cartState.isCvvFocused,
          //             onCreditCardWidgetChange: (CreditCardBrand) {},
          //           )
          //         // : Container()
          //         ,
          //     Expanded(
          //       child: Material(
          //           borderRadius: BorderRadius.only(
          //               topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          //           elevation: 10,
          //           shadowColor: ColorSystem.greyDark,
          //           color: Color(0xffFDFDFE),
          //           borderOnForeground: true,
          //           type: MaterialType.card,
          //           clipBehavior: Clip.hardEdge,
          //           child: SizedBox(
          //             width: double.infinity,
          //             child: Padding(
          //               padding:
          //                   EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
          //               child: NotificationListener<ScrollNotification>(
          //                 onNotification: (scrollNotification) {
          //                   if (scrollNotification is ScrollStartNotification) {
          //                     widget.onScroll();
          //                   } else if (scrollNotification
          //                       is ScrollUpdateNotification) {
          //                     widget.onScroll();
          //                   } else if (scrollNotification is ScrollEndNotification) {
          //                     widget.onScroll();
          //                   }
          //                   return true;
          //                 },
          //                 child: SingleChildScrollView(
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     mainAxisAlignment: MainAxisAlignment.start,
          //                     children: [
          //                       SizedBox(height: 30),
          //                       Text(
          //                         "Enter Your Credit Card Details",
          //                         style: TextStyle(
          //                             fontSize: 18,
          //                             fontWeight: FontWeight.w600,
          //                             color: Color(0xFF222222),
          //                             fontFamily: kRubik),
          //                       ),
          //                       SizedBox(height: 0),
          //                       CreditCardForm(
          //                         maxAmount: widget.cartState.total.toString(),
          //                         // maxAmount: (double.parse(widget.cartState.creditCardModelSave.fold(
          //                         //         "0", (a, b) => (double.parse(a.toString()) + (double.parse(b.paymentMethod.amount) * 1)).toString()))).toStringAsFixed(2),
          //                         formKey: formKey,
          //                         themeColor: Colors.red,
          //                         onCreditCardModelChange: (model) {
          //                           onCreditCardModelChange(model, widget.cartState);
          //                         },
          //                         obscureCvv: true,
          //                         sameAsBilling: widget.cartState.sameAsBilling,
          //                         cardHolderName: widget.cartState.cardHolderName,
          //                         state: widget.cartState.state,
          //                         city: widget.cartState.city,
          //                         zipCode: widget.cartState.zipCode,
          //                         address: widget.cartState.address,
          //                         heading: widget.cartState.heading,
          //                         onChangeSameAsBillingAddress: (v) => setState(() {
          //                           cartBloc.add(UpdateSameAsBilling(value: v));
          //                           FocusScope.of(context).unfocus();
          //                         }),
          //                         expiryDate:
          //                             "${widget.cartState.expiryMonth}/${widget.cartState.expiryYear}",
          //                         cardNumber: widget.cartState.cardNumber,
          //                         cardAmount: widget.cartState.cardAmount,
          //                         onAmountChange: (value) {
          //                           if (value.isNotEmpty) {
          //                             cartBloc.add(UpdateShowAmount(value: true));
          //                             cartBloc.add(UpdateAddCardAmount(value: value));
          //                           } else {
          //                             cartBloc.add(UpdateShowAmount(value: false));
          //                             cartBloc.add(UpdateAddCardAmount(value: ""));
          //                           }
          //                         },
          //                         cvvCode: widget.cartState.cvvCode,
          //                         obscureNumber: widget.cartState.obscureCardNumber,
          //                         isHolderNameVisible: true,
          //                         isCardNumberVisible: true,
          //                         isExpiryDateVisible: true,
          //                         cardNumberDecoration: InputDecoration(
          //                           constraints: BoxConstraints(),
          //                           contentPadding: EdgeInsets.symmetric(
          //                               vertical: 0, horizontal: 0),
          //                           labelStyle: TextStyle(
          //                             color: ColorSystem.greyDark,
          //                             fontSize: 18,
          //                           ),
          //                           focusedBorder: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: Theme.of(context).primaryColor,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           suffixIconColor: ColorSystem.secondary,
          //                           suffixIcon: IconButton(
          //                             onPressed: () {
          //                               cartBloc.add(UpdateObscureCardNumber(
          //                                   value: widget.cartState.obscureCardNumber
          //                                       ? false
          //                                       : true));
          //                             },
          //                             icon: Icon(
          //                                 widget.cartState.obscureCardNumber
          //                                     ? Icons.visibility_outlined
          //                                     : Icons.visibility_off_outlined,
          //                                 color: ColorSystem.secondary),
          //                           ),
          //                           border: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: ColorSystem.greyDark,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           labelText: 'Card Number',
          //                           hintText: 'XXXX XXXX XXXX XXXX',
          //                         ),
          //                         cardHolderDecoration: InputDecoration(
          //                           constraints: BoxConstraints(),
          //                           contentPadding: EdgeInsets.symmetric(
          //                               vertical: 0, horizontal: 0),
          //                           labelStyle: TextStyle(
          //                             color: ColorSystem.greyDark,
          //                             fontSize: 18,
          //                           ),
          //                           focusedBorder: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: Theme.of(context).primaryColor,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           border: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: ColorSystem.greyDark,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           labelText: 'Cardholder Name',
          //                         ),
          //                         amountDecoration: InputDecoration(
          //                           constraints: BoxConstraints(),
          //                           counterText: "",
          //                           contentPadding: EdgeInsets.symmetric(
          //                               vertical: 0, horizontal: 0),
          //                           labelStyle: TextStyle(
          //                             color: ColorSystem.greyDark,
          //                             fontSize: 18,
          //                           ),
          //                           border: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: ColorSystem.greyDark,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           focusedBorder: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: Theme.of(context).primaryColor,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           labelText: 'Enter Amount',
          //                         ),
          //                         expiryDateDecoration: InputDecoration(
          //                           constraints: BoxConstraints(),
          //                           contentPadding: EdgeInsets.symmetric(
          //                               vertical: 0, horizontal: 0),
          //                           labelStyle: TextStyle(
          //                             color: ColorSystem.greyDark,
          //                             fontSize: 18,
          //                           ),
          //                           focusedBorder: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: Theme.of(context).primaryColor,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           border: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: ColorSystem.greyDark,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           labelText: 'Expiry Date',
          //                           hintText: 'XX/XX',
          //                         ),
          //                         cvvCodeDecoration: InputDecoration(
          //                           constraints: BoxConstraints(),
          //                           contentPadding: EdgeInsets.symmetric(
          //                               vertical: 0, horizontal: 0),
          //                           labelStyle: TextStyle(
          //                             color: ColorSystem.greyDark,
          //                             fontSize: 18,
          //                           ),
          //                           focusedBorder: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: Theme.of(context).primaryColor,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           border: UnderlineInputBorder(
          //                             borderSide: BorderSide(
          //                               color: ColorSystem.greyDark,
          //                               width: 1,
          //                             ),
          //                           ),
          //                           labelText: 'CVV',
          //                           hintText: 'XXX',
          //                         ),
          //                       ),
          //                       SizedBox(height: 20),
          //                       ElevatedButton(
          //                         style: ButtonStyle(
          //                             backgroundColor: MaterialStateProperty.all(
          //                                 Theme.of(context).primaryColor),
          //                             shape: MaterialStateProperty.all<
          //                                     RoundedRectangleBorder>(
          //                                 RoundedRectangleBorder(
          //                               borderRadius: BorderRadius.circular(10.0),
          //                             ))),
          //                         onPressed: () {
          //                           FocusScope.of(context).unfocus();
          //                           if (formKey.currentState!.validate()) {
          //                             setState(() {
          //                               cartBloc.add(UpdateShowAmount(value: false));
          //                               cartBloc.add(AddInCreditCardModel(
          //                                   value: CreditCardModelSave(
          //                                 cardNumber: widget.cartState.cardNumber,
          //                                 expiryYear: widget.cartState.expiryYear,
          //                                 expiryMonth: widget.cartState.expiryMonth,
          //                                 cardHolderName:
          //                                     widget.cartState.cardHolderName,
          //                                 isCvvFocused: false,
          //                                 paymentMethod: PaymentMethod(
          //                                     address: widget.cartState.address.isNotEmpty
          //                                         ? widget.cartState.address
          //                                         : widget.cartState.addressModel
          //                                             .firstWhere((element) =>
          //                                                 element.isSelected!)
          //                                             .address1!,
          //                                     city: widget.cartState.city.isNotEmpty
          //                                         ? widget.cartState.city
          //                                         : widget.cartState.addressModel
          //                                             .firstWhere((element) =>
          //                                                 element.isSelected!)
          //                                             .city!,
          //                                     state: widget.cartState.state.isNotEmpty
          //                                         ? widget.cartState.city
          //                                         : widget.cartState.addressModel
          //                                             .firstWhere((element) =>
          //                                                 element.isSelected!)
          //                                             .state!,
          //                                     country: "United States",
          //                                     amount: widget.cartState.cardAmount,
          //                                     zipCode: widget.cartState.zipCode.isNotEmpty
          //                                         ? widget.cartState.zipCode
          //                                         : widget.cartState.addressModel
          //                                             .firstWhere((element) =>
          //                                                 element.isSelected!)
          //                                             .postalCode!,
          //                                     heading: widget.cartState.heading.isNotEmpty
          //                                         ? widget.cartState.heading
          //                                         : widget.cartState.addressModel.firstWhere((element) => element.isSelected!).addressLabel!,
          //                                     firstName: widget.orderInfo.userName.split(" ").length > 1 ? widget.orderInfo.userName.split(" ")[0] : widget.orderInfo.userName,
          //                                     lastName: widget.orderInfo.userName.split(" ").length > 1 ? widget.orderInfo.userName.split(" ")[1] : "",
          //                                     orderID: widget.orderInfo.orderId,
          //                                     email: widget.orderInfo.email,
          //                                     phone: widget.orderInfo.phone),
          //                                 cvvCode: widget.cartState.cvvCode,
          //                                 cardType: "",
          //                               )));

          //                               cartBloc.add(UpdateShowAddCard(value: false));
          //                               cartBloc.add(UpdateCardHolderName(value: ""));
          //                               cartBloc.add(UpdateCardNumber(value: ""));
          //                               cartBloc.add(UpdateCardAmount(value: ""));
          //                             });
          //                           } else {}
          //                         },
          //                         child: Padding(
          //                           padding: EdgeInsets.symmetric(vertical: 15),
          //                           child: Row(
          //                             mainAxisAlignment: MainAxisAlignment.center,
          //                             children: [
          //                               Text(
          //                                 'Add Card',
          //                                 style: TextStyle(fontSize: 18),
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                       ),
          //                       SizedBox(
          //                         height: 30,
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           )),
          //     ),
          //   ],
          // )
          // :
          Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  widget.onScroll();
                } else if (scrollNotification is ScrollUpdateNotification) {
                  widget.onScroll();
                } else if (scrollNotification is ScrollEndNotification) {
                  widget.onScroll();
                }
                return true;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: widget.cartState.creditCardModelSave.map((e) {
                        return Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: CreditCardWidget(
                                obscureCardNumber: true,
                                showAmount: true,
                                showChip: true,
                                amount: e.paymentMethod!.amount,
                                obscureCardCvv: false,
                                isHolderNameVisible: true,
                                isSwipeGestureEnabled: true,
                                height: 280,
                                width: MediaQuery.of(context).size.width,
                                backgroundImage:
                                    "assets/icons/credit_card_background.png",
                                glassmorphismConfig: null,
                                cardHolderName: e.cardHolderName,
                                expiryMonth: e.expiryMonth,
                                expiryYear: e.expiryYear,
                                cardNumber: e.cardNumber,
                                cvvCode: e.cvvCode,
                                showBackView: e.isCvvFocused,
                                onCreditCardWidgetChange: (CreditCardBrand) {},
                              ),
                            ),
                            Positioned(
                                left: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: IconButton(
                                    constraints: BoxConstraints(),
                                    color: Colors.white,
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        cartBloc.add(RemoveCreditCardModelSave(
                                            value: e));
                                      });
                                    },
                                  ),
                                ))
                          ],
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 31, vertical: 11),
                      child: InkWell(
                        onTap: () {
                          // cartBloc.add(UpdateShowAddCard(value: true));
                          // cartBloc.add(UpdateShowAmount(value: false));
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: ColorSystem.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        topRight: Radius.circular(32))),
                                child: Column(
                                  children: [
                                    Text(
                                      "Credit Card Details",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF222222),
                                          fontFamily: kRubik),
                                    ),
                                    CreditCardForm(
                                      maxAmount: widget.cartState.total.toString(),
                                      shippingFormKey:  widget.cartState.shippingFormKey!,
                                      cartBloc: cartBloc,
                                      showEmail: true,
                                      email:  widget.cartState.shippingEmail,
                                      phone:  widget.cartState.shippingPhone,
                                      sFName:  widget.cartState.shippingFName,
                                      sLName:  widget.cartState.shippingLName,
                                      formKey: formKey,
                                      themeColor: Colors.red,
                                      onCreditCardModelChange: (model) {
                                        onCreditCardModelChange(
                                            model, widget.cartState);
                                      },
                                      obscureCvv: true,
                                      sameAsBilling:
                                          widget.cartState.sameAsBilling,
                                      cardHolderName:
                                          widget.cartState.cardHolderName,
                                      state: widget.cartState.state,
                                      city: widget.cartState.city,
                                      zipCode: widget.cartState.zipCode,
                                      address: widget.cartState.address,
                                      heading: widget.cartState.heading,
                                      onChangeSameAsBillingAddress: (v) =>
                                          setState(() {
                                        cartBloc
                                            .add(UpdateSameAsBilling(value: v));
                                        FocusScope.of(context).unfocus();
                                      }),
                                      expiryDate:
                                          "${widget.cartState.expiryMonth}/${widget.cartState.expiryYear}",
                                      cardNumber: widget.cartState.cardNumber,
                                      cardAmount: widget.cartState.cardAmount,
                                      onAmountChange: (value) {
                                        if (value.isNotEmpty) {
                                          cartBloc.add(
                                              UpdateShowAmount(value: true));
                                          cartBloc.add(UpdateAddCardAmount(
                                              value: value));
                                        } else {
                                          cartBloc.add(
                                              UpdateShowAmount(value: false));
                                          cartBloc.add(
                                              UpdateAddCardAmount(value: ""));
                                        }
                                      },
                                      cvvCode: widget.cartState.cvvCode,
                                      obscureNumber:
                                          widget.cartState.obscureCardNumber,
                                      isHolderNameVisible: true,
                                      isCardNumberVisible: true,
                                      isExpiryDateVisible: true,
                                      cardNumberDecoration: InputDecoration(
                                        constraints: BoxConstraints(),
                                        contentPadding: EdgeInsets.zero,
                                        labelStyle: TextStyle(
                                          color: ColorSystem.greyDark,
                                          fontSize: 16,
                                        ),
                                        focusedBorder:
                                            UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 1,
                                          ),
                                        ),
                                        suffixIconColor: ColorSystem.secondary,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            cartBloc.add(
                                                UpdateObscureCardNumber(
                                                    value: !widget.cartState
                                                        .obscureCardNumber));
                                          },
                                          icon: Icon(
                                              widget.cartState.obscureCardNumber
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color: ColorSystem.secondary),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorSystem.greyDark,
                                            width: 1,
                                          ),
                                        ),
                                        labelText: 'Card number',
                                        hintText: '**** **** **** ****',
                                      ),
                                      cardHolderDecoration:
                                          InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        labelStyle: TextStyle(
                                          color: ColorSystem.greyDark,
                                          fontSize: 16,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 1,
                                          ),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorSystem.greyDark,
                                            width: 1,
                                          ),
                                        ),
                                        labelText: 'Cardholder name',
                                      ),
                                      amountDecoration: InputDecoration(
                                        constraints: BoxConstraints(),
                                        counterText: "",
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 0),
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
                                        labelText: 'Enter Amount',
                                      ),
                                      expiryDateDecoration:
                                          InputDecoration(
                                        constraints: BoxConstraints(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 0),
                                        labelStyle: TextStyle(
                                          color: ColorSystem.greyDark,
                                          fontSize: 16,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 1,
                                          ),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorSystem.greyDark,
                                            width: 1,
                                          ),
                                        ),
                                        labelText: 'Expiry Date',
                                        hintText: '  /  ',
                                      ),
                                      cvvCodeDecoration: InputDecoration(
                                        constraints: BoxConstraints(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 0),
                                        labelStyle: TextStyle(
                                          color: ColorSystem.greyDark,
                                          fontSize: 16,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 1,
                                          ),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorSystem.greyDark,
                                            width: 1,
                                          ),
                                        ),
                                        labelText: 'CVV',
                                        hintText: '***',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Material(
                          clipBehavior: Clip.hardEdge,
                          type: MaterialType.card,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                          child: DottedBorder(
                            color: Colors.black,
                            strokeWidth: 2,
                            dashPattern: [8, 2],
                            radius: Radius.circular(12),
                            borderType: BorderType.RRect,
                            child: Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width * 0.9,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 30.0, horizontal: 40),
                                child: Center(
                                  child: Text(
                                    " + Add Payment Method",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: kRubik),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.17,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}
