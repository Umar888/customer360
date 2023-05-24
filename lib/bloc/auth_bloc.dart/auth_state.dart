part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthProgress extends AuthState {}

class AuthFailure extends AuthState {}

class AuthSuccess extends AuthState {
  final String? token;
  AuthSuccess({this.token});

  @override
  List<Object?> get props => [token];
}
