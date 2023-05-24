part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  AuthenticationState._(
      this.user, {
        this.status = AuthenticationStatus.unknown,
        this.isLoggedIn = false,
      });

  AuthenticationState.unknown() : this._("",isLoggedIn: false);

  AuthenticationState.authenticated(String user)
      : this._(user,status: AuthenticationStatus.authenticated,isLoggedIn: true);

  AuthenticationState.unauthenticated()
      : this._("",status: AuthenticationStatus.unauthenticated,isLoggedIn: false);

  final AuthenticationStatus status;
  final String user;
  final bool isLoggedIn;

  @override
  List<Object> get props => [status, user,isLoggedIn];
}
