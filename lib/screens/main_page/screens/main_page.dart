import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/approval_process_bloc/approval_process_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as plb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlb;
import 'package:gc_customer_app/data/reporsitories/approval_process_repository/approval_process_repository.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/repositories/auth/repository/authentication_repository.dart';
import 'package:gc_customer_app/screens/cart/views/cart_page.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_page.dart';
import 'package:gc_customer_app/screens/notification/approval_web_view.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/routes/cart_page_arguments.dart';
import 'package:get/get.dart';

import '../../../bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import '../../../bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import '../../../common_widgets/bottom_navigation_bar.dart';
import '../../../data/reporsitories/customer_look_up_repository/customer_lookup_repository.dart';
import '../../../models/landing_screen/customer_info_model.dart';
import '../../../primitives/color_system.dart';
import '../../../primitives/size_system.dart';
import '../../../repositories/auth/bloc/authentication_bloc.dart';
import '../../../services/deeplinking/deeplinks.dart';
import '../../../services/okta/auth_okta_service.dart';
import '../../../services/okta/okta_auth_provider.dart';
import '../../customer_look_up/customer_lookup_widget.dart';

class MainPage extends StatefulWidget {
  AuthenticationRepository authenticationRepository;
  AuthenticationStatus authenticationStatus;
  final Map<String, dynamic>? notificationMessage;
  final Map<String, String>? deeplinkMessage;
  MainPage(
      {Key? key,
      required this.authenticationRepository,
      required this.deeplinkMessage,
      required this.authenticationStatus,
      this.notificationMessage})
      : super(key: key);
  static Route route(AuthenticationRepository authenticationRepository,
      AuthenticationStatus authenticationStatus,
      {Map<String, dynamic>? notificationMessage,
        Map<String, String>? deeplinkMessage}) {
    return MaterialPageRoute<void>(
        builder: (_) => MainPage(
            deeplinkMessage: deeplinkMessage,
            notificationMessage: notificationMessage,
            authenticationRepository: authenticationRepository,
            authenticationStatus: authenticationStatus));
  }

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late LandingScreenBloc landingScreenBloc;
  late InventorySearchBloc inventorySearchBloc;
  late plb.ProductDetailBloc productDetailBloc;
  late zlb.ZipStoreListBloc zipStoreListBloc;
  late AppBottomNavBar bottomBar;

  @override
  Widget build(BuildContext context) {
    return _handleNoCustomerData();
  }

  bool isLogging = true;

  Future<void> performLogin() async {
    setState(() => isLogging = true);
    if (widget.authenticationStatus == AuthenticationStatus.unauthenticated) {
      Future.delayed(Duration(milliseconds: 1000), () async {
        AuthenticationStatus currentAuthenticationStatus =
            await widget.authenticationRepository.socialLogin(context);
        setState(() => isLogging = false);
        if(currentAuthenticationStatus == AuthenticationStatus.authenticated){
          if (widget.notificationMessage == null &&
              (widget.deeplinkMessage == null ||
                  !widget.deeplinkMessage!.containsKey("id"))){
            bottomBar.showCustomerLookup(context);
          }
          else{
            print("widget.notificationMessage ${widget.notificationMessage}");
            print("widget.deeplinkMessage ${widget.deeplinkMessage}");
            print("!widget.deeplinkMessage!.containsKey() ${!widget.deeplinkMessage!.containsKey("id")}");

            if (widget.deeplinkMessage != null){
              Map<String ,String> map = widget.deeplinkMessage??{};
              if(map.containsKey("id") && map["id"] != null){
                redirectApp(map);
              }
              else{
                print("widget.deeplinkMessage id is null");
                if (widget.notificationMessage != null) {
                  _handleOnClickNotification();
                }
              }
            }
            else{
              if (widget.notificationMessage != null) {
                _handleOnClickNotification();
              }
            }
          }
        }
      });
    }
  }

