import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/profile_screen_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/profile/profile_screen_repository.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/screens/profile/profile_screen.dart';
import 'package:gc_customer_app/screens/profile/profile_web_screen.dart';

class ProfileScreenMain extends StatelessWidget {
  final UserProfile? userProfile;
  final Function? onPressed;
  final LandingScreenState? landingScreenState;
  ProfileScreenMain(
      {Key? key, this.userProfile, this.onPressed, this.landingScreenState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileScreenBloc>(
        create: (context) => ProfileScreenBloc(ProfileScreenRepository()),
        child: kIsWeb
            ? ProfileWebScreen(
                userProfile: userProfile,
                onPressed: onPressed,
                landingScreenState: landingScreenState,
              )
            : ProfileScreen(userProfile: userProfile));
  }
}
