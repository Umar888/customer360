import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/auth_bloc.dart/auth_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/common_widgets/activity_button.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/agent_widget.dart';
import 'package:gc_customer_app/common_widgets/other_tile_widget.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/profile_widget.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:intl/intl.dart';

class DrawerLandingWidget extends StatefulWidget {
  DrawerLandingWidget({Key? key}) : super(key: key);

  @override
  State<DrawerLandingWidget> createState() => _DrawerLandingWidgetState();
}

class _DrawerLandingWidgetState extends State<DrawerLandingWidget> {
  late NavigatorWebBloC _navigatorBloC = context.read<NavigatorWebBloC>();
  late LandingScreenBloc landingScreenBloc;
  @override
  void initState() {
    super.initState();
    landingScreenBloc = context.read<LandingScreenBloc>();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return BlocBuilder<LandingScreenBloc, LandingScreenState>(
        builder: (context, landingScreenState) {
      CustomerInfoModel? customerInfoModel =
          landingScreenState.customerInfoModel;
      Records? userInfo = customerInfoModel!.records!.first;
      return StreamBuilder<int>(
          stream: _navigatorBloC.selectedTab,
          initialData: 0,
          builder: (context, snapshot) {
            var index = snapshot.data ?? 0;
            return Drawer(
              child: ListView(
                padding: EdgeInsets.only(bottom: 100),
                children: [
                  _header(theme, landingScreenState, userInfo, index),
                  _profileTabs(theme, userInfo, index),
                  _ordersButtons(landingScreenState, index),
                  _otherTabs(theme, landingScreenState, index),
                  _gearAdvisor(landingScreenState),
                ],
              ),
            );
          });
    });
  }

