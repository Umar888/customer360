import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_okta_auth_sdk/base_request.dart';
import 'package:flutter_okta_auth_sdk/flutter_okta_auth_sdk.dart';
import 'package:gc_customer_app/primitives/constants.dart';



class AuthOktaService {
  var flutterOktaAuthSdk = FlutterOktaAuthSdk();
  static const String oktaDomain = oktaOrgUrl;
  static const String oktaAuthorizer = 'default';

  static const String oktaClientId = oktaTestClientId;

  static const String oktaIssuerUrl =
      'https://$oktaDomain';
  static const String oktaDiscoveryUrl =
      'https://$oktaDomain/.well-known/openid-configuration';

  // static const String oktaRedirectUrl =
  //     'com.customer360:/callback';
  // static const String oktaLogoutRedirectUrl =
  //     'com.customer360:/';

  static const String oktaRedirectUrl =
      'com.okta.guitarcenter:/callback';
  static const String oktaLogoutRedirectUrl =
      'com.okta.guitarcenter:/';

  static final oktaBaseRequest = BaseRequest(
      issuer: oktaIssuerUrl,
      clientId: oktaClientId,
      discoveryUrl: oktaDiscoveryUrl,
      endSessionRedirectUri: oktaLogoutRedirectUrl,
      redirectUrl: oktaRedirectUrl,
      scopes: ["openid", "profile", "offline_access"]);

  Future createConfig() async {
//    print("oktaBaseRequest ${convertBaseRequestToMap(oktaBaseRequest)}");
    await flutterOktaAuthSdk.createConfig(oktaBaseRequest);
  }

  Future authorize() async {
    try {
      print("i am authorzing");
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      await flutterOktaAuthSdk.signIn();
    } catch (e) {
      print("e.toString() ${e.toString()}");
    }
  }

  Future logout() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      await flutterOktaAuthSdk.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getUser() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.getUser();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future getSessions() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.getUser();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<bool> isAuthenticatedStream() async* {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      yield await flutterOktaAuthSdk.isAuthenticated();
    } catch (e) {
      debugPrint(e.toString());
      yield false;
    }
  }
  Future<bool> isAuthenticated() async {

    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.isAuthenticated();
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.getAccessToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> getIdToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.getIdToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<bool?> revokeAccessToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.revokeAccessToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<bool?> revokeIdToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.revokeIdToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<bool?> revokeRefreshToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.revokeRefreshToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<bool?> clearTokens() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.clearTokens();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> introspectAccessToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.introspectAccessToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> introspectIdToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.introspectIdToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> introspectRefreshToken() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.introspectRefreshToken();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> refreshTokens() async {
    try {
      if (flutterOktaAuthSdk.isInitialized == false) {
        await createConfig();
      }
      return await flutterOktaAuthSdk.refreshTokens();
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}