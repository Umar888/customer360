import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/settings_screen_bloc/settings_screen_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/settings_screen_repository/settings_screen_repository.dart';
import 'package:gc_customer_app/screens/settings_screen/settings_screen.dart';

class SettingsScreenMain extends StatelessWidget {
  SettingsScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsScreenBloc>(
        create: (context) => SettingsScreenBloc(
            settingsScreenRepository: SettingsScreenRepository()),
        child: SettingScreen());
  }
}
