part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PageLoad extends CartEvent {
  final String orderID;
  final cim.CustomerInfoModel customerId;
  final InventorySearchBloc inventorySearchBloc;

  PageLoad({required this.customerId,required this.orderID, required this.inventorySearchBloc});

  @override
  List<Object> get props => [customerId,orderID, inventorySearchBloc];
}

class ReloadCart extends CartEvent {
  final String orderID;
  bool smallLoading;
  String smallLoadingId;
  final InventorySearchBloc inventorySearchBloc;

  ReloadCart({required this.orderID, this.smallLoading = false, this.smallLoadingId = "", required this.inventorySearchBloc});

  @override
  List<Object> get props => [orderID, smallLoading, inventorySearchBloc];
}

class SaveAddressesData extends CartEvent {
  final bool isDefault;
  final AddressList addressModel;
  final String orderId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  SaveAddressesData(
      {required this.addressModel,
      required this.isDefault,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.orderId});

  @override
  List<Object> get props => [isDefault, addressModel, orderId, firstName, lastName, email, phone];
}

class FetchShippingMethods extends CartEvent {
  final String orderId;
  final InventorySearchBloc inventorySearchBloc;

  FetchShippingMethods({required this.orderId, required this.inventorySearchBloc});

  @override
  List<Object> get props => [orderId, inventorySearchBloc];
}

class SetShippingCredential extends CartEvent {
  final GlobalKey<FormState> shippingFormKey;
  final String shippingFName;
  final String shippingLName;
  final String shippingPhone;
  final String shippingEmail;

  SetShippingCredential(
      {required this.shippingFormKey,
      required this.shippingFName,
      required this.shippingLName,
      required this.shippingPhone,
      required this.shippingEmail});

  @override
  List<Object> get props => [shippingFormKey, shippingFName, shippingLName, shippingPhone, shippingEmail];
}

class UpdateAddAddress extends CartEvent {
  final bool value;

  UpdateAddAddress({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateShowAddCard extends CartEvent {
  final bool value;

  UpdateShowAddCard({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateAddressDone extends CartEvent {
  final bool value;

  UpdateAddressDone({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateShowMessageField extends CartEvent {
  final bool value;

  UpdateShowMessageField({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateSubmitQuoteDone extends CartEvent {
  final bool value;

  UpdateSubmitQuoteDone({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateCurrentQuote extends CartEvent {
  final String value;

  UpdateCurrentQuote({required this.value});

  @override
  List<Object> get props => [value];
}

class SubmitQuote extends CartEvent {
  final String email;
  final String phone;
  final String expiration;
  final String subtotal;
  final String orderId;

  SubmitQuote({required this.email, required this.phone, required this.expiration, required this.subtotal, required this.orderId});

  @override
  List<Object> get props => [email, phone, expiration, subtotal, orderId];
}

class UpdateShowAmount extends CartEvent {
  final bool value;

  UpdateShowAmount({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateSaveAsDefaultAddress extends CartEvent {
  final bool value;

  UpdateSaveAsDefaultAddress({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateSameAsBilling extends CartEvent {
  final bool value;

  UpdateSameAsBilling({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateProceedingOrder extends CartEvent {
  final bool value;

  UpdateProceedingOrder({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateCompleteOrder extends CartEvent {
  final bool value;

  UpdateCompleteOrder({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateObscureCardNumber extends CartEvent {
  final bool value;

  UpdateObscureCardNumber({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateActiveStep extends CartEvent {
  final int value;

  UpdateActiveStep({required this.value});

  @override
  List<Object> get props => [value];
}

class SetSelectedAddress extends CartEvent {
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postalCode;

  SetSelectedAddress({required this.postalCode, required this.address1, required this.address2, required this.city, required this.state});

  @override
  List<Object> get props => [postalCode, address1, address2, city, state];
}

class UpdateAddCardAmount extends CartEvent {
  final String value;

  UpdateAddCardAmount({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdatePickUpZip extends CartEvent {
  final SearchStoreList searchStoreList;
  final SearchStoreListInformation searchStoreListInformation;
  final String orderID;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  UpdatePickUpZip(
      {required this.searchStoreList,
      required this.searchStoreListInformation,
      required this.orderID,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.phone});

  @override
  List<Object> get props => [searchStoreList, searchStoreListInformation, orderID];
}

class UpdateOrderUser extends CartEvent {
  final String orderId;
  final String accountId;
  final int index;
  final bool newCustomer;

  UpdateOrderUser({
    required this.index,
    this.newCustomer = false,
    required this.orderId,
    required this.accountId,
  });

  @override
  List<Object> get props => [orderId, newCustomer, accountId, index];
}

class UpdateLoadingScreen extends CartEvent {
  final bool value;

  UpdateLoadingScreen({required this.value});

  @override
  List<Object> get props => [value];
}

class AddInAddressModel extends CartEvent {
  final AddressList value;

  AddInAddressModel({required this.value});

  @override
  List<Object> get props => [value];
}

class AddInCreditCardModel extends CartEvent {
  final CreditCardModelSave value;

  AddInCreditCardModel({required this.value});

  @override
  List<Object> get props => [value];
}

class RemoveCreditCardModelSave extends CartEvent {
  final CreditCardModelSave value;

  RemoveCreditCardModelSave({required this.value});

  @override
  List<Object> get props => [value];
}

class ChangeAddressIsSelected extends CartEvent {
  ChangeAddressIsSelected();

  @override
  List<Object> get props => [];
}

class ChangeAddressIsSelectedWithAddress extends CartEvent {
  final AddressList addressModel;
  final String orderID;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int index;

  ChangeAddressIsSelectedWithAddress(
      {required this.addressModel,
      required this.orderID,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.index});

  @override
  List<Object> get props => [addressModel, orderID, index, firstName, lastName, email, phone];
}

class ChangeAddressFacing extends CartEvent {
  final int index;

  ChangeAddressFacing({required this.index});

  @override
  List<Object> get props => [index];
}

class ChangeRecommendedAddress extends CartEvent {
  final String address;
  final int index;
  final String orderID;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  ChangeRecommendedAddress(
      {required this.address,
      required this.orderID,
      required this.index,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.phone});

  @override
  List<Object> get props => [address, orderID, index, firstName, lastName, email, phone];
}

class ChangeDeliveryModelIsSelectedWithDelivery extends CartEvent {
  final DeliveryModel deliveryModel;
  final String orderId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  ChangeDeliveryModelIsSelectedWithDelivery(
      {required this.deliveryModel,
      required this.orderId,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.phone});

  @override
  List<Object> get props => [deliveryModel, orderId, firstName, lastName, email, phone];
}

class UpdateCardHolderName extends CartEvent {
  final String value;

  UpdateCardHolderName({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateCardNumber extends CartEvent {
  final String value;

  UpdateCardNumber({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateCardAmount extends CartEvent {
  final String value;

  UpdateCardAmount({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateExpiryYear extends CartEvent {
  final String value;

  UpdateExpiryYear({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateCvvCode extends CartEvent {
  final String value;

  UpdateCvvCode({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateExpiryMonth extends CartEvent {
  final String value;

  UpdateExpiryMonth({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateHeading extends CartEvent {
  final String value;

  UpdateHeading({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateState extends CartEvent {
  final String value;

  UpdateState({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateAddress extends CartEvent {
  final String value;

  UpdateAddress({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateZipCode extends CartEvent {
  final String value;

  UpdateZipCode({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateCity extends CartEvent {
  final String value;

  UpdateCity({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateSelectedState extends CartEvent {
  final String value;

  UpdateSelectedState({required this.value});

  @override
  List<Object> get props => [value];
}

class GetProductEligibility extends CartEvent {
  final String itemSKUId;

  GetProductEligibility({required this.itemSKUId});

  @override
  List<Object> get props => [itemSKUId];
}

class UpdateSelectedCity extends CartEvent {
  final String value;

  UpdateSelectedCity({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateNumberOfCartItems extends CartEvent {
  final String value;

  UpdateNumberOfCartItems({required this.value});

  @override
  List<Object> get props => [value];
}

class UpdateIsCvvFocused extends CartEvent {
  final bool value;

  UpdateIsCvvFocused({required this.value});

  @override
  List<Object> get props => [value];
}

class GetOverrideReasons extends CartEvent {
  GetOverrideReasons();

  @override
  List<Object> get props => [];
}

class GetShippingOverrideReasons extends CartEvent {
  GetShippingOverrideReasons();

  @override
  List<Object> get props => [];
}

class ClearWholeCart extends CartEvent {
  final List<Items> e;
  final String customerID;
  final String orderID;
  final InventorySearchBloc inventorySearchBloc;
  final void Function() onCompleted;

  ClearWholeCart({required this.customerID, required this.orderID, required this.e, required this.inventorySearchBloc, required this.onCompleted});

  @override
  List<Object> get props => [customerID, orderID, e, inventorySearchBloc, onCompleted];
}

class GetDeleteReasons extends CartEvent {
  GetDeleteReasons();

  @override
  List<Object> get props => [];
}

class GetRecommendedAddresses extends CartEvent {
  String orderId;
  String contactPointAddressId;
  String recordId;
  String address1;
  String address2;
  String city;
  String? label;
  String state;
  String postalCode;
  String country;
  bool isShipping;
  bool isBilling;
  int index;

  GetRecommendedAddresses(
      {required this.orderId,
      required this.recordId,
      required this.index,
      required this.address1,
      required this.address2,
      required this.city,
      required this.state,
      required this.postalCode,
      required this.country,
      required this.isShipping,
      required this.isBilling,
      this.label = "",
      this.contactPointAddressId = ""});

  @override
  List<Object> get props =>
      [orderId, recordId, index, address1, address2, city, label!, contactPointAddressId, state, postalCode, country, isShipping, isBilling];
}

class ClearRecommendedAddresses extends CartEvent {
  ClearRecommendedAddresses();

  @override
  List<Object> get props => [];
}

class HideRecommendedDialog extends CartEvent {
  HideRecommendedDialog();

  @override
  List<Object> get props => [];
}

class DeleteOrder extends CartEvent {
  final String orderId;
  final String reason;
  final InventorySearchBloc inventorySearchBloc;
  final void Function() onSuccess;

  DeleteOrder({required this.orderId, required this.reason, required this.inventorySearchBloc, required this.onSuccess});

  @override
  List<Object> get props => [orderId, reason, inventorySearchBloc, onSuccess];
}

class GetWarranties extends CartEvent {
  String skuEntId;
  int index;

  GetWarranties({required this.skuEntId, required this.index});

  @override
  List<Object> get props => [skuEntId, index];
}

class UpdateDeleteDone extends CartEvent {
  bool value;

  UpdateDeleteDone({required this.value});

  @override
  List<Object> get props => [value];
}

class EmptyMessage extends CartEvent {
  EmptyMessage();

  @override
  List<Object> get props => [];
}

class ChangeOverrideReason extends CartEvent {
  final String reason;

  ChangeOverrideReason({required this.reason});

  @override
  List<Object> get props => [reason];
}

class ClearOverrideReasonList extends CartEvent {
  ClearOverrideReasonList();

  @override
  List<Object> get props => [];
}

class ChangeDeleteReason extends CartEvent {
  final String reason;

  ChangeDeleteReason({required this.reason});

  @override
  List<Object> get props => [reason];
}

class ChangeWarranties extends CartEvent {
  final Warranties warranties;
  final String orderItem;
  final String warrantyId;
  final String orderID;
  final String warrantyName;
  final String warrantyPrice;
  final int index;
  final InventorySearchBloc inventorySearchBloc;

  ChangeWarranties(
      {required this.orderID,
      required this.warrantyId,
      required this.warrantyName,
      required this.warrantyPrice,
      required this.orderItem,
      required this.warranties,
      required this.inventorySearchBloc,
      required this.index});

  @override
  List<Object> get props => [orderID, warrantyId, warrantyName, warrantyPrice, warranties, orderItem, inventorySearchBloc];
}

class RemoveWarranties extends CartEvent {
  final Warranties warranties;
  final String orderItem;
  final String warrantyId;
  final String orderID;
  final String warrantyName;
  final String warrantyPrice;
  final int index;
  final InventorySearchBloc inventorySearchBloc;

  RemoveWarranties(
      {required this.orderID,
      required this.warrantyId,
      required this.warrantyName,
      required this.warrantyPrice,
      required this.orderItem,
      required this.warranties,
      required this.inventorySearchBloc,
      required this.index});

  @override
  List<Object> get props => [orderID, warrantyId, warrantyName, warrantyPrice, warranties, orderItem, inventorySearchBloc];
}

class ChangeIsOverridden extends CartEvent {
  final bool value;
  final Items item;

  ChangeIsOverridden({required this.value, required this.item});

  @override
  List<Object> get props => [value, item];
}

class ChangeIsExpanded extends CartEvent {
  final bool value;
  final Items item;

  ChangeIsExpanded({required this.value, required this.item});

  @override
  List<Object> get props => [value, item];
}

class ChangeIsExpandedBottomSheet extends CartEvent {
  final bool value;

  ChangeIsExpandedBottomSheet({required this.value});

  @override
  List<Object> get props => [value];
}

class AnimatedHide extends CartEvent {
  final bool value;

  AnimatedHide({required this.value});

  @override
  List<Object> get props => [value];
}

class SendOverrideReason extends CartEvent {
  final Items item;
  final String orderLineItemID;
  final String orderID;
  final String requestedAmount;
  final String selectedOverrideReasons;
  final String userID;
  final InventorySearchBloc inventorySearchBloc;
  final void Function() onCompleted;

  SendOverrideReason(
      {required this.item,
      required this.orderID,
      required this.orderLineItemID,
      required this.requestedAmount,
      required this.selectedOverrideReasons,
      required this.inventorySearchBloc,
      required this.userID,
        required this.onCompleted,
      });

  @override
  List<Object> get props => [item, orderID, orderLineItemID, requestedAmount, selectedOverrideReasons, userID, inventorySearchBloc, this.onCompleted];
}

class SendShippingOverrideReason extends CartEvent {
  final String orderID;
  final String requestedAmount;
  final String selectedOverrideReasons;
  final String userID;
  final void Function() onCompleted;

  SendShippingOverrideReason({required this.orderID, required this.requestedAmount, required this.selectedOverrideReasons, required this.userID, required this.onCompleted});

  @override
  List<Object> get props => [orderID, requestedAmount, selectedOverrideReasons, userID, onCompleted];
}

class ResetShippingOverrideReason extends CartEvent {
  final String orderID;
  final String userID;
  final void Function() onException;

  ResetShippingOverrideReason({required this.orderID, required this.userID, required this.onException});

  @override
  List<Object> get props => [orderID, userID, onException];
}

class RefreshShippingOverrideReason extends CartEvent {
  final String orderID;
  final void Function() onException;

  RefreshShippingOverrideReason({required this.orderID, required this.onException});

  @override
  List<Object> get props => [orderID, onException];
}

class ResetOverrideReason extends CartEvent {
  final Items item;
  final String orderLineItemID;
  final String orderID;
  final String requestedAmount;
  final String selectedOverrideReasons;
  final String userID;
  final InventorySearchBloc inventorySearchBloc;

  ResetOverrideReason(
      {required this.item,
      required this.orderID,
      required this.orderLineItemID,
      required this.requestedAmount,
      required this.selectedOverrideReasons,
      required this.inventorySearchBloc,
      required this.userID});

  @override
  List<Object> get props => [item, orderID, orderLineItemID, requestedAmount, selectedOverrideReasons, userID, inventorySearchBloc];
}

class AddToCart extends CartEvent {
  final Items records;
  final int quantity;
  final String customerID;
  final String orderID;
  final InventorySearchBloc inventorySearchBloc;

  AddToCart({this.quantity = -1, required this.records, required this.customerID, required this.orderID, required this.inventorySearchBloc});

  @override
  List<Object> get props => [quantity, records, customerID, orderID, inventorySearchBloc];
}

class UpdateWarranty extends CartEvent {
  final Warranties warranties;
  final String itemsId;

  UpdateWarranty({required this.warranties, required this.itemsId});

  @override
  List<Object> get props => [warranties, itemsId];
}

class RemoveFromCart extends CartEvent {
  final Items records;
  final int quantity;
  final String customerID;
  final String orderID;
  final InventorySearchBloc inventorySearchBloc;

  RemoveFromCart({this.quantity = -1, required this.records, required this.customerID, required this.orderID, required this.inventorySearchBloc});

  @override
  List<Object> get props => [quantity, records, customerID, orderID, inventorySearchBloc];
}

class AddCoupon extends CartEvent {
  final String orderId;
  final String couponId;

  AddCoupon({required this.couponId, required this.orderId});

  @override
  List<Object> get props => [couponId, couponId];
}

class RemoveCoupon extends CartEvent {
  final String orderId;

  RemoveCoupon({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class UpdateStateMessage extends CartEvent {
  UpdateStateMessage();

  @override
  List<Object> get props => [];
}

class NotifyContactIsMissing extends CartEvent {
  NotifyContactIsMissing();

  @override
  List<Object> get props => [];
}
