import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/models/address_models/delivery_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

class DeliveryPanelWidget extends StatelessWidget {
  final CartState cartState;
  final bool isDeliveryExpand;
  final Function onTapEdit;
  DeliveryPanelWidget(
      {super.key,
      required this.cartState,
      required this.isDeliveryExpand,
      required this.onTapEdit});

  @override
  Widget build(BuildContext context) {
    var selectedAddress =
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
    var selectedDelivery =
        cartState.deliveryModels.firstWhere((dm) => dm.isSelected == true);
    bool isApproved =
        cartState.orderDetailModel[0].approvalRequest! == "Approved";
    String shippingAndHandlingPrice =
        cartState.orderDetailModel[0].shippingAndHandling!.toStringAsFixed(2);
    if (isApproved) {
      shippingAndHandlingPrice =
          (cartState.orderDetailModel[0].shippingAndHandling! -
                  cartState.orderDetailModel[0].shippingAdjustment!)
              .toStringAsFixed(2);
    }
    return Container(
      height: 370,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(26, 45, 49, 66),
                blurRadius: 30,
                offset: Offset(0, -5))
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                    color: ColorSystem.greyMild,
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    IconSystem.shipping,
                    package: 'gc_customer_app',
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delivery",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                        InkWell(
                          onTap: () {
                            onTapEdit();
                            context
                                .read<CartBloc>()
                                .add(UpdateActiveStep(value: 1));
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 3),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: ColorSystem.lavender,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: ColorSystem.lavender),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                    if (!isDeliveryExpand)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (selectedDelivery.type
                                        ?.toLowerCase()
                                        .contains('pick-up') ??
                                    false)
                                ? 'Pick-up'
                                : selectedAddress != null
                                    ? (selectedAddress.address1 ?? '')
                                    : 'Pick-up',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik),
                          ),
                          Text(
                            (selectedDelivery.type
                                        ?.toLowerCase()
                                        .contains('pick-up') ??
                                    false)
                                ? '${selectedDelivery.time ?? '0'} miles'
                                : '\$$shippingAndHandlingPrice',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                                fontFamily: kRubik),
                          ),
                        ],
                      )
                  ],
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
          if (isDeliveryExpand)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (selectedDelivery.type
                                    ?.toLowerCase()
                                    .contains('pick-up') ??
                                false)
                            ? 'Pick-up'
                            : '',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik,
                            fontSize: 16),
                      ),
                      Text(
                        selectedDelivery.isPickup == true
                            ? '${selectedDelivery.time ?? ''} miles'
                            : '\$$shippingAndHandlingPrice',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    selectedDelivery.isPickup == true
                        ? '${selectedDelivery.name ?? ''}\n${selectedDelivery.pickupAddress}'
                        : selectedAddress != null
                            ? '${selectedAddress.address1},\n${(selectedAddress.address2 ?? '').isEmpty ? '' : '${selectedAddress.address2}, '}${selectedAddress.city}, ${selectedAddress.state}, ${selectedAddress.postalCode}'
                            : '${selectedDelivery.name ?? ''}\n${selectedDelivery.pickupAddress}',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik,
                        height: 1.3,
                        fontSize: 16),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFFF9FAFB),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cartState.deliveryModels.firstWhere(
                                (element) => element.isSelected!,
                                orElse: () => DeliveryModel(address: ''),
                              ).type}',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                        Text(
                          '\$$shippingAndHandlingPrice',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                              fontFamily: kRubik),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
