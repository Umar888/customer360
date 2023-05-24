import 'dart:ui';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/approval_process_bloc/approval_process_bloc.dart';
import 'package:gc_customer_app/bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/common_widgets/bottom_navigation_bar.dart';
import 'package:gc_customer_app/data/reporsitories/approval_process_repository/approval_process_repository.dart';
import 'package:gc_customer_app/data/reporsitories/customer_look_up_repository/customer_lookup_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/input_field_with_validations.dart';
import 'package:gc_customer_app/models/approval_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/customer_look_up/create_new_customer_screen.dart';
import 'package:gc_customer_app/screens/customer_look_up/customer_details_card.dart';
import 'package:gc_customer_app/screens/customer_look_up/search_by_name_screen.dart';
import 'package:gc_customer_app/screens/notification/notification_screen.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/formatter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as plb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlb;

import '../landing_screen/landing_screen_page.dart';

class CustomerLookUpWidget extends StatefulWidget {
  final bool isNoUser;
  CustomerLookUpWidget({Key? key, this.isNoUser = false}) : super(key: key);

  @override
  State<CustomerLookUpWidget> createState() => _CustomerLookUpWidgetState();
}

class _CustomerLookUpWidgetState extends State<CustomerLookUpWidget> {
  late CustomerLookUpBloc customerLookUpBloc;