  redirectApp(Map<String, String> map) async {
    String id = map["id"]??"";
    String name = map["name"]??"";
    String email = map["email"]??"";
    String phone = map["phone"]??"";

    await SharedPreferenceService().setKey(key: agentId, value: id);
    await SharedPreferenceService().setKey(key: savedAgentName, value: name);
    await SharedPreferenceService().setKey(key: agentEmail, value: email);
    await SharedPreferenceService().setKey(key: agentPhone, value: phone);
    context.read<InventorySearchBloc>()
        .add(SetCart(itemOfCart: [], records: [], orderId: ''));

    Navigator.of(context).push(
        CupertinoPageRoute(
            settings: RouteSettings(name: 'CustomerLandingScreen'),
            builder: (context) => CustomerLandingScreen(appName: "Smart Trigger")));

  }
  @override
  void initState()  {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    landingScreenBloc = context.read<LandingScreenBloc>();
    inventorySearchBloc = context.read<InventorySearchBloc>();
    productDetailBloc = context.read<plb.ProductDetailBloc>();
    zipStoreListBloc = context.read<zlb.ZipStoreListBloc>();
    bottomBar = AppBottomNavBar(CustomerInfoModel(records: [Records(id: null)]),
        null, null, inventorySearchBloc, productDetailBloc, zipStoreListBloc);


        if (context.read<AuthenticationBloc>().state.isLoggedIn && !kIsWeb) {
          if (widget.notificationMessage == null &&
              (widget.deeplinkMessage == null ||
              !widget.deeplinkMessage!.containsKey("id"))){
            bottomBar.showCustomerLookup(context);
          }
          else{
            print("widget.notificationMessage ${widget.notificationMessage}");
            print("widget.deeplinkMessage ${widget.deeplinkMessage}");
            print("!widget.deeplinkMessage!.containsKey() ${!widget.deeplinkMessage!.containsKey("id")}");
            if (widget.deeplinkMessage != null){
              Map<String ,String> map = widget.deeplinkMessage??{};
              if(map.containsKey("id") && map["id"] != null){
                redirectApp(map);
              }
              else{
                print("widget.deeplinkMessage id is null");
                if (widget.notificationMessage != null) {
                  _handleOnClickNotification();
                }
              }
            }
            else{
              if (widget.notificationMessage != null) {
                _handleOnClickNotification();
              }
            }
          }
        }
        else{
            if (!kIsWeb) {
             performLogin();
            }
        }
  }