  Widget _header(TextTheme theme, LandingScreenState landingScreenState,
          Records userInfo, int index) =>
      Container(
        width: 350,
        height: 250,
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          index = 0;
                          SharedPreferenceService()
                              .setKey(key: agentId, value: '');
                          SharedPreferenceService()
                              .setKey(key: agentEmail, value: '');
                          _navigatorBloC.selectedTabIndex = 0;
                          landingScreenBloc.add(LoadData());
                        },
                        icon: SvgPicture.asset(IconSystem.leaveIcon)),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Hi, ${userInfo.firstName ?? ''}',
                          maxLines: 2,
                          style: theme.caption?.copyWith(fontSize: 32),
                        ),
                        Text(
                          DateFormat('E, MMM dd').format(DateTime.now()),
                          maxLines: 2,
                          style: theme.caption?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.67),
                        ),
                      ],
                    ),
                  ],
                ),
                // IconButton(
                //     onPressed: () {
                //       context.read<AuthBloC>().add(LogOutEvent());
                //     },
                //     icon: Image.asset(IconSystem.logout))
              ],
            ),
            SizedBox(height: 24),
            ProfileLandingWidget(
              landingScreenState: landingScreenState,
              onPressed: () => selectTab(0),
            )
          ],
        ),
      );

  Widget _profileTabs(TextTheme theme, Records userInfo, int index) {
    var divider = Divider(
      height: 4,
      color: ColorSystem.black.withOpacity(0.04),
    );
    return Container(
      padding: EdgeInsets.only(left: 14),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: ShadowSystem.webWidgetShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14, top: 31, bottom: 27),
            child: Text(
              '${userInfo.firstName?.toUpperCase()} PROFILE',
              style: theme.bodyText1
                  ?.copyWith(color: ColorSystem.lavender2, letterSpacing: 2.33),
            ),
          ),
          divider,
          ListTile(
            title: Text(
              recommendedtxt,
              style: theme.bodyText2?.copyWith(
                  fontWeight: index == 1 ? FontWeight.w600 : FontWeight.w400),
            ),
            onTap: (() => selectTab(1)),
            trailing: index == 1 ? selectedWidget() : SizedBox.shrink(),
            contentPadding: EdgeInsets.only(left: 16),
          ),
          divider,
          ListTile(
            title: Text(
              favoriteBrandtxt,
              style: theme.bodyText2?.copyWith(
                  fontWeight: index == 2 ? FontWeight.w600 : FontWeight.w400),
            ),
            onTap: (() => selectTab(2)),
            trailing: index == 2 ? selectedWidget() : SizedBox.shrink(),
            contentPadding: EdgeInsets.only(left: 16),
          ),
          divider,
          // ListTile(
          //   title: Text(
          //     smartTriggerTasks,
          //     style: theme.bodyText2?.copyWith(
          //         fontWeight: index == 3 ? FontWeight.w600 : FontWeight.w400),
          //   ),
          //   onTap: (() => selectTab(3)),
          //   trailing: index == 3 ? selectedWidget() : SizedBox.shrink(),
          //   contentPadding: EdgeInsets.only(left: 16),
          // ),
          // divider,
          // ListTile(
          //   title: Text(
          //     customerRemindertxt,
          //     style: theme.bodyText2?.copyWith(
          //         fontWeight: index == 4 ? FontWeight.w600 : FontWeight.w400),
          //   ),
          //   onTap: (() => selectTab(4)),
          //   trailing: index == 4 ? selectedWidget() : SizedBox.shrink(),
          //   contentPadding: EdgeInsets.only(left: 16),
          // ),
          SizedBox(height: 8)
        ],
      ),
    );
  }

  Widget _ordersButtons(LandingScreenState landingScreenState, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActivityButton(
            onTap: () => selectTab(3),
            widthOfScreen: MediaQuery.of(context).size.width,
            heightOfScreen: MediaQuery.of(context).size.height,
            buttonColor: AppColors.pinkHex,
            iconImage: SvgPicture.asset(IconSystem.shoppingBag),
            text: 'ORDERS',
            isSelected: index == 5,
            isLoading: false,
          ),
        ],
      ),
    );
  }

  Widget _otherTabs(
      TextTheme theme, LandingScreenState landingScreenState, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(othertxt,
              style: TextStyle(
                  color: ColorSystem.blueGrey,
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ),
        SizedBox(height: 15),
        OtherTilesWidget(
          widthOfScreen: MediaQuery.of(context).size.width,
          textThem: theme,
          nameOfAssociate: 'Custom',
          subtitleOftile: 'Recommendations',
          iconpath: IconSystem.treeStructureThinIcons,
          isWidget: false,
          ontapList: () => selectTab(5),
          isSelected: index == 7,
        ),
        OtherTilesWidget(
          widthOfScreen: MediaQuery.of(context).size.width,
          textThem: theme,
          nameOfAssociate: 'Email',
          subtitleOftile: 'Promotions',
          iconpath: IconSystem.emailSettingIcon,
          isWidget: false,
          ontapList: () => selectTab(6),
          isSelected: index == 8,
        ),
        OtherTilesWidget(
          widthOfScreen: MediaQuery.of(context).size.width,
          textThem: theme,
          nameOfAssociate: 'Settings',
          subtitleOftile: 'Opt-Out/ Opt-In',
          iconpath: IconSystem.runIcon,
          isWidget: false,
          ontapList: () => selectTab(7),
          isSelected: index == 9,
        ),
      ],
    );
  }

  Widget _gearAdvisor(LandingScreenState landingScreenState) {
    return Padding(
      padding: EdgeInsets.only(top: 24, left: 14, right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(gearAdvisor,
              style: TextStyle(
                  color: ColorSystem.blueGrey,
                  fontFamily: kRubik,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          SizedBox(height: 10),
          BlocProvider.value(
            value: landingScreenBloc,
            child: AgentWidget(),
          ),
        ],
      ),
    );
  }

  void selectTab(int index) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    _navigatorBloC.selectedTabIndex = index;
  }

  Widget selectedWidget() => Container(
        height: 60,
        width: 5,
        decoration: BoxDecoration(
            color: ColorSystem.lavender3,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(55),
              bottomLeft: Radius.circular(55),
            )),
      );
}