  String email = '';

  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // if (!kIsWeb)
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'CustomerLookup');
    context.read<ApprovalProcessBloC>().add(LoadApprovalProcess());
    customerLookUpBloc = context.read<CustomerLookUpBloc>();
    phoneNumberController.addListener(() {
      var phone = phoneNumberController.text;
      phone = phone.replaceFirst('(', '');
      phone = phone.replaceFirst(')', '');
      phone = phone.replaceFirst(' ', '');
      phone = phone.replaceFirst('-', '');
      if (phone.length == 10) {
        EasyDebounce.debounce(
            'search_name_debounce', Duration(milliseconds: 800), () {
          customerLookUpBloc.add(LoadLookUpData(phone, SearchType.phone));
        });
      }
      if (phone.isEmpty) customerLookUpBloc.add(ClearData());
    });

    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email)) {
          customerLookUpBloc.add(LoadLookUpData(email, SearchType.email));
        }
      }
    });

    emailController.addListener(() {
      if (emailController.text.isEmpty) customerLookUpBloc.add(ClearData());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  kIsWeb ? SizedBox.shrink() : _closeButton(),
                  Expanded(
                    child: Card(
                      shape: kIsWeb
                          ? null
                          : RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(SizeSystem.size32),
                                  topRight:
                                      Radius.circular(SizeSystem.size32))),
                      borderOnForeground: !kIsWeb,
                      elevation: kIsWeb ? 0 : 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 32),
                        child: BlocBuilder<CustomerLookUpBloc,
                            CustomerLookUpState>(builder: (context, state) {
                          List<UserProfile>? customers;
                          SearchType? type;
                          if (state is CustomerLookUpSuccess) {
                            customers = state.users ?? [];
                            type = state.type;
                          }

                          return ListView(
                            physics: ClampingScrollPhysics(),
                            children: [
                              _title(),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _phoneEmailInput(customers, type),
                                  if ((customers ?? []).isNotEmpty)
                                    ListView.builder(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: customers!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return CustomerDetailsCard(
                                          isNameSearch: false,
                                          onTap: () async {},
                                          customer: customers![index],
                                        );
                                      },
                                    ),
                                ],
                              ),
                              if ((customers ?? []).isEmpty && !kIsWeb)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(24, 30, 24, 10),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.resolveWith<
                                              RoundedRectangleBorder>(
                                          (states) => RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                                  MaterialState.pressed) ||
                                              !states.contains(
                                                  MaterialState.disabled)) {
                                            return Theme.of(context)
                                                .primaryColor;
                                          } else if (states.contains(
                                              MaterialState.disabled)) {
                                            return Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1);
                                          }
                                          return Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1);
                                        },
                                      ),
                                    ),
                                    onPressed: (customers != null &&
                                            customers.isEmpty)
                                        ? () async {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        BlocProvider<
                                                            CustomerLookUpBloc>(
                                                          create: (context) =>
                                                              CustomerLookUpBloc(
                                                                  CustomerLookUpRepository()),
                                                          child:
                                                              CreateNewCustomerScreen(
                                                            phoneText:
                                                                phoneNumberController
                                                                    .text,
                                                            emailText:
                                                                emailController
                                                                    .text,
                                                          ),
                                                        ))).then((value) {
                                              if (value == true) {
                                                if (kIsWeb) {
                                                  context
                                                      .read<LandingScreenBloc>()
                                                      .add(LoadData());
                                                } else {
                                                  context
                                                      .read<
                                                          InventorySearchBloc>()
                                                      .add(SetCart(
                                                          itemOfCart: [],
                                                          records: [],
                                                          orderId: ''));
                                                  Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                          settings: RouteSettings(
                                                              name:
                                                                  'CustomerLandingScreen'),
                                                          builder: (context) =>
                                                              CustomerLandingScreen()));
                                                  setState(() {
                                                    phoneNumberController
                                                        .clear();
                                                    emailController.clear();
                                                    customerLookUpBloc
                                                        .add(ClearData());
                                                  });
                                                }
                                              }
                                            });
                                          }
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '+ADD NEW CUSTOMER',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: SizeSystem.size18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if ((customers ?? []).isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  BlocProvider<
                                                      CustomerLookUpBloc>(
                                                    create: (context) =>
                                                        CustomerLookUpBloc(
                                                            CustomerLookUpRepository()),
                                                    child: SearchByNameScreen(),
                                                  ))).then((value) {
                                        if (value == true) {
                                          if (kIsWeb) {
                                            context
                                                .read<LandingScreenBloc>()
                                                .add(LoadData());
                                            context
                                                .read<LandingScreenBloc>()
                                                .add(LoadFavoriteBrands());
                                          } else {
                                            context
                                                .read<InventorySearchBloc>()
                                                .add(SetCart(
                                                    itemOfCart: [],
                                                    records: [],
                                                    orderId: ''));
                                            // Navigator.of(context).push(
                                            //     CupertinoPageRoute(
                                            //         settings: RouteSettings(
                                            //             name:
                                            //                 'CustomerLandingScreen'),
                                            //         builder: (context) =>
                                            //             CustomerLandingScreen()));
                                            setState(() {
                                              phoneNumberController.clear();
                                              emailController.clear();
                                              customerLookUpBloc
                                                  .add(ClearData());
                                            });
                                          }
                                        }
                                      });
                                    },
                                    focusColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            hintText: 'Search Name',
                                            hintStyle: TextStyle(
                                              color: ColorSystem.secondary,
                                              fontSize: SizeSystem.size18,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 70),
                                        Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text(
                                            'v 1.6.2',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: SizeSystem.size20,
                                              fontFamily: kRubik,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!kIsWeb)
            Align(
              alignment: Alignment.bottomCenter,
              child: BlocProvider.value(
                value: context.read<LandingScreenBloc>(),
                child: AppBottomNavBar(
                    CustomerInfoModel(records: [Records(id: null)]),
                    null,
                    null,
                    context.read<InventorySearchBloc>(),
                    context.read<plb.ProductDetailBloc>(),
                    context.read<zlb.ZipStoreListBloc>(),
                    false,
                    true),
              ),
            )
        ],
      ),
    );
  }

  Widget _closeButton() => InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(bottom: 24),
          child: Icon(
            Icons.close,
            size: 28,
          ),
        ),
      );

  Widget _phoneEmailInput(List<UserProfile>? customers, SearchType? type) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: GuitarCentreInputField(
            focusNode: phoneFocusNode,
            textEditingController: phoneNumberController,
            label: 'Phone',
            hintText: '(123) 456-7890',
            textInputType: TextInputType.number,
            inputFormatters: [PhoneInputFormatter(mask: '(###) ###-####')],
            leadingIcon: IconSystem.phone,
            errorText: (customers ?? []).isEmpty && type == SearchType.phone
                ? 'No data found.'
                : null,
            suffixIcon: customers != null && type == SearchType.phone
                ? customers.isNotEmpty
                    ? SvgPicture.asset(
                        IconSystem.checkmark,
                        package: 'gc_customer_app',
                        color: ColorSystem.additionalGreen,
                        height: 24,
                      )
                    : InkWell(
                        onTap: () {
                          phoneNumberController.clear();
                          customerLookUpBloc.add(ClearData());
                        },
                        child: Icon(
                          CupertinoIcons.clear,
                          color: ColorSystem.complimentary,
                        ),
                      )
                : SizedBox.shrink(),
          ),
        ),
        if (!((customers ?? []).isNotEmpty && type == SearchType.phone))
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: GuitarCentreInputField(
              focusNode: emailFocusNode,
              textEditingController: emailController,
              label: 'Email',
              hintText: 'abc@xyz.com',
              textInputType: TextInputType.emailAddress,
              leadingIcon: IconSystem.messageOutline,
              onChanged: (email) {
                EasyDebounce.cancelAll();
                if (RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(email)) {
                  EasyDebounce.debounce(
                      'search_name_debounce', Duration(milliseconds: 800), () {
                    customerLookUpBloc
                        .add(LoadLookUpData(email, SearchType.email));
                  });
                }
              },
              errorText: ((customers ?? []).isEmpty && type == SearchType.email)
                  ? 'No data found'
                  : null,
              suffixIcon: customers != null && type == SearchType.email
                  ? customers.isNotEmpty
                      ? SvgPicture.asset(
                          IconSystem.checkmark,
                          package: 'gc_customer_app',
                          color: ColorSystem.additionalGreen,
                          height: 24,
                        )
                      : InkWell(
                          onTap: () {
                            emailController.clear();
                            customerLookUpBloc.add(ClearData());
                          },
                          child: Icon(
                            CupertinoIcons.clear,
                            color: ColorSystem.complimentary,
                          ),
                        )
                  : SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  Widget _title() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 50),
              Text(
                'Customer',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: SizeSystem.size34,
                  fontFamily: kRubik,
                ),
              ),
              kIsWeb
                  ? SizedBox(width: 50)
                  : BlocBuilder<ApprovalProcessBloC, ApprovalProcessState>(
                      builder: (context, state) {
                      List<ApprovalModel> approvalModels = [];
                      if (state is ApprovalProcessSuccess) {
                        approvalModels = state.approvalModels ?? [];
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ));
                        },
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    color: Theme.of(context).primaryColor,
                                    IconSystem.notification,
                                    package: 'gc_customer_app',
                                  )),
                              if (approvalModels.length > 0)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 16,
                                    width: 16,
                                    margin: EdgeInsets.only(top: 4, right: 4),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorSystem.pureRed,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color.fromARGB(
                                                  115, 232, 16, 27),
                                              blurRadius: 10,
                                              offset: Offset(0, 6))
                                        ]),
                                    child: Center(
                                      child: Text(
                                        approvalModels.length.toString(),
                                        style: TextStyle(
                                            color: ColorSystem.white,
                                            fontFamily: kRubik,
                                            fontSize: 10),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    })
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 30),
            child: Text(
              'Please enter a phone number/email/name to search a customer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: SizeSystem.size16),
            ),
          ),
        ],
      );
}
