import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as meth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/data_sources/approval_process_data_source/approval_process_data_source.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/repositories/auth/bloc/authentication_bloc.dart';
import 'package:gc_customer_app/screens/cart/views/cart_page.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:get/get.dart';

import 'package:rxdart/subjects.dart';

import '../../app.dart';
import '../../data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import '../../models/approval_model.dart';
import '../../models/landing_screen/customer_info_model.dart';
import '../../screens/notification/approval_web_view.dart';
import '../../utils/routes/cart_page_arguments.dart';

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage messages) async {
  await Firebase.initializeApp();
  print("background message received");
  Map<String, dynamic> message = messages.data;
  if (message.containsKey("title")) {
    if (message["title"]
        .toString()
        .toLowerCase()
        .contains("logout successfully")) {
      await SharedPreferenceService().setBool(key: isValidToken, value: false);
    }
  }
  if (Platform.isAndroid) {
    // _showNotifications(messages.notification!.body!, messages.notification!.title!,'message_channel','message',true,false,'CATEGORY_MESSAGE',0);
  } else {
    // _showNotifications(messages.notification!.body!, messages.notification!.title!,'message_channel','message',true,false,'CATEGORY_MESSAGE',int.parse(message['badge']));
  }

  await getApproval();
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

String urlLaunchActionId = 'id_1';

String navigationActionId = 'id_3';

String darwinNotificationCategoryText = 'textCategory';

String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class FCM {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final streamCtrl = StreamController<String>.broadcast();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@drawable/shopping');
  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[];
  DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationSubject.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: [],
  );

  late InitializationSettings initializationSettings;

  Future<void> initializing() async {
    await FirebaseMessaging.instance
        .setAutoInitEnabled(true)
        .catchError((onError) {}); // later added for manifest.xml permission
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        )
        .catchError((onError) {});
    // print("int");

    initializationSettings = InitializationSettings(
        iOS: initializationSettingsDarwin,
        android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin
        .initialize(initializationSettings,
            onDidReceiveBackgroundNotificationResponse:
                notificationTapBackground)
        .onError((error, stackTrace) {});
  }

  Future clearAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static void _showNotifications(
      String body,
      String title,
      String channelDescription,
      String ticker,
      bool wakeUpScreen,
      bool autoCancel,
      String category,
      int? badge) async {
    await notification(body, title, channelDescription, ticker, wakeUpScreen,
        autoCancel, category, badge);
  }

  static Future<void> notification(
      String body,
      String title,
      String channelDescription,
      String ticker,
      bool wakeUpScreen,
      bool autoCancel,
      String category,
      int? badge) async {
    log("sending notification");
    var vibrationPattern = Int64List(8);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 250;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 250;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 250;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 250;
    vibrationPattern[6] = 0;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            meth.Random().nextInt(1000).toString(), title,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
            vibrationPattern: vibrationPattern,
            channelDescription: channelDescription,
            fullScreenIntent: wakeUpScreen,
            category: AndroidNotificationCategory.message,
            autoCancel: autoCancel,
            importance: Importance.high,
            channelShowBadge: true,
            styleInformation:
                BigTextStyleInformation(body, htmlFormatSummaryText: true),
            ticker: ticker);

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
            categoryIdentifier: darwinNotificationCategoryPlain,
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: badge);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin
        .show(meth.Random().nextInt(1000), title, body, notificationDetails,
            payload: 'item z')
        .catchError((onError) {
      log("onError $onError");
    }).whenComplete(() {
      log("done");
    });
  }

  void onSelectNotification(String? payload) {
//    _navigationService.navigateTo(FaqPage.route());
  }
  Future<void> iosPermission() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            critical: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
    }
    _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
  }

  // BuildContext get _navigator => navigatorKey.currentContext!;
  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();
    Future.delayed(Duration(milliseconds: 500), () {
      FirebaseMessaging.onMessage.listen((RemoteMessage messages) async {
        Map<String, dynamic> message = messages.data;
        log("logout event came ${jsonEncode(messages.toMap())}");
        if (message.containsKey("title")) {
          if (message["title"]
              .toString()
              .toLowerCase()
              .contains("logout successfully")) {
            // if (navigatorKey?.currentContext != null)
            //   navigatorKey?.currentContext?.read<AuthenticationBloc>().add(
            //       AuthenticationLogoutRequested(
            //           context: navigatorKey!.currentContext!));
          }
        }
        if (Platform.isAndroid) {
          _showNotifications(
              messages.notification!.body!,
              messages.notification!.title!,
              'message_channel',
              'message',
              true,
              false,
              'CATEGORY_MESSAGE',
              0);
        } else {
          // _showNotifications(messages.notification!.body!, messages.notification!.title!,'message_channel','message',true,false,'CATEGORY_MESSAGE',int.parse(message['badge']??"0"));
        }
        await getApproval();
      });
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage messages) async {
        Map<String, dynamic> message = messages.data;
//         if (message["approvalProcess"] != null &&
//             message["approvalProcess"].toString().isNotEmpty &&
//             navigatorKey?.currentState != null) {
//           Future.delayed(Duration(milliseconds: 1000), () {
//             Navigator.push(
//                 navigatorKey!.currentState!.context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       ApprovalWebViewWidget(url: message["approvalProcess"]),
//                 ));
//           });
//         } else if (message["recordId"] != null &&
//             message["recordId"].isNotEmpty &&
//             message["orderNo"] != null &&
//             message["orderId"] != null &&
//             navigatorKey?.currentState != null) {
//           String recordId = message['recordId'];
//           String orderId = message['orderId'];
//           String orderNumber = message['orderNo'];
// //          var route = ModalRoute.of(navigatorKey.currentState!.);
//           String? currentPath;
//           navigatorKey?.currentState?.popUntil((route) {
//             currentPath = route.settings.name;
//             return true;
//           });

//           CustomerInfoModel customerInfoModel = await getCustomerInfo(recordId);
//           if (customerInfoModel.records!.isNotEmpty &&
//               customerInfoModel.records!.first.id != null) {
//             if (Get.currentRoute.contains("cartPage") ||
//                 (currentPath != null && currentPath!.contains("cartPage"))) {
//               Navigator.pushReplacementNamed(
//                 navigatorKey!.currentState!.context,
//                 CartPage.routeName,
//                 arguments: CartArguments(
//                   email: customerInfoModel.records![0].accountEmailC != null
//                       ? customerInfoModel.records![0].accountEmailC!
//                       : customerInfoModel.records![0].emailC != null
//                           ? customerInfoModel.records![0].emailC!
//                           : customerInfoModel.records![0].personEmail != null
//                               ? customerInfoModel.records![0].personEmail!
//                               : "",
//                   phone: customerInfoModel.records![0].accountPhoneC != null
//                       ? customerInfoModel.records![0].accountPhoneC!
//                       : customerInfoModel.records![0].phone != null
//                           ? customerInfoModel.records![0].phone!
//                           : customerInfoModel.records![0].phoneC != null
//                               ? customerInfoModel.records![0].phoneC!
//                               : "",
//                   orderId: orderId,
//                   orderNumber: orderNumber,
//                   orderLineItemId: orderNumber,
//                   orderDate: "",
//                   customerInfoModel: customerInfoModel,
//                   userName: customerInfoModel.records!.first.name!,
//                   userId: customerInfoModel.records!.first.id!,
//                 ),
//               );
//             } else {
//               Navigator.pushNamed(
//                 navigatorKey!.currentState!.context,
//                 CartPage.routeName,
//                 arguments: CartArguments(
//                   email: customerInfoModel.records![0].accountEmailC != null
//                       ? customerInfoModel.records![0].accountEmailC!
//                       : customerInfoModel.records![0].emailC != null
//                           ? customerInfoModel.records![0].emailC!
//                           : customerInfoModel.records![0].personEmail != null
//                               ? customerInfoModel.records![0].personEmail!
//                               : "",
//                   phone: customerInfoModel.records![0].accountPhoneC != null
//                       ? customerInfoModel.records![0].accountPhoneC!
//                       : customerInfoModel.records![0].phone != null
//                           ? customerInfoModel.records![0].phone!
//                           : customerInfoModel.records![0].phoneC != null
//                               ? customerInfoModel.records![0].phoneC!
//                               : "",
//                   orderId: orderId,
//                   orderNumber: orderNumber,
//                   orderLineItemId: orderNumber,
//                   orderDate: "",
//                   customerInfoModel: customerInfoModel,
//                   userName: customerInfoModel.records!.first.name!,
//                   userId: customerInfoModel.records!.first.id!,
//                   isFromNotificaiton: true,
//                 ),
//               );
//             }
//           } else {
//             showMessage(context: context,message:"Customer information not found");
//           }
//         } else if (message["recordId"] != null &&
//             message["recordId"].toString().isEmpty &&
//             message["orderNo"] != null &&
//             message["orderId"] != null &&
//             navigatorKey?.currentState != null) {
//           String orderId = message['orderId'];
//           String orderNumber = message['orderNo'];
//           String? currentPath;
//           navigatorKey?.currentState?.popUntil((route) {
//             currentPath = route.settings.name;
//             return true;
//           });

//           CustomerInfoModel customerInfoModel =
//               CustomerInfoModel(records: [Records(id: null)]);
//           if (Get.currentRoute.contains("cartPage") ||
//               (currentPath != null && currentPath!.contains("cartPage"))) {
//             Navigator.pushReplacementNamed(
//               navigatorKey!.currentState!.context,
//               CartPage.routeName,
//               arguments: CartArguments(
//                 email: customerInfoModel.records![0].accountEmailC != null
//                     ? customerInfoModel.records![0].accountEmailC!
//                     : customerInfoModel.records![0].emailC != null
//                         ? customerInfoModel.records![0].emailC!
//                         : customerInfoModel.records![0].personEmail != null
//                             ? customerInfoModel.records![0].personEmail!
//                             : "",
//                 phone: customerInfoModel.records![0].accountPhoneC != null
//                     ? customerInfoModel.records![0].accountPhoneC!
//                     : customerInfoModel.records![0].phone != null
//                         ? customerInfoModel.records![0].phone!
//                         : customerInfoModel.records![0].phoneC != null
//                             ? customerInfoModel.records![0].phoneC!
//                             : "",
//                 orderId: orderId,
//                 orderNumber: orderNumber,
//                 orderLineItemId: orderNumber,
//                 orderDate: "",
//                 customerInfoModel: customerInfoModel,
//                 userName: customerInfoModel.records!.first.name ?? "",
//                 userId: customerInfoModel.records!.first.id ?? "",
//               ),
//             );
//           } else {
//             Navigator.pushNamed(
//               navigatorKey!.currentState!.context,
//               CartPage.routeName,
//               arguments: CartArguments(
//                 email: customerInfoModel.records![0].accountEmailC != null
//                     ? customerInfoModel.records![0].accountEmailC!
//                     : customerInfoModel.records![0].emailC != null
//                         ? customerInfoModel.records![0].emailC!
//                         : customerInfoModel.records![0].personEmail != null
//                             ? customerInfoModel.records![0].personEmail!
//                             : "",
//                 phone: customerInfoModel.records![0].accountPhoneC != null
//                     ? customerInfoModel.records![0].accountPhoneC!
//                     : customerInfoModel.records![0].phone != null
//                         ? customerInfoModel.records![0].phone!
//                         : customerInfoModel.records![0].phoneC != null
//                             ? customerInfoModel.records![0].phoneC!
//                             : "",
//                 orderId: orderId,
//                 orderNumber: orderNumber,
//                 orderLineItemId: orderNumber,
//                 orderDate: "",
//                 customerInfoModel: customerInfoModel,
//                 userName: customerInfoModel.records!.first.name ?? "",
//                 userId: customerInfoModel.records!.first.id ?? "",
//               ),
//             );
//           }
//         }
      });
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    });
  }

  Future<CustomerInfoModel> getCustomerInfo(String id) async {
    late CustomerInfoModel response;
    try {
      response = await LandingScreenRepository().getCustomerInfoById(id);
      print(response.records?.first.id);
      if (response.records!.isEmpty) {
        return CustomerInfoModel(records: [Records(id: null)], done: false);
      } else {
        if (response.records![0].id != null) {
          SharedPreferenceService()
              .setKey(key: agentId, value: response.records![0].id!);
        }
        if (response.records![0].accountEmailC != null) {
          SharedPreferenceService().setKey(
              key: agentEmail, value: response.records![0].accountEmailC!);
        } else if (response.records![0].emailC != null) {
          SharedPreferenceService()
              .setKey(key: agentEmail, value: response.records![0].emailC!);
        } else if (response.records![0].personEmail != null) {
          SharedPreferenceService().setKey(
              key: agentEmail, value: response.records![0].personEmail!);
        }
        if (response.records![0].name != null) {
          SharedPreferenceService()
              .setKey(key: savedAgentName, value: response.records![0].name!);
        }
        if (response.records![0].accountEmailC != null) {
          SharedPreferenceService().setKey(
              key: agentEmail, value: response.records![0].accountEmailC!);
        } else if (response.records![0].emailC != null) {
          SharedPreferenceService()
              .setKey(key: agentEmail, value: response.records![0].emailC!);
        } else if (response.records![0].personEmail != null) {
          SharedPreferenceService().setKey(
              key: agentEmail, value: response.records![0].personEmail!);
        }
      }
    } catch (e) {
      if (kIsWeb) return CustomerInfoModel(records: [], done: false);
      return CustomerInfoModel(records: [Records(id: null)], done: false);
    }
    return response;
  }

  Future<String> setNotifications() async {
    await initializing();
    firebaseCloudMessagingListeners();
    String token = "";
    _firebaseMessaging.getToken().then((tokens) async {
      print("tokens => $tokens");
      await SharedPreferenceService().setKey(key: fcmToken, value: tokens!);
    }).catchError((onError) {});
    return token;
  }
}

Future<List<ApprovalModel>> getApproval() async {
  try {
    String loggedInId =
        await SharedPreferenceService().getValue(loggedInAgentId);
    var response = await ApprovalProcesssDataSource().getApproval(loggedInId);

    List<ApprovalModel> approvals = [];
    if (response.data['ShippingOverrideApprovals'] != null) {
      approvals.addAll(response.data['ShippingOverrideApprovals']
              ?.map<ApprovalModel>((pr) => ApprovalModel.fromJson(pr))
              .toList() ??
          <ApprovalModel>[]);
    }
    if (response.data['PriceOverrideApprovals'] != null) {
      approvals.addAll(response.data['PriceOverrideApprovals']
              ?.map<ApprovalModel>((pr) => ApprovalModel.fromJson(pr))
              .toList() ??
          <ApprovalModel>[]);
    }

    if (await FlutterAppBadger.isAppBadgeSupported()) {
      if (approvals.isNotEmpty) {
        FlutterAppBadger.updateBadgeCount(approvals.length);
      }
    }
    return approvals;
  } catch (e) {
    return [];
  }
}
