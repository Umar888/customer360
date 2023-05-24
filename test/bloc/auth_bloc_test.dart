import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:gc_customer_app/bloc/auth_bloc.dart/auth_bloc.dart';
import 'package:gc_customer_app/bloc/task_details_bloc/task_details_bloc.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthBloC? authBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  blocTest<AuthBloC, AuthState>(
    'Authentication',
    setUp: () => authBloc = AuthBloC(),
    tearDown: () => authBloc = null,
    build: () => authBloc!,
    act: (bloc) => bloc.add(Authentication()),
    expect: () => [
      AuthProgress(),
      AuthSuccess(token: ""),
    ],
  );
}
