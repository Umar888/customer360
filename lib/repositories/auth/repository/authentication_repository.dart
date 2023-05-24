import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cron/cron.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/models/access_token/access_token_model.dart';
import 'package:gc_customer_app/repositories/auth/model/periodic_time_token.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../models/agent.dart';
import '../../../primitives/constants.dart';
import '../../../services/okta/okta_auth_provider.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_helper.dart';
import '../model/agent_account.dart';
import '../model/decode_token_model.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  Cron? refreshTokenCron;
  Cron? validateTokenCron;
  final SharedPreferenceService _sharedPref = SharedPreferenceService();
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept-Charset': 'utf-8'
  };

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(Duration(seconds: 1));
    yield* _controller.stream;
  }

  void logOut(AuthenticationLogoutRequested event) async {
    logoutCall(event.context);
  }

  Future<void> getNotification(String id) async {
    var token = await SharedPreferenceService().getValue(fcmToken);

    await HttpService().doPost(
        path: Endpoints.getNotificationAPI(),
        body: RequestBody.getAgentNotificationBody(
            token: token, id: id, badgeCount: 0));
  }

  Future<bool> loginCall(String email) async {
    var response = await HttpService().doPost(
        path: Endpoints.loginAPI(),
        body: RequestBody.getLoginBody(email: email));
    log(jsonEncode(response.data));
    if (response.data != null) {
      if (response.data["isSuccess"]) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<String> getAgentProfile(String email) async {
    var response = await HttpService().doPost(
        path: Endpoints.getAgentProfile(),
        body: RequestBody.getAgentProfileBody(email: email));
    log(jsonEncode(response.data));
    if (response.data != null) {
      AgentAccountModel agent = AgentAccountModel.fromJson(response.data);
      if (agent.userList != null &&
          agent.userList!.isNotEmpty &&
          agent.userList!.first.user != null &&
          agent.userList!.first.user!.id != null) {
        await SharedPreferenceService().setKey(
            key: loggedInAgentId, value: agent.userList!.first.user!.id!);
        await getNotification(agent.userList!.first.user!.id!);

        return agent.userList!.first.user!.id ?? "";
      } else {
        await SharedPreferenceService().setKey(key: loggedInAgentId, value: '');
        return "";
      }
    } else {
      await SharedPreferenceService().setKey(key: loggedInAgentId, value: '');
      return "";
    }
  }

  Future<void> generateAccessToken() async {
    var tokenResponse = await http
        .post(Uri.parse('${Endpoints.kBaseURL}$authURL'), body: authJson);

    if (tokenResponse.statusCode == 200) {
      try {
        var accessTokenBody = jsonDecode(tokenResponse.body);
        var accessToken = accessTokenBody['access_token'];
        var instanceUrl = accessTokenBody['instance_url'];
        print("accessToken ${accessToken}");
        SharedPreferenceService().setUserToken(authToken: accessToken);
        SharedPreferenceService().setInstanceUrl(url: instanceUrl);
        await SharedPreferenceService().setBool(key: isValidToken, value: true);
        print(accessToken);
      } catch (e) {}
    }
  }

  Future<String> generateAccessCustomToken(
      String clientId, String returnUrl, String deviceId) async {
    var tokenResponse = await await HttpService().doPost(
        path: Endpoints.customTokenApi(),
        body: RequestBody.getCustomTokenBody(
            clientId: clientId, returnUrl: returnUrl, deviceId: deviceId),
        xAPIKey: true);
    if (tokenResponse != null && tokenResponse.data != null) {
      AccessTokenModel accessTokenModel =
          AccessTokenModel.fromJson(tokenResponse.data);
      if (accessTokenModel.success! &&
          accessTokenModel.data != null &&
          accessTokenModel.data!.tokenData != null) {
        try {
          String accessToken =
              accessTokenModel.data!.tokenData!.accessToken ?? "";
          String accessEmail = accessTokenModel.data!.userData!.email ?? "";
          int accessTime = accessTokenModel.data!.tokenData!.expiresIn ?? 0;
          bool hasExpired = JwtDecoder.isExpired(accessToken);
          if (!hasExpired) {
            Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
            DecodeTokenModel decodeTokenModel =
                DecodeTokenModel.fromJson(decodedToken);
            if ((decodeTokenModel.sub ?? "").toLowerCase() ==
                accessEmail.toLowerCase()) {
              return "${accessTime}";
            } else {
              return "";
            }
          } else {
            return "";
          }
        } catch (e) {
          return "";
        }
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor;
  }

  periodicTimeCall(BuildContext context, String email, String authTime,
      String expiryTime, String loggedInAgentId) async {
    DateTime auth =
        DateTime.fromMillisecondsSinceEpoch(int.parse(authTime) * 1000);
    DateTime expiry =
        DateTime.fromMillisecondsSinceEpoch(int.parse(expiryTime) * 1000);
    String time = expiry.difference(auth).inSeconds.toString();
    print("email $email");
    print("time $time");
    if (time.isNotEmpty) {
      var tokenResponse = await HttpService()
          .doGet(path: Endpoints.periodicTimeApi(loggedInAgentId));
      if (tokenResponse.data != null) {
        PeriodicTimeModel periodicTimeModel =
            PeriodicTimeModel.fromJson(tokenResponse.data);
        if (int.parse(time.toString()) <
            (periodicTimeModel.refreshTokenInSec ?? 0)) {
          await SharedPreferenceService()
              .setKey(key: cronTimeRefresh, value: time.toString());
        } else {
          await SharedPreferenceService().setKey(
              key: cronTimeRefresh,
              value: (periodicTimeModel.refreshTokenInSec ?? 0).toString());
        }

        await SharedPreferenceService().setKey(
            key: cronTimeValidate,
            value: (periodicTimeModel.validateTokenInSec ?? 0).toString());
        String cronRefreshJobTime =
            await SharedPreferenceService().getValue(cronTimeRefresh);
        String cronValidateJobTime =
            await SharedPreferenceService().getValue(cronTimeValidate);

        int cronJobSecRefresh = 0;
        cronJobSecRefresh = double.parse(cronRefreshJobTime).toInt();
        print("cronJobSecRefresh $cronJobSecRefresh sec");

        int cronJobSecValidate = 0;
        cronJobSecValidate = double.parse(cronValidateJobTime).toInt();
        print("cronJobSecValidate $cronJobSecValidate sec");

        refreshTokenCron = Cron();
        validateTokenCron = Cron();

        refreshTokenCron!.schedule(
            Schedule.parse('*/${cronJobSecRefresh} * * * * *'), () async {
          print("refresh cron job called");
          await OktaAuthProvider.of(context)?.authService.refreshTokens();
          var accessToken =
              await OktaAuthProvider.of(context)?.authService.getAccessToken();
          var idToken =
              await OktaAuthProvider.of(context)?.authService.getIdToken();
          await SharedPreferenceService()
              .setKey(key: oktaAccessToken, value: accessToken ?? "");
          await SharedPreferenceService()
              .setKey(key: oktaIdToken, value: idToken ?? "");
        });

        validateTokenCron!.schedule(
            Schedule.parse('*/${cronJobSecValidate} * * * * *'), () async {
          String? isValidRefreshToken = await OktaAuthProvider.of(context)
              ?.authService
              .introspectRefreshToken();
          if (isValidRefreshToken != null && isValidRefreshToken.isNotEmpty) {
            print("validate cron job called and token is valid");
            await SharedPreferenceService()
                .setBool(key: isValidToken, value: true);
          } else {
            print("validate cron job called and token is not valid");
            await SharedPreferenceService()
                .setBool(key: isValidToken, value: false);
//            _controller.add(AuthenticationStatus.unauthenticated);
          }
        });
      }
    }
  }

  resetCredentials() async {
    _controller.add(AuthenticationStatus.unauthenticated);
    await SharedPreferenceService().setKey(key: kAccessTokenKey, value: '');
    await SharedPreferenceService().setKey(key: kInstanceUrlKey, value: '');
    await SharedPreferenceService().setKey(key: agentEmail, value: '');
    await SharedPreferenceService().setKey(key: agentId, value: '');
    await SharedPreferenceService().setKey(key: savedAgentName, value: '');
    await SharedPreferenceService().setKey(key: agentPhone, value: '');
    await SharedPreferenceService().setKey(key: agentIndex, value: '');
    await SharedPreferenceService().setKey(key: agentAddress, value: '');
    await SharedPreferenceService().setKey(key: loggedInAgentId, value: '');
    await SharedPreferenceService().setKey(key: loggedInUserEmail, value: "");
  }

  checkAuth(BuildContext context) async {
    bool valid = await SharedPreferenceService().getBool(isValidToken);
    if (!valid) {
      print("not valid");
      logoutCall(context);
    } else {
      print("valid");
    }
  }

  logoutCall(BuildContext context) async {
    await SharedPreferenceService().setBool(key: isValidToken, value: false);
    await SharedPreferenceService().setKey(key: oktaAccessToken, value: "");
    await SharedPreferenceService().setKey(key: loggedInAgentId, value: "");
    await SharedPreferenceService().setKey(key: loggedInUserEmail, value: "");
    await SharedPreferenceService().setKey(key: agentEmail, value: "");
    await SharedPreferenceService().setKey(key: agentPhone, value: "");
    await SharedPreferenceService().setKey(key: agentId, value: "");
    await SharedPreferenceService().setKey(key: oktaIdToken, value: "");
    await SharedPreferenceService().setKey(key: cronTimeRefresh, value: "");
    await SharedPreferenceService().setKey(key: cronTimeValidate, value: "");
    await OktaAuthProvider.of(context)?.authService.revokeRefreshToken();
    await OktaAuthProvider.of(context)?.authService.revokeAccessToken();
    await OktaAuthProvider.of(context)?.authService.revokeIdToken();
    await OktaAuthProvider.of(context)?.authService.clearTokens();
    if (validateTokenCron != null) {
      validateTokenCron!.close();
    }
    if (refreshTokenCron != null) {
      refreshTokenCron!.close();
    }
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  Future<AuthenticationStatus> socialLogin(BuildContext context) async {
    try {
      // var userEmail = "ankit.kumar@guitarcenter.com";
      var userEmail = await SharedPreferenceService().getValue(loggedInUserEmail);
      print("user email ${userEmail}");
      if (userEmail.isNotEmpty) {
        await generateAccessToken();
        String agentId = await getAgentProfile(userEmail);
        if (agentId.isNotEmpty) {
          await SharedPreferenceService()
              .setKey(key: oktaAccessToken, value: "" ?? "");
          await SharedPreferenceService()
              .setKey(key: oktaIdToken, value: "" ?? "");
          await SharedPreferenceService()
              .setBool(key: isValidToken, value: true);
          _controller.add(AuthenticationStatus.authenticated);
          return AuthenticationStatus.authenticated;
        } else {
          _controller.add(AuthenticationStatus.unauthenticated);
          return AuthenticationStatus.unauthenticated;
        }
      } else {
        _controller.add(AuthenticationStatus.unauthenticated);
        return AuthenticationStatus.unauthenticated;
      }

      //   else {
      //     var accessToken =
      //       await OktaAuthProvider.of(context)?.authService.getAccessToken();
      //   var idToken =
      //       await OktaAuthProvider.of(context)?.authService.getIdToken();
      //   var checkAuthToken =
      //       await OktaAuthProvider.of(context)?.authService.isAuthenticated();
      //   String? isValidAccessToken = await OktaAuthProvider.of(context)
      //       ?.authService
      //       .introspectAccessToken();

      //   log("-------------------------------");
      //   log("idToken $idToken");
      //   log("accessToken $accessToken");
      //   log("-------------------------------");
      //   if (checkAuthToken == true &&
      //       accessToken != null &&
      //       accessToken.isNotEmpty &&
      //       isValidAccessToken != null &&
      //       isValidAccessToken.isNotEmpty) {
      //     await SharedPreferenceService().setBool(key: isValidToken, value: true);
      //     Map<String, dynamic> decodedToken =
      //         JwtDecoder.decode(accessToken.toString());
      //     DecodeTokenModel decodeTokenModel =
      //         DecodeTokenModel.fromJson(decodedToken);
      //     log("decodeTokenModel.sub ${jsonEncode(decodeTokenModel)}");

      //     String email = decodeTokenModel.sub??"";
      //     // String email = "ankit.kumar@guitarcenter.com";
      //     SharedPreferenceService()
      //         .setKey(key: loggedInUserEmail, value: '${email}');
      //     // if (!kIsWeb)
      //     FirebaseAnalytics.instance.setUserProperty(
      //     //     name: 'loggedUserEmail',
      //     //     value: email,
      //     //   );
      //     await generateAccessToken();
      //     String agentId = await getAgentProfile(email);
      //     if (agentId.isNotEmpty) {
      //       await SharedPreferenceService()
      //           .setKey(key: oktaAccessToken, value: accessToken ?? "");
      //       await SharedPreferenceService()
      //           .setKey(key: oktaIdToken, value: idToken ?? "");
      //       _controller.add(AuthenticationStatus.authenticated);
      //       //periodicTimeCall(context,email,decodeTokenModel.iat.toString(),decodeTokenModel.exp.toString(),agentId);
      //       return AuthenticationStatus.authenticated;
      //     } else {
      //       _controller.add(AuthenticationStatus.unauthenticated);
      //       return AuthenticationStatus.unauthenticated;
      //     }
      //   } else {
      //     await OktaAuthProvider.of(context)?.authService.authorize();
      //     var accessToken =
      //         await OktaAuthProvider.of(context)?.authService.getAccessToken();
      //     var idToken =
      //         await OktaAuthProvider.of(context)?.authService.getIdToken();
      //     var checkAuth =
      //         await OktaAuthProvider.of(context)?.authService.isAuthenticated();
      //     String? isValid = await OktaAuthProvider.of(context)
      //         ?.authService
      //         .introspectAccessToken();
      //     if (checkAuth == true && isValid != null && isValid.isNotEmpty) {
      //       await SharedPreferenceService()
      //           .setBool(key: isValidToken, value: true);
      //       Map<String, dynamic> decodedToken =
      //           JwtDecoder.decode(accessToken.toString());
      //       DecodeTokenModel decodeTokenModel =
      //           DecodeTokenModel.fromJson(decodedToken);

      //       String email = decodeTokenModel.sub??"";
      //       // String email = "ankit.kumar@guitarcenter.com";
      //       SharedPreferenceService()
      //           .setKey(key: loggedInUserEmail, value: '${email}');
      //       // if (!kIsWeb)
      //       FirebaseAnalytics.instance.setUserProperty(
      //       //     name: 'loggedUserEmail',
      //       //     value: email,
      //       //   );
      //       await generateAccessToken();
      //       String agentId = await getAgentProfile(email);
      //       if (agentId.isNotEmpty) {
      //         await SharedPreferenceService()
      //             .setKey(key: oktaAccessToken, value: accessToken ?? "");
      //         await SharedPreferenceService()
      //             .setKey(key: oktaIdToken, value: idToken ?? "");
      //         _controller.add(AuthenticationStatus.authenticated);
      //         //periodicTimeCall(context,email,decodeTokenModel.iat.toString(),decodeTokenModel.exp.toString(),agentId);
      //         return AuthenticationStatus.authenticated;
      //       } else {
      //         _controller.add(AuthenticationStatus.unauthenticated);
      //         return AuthenticationStatus.unauthenticated;
      //       }
      //     } else {
      //       _controller.add(AuthenticationStatus.unauthenticated);
      //       return AuthenticationStatus.unauthenticated;
      //     }
      //   }
      // }
    } catch (e) {
      print("login error ${e.toString()}");
      return AuthenticationStatus.unauthenticated;
    }
  }

  void dispose() => _controller.close();
}
