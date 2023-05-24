import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/approval_process_bloc/approval_process_bloc.dart';
import 'package:gc_customer_app/bloc/auth_bloc.dart/auth_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/add_customer_bloc/add_customer_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/order_cards_bloc/order_cards_bloc.dart';
import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/customer_reminder_bloc/customer_reminder_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/my_customer_bloc/my_customer_bloc.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/order_printer_bloc/order_printer_bloc.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/purchase_metrics_bloc/purchase_metrics_bloc.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/data/data_sources/cart_data_source/cart_data_source.dart';
import 'package:gc_customer_app/data/data_sources/inventory_search_data_source/inventory_search_data_source.dart';
import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/approval_process_repository/approval_process_repository.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/inventory_search_reporsitory/inventory_search_repository.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/my_customer_repository/my_customer_repository.dart';
import 'package:gc_customer_app/data/reporsitories/offers_screen_repository/offers_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_history_screen_repository/order_history_repository.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/data/reporsitories/profile/purchase_metrics_repository.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/repositories/auth/bloc/authentication_bloc.dart';
import 'package:gc_customer_app/repositories/auth/repository/authentication_repository.dart';
import 'package:gc_customer_app/screens/cart/views/cart_page.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_main.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_page.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_web_page.dart';
import 'package:gc_customer_app/screens/splash/screens/splash_page.dart';
import 'package:gc_customer_app/services/deeplinking/deeplinks.dart';
import 'package:gc_customer_app/services/fcm/firebase_messaging.dart';
import 'package:gc_customer_app/services/fcm/life_cycle_event_handler.dart';
import 'package:gc_customer_app/services/okta/auth_okta_service.dart';
import 'package:gc_customer_app/services/okta/okta_auth_provider.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/theme.dart';
import 'package:gc_customer_app/utils/app_theme.dart';
import 'package:gc_customer_app/utils/routes/cart_page_arguments.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';
import 'package:azure_ad_authentication/azure_ad_authentication.dart';
import 'package:azure_ad_authentication/exeption.dart';
import 'package:azure_ad_authentication/model/user_ad.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'bloc/offers_screen_bloc/offers_screen_bloc.dart';
import 'bloc/order_lookup_bloc/order_lookup_bloc.dart';
import 'bloc/profile_screen_bloc/address_bloc/address_bloc.dart';
import 'bloc/reminder_bloc/reminder_bloc.dart';
import 'bloc/task_details_bloc/task_details_bloc.dart';
import 'data/reporsitories/order_lookup_repository/order_lookup_repository.dart';
import 'data/reporsitories/order_printer_repository/order_printer_repository.dart';
import 'data/reporsitories/profile/addresses_repository.dart';
import 'data/reporsitories/reminder_screen_repository/reminder_screen_repository.dart';
import 'screens/google_map/providers/place_provider.dart';
import 'utils/theme_provider.dart';
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  App({Key? key,
      required this.authenticationRepository,
      this.notificationMessage,required this.deeplinkMessage})
      : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final Map<String, dynamic>? notificationMessage;
  final Map<String, String>? deeplinkMessage;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloC>(create: (context) => AuthBloC()),
          BlocProvider<ApprovalProcessBloC>(
              create: (context) =>
                  ApprovalProcessBloC(ApprovalProcesssRepository())),
          BlocProvider<OrderHistoryBloc>(
            create: (context) => OrderHistoryBloc(
                orderHistoryRepository: OrderHistoryRepository(),
                landingScreenRepository: LandingScreenRepository()),
          ),
          BlocProvider<AddressBloc>(
            create: (context) => AddressBloc(AddressesRepository()),
          ),
          BlocProvider(
              create: (_) => AuthenticationBloc(
                  authenticationRepository: authenticationRepository)),
          BlocProvider(create: (_) => MyCustomerBloC(MyCustomerRepository())),
          BlocProvider<ReminderBloC>(
            create: (context) =>
                ReminderBloC(reminderRepo: ReminderScreenReponsitory()),
          ),
          BlocProvider<CustomerReminderBloc>(
            create: (context) =>
                CustomerReminderBloc(LandingScreenRepository()),
          ),
          BlocProvider<PurchaseMetricsBloc>(
            create: (context) =>
                PurchaseMetricsBloc(PurchaseMetricsRepository()),
          ),
          BlocProvider<AddCustomerBloc>(
            create: (context) => AddCustomerBloc(
                CartRepository(cartDataSource: CartDataSource())),
          ),
          BlocProvider<OffersScreenBloc>(
            create: (context) => OffersScreenBloc(
                offersScreenRepository: OffersScreenRepository()),
          ),
          BlocProvider<FavouriteBrandScreenBloc>(
            create: (context) => FavouriteBrandScreenBloc(
                favouriteBrandScreenRepository:
                    FavouriteBrandScreenRepository()),
          ),
          BlocProvider<InventorySearchBloc>(
            create: (context) => InventorySearchBloc(
                inventorySearchRepository: InventorySearchRepository(
                  inventorySearchDataSource: InventorySearchDataSource(),
                ),
                favouriteBrandScreenRepository:
                    FavouriteBrandScreenRepository()),
          ),
          BlocProvider(
            create: (context) {
              return ProductDetailBloc(
                productDetailRepository: ProductDetailRepository(
                    productDetailDataSource: ProductDetailDataSource()),
              );
            },
          ),
          BlocProvider(
            create: (context) {
              return ZipStoreListBloc();
            },
          ),
          BlocProvider(
            create: (context) {
              return OrderCardsBloc(
                  CartRepository(cartDataSource: CartDataSource()));
            },
          ),
          BlocProvider(
            create: (context) => LandingScreenBloc(
                landingScreenRepository: LandingScreenRepository()),
          ),
          BlocProvider(
            create: (context) => OrderPrinterBloC(OrderPrinterRepository()),
          ),
          BlocProvider(
              create: (_) => AuthenticationBloc(
                  authenticationRepository: authenticationRepository)),
          BlocProvider(
              create: (_) =>
                  OrderLookUpBloC(orderLookUpRepo: OrderLookUpRepository())),
          BlocProvider<TaskDetailsBloc>(create: (context) => TaskDetailsBloc()),
        ],
        child: MyApp(
            deeplinkMessage: deeplinkMessage,
            authenticationRepository: authenticationRepository,
            notificationMessage: notificationMessage),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final AuthenticationRepository authenticationRepository;
  final Map<String, dynamic>? notificationMessage;
  final Map<String, String>? deeplinkMessage;
  MyApp(
      {Key? key,
      required this.authenticationRepository,
      required this.deeplinkMessage,
      this.notificationMessage})
      : super(key: key);
  static Route route(AuthenticationRepository authenticationRepository,
      Map<String, dynamic>? notificationMessage,Map<String, String>? deeplinkMessage) {
    return MaterialPageRoute<void>(
        builder: (_) => MyApp(
              authenticationRepository: authenticationRepository,
          deeplinkMessage: deeplinkMessage,
              notificationMessage: notificationMessage,
            ));
  }

  @override
  State<MyApp> createState() => _MyAppState();
}
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey=GlobalKey<ScaffoldMessengerState>();

