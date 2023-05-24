import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/auth_bloc.dart/auth_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';

class LogoutButtonWeb extends StatelessWidget {
  LogoutButtonWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          context.read<AuthBloC>().add(LogOutEvent());
          context.read<LandingScreenBloc>().add(RemoveCustomer());
        },
        child: Row(
          children: [
            Text(
              'Log out',
              style: TextStyle(color: Colors.black),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.logout,
                color: Colors.black,
                size: 20,
              ),
            )
          ],
        ));
  }
}
