import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/settings_screen_bloc/settings_screen_bloc.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/logout_button_web.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/app_bar_widget.dart';
import '../../common_widgets/settings_tiles_widget.dart';
import '../../constants/text_strings.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';
import '../../services/storage/shared_preferences_service.dart';
import '../../theme.dart';
import '../../utils/theme_provider.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  SettingsScreenBloc? settingsScreenBloc;
  @override
  void initState() {
    super.initState();
    // if (!kIsWeb)
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'SettingScreen');
    settingsScreenBloc = context.read<SettingsScreenBloc>();
    settingsScreenBloc!.add(LoadSettingsChecks());
  }

  bool? correspondanceCheck = false;
  bool? emailCheck = false;
  bool? voiceemailCheck = false;
  bool? directMailCheck = false;
  bool? smsCheck = false;
  bool? allServicesCheck = false;
  bool? promotionalCheck = false;
  bool? announcementCheck = false;
  bool? specialEventCheck = false;
  bool? discountCheck = false;
  bool? lessonsCheck = false;
  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      // drawer: widthOfScreen.isMobileWebDevice() && kIsWeb
      //     ? DrawerLandingWidget()
      //     : null,
      backgroundColor: kIsWeb ? ColorSystem.webBackgr : null,
      appBar: AppBar(
        backgroundColor: kIsWeb
            ? ColorSystem.webBackgr
            : Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text('SETTINGS',
            style: TextStyle(
                fontFamily: kRubik,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 15)),
        actions: [
          if (!widthOfScreen.isMobileWebDevice() && kIsWeb) LogoutButtonWeb()
        ],
      ),
      body: BlocBuilder<SettingsScreenBloc, SettingsScreenState>(
        builder: (context, state) {
          if (state is LoadSettingCheckSuccess) {
            return Container(
              decoration: kIsWeb
                  ? BoxDecoration(
                      color: ColorSystem.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ColorSystem.blue1.withOpacity(0.15),
                          blurRadius: 12.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    )
                  : null,
              padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb ? 30 : widthOfScreen * 0.04,
                  vertical: kIsWeb ? 25 : widthOfScreen * 0.04),
              margin: kIsWeb
                  ? EdgeInsets.symmetric(horizontal: 30, vertical: 20)
                  : null,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manualPreftxt,
                        style: textThem.headline2,
                      ),
                      SizedBox(
                        height: heightOfScreen * 0.02,
                      ),
                      ...state.getSettingsModel!.settings.map<Widget>((sett) {
                        var index = state.getSettingsModel!.settings.indexWhere(
                          (e) => e.type == sett.type,
                        );
                        if (index == 1) return SizedBox.shrink();
                        return Column(
                          children: [
                            SettingTilesWidget(
                              widthOfScreen: widthOfScreen,
                              nameOfAssociate:
                                  sett.type.replaceAll('Status', ''),
                              iconpath:
                                  'assets/icons/${sett.type.split('Status').first.toLowerCase().replaceAll(' ', '_')}icon.svg',
                              toggleButtonStatus: sett.isChecked!,
                              isSaving: sett.isSaving!,
                              onChanged: (bool val) {
                                dynamic jsonObject;
                                sett.isChecked = val;
                                jsonObject = sett.toJson();
                                settingsScreenBloc!.add(SaveSettings(
                                    incomingObject: jsonObject, index: index));
                              },
                              isDisabled: sett.isDisabled,
                              onClick: kIsWeb ? false : sett.onClickButton!,
                            ),
                            SizedBox(
                              height: heightOfScreen * 0.02,
                            ),
                          ],
                        );
                      }).toList(),
/*
                      FutureBuilder<String?>(
                        future:SharedPreferenceService().getValue(mode),
                        builder: (context,value) {
                          if(value.hasData){
                            print("value.data ${value.data}");
                            return SettingTilesWidget(
                              widthOfScreen: widthOfScreen,
                              nameOfAssociate: "Dark Mode",
                              iconpath: 'assets/icons/moon.svg',
                              toggleButtonStatus: value.data == "dark",
                              isSaving: false,
                              onChanged: (bool value) async {
                                if(value){
                                  await SharedPreferenceService().setKey(key: mode, value: "dark");
                                  final providerTheme = Provider.of<ThemeProvider>(context,listen: false);
                                  Future.delayed(Duration.zero,(){
                                    providerTheme.setThemeData(themeDark);
                                  });
                                }
                                else{
                                  await SharedPreferenceService().setKey(key: mode, value: "light");
                                  final providerTheme = Provider.of<ThemeProvider>(context,listen: false);
                                  Future.delayed(Duration.zero,(){
                                    providerTheme.setThemeData(themeLight);
                                  });
                                }
                              },
                              isDisabled: false,
                              onClick: kIsWeb ? false :true,
                            );
                          }
                          else{
                           return Container();
                          }
                        }
                      ),
                      SizedBox(
                        height: heightOfScreen * 0.02,
                      ),
*/
                    ],
                  ),
                ],
              ),
            );
          } else if (state is LoadSettingChecksFailure) {
            return Center(
              child: AspectRatio(
                aspectRatio: 2,
                child: Column(
                  children: [
                    Text(
                      'Ooops! Something went Wrong \n Try Again Later',
                      textAlign: TextAlign.center,
                      style: textThem.headline2,
                    ),
                    SvgPicture.asset(
                      IconSystem.accessoriesNotFound,
                      package: 'gc_customer_app',
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              height: heightOfScreen,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