class _MyAppState extends State<MyApp> {
  late AuthenticationBloc authenticationBloc;
  NavigatorState get _navigator => navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (kIsWeb)
          Provider<NavigatorWebBloC>(create: (context) => NavigatorWebBloC()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<PlaceProvider>(
            create: (_) =>
                PlaceProvider(mapApiKey, "", null, <String, String>{})),
      ],
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return OktaAuthProvider(
          authService: AuthOktaService(),
          child: GetMaterialApp(
            theme: themeLight,
            navigatorKey: navigatorKey,

            title: 'GC Customer',
            scaffoldMessengerKey: scaffoldMessengerKey,
            locale: Locale("en"),
            useInheritedMediaQuery: true, //Only for Mega App
            debugShowCheckedModeBanner: false,
            routes: kIsWeb
                ? {}
                : {
                    '/cartPage': (context) => CartPage(ModalRoute.of(context)!
                        .settings
                        .arguments as CartArguments),
                  },
            home: kIsWeb
                ? LandingScreenWebPage()
                : LandingScreenMain(
                    authenticationRepository: widget.authenticationRepository,
                    notificationMessage: widget.notificationMessage,
                deeplinkMessage: widget.deeplinkMessage,
                    authenticationStatus:
                        AuthenticationStatus.unauthenticated),
          ),
        );
      },
    );
  }

  late final DeepLinks _deepLinks;
  bool _isInitializedDeepLinks = false;
  @override
  void initState() {
    super.initState();
    // FCM firebaseMessaging = FCM();
    // firebaseMessaging.setNotifications();
    authenticationBloc = context.read<AuthenticationBloc>();
    if (!kIsWeb) {
      // if (authenticationBloc.state.status == AuthenticationStatus.authenticated) {
        if (widget.deeplinkMessage != null){


/*        _deepLinks = DeepLinks();
        setState(() {
          _isInitializedDeepLinks = true;
        });
        _deepLinks.stream.listen((link) async {
          print(
              "${link.split("/").first} - ${link.split("/").first == "profile"}");
          if (link.split("/").first == "profile" &&
              link.split("/").length == 5) {
            String id = link.split("/")[1];
            String name = link.split("/")[2].replaceAll("%20", " ");
            String email = link.split("/")[3];
            String phone = link.split("/")[4];
            // String preId = await SharedPreferenceService().getValue(agentId);
            // String preName = await SharedPreferenceService().getValue(savedAgentName);
            // String preEmail = await SharedPreferenceService().getValue(agentEmail);
            // String prePhone = await SharedPreferenceService().getValue(agentPhone);

            await SharedPreferenceService().setKey(key: agentId, value: id);
            await SharedPreferenceService().setKey(key: savedAgentName, value: name);
            await SharedPreferenceService().setKey(key: agentEmail, value: email);
            await SharedPreferenceService().setKey(key: agentPhone, value: phone);
            context
                .read<InventorySearchBloc>()
                .add(SetCart(itemOfCart: [], records: [], orderId: ''));

            _navigator.push(
                CupertinoPageRoute(
                    settings: RouteSettings(name: 'CustomerLandingScreen'),
                    builder: (context) => CustomerLandingScreen(appName: "Smart Trigger")));
            // await SharedPreferenceService().setKey(key: agentId, value: preId);
            // await SharedPreferenceService().setKey(key: savedAgentName, value: preName);
            // await SharedPreferenceService().setKey(key: agentEmail, value: preEmail);
            // await SharedPreferenceService().setKey(key: agentPhone, value: prePhone);
          }
        });*/
      }
        else{
          print("widget.deeplinkMessage is null");
        }
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
      print("cust id $id");
      print("cust name $name");
      print("cust email $email");
      print("cust phone $phone");
    _navigator.push(
        CupertinoPageRoute(
            settings: RouteSettings(name: 'CustomerLandingScreen'),
            builder: (context) => CustomerLandingScreen(appName: "Smart Trigger")));

  }

  @override
  void dispose() {
    if (_isInitializedDeepLinks) {
      _deepLinks.dispose();
    }
    super.dispose();
  }

  Future<AuthenticationStatus> performLogin() async {
    // FirebaseAnalytics.instance.logAppOpen();
    AuthenticationStatus authenticationState =
        await widget.authenticationRepository.socialLogin(context);
    return authenticationState;
  }
}

void showMessage({
  required String message,
  required BuildContext context
}){
  scaffoldMessengerKey.currentState!
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar(message,context));
}
SnackBar snackBar(message, context) {
  return SnackBar(
      elevation: 4.0,
      backgroundColor:  Color(0xff212121),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
      ),
      behavior: SnackBarBehavior.floating,

      margin: EdgeInsets.only(
          left:20,
          right:20,
          bottom:40),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
              ),
            ),
            InkWell(
              onTap: (){
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
              },
              child: const Text(
                "Dismiss",
                style:  TextStyle(
                    color: ColorSystem.lavender4,
                    fontSize: 14,
                    fontFamily: kRubik
                ),
              ),
            ),
          ],
        ),
      ));
}