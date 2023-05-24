import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/common_widgets/cart_widgets/cart_item.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/views/flutter_credit_card.dart';
import 'package:gc_customer_app/models/address_models/delivery_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

class SummaryPaymentPage extends StatefulWidget {
  final CartState cartState;
  final Function onScroll;
  final String orderId;
  final String userId;
  final CustomerInfoModel customerInfoModel;
  SummaryPaymentPage(
      {super.key,
      required this.onScroll,
      required this.cartState,
      required this.orderId,
      required this.userId,
      required this.customerInfoModel});

  @override
  State<SummaryPaymentPage> createState() => _SummaryPaymentPageState();
}

class _SummaryPaymentPageState extends State<SummaryPaymentPage> {
  late CartBloc cartBloc;

  @override
  void initState() {
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'SummaryCartScreen');
    cartBloc = context.read<CartBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      color: ColorSystem.greyMild,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      IconSystem.cart,
                      package: 'gc_customer_app',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "In your cart",
                  style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).primaryColor,
                      fontFamily: kRubik),
                ),
                Spacer(),
                Text(
                  widget.cartState.orderDetailModel.first.items!.length
                      .toString(),
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                      fontFamily: kRubik),
                ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
            SizedBox(height: 20),
            (widget.cartState.orderDetailModel.isNotEmpty &&
                    widget.cartState.orderDetailModel[0] != null &&
                    widget.cartState.orderDetailModel[0].items != null &&
                    widget.cartState.orderDetailModel[0].items!.isNotEmpty)
                ? widget.cartState.orderDetailModel[0].items!
                        .where((element) => element.quantity! > 0)
                        .isNotEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.cartState.orderDetailModel[0].items!
                            .where((element) => element.quantity! > 0)
                            .map((e) {
                          return CartItem(
                            cartBloc: cartBloc,
                            userID: widget.userId,
                            customerInfoModel: widget.customerInfoModel,
                            orderLineItemID: e.itemId!,
                            orderID: widget.orderId,
                            items: e,
                          );
                        }).toList())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            IconSystem.noDataFound,
                            package: 'gc_customer_app',
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Text(
                            'NO ITEMS IN CART!',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: kRubik,
                              fontSize: 20,
                            ),
                          )
                        ],
                      )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        IconSystem.noDataFound,
                        package: 'gc_customer_app',
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        'NO ITEMS IN CART!',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: kRubik,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
            SizedBox(height: 170),
            // Material(
            //     borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(60),
            //         topRight: Radius.circular(60)),
            //     elevation: 10,
            //     shadowColor: ColorSystem.greyDark,
            //     borderOnForeground: true,
            //     type: MaterialType.card,
            //     clipBehavior: Clip.hardEdge,
            //     child: SizedBox(
            //       width: double.infinity,
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           Padding(
            //             padding: EdgeInsets.symmetric(
            //                 horizontal: 30.0, vertical: 0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 SizedBox(height: 40),
            //                 Row(
            //                   children: [
            //                     Container(
            //                       height: 60,
            //                       width: 60,
            //                       decoration: BoxDecoration(
            //                           color: ColorSystem.greyMild,
            //                           borderRadius: BorderRadius.circular(15)),
            //                       child: Padding(
            //                         padding: EdgeInsets.all(15.0),
            //                         child: SvgPicture.asset(
            //                           IconSystem.shipping,
            //                         ),
            //                       ),
            //                     ),
            //                     SizedBox(
            //                       width: 20,
            //                     ),
            //                     Text(
            //                       "Delivery",
            //                       style: TextStyle(
            //                           fontSize: 19,
            //                           fontWeight: FontWeight.w700,
            //                           color: Color(0xFF222222),
            //                           fontFamily: kRubik),
            //                     ),
            //                     Spacer(),
            //                     Text(
            //                       r"+ $"
            //                       "${widget.cartState.deliveryModels.firstWhere(
            //                             (element) => element.isSelected!,
            //                             orElse: () => DeliveryModel(
            //                                 address: '', price: ''),
            //                           ).price}",
            //                       style: TextStyle(
            //                           fontSize: 20,
            //                           fontWeight: FontWeight.w700,
            //                           color: Color(0xFF222222),
            //                           fontFamily: kRubik),
            //                     ),
            //                     SizedBox(
            //                       width: 20,
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(height: 20),
            //                 Text(
            //                     widget.cartState.addressModel
            //                         .firstWhere(
            //                             (element) => element.isSelected!)
            //                         .addressLabel!,
            //                     style: TextStyle(
            //                         fontSize: 20,
            //                         fontWeight: FontWeight.w600,
            //                         color: Color(0xFF222222),
            //                         fontFamily: kRubik)),
            //                 SizedBox(height: 15),
            //                 Text(
            //                     "${widget.cartState.addressModel.firstWhere((element) => element.isSelected!).address1!},",
            //                     style: TextStyle(
            //                         fontSize: 17,
            //                         fontWeight: FontWeight.w400,
            //                         color: Color(0xFF222222),
            //                         fontFamily: kRubik)),
            //                 Text(
            //                     "${widget.cartState.addressModel.firstWhere((element) => element.isSelected!).city!}, ${widget.cartState.addressModel.firstWhere((element) => element.isSelected!).state!}, ${widget.cartState.addressModel.firstWhere((element) => element.isSelected!).postalCode!}",
            //                     style: TextStyle(
            //                         fontSize: 17,
            //                         fontWeight: FontWeight.w400,
            //                         color: Color(0xFF222222),
            //                         fontFamily: kRubik)),
            //                 SizedBox(height: 20),
            //                 Container(
            //                   height: 60,
            //                   decoration: BoxDecoration(
            //                       color: ColorSystem.greyMild,
            //                       borderRadius: BorderRadius.circular(15)),
            //                   child: Padding(
            //                     padding: EdgeInsets.all(10.0),
            //                     child: Row(
            //                       mainAxisAlignment:
            //                           MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         Text(
            //                           widget.cartState.deliveryModels
            //                                       .firstWhere(
            //                                         (element) =>
            //                                             element.isSelected!,
            //                                         orElse: () => DeliveryModel(
            //                                             address: '',
            //                                             price: '',
            //                                             type: ''),
            //                                       )
            //                                       .type! ==
            //                                   "Pick-up"
            //                               ? "${widget.cartState.deliveryModels.firstWhere(
            //                                     (element) =>
            //                                         element.isSelected!,
            //                                     orElse: () => DeliveryModel(
            //                                         address: '', price: ''),
            //                                   ).type!} @ ${widget.cartState.pickUpZip}"
            //                               : widget.cartState.deliveryModels
            //                                   .firstWhere(
            //                                     (element) =>
            //                                         element.isSelected!,
            //                                     orElse: () => DeliveryModel(
            //                                         address: '',
            //                                         price: '',
            //                                         type: ''),
            //                                   )
            //                                   .type!,
            //                           style: TextStyle(
            //                               fontSize: 18,
            //                               fontWeight: FontWeight.w500,
            //                               color: Color(0xFF222222),
            //                               fontFamily: kRubik),
            //                         ),
            //                         SizedBox(
            //                           width: 20,
            //                         ),
            //                         Flexible(
            //                           child: Text(
            //                             widget.cartState.deliveryModels
            //                                 .firstWhere(
            //                                   (element) => element.isSelected!,
            //                                   orElse: () =>
            //                                       DeliveryModel(time: ''),
            //                                 )
            //                                 .time!,
            //                             style: TextStyle(
            //                                 fontSize: 18,
            //                                 fontWeight: FontWeight.w500,
            //                                 color: Color(0xFF222222),
            //                                 fontFamily: kRubik),
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 20),
            //               ],
            //             ),
            //           ),
            //           Material(
            //               borderRadius: BorderRadius.only(
            //                   topLeft: Radius.circular(60),
            //                   topRight: Radius.circular(60)),
            //               elevation: 10,
            //               shadowColor: ColorSystem.greyDark,
            //               borderOnForeground: true,
            //               type: MaterialType.card,
            //               color: ColorSystem.culturedGrey,
            //               clipBehavior: Clip.hardEdge,
            //               child: SizedBox(
            //                 width: double.infinity,
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   mainAxisAlignment: MainAxisAlignment.start,
            //                   children: [
            //                     SizedBox(height: 30),
            //                     Padding(
            //                       padding: EdgeInsets.symmetric(
            //                           horizontal: 25.0),
            //                       child: Row(
            //                         children: [
            //                           Container(
            //                             height: 60,
            //                             width: 60,
            //                             decoration: BoxDecoration(
            //                                 color: ColorSystem.greyMild,
            //                                 borderRadius:
            //                                     BorderRadius.circular(15)),
            //                             child: Padding(
            //                               padding: EdgeInsets.all(15.0),
            //                               child: Image.asset(
            //                                   IconSystem.creditCard),
            //                             ),
            //                           ),
            //                           SizedBox(
            //                             width: 20,
            //                           ),
            //                           Text(
            //                             "Payment",
            //                             style: TextStyle(
            //                                 fontSize: 19,
            //                                 fontWeight: FontWeight.w700,
            //                                 color: Color(0xFF222222),
            //                                 fontFamily: kRubik),
            //                           ),
            //                           SizedBox(
            //                             width: 20,
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                     SizedBox(height: 20),
            //                     Padding(
            //                       padding: EdgeInsets.symmetric(
            //                           horizontal: 15.0),
            //                       child: Column(
            //                         children: widget
            //                             .cartState.creditCardModelSave
            //                             .map((e) {
            //                           return Stack(
            //                             children: [
            //                               Padding(
            //                                 padding: EdgeInsets.only(
            //                                     top: 15.0),
            //                                 child: CreditCardWidget(
            //                                   obscureCardNumber: true,
            //                                   showChip: false,
            //                                   showAmount: false,
            //                                   amount:
            //                                       (e.paymentMethod?.amount ??
            //                                           '0.0'),
            //                                   obscureCardCvv: false,
            //                                   isHolderNameVisible: true,
            //                                   isSwipeGestureEnabled: true,
            //                                   height: 200,
            //                                   width: MediaQuery.of(context)
            //                                       .size
            //                                       .width,
            //                                   backgroundImage:
            //                                       "assets/icons/credit_card_background.png",
            //                                   glassmorphismConfig: null,
            //                                   cardHolderName: e.cardHolderName,
            //                                   expiryYear: e.expiryYear,
            //                                   expiryMonth: e.expiryMonth,
            //                                   cardNumber: e.cardNumber,
            //                                   cvvCode: e.cvvCode,
            //                                   showBackView: e.isCvvFocused,
            //                                   onCreditCardWidgetChange:
            //                                       (CreditCardBrand) {},
            //                                 ),
            //                               ),
            //                               Positioned(
            //                                   right: 5,
            //                                   child: Container(
            //                                     decoration: BoxDecoration(
            //                                         border: Border.all(),
            //                                         color: Theme.of(context).primaryColor,
            //                                         borderRadius:
            //                                             BorderRadius.circular(
            //                                                 30)),
            //                                     child: Padding(
            //                                       padding:
            //                                           EdgeInsets.only(
            //                                               left: 10.0,
            //                                               top: 5,
            //                                               bottom: 5,
            //                                               right: 20),
            //                                       child: Text(
            //                                         r"$ " +
            //                                             (e.paymentMethod
            //                                                     ?.amount ??
            //                                                 '0.0'),
            //                                         style: TextStyle(
            //                                             color: Colors.white,
            //                                             fontWeight:
            //                                                 FontWeight.w700,
            //                                             fontFamily: kRubik,
            //                                             fontSize: 18),
            //                                       ),
            //                                     ),
            //                                   ))
            //                             ],
            //                           );
            //                         }).toList(),
            //                       ),
            //                     ),
            //                     SizedBox(height: 30),
            //                   ],
            //                 ),
            //               )),
            //         ],
            //       ),
            //     )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.14,
            )
          ],
        ),
      ),
    ));
  }
}
