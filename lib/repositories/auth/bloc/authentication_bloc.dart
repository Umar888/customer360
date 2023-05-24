import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../repository/authentication_repository.dart';


part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required AuthenticationRepository authenticationRepository}):_authenticationRepository = authenticationRepository, super(AuthenticationState.unknown()) {
    _authenticationStatusSubscription = _authenticationRepository.status.listen((status) {
            return add(AuthenticationStatusChanged(status));
          },
    );
    on<AuthenticationStatusChanged>((event, emit) async {
      emit(await _mapAuthenticationStatusChangedToState(event));
    });
    on<AuthenticationLogoutRequested>((event, emit) async {
      _authenticationRepository.logOut(event);
    });
  }

  final AuthenticationRepository _authenticationRepository;

  late StreamSubscription<AuthenticationStatus> _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }

  Future<AuthenticationState> _mapAuthenticationStatusChangedToState(AuthenticationStatusChanged event) async {
    switch (event.status) {
      case AuthenticationStatus.authenticated:
        var user = (await _tryGetUser());
        return user != null
            ? AuthenticationState.authenticated(user)
            : AuthenticationState.unauthenticated();
      case AuthenticationStatus.unauthenticated:
        return AuthenticationState.unauthenticated();
      default:
        return AuthenticationState.unknown();
    }
  }

  Future<String?> _tryGetUser() async {
    try {
      var userMap = await SharedPreferenceService().getValue(loggedInUserEmail);
      //print("userMap $userMap");
      if(userMap == null){
        return "";
      }else{
        return userMap;
      }
    } on Exception {
      return null;
    }
  }
}