  Widget _handleNoCustomerData() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: isLogging?3:2,
            ),
            Text(
              isLogging
                  ? ''
                  : context.read<AuthenticationBloc>().state.isLoggedIn
                      ? 'Initiate'
                      : 'Associate Not Found',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline3?.copyWith(
                  color: AppColors.redTextColor,
                  fontSize: isLogging?22:25,
                  fontWeight: isLogging?FontWeight.w500:FontWeight.bold),
            ),
            isLogging
                ? SizedBox(height: 30)
                : SizedBox.shrink(),
            isLogging?CircularProgressIndicator(color: AppColors.redTextColor):SizedBox.shrink(),

            context.read<AuthenticationBloc>().state.isLoggedIn
                ? SizedBox(height: 24)
                : SizedBox.shrink(),
            context.read<AuthenticationBloc>().state.isLoggedIn
                ? Text(
                    'Customer\nLookup',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                        color: AppColors.redTextColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  )
                : SizedBox.shrink(),
            context.read<AuthenticationBloc>().state.isLoggedIn
                ? SizedBox(height: 8)
                : SizedBox.shrink(),
            context.read<AuthenticationBloc>().state.isLoggedIn
                ? Text(
                    'OR',
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(fontSize: 20),
                  )
                : SizedBox.shrink(),
            context.read<AuthenticationBloc>().state.isLoggedIn
                ? SizedBox(height: 8)
                : SizedBox.shrink(),
            context.read<AuthenticationBloc>().state.isLoggedIn
                ? Text(
                    'Inventory\nLookup',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                        color: AppColors.redTextColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  )
                : SizedBox.shrink(),
            context.read<AuthenticationBloc>().state.isLoggedIn
                ? SizedBox(height: 8)
                : SizedBox.shrink(),
            context.read<AuthenticationBloc>().state.isLoggedIn
                ? SizedBox.shrink()
                : SizedBox.shrink(),
            // : Padding(
            //     padding: EdgeInsets.fromLTRB(24, 30, 24, 10),
            //     child: TextButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.resolveWith<
            //                 RoundedRectangleBorder>(
            //             (states) => RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(12))),
            //         backgroundColor:
            //             MaterialStateProperty.resolveWith<Color>(
            //           (Set<MaterialState> states) {
            //             if (states.contains(MaterialState.pressed) ||
            //                 !states.contains(MaterialState.disabled)) {
            //               return ColorSystem.complimentary;
            //             } else if (states
            //                 .contains(MaterialState.disabled)) {
            //               return ColorSystem.complimentary.withOpacity(0.1);
            //             }
            //             return ColorSystem.complimentary.withOpacity(0.1);
            //           },
            //         ),
            //       ),
            //       onPressed: isLoading
            //           ? () {}
            //           : () async {
            //               String token = '';
            //               var isAuthenticated =
            //                   await OktaAuthProvider.of(context)
            //                       ?.authService
            //                       .isAuthenticated();
            //               if (isAuthenticated == true) {
            //                 await OktaAuthProvider.of(context)
            //                     ?.authService
            //                     .revokeAccessToken();
            //                 await OktaAuthProvider.of(context)
            //                     ?.authService
            //                     .revokeIdToken();
            //                 await OktaAuthProvider.of(context)
            //                     ?.authService
            //                     .clearTokens();
            //                 await OktaAuthProvider.of(context)
            //                     ?.authService
            //                     .logout();
            //                 var checkAuth =
            //                     await OktaAuthProvider.of(context)
            //                         ?.authService
            //                         .isAuthenticated();
            //                 if (checkAuth == true) {
            //                   setState(() {});
            //                   ScaffoldMessenger.of(context)
            //                       .showSnackBar(const SnackBar(
            //                     content: Text('Logout Failed'),
            //                     duration: Duration(seconds: 2),
            //                   ));
            //                 } else {
            //                   setState(() {});
            //                   ScaffoldMessenger.of(context)
            //                       .showSnackBar(const SnackBar(
            //                     content: Text('Logout Successful'),
            //                     duration: Duration(seconds: 2),
            //                   ));
            //                 }
            //               } else {
            //                 setState(() => isLoading = true);
            //                 await widget.authenticationRepository
            //                     .socialLogin(context);
            //                 setState(() => isLoading = false);
            //               }
            //             },
            //       child: Padding(
            //         padding: EdgeInsets.all(8),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             StreamBuilder(
            //                 stream: OktaAuthProvider.of(context)
            //                     ?.authService
            //                     .isAuthenticatedStream(),
            //                 builder: (context, auth) {
            //                   return isLoading
            //                       ? CupertinoActivityIndicator(
            //                           color: Colors.white)
            //                       : Text(
            //                           auth.hasData
            //                               ? auth.data!
            //                                   ? "Logout"
            //                                   : "Login"
            //                               : "Please wait",
            //                           style: TextStyle(
            //                               color: ColorSystem.white,
            //                               fontSize: SizeSystem.size18),
            //                         );
            //                 }),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            Spacer(
              flex: 2,
            ),
            SafeArea(
              child: Text(
                'Version 1.6.2',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline3?.copyWith(
                    color: AppColors.redTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const SizedBox(height: 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: context.read<AuthenticationBloc>().state.isLoggedIn
          ? BlocProvider.value(
              value: landingScreenBloc,
              child: AppBottomNavBar(
                  CustomerInfoModel(records: [Records(id: null)]),
                  null,
                  null,
                  inventorySearchBloc,
                  productDetailBloc,
                  zipStoreListBloc),
            )
          : null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      var loggedInId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      ApprovalProcesssRepository()
          .getApproval(loggedInId)
          .then((approvals) async {
        if (await FlutterAppBadger.isAppBadgeSupported()) {
          if (approvals.isNotEmpty) {
            // FlutterAppBadger.updateBadgeCount(approvals.length);
          } else {
            FlutterAppBadger.removeBadge();
          }
        }
      });
    }

    super.didChangeAppLifecycleState(state);
  }

  Future<void> _handleOnClickNotification() async {
    var message = widget.notificationMessage!;
    if (message["approvalProcess"] != null &&
        message["approvalProcess"].toString().isNotEmpty) {
      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ApprovalWebViewWidget(url: message["approvalProcess"]),
            )).then((value) => bottomBar.showCustomerLookup(context));
      });
    } else if (message["recordId"] != null &&
        message["recordId"].isNotEmpty &&
        message["orderNo"] != null &&
        message["orderId"] != null) {
      String recordId = message['recordId'];
      String orderId = message['orderId'];
      String orderNumber = message['orderNo'];
      String? currentPath;
      Navigator.of(context).popUntil((route) {
        currentPath = route.settings.name;
        return true;
      });

      CustomerInfoModel customerInfoModel = await landingScreenBloc
          .landingScreenRepository
          .getCustomerInfoById(recordId);
      if (customerInfoModel.records!.isNotEmpty &&
          customerInfoModel.records!.first.id != null) {
        if (Get.currentRoute.contains("cartPage") ||
            (currentPath != null && currentPath!.contains("cartPage"))) {
          Navigator.pushReplacementNamed(
            context,
            CartPage.routeName,
            arguments: CartArguments(
              email: customerInfoModel.records![0].accountEmailC != null
                  ? customerInfoModel.records![0].accountEmailC!
                  : customerInfoModel.records![0].emailC != null
                      ? customerInfoModel.records![0].emailC!
                      : customerInfoModel.records![0].personEmail != null
                          ? customerInfoModel.records![0].personEmail!
                          : "",
              phone: customerInfoModel.records![0].accountPhoneC != null
                  ? customerInfoModel.records![0].accountPhoneC!
                  : customerInfoModel.records![0].phone != null
                      ? customerInfoModel.records![0].phone!
                      : customerInfoModel.records![0].phoneC != null
                          ? customerInfoModel.records![0].phoneC!
                          : "",
              orderId: orderId,
              orderNumber: orderNumber,
              orderLineItemId: orderNumber,
              orderDate: "",
              customerInfoModel: customerInfoModel,
              userName: customerInfoModel.records!.first.name!,
              userId: customerInfoModel.records!.first.id!,
            ),
          );
        } else {
          Navigator.pushNamed(
            context,
            CartPage.routeName,
            arguments: CartArguments(
              email: customerInfoModel.records![0].accountEmailC != null
                  ? customerInfoModel.records![0].accountEmailC!
                  : customerInfoModel.records![0].emailC != null
                      ? customerInfoModel.records![0].emailC!
                      : customerInfoModel.records![0].personEmail != null
                          ? customerInfoModel.records![0].personEmail!
                          : "",
              phone: customerInfoModel.records![0].accountPhoneC != null
                  ? customerInfoModel.records![0].accountPhoneC!
                  : customerInfoModel.records![0].phone != null
                      ? customerInfoModel.records![0].phone!
                      : customerInfoModel.records![0].phoneC != null
                          ? customerInfoModel.records![0].phoneC!
                          : "",
              orderId: orderId,
              orderNumber: orderNumber,
              orderLineItemId: orderNumber,
              orderDate: "",
              customerInfoModel: customerInfoModel,
              userName: customerInfoModel.records!.first.name!,
              userId: customerInfoModel.records!.first.id!,
              isFromNotificaiton: true,
            ),
          );
        }
      } else {
        showMessage(
            context: context, message: "Customer information not found");
      }
    } else if (message["recordId"] != null &&
        message["recordId"].toString().isEmpty &&
        message["orderNo"] != null &&
        message["orderId"] != null) {
      String orderId = message['orderId'];
      String orderNumber = message['orderNo'];
      String? currentPath;
      Navigator.of(context).popUntil((route) {
        currentPath = route.settings.name;
        return true;
      });

      CustomerInfoModel customerInfoModel =
          CustomerInfoModel(records: [Records(id: null)]);
      if (Get.currentRoute.contains("cartPage") ||
          (currentPath != null && currentPath!.contains("cartPage"))) {
        Navigator.pushReplacementNamed(
          context,
          CartPage.routeName,
          arguments: CartArguments(
            email: customerInfoModel.records![0].accountEmailC != null
                ? customerInfoModel.records![0].accountEmailC!
                : customerInfoModel.records![0].emailC != null
                    ? customerInfoModel.records![0].emailC!
                    : customerInfoModel.records![0].personEmail != null
                        ? customerInfoModel.records![0].personEmail!
                        : "",
            phone: customerInfoModel.records![0].accountPhoneC != null
                ? customerInfoModel.records![0].accountPhoneC!
                : customerInfoModel.records![0].phone != null
                    ? customerInfoModel.records![0].phone!
                    : customerInfoModel.records![0].phoneC != null
                        ? customerInfoModel.records![0].phoneC!
                        : "",
            orderId: orderId,
            orderNumber: orderNumber,
            orderLineItemId: orderNumber,
            orderDate: "",
            customerInfoModel: customerInfoModel,
            userName: customerInfoModel.records!.first.name ?? "",
            userId: customerInfoModel.records!.first.id ?? "",
          ),
        );
      } else {
        Navigator.pushNamed(
          context,
          CartPage.routeName,
          arguments: CartArguments(
            email: customerInfoModel.records![0].accountEmailC != null
                ? customerInfoModel.records![0].accountEmailC!
                : customerInfoModel.records![0].emailC != null
                    ? customerInfoModel.records![0].emailC!
                    : customerInfoModel.records![0].personEmail != null
                        ? customerInfoModel.records![0].personEmail!
                        : "",
            phone: customerInfoModel.records![0].accountPhoneC != null
                ? customerInfoModel.records![0].accountPhoneC!
                : customerInfoModel.records![0].phone != null
                    ? customerInfoModel.records![0].phone!
                    : customerInfoModel.records![0].phoneC != null
                        ? customerInfoModel.records![0].phoneC!
                        : "",
            orderId: orderId,
            orderNumber: orderNumber,
            orderLineItemId: orderNumber,
            orderDate: "",
            customerInfoModel: customerInfoModel,
            userName: customerInfoModel.records!.first.name ?? "",
            userId: customerInfoModel.records!.first.id ?? "",
          ),
        );
      }
    }
  }
}
