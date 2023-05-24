import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/repositories/auth/repository/authentication_repository.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_web_page.dart';
import 'package:gc_customer_app/services/deeplinking/deeplinks.dart';

import '../main_page/screens/main_page.dart';
import 'landing_screen_page.dart';

class LandingScreenMain extends StatelessWidget {
  final UserProfile? userProfile;
  final AuthenticationRepository authenticationRepository;
  final AuthenticationStatus authenticationStatus;
  final Map<String, dynamic>? notificationMessage;
  final Map<String, String>? deeplinkMessage;

  LandingScreenMain(
      {Key? key,
      this.userProfile,
      required this.authenticationRepository,
      required this.deeplinkMessage,
      required this.authenticationStatus,
      this.notificationMessage})
      : super(key: key);
  static Route route(AuthenticationRepository authenticationRepository,
      AuthenticationStatus authenticationStatus,
      {Map<String, dynamic>? notificationMessage,Map<String, String>? deeplinkMessage}) {
    return MaterialPageRoute<void>(
        builder: (_) => LandingScreenMain(
              authenticationRepository: authenticationRepository,
          deeplinkMessage: deeplinkMessage,
              authenticationStatus: authenticationStatus,
              notificationMessage: notificationMessage,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? LandingScreenWebPage(userProfile: userProfile)
        : MainPage(
            authenticationRepository: authenticationRepository,
            authenticationStatus: authenticationStatus,
            notificationMessage: notificationMessage,
            deeplinkMessage: deeplinkMessage,
          );
  }
}
