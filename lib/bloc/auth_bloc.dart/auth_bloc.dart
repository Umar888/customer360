import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'dart:html' as html;

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloC extends Bloc<AuthEvent, AuthState> {
  String token = '';

  AuthBloC() : super(AuthInitial()) {
    on<Authentication>(
      (event, emit) async {
        emit(AuthProgress());

        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          var result = await FlutterWebAuth2.authenticate(
            url:
                "https://guitarcenter.okta.com/oauth2/v1/authorize?client_id=$kOktaClientId&response_type=id_token&scope=openid%20profile&redirect_uri=$kOktaRedirectUri&nonce=$kwebOktaNonce&state=$kwebOktaState",
            callbackUrlScheme: "https",
          );
          //     .timeout(
          //   Duration(seconds: 1),
          //   onTimeout: () => 'temp token',
          // );

          final results = result.split('id_token=');
          token = results.last;
        }

        // print('---- $token');
        // SharedPreferenceService().setUserToken(authToken: token);
        emit(AuthSuccess(token: token));
        return;
      },
    );

    on<LogOutEvent>(
      (event, emit) async {
        launchUrl(
          Uri.parse('https://guitarcenter.okta.com/oauth2/v1/logout?id_token_hint=${token}'),
          webOnlyWindowName: '_self',
        );
        await SharedPreferenceService().setKey(key: agentEmail, value: '');
        await SharedPreferenceService().setKey(key: agentId, value: '');
        token = '';
        emit(AuthSuccess(token: token));
      },
    );
  }
}
