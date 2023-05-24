import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/address_bloc/address_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/intermediate_widgets/recommend_address_dialog.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/profile/addresses/add_address_bottom_sheet.dart';
import 'package:gc_customer_app/screens/profile/addresses/address_widget.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

class Addresses extends StatefulWidget {
  final BoxConstraints constraints;
  final UserProfile? userProfile;
  Addresses(this.constraints, {Key? key, this.userProfile})
      : super(key: key);

  @override
  State<Addresses> createState() => _AddressesState();
}

class _AddressesState extends State<Addresses> {
  late AddressBloc addressBloc;

  @override
  void initState() {
    super.initState();
    addressBloc = context.read<AddressBloc>();
    addressBloc.add(LoadAddressesData());
    addressBloc.stream.listen((state) {
      if (state is AddressProgress && state.isShowDialog == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => RecommendAddressDialog(
              enteredAddress: state.enteredAddress!,
              recommendAddress: state.recommendAddress!),
        ).then((value) {
          var selectAddress =
              value == true ? state.recommendAddress : state.enteredAddress;
          addressBloc.add(SaveAddressesData(
              isDefault: state.isDefault ?? false,
              addressModel: AddressList(
                  address1: selectAddress?.addressline1 ?? '',
                  address2: selectAddress?.addressline2 ?? '',
                  addressLabel: state.addressLabel ?? '',
                  city: selectAddress?.city ?? '',
                  state: selectAddress?.state ?? '',
                  country: 'US',
                  postalCode: selectAddress?.postalcode ?? '',
                  contactPointAddressId: state.contactPointId ?? '',
                  isPrimary: state.isPrimary)));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    double addressWidth = kIsWeb ? 180 : (widget.constraints.maxWidth - 48) / 2;
    double widgetHeight = addressWidth / 1.54;
    return Container(
      margin: EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addressestxt,
            style: textTheme.headline2?.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 12),
          Container(
            height: widgetHeight + 55,
            child: BlocBuilder<AddressBloc, AddressState>(
                builder: (context, state) {
              List<AddressList> addresses = [];
              if (state is AddressSuccess) {
                addresses = state.addresses ?? <AddressList>[];
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10, bottom: 30),
                children: [
                  if (widget.userProfile == null && !kIsWeb)
                    Padding(
                      padding: EdgeInsets.only(right: 12, bottom: 7),
                      child: InkWell(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          barrierColor: Color.fromARGB(25, 92, 106, 196),
                          isScrollControlled: true,
                          builder: (context) {
                            return AddAddressBottomSheet();
                          },
                        ),
                        child: DottedBorder(
                          dashPattern: [5, 5],
                          borderType: BorderType.RRect,
                          color: ColorSystem.black,
                          radius: Radius.circular(15),
                          child: Container(
                            height: widgetHeight,
                            width: addressWidth / 2.76,
                            alignment: Alignment.center,
                            child: Icon(Icons.add),
                          ),
                        ),
                      ),
                    ),
                  if (state is AddressProgress)
                    SizedBox(
                      height: widgetHeight,
                      width: addressWidth,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ...addresses
                      .map<Widget>((ad) => Container(
                            height: 120,
                            width: addressWidth,
                            margin: EdgeInsets.only(right: 12, bottom: 8),
                            child: AddressWidget(
                              address: ad,
                              isDefault:
                                  ad.hashCode == addresses.first.hashCode,
                            ),
                          ))
                      .toList()
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}
