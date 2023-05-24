import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/repositories/auth/model/agent_account.dart';
import 'package:gc_customer_app/repositories/auth/repository/authentication_repository.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import 'data/data_sources/approval_process_data_source/approval_process_data_source.dart';
import 'data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'models/approval_model.dart';
import 'models/landing_screen/customer_info_model.dart';

class Customer360Module {
  static Customer360Module instance = Customer360Module._();

  Customer360Module._() {
    _init();
  }

  String? storeNumber;
  String? storeName;

  Future<void> _init() async {
    if (!kIsWeb) {
      // await Firebase.initializeApp();
      // FCM firebaseMessaging = FCM();
      // firebaseMessaging.setNotifications();
      // firebaseMessaging.streamCtrl.stream.listen((msgData) {
      //   debugPrint('messageData $msgData');
      // });
    } else {
      await SharedPreferenceService().setKey(key: agentEmail, value: '');
      await SharedPreferenceService().setKey(key: agentId, value: '');
    }
  }

  Future openCustomer360App(BuildContext context, String id, String fcmToken,
      String userEmail,Map<String,String> deeplinkMessage) async {
    // await sendNotification(id, fcmToken);
    await SharedPreferenceService()
        .setKey(key: loggedInUserEmail, value: userEmail);
    await SharedPreferenceService().setKey(key: agentId, value: '');
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    backgroundColor: ColorSystem.pieChartRed,
                    title: const Text('Customer360'),
                    toolbarHeight: 40,
                    elevation: 0,
                  ),
                  body:
                      App(authenticationRepository: AuthenticationRepository(),deeplinkMessage: deeplinkMessage,),
                )));
  }

  Future<int> getNotification(String id) async {
    var response = await HttpService().doGet(
        requiredAuthentication: false, path: Endpoints.getApprovalProcess(id));

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
    return approvals.length;
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
      return approvals;
    } catch (e) {
      return [];
    }
  }

  onMessageOpen(
      RemoteMessage messages, BuildContext context, bool isInMainApp,Map<String,String> deeplinkMessage) async {
    Map<String, dynamic> message = messages.data;
    if (isInMainApp) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      backgroundColor: ColorSystem.pieChartRed,
                      title: const Text('Customer360'),
                      toolbarHeight: 40,
                      elevation: 0,
                    ),
                    body: App(
                        authenticationRepository: AuthenticationRepository(),
                        notificationMessage: message,deeplinkMessage: deeplinkMessage,),
                  )));
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
      await Future.delayed(Duration(milliseconds: 500));
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      backgroundColor: ColorSystem.pieChartRed,
                      title: const Text('Customer360'),
                      toolbarHeight: 40,
                      elevation: 0,
                    ),
                    body: App(
                        authenticationRepository: AuthenticationRepository(),
                        notificationMessage: message,deeplinkMessage: deeplinkMessage,),
                  )));
      // if (message["approvalProcess"] != null &&
      //     message["approvalProcess"].toString().isNotEmpty) {
      //   Future.delayed(Duration(milliseconds: 1000), () {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) =>
      //               ApprovalWebViewWidget(url: message["approvalProcess"]),
      //         ));
      //   });
      // } else if (message["recordId"] != null &&
      //     message["recordId"].isNotEmpty &&
      //     message["orderNo"] != null &&
      //     message["orderId"] != null) {
      //   String recordId = message['recordId'];
      //   String orderId = message['orderId'];
      //   String orderNumber = message['orderNo'];
      //   String? currentPath;
      //   Navigator.of(context).popUntil((route) {
      //     currentPath = route.settings.name;
      //     return true;
      //   });

      //   CustomerInfoModel customerInfoModel = await getCustomerInfo(recordId);
      //   if (customerInfoModel.records!.isNotEmpty &&
      //       customerInfoModel.records!.first.id != null) {
      //     if (Get.currentRoute.contains("cartPage") ||
      //         (currentPath != null && currentPath!.contains("cartPage"))) {
      //       Navigator.pushReplacementNamed(
      //         context,
      //         CartPage.routeName,
      //         arguments: CartArguments(
      //           email: customerInfoModel.records![0].accountEmailC != null
      //               ? customerInfoModel.records![0].accountEmailC!
      //               : customerInfoModel.records![0].emailC != null
      //                   ? customerInfoModel.records![0].emailC!
      //                   : customerInfoModel.records![0].personEmail != null
      //                       ? customerInfoModel.records![0].personEmail!
      //                       : "",
      //           phone: customerInfoModel.records![0].accountPhoneC != null
      //               ? customerInfoModel.records![0].accountPhoneC!
      //               : customerInfoModel.records![0].phone != null
      //                   ? customerInfoModel.records![0].phone!
      //                   : customerInfoModel.records![0].phoneC != null
      //                       ? customerInfoModel.records![0].phoneC!
      //                       : "",
      //           orderId: orderId,
      //           orderNumber: orderNumber,
      //           orderLineItemId: orderNumber,
      //           orderDate: "",
      //           customerInfoModel: customerInfoModel,
      //           userName: customerInfoModel.records!.first.name!,
      //           userId: customerInfoModel.records!.first.id!,
      //         ),
      //       );
      //     } else {
      //       Navigator.pushNamed(
      //         context,
      //         CartPage.routeName,
      //         arguments: CartArguments(
      //           email: customerInfoModel.records![0].accountEmailC != null
      //               ? customerInfoModel.records![0].accountEmailC!
      //               : customerInfoModel.records![0].emailC != null
      //                   ? customerInfoModel.records![0].emailC!
      //                   : customerInfoModel.records![0].personEmail != null
      //                       ? customerInfoModel.records![0].personEmail!
      //                       : "",
      //           phone: customerInfoModel.records![0].accountPhoneC != null
      //               ? customerInfoModel.records![0].accountPhoneC!
      //               : customerInfoModel.records![0].phone != null
      //                   ? customerInfoModel.records![0].phone!
      //                   : customerInfoModel.records![0].phoneC != null
      //                       ? customerInfoModel.records![0].phoneC!
      //                       : "",
      //           orderId: orderId,
      //           orderNumber: orderNumber,
      //           orderLineItemId: orderNumber,
      //           orderDate: "",
      //           customerInfoModel: customerInfoModel,
      //           userName: customerInfoModel.records!.first.name!,
      //           userId: customerInfoModel.records!.first.id!,
      //           isFromNotificaiton: true,
      //         ),
      //       );
      //     }
      //   } else {
      //     showMessage(context: context,message:"Customer information not found");
      //   }
      // } else if (message["recordId"] != null &&
      //     message["recordId"].toString().isEmpty &&
      //     message["orderNo"] != null &&
      //     message["orderId"] != null) {
      //   String orderId = message['orderId'];
      //   String orderNumber = message['orderNo'];
      //   String? currentPath;
      //   Navigator.of(context).popUntil((route) {
      //     currentPath = route.settings.name;
      //     return true;
      //   });

      //   CustomerInfoModel customerInfoModel =
      //       CustomerInfoModel(records: [Records(id: null)]);
      //   if (Get.currentRoute.contains("cartPage") ||
      //       (currentPath != null && currentPath!.contains("cartPage"))) {
      //     Navigator.pushReplacementNamed(
      //       context,
      //       CartPage.routeName,
      //       arguments: CartArguments(
      //         email: customerInfoModel.records![0].accountEmailC != null
      //             ? customerInfoModel.records![0].accountEmailC!
      //             : customerInfoModel.records![0].emailC != null
      //                 ? customerInfoModel.records![0].emailC!
      //                 : customerInfoModel.records![0].personEmail != null
      //                     ? customerInfoModel.records![0].personEmail!
      //                     : "",
      //         phone: customerInfoModel.records![0].accountPhoneC != null
      //             ? customerInfoModel.records![0].accountPhoneC!
      //             : customerInfoModel.records![0].phone != null
      //                 ? customerInfoModel.records![0].phone!
      //                 : customerInfoModel.records![0].phoneC != null
      //                     ? customerInfoModel.records![0].phoneC!
      //                     : "",
      //         orderId: orderId,
      //         orderNumber: orderNumber,
      //         orderLineItemId: orderNumber,
      //         orderDate: "",
      //         customerInfoModel: customerInfoModel,
      //         userName: customerInfoModel.records!.first.name ?? "",
      //         userId: customerInfoModel.records!.first.id ?? "",
      //       ),
      //     );
      //   } else {
      //     Navigator.pushNamed(
      //       context,
      //       CartPage.routeName,
      //       arguments: CartArguments(
      //         email: customerInfoModel.records![0].accountEmailC != null
      //             ? customerInfoModel.records![0].accountEmailC!
      //             : customerInfoModel.records![0].emailC != null
      //                 ? customerInfoModel.records![0].emailC!
      //                 : customerInfoModel.records![0].personEmail != null
      //                     ? customerInfoModel.records![0].personEmail!
      //                     : "",
      //         phone: customerInfoModel.records![0].accountPhoneC != null
      //             ? customerInfoModel.records![0].accountPhoneC!
      //             : customerInfoModel.records![0].phone != null
      //                 ? customerInfoModel.records![0].phone!
      //                 : customerInfoModel.records![0].phoneC != null
      //                     ? customerInfoModel.records![0].phoneC!
      //                     : "",
      //         orderId: orderId,
      //         orderNumber: orderNumber,
      //         orderLineItemId: orderNumber,
      //         orderDate: "",
      //         customerInfoModel: customerInfoModel,
      //         userName: customerInfoModel.records!.first.name ?? "",
      //         userId: customerInfoModel.records!.first.id ?? "",
      //       ),
      //     );
      //   }
      // }
    }
  }

  Future<String> getCustomerId(String email) async {
    var response = await HttpService().doPost(
        path: Endpoints.getAgentProfile(),
        requiredAuthentication: false,
        body: RequestBody.getAgentProfileBody(email: email));
    if (response.data != null) {
      AgentAccountModel agent = AgentAccountModel.fromJson(response.data);
      if (agent.userList != null &&
          agent.userList!.isNotEmpty &&
          agent.userList!.first.user != null &&
          agent.userList!.first.user!.id != null) {
        await SharedPreferenceService().setKey(
            key: loggedInAgentId, value: agent.userList!.first.user!.id!);
        return agent.userList!.first.user!.id ?? "";
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  Future getNotificationCount(String id) async {
    int count = await getNotification(id);
    return count.toString();
  }

  Future<void> sendNotification(String id, String fcmToken) async {
    await HttpService().doPost(
        path: Endpoints.getMegaNotificationAPI(),
        requiredAuthentication: false,
        body: RequestBody.getAgentNotificationBody(
            token: fcmToken, id: id, badgeCount: 0));
  }

  // Future getUserInformation() async {
  //   var email = await SharedPreferenceService().getValue(agentEmail);
  //   var response = await HttpService().doPost(
  //       path: Endpoints.getUserSmartTrigger(),
  //       body: {
  //         "userId": "0054M000004UMmEQAW",
  //         "email": "",
  //         "loggedinUserId": "0054M000004UMmEQAW",
  //         "platform": "Web"
  //       },
  //       addLoggedInUserId: false);
  //   return response;
  // }
}
