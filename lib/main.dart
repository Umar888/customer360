import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/repositories/auth/repository/authentication_repository.dart';
import 'package:gc_customer_app/services/fcm/firebase_messaging.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
    // FCM firebaseMessaging = FCM();
    // await firebaseMessaging.setNotifications();
    // firebaseMessaging.streamCtrl.stream.listen((msgData) {
    //   debugPrint('messageData $msgData');
    // });
  } else {
    await SharedPreferenceService().setKey(key: agentEmail, value: '');
    await SharedPreferenceService().setKey(key: agentId, value: '');
  }
  runApp(App(authenticationRepository: AuthenticationRepository(),deeplinkMessage: null));
}
