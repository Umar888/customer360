import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/models/promotion_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/logout_button_web.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/drawer_widget.dart';
import 'package:gc_customer_app/screens/promotions/active_promotion.dart';
import 'package:gc_customer_app/screens/promotions/top_promotion.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

import 'active_promotions.dart';
import 'expried_promotion.dart';

class PromotionsScreen extends StatefulWidget {
  PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  late PromotionBloC promotionBloC;

  List<PromotionModel> expiredPromotions = [];
  @override
  void initState() {
    super.initState();
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'PromotionsScreen');
    promotionBloC = context.read<PromotionBloC>();
    promotionBloC.add(LoadPromotions());
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: _appbar(),
      // drawer: widthOfScreen.isMobileWebDevice() && kIsWeb
      //     ? DrawerLandingWidget()
      //     : null,
      backgroundColor: kIsWeb ? ColorSystem.webBackgr : null,
      appBar: AppBar(
        backgroundColor: kIsWeb ? ColorSystem.webBackgr : null,
        centerTitle: true,
        title: Text('PROMOTIONS',
            style: TextStyle(
                fontFamily: kRubik,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 15)),
        actions: [
          if (!widthOfScreen.isMobileWebDevice() && kIsWeb) LogoutButtonWeb()
        ],
      ),
      body: BlocBuilder<PromotionBloC, PromotionScreenState>(
          builder: (context, state) {
        if (state is PromotionScreenSuccess) {
          var topPromotion = state.topPromotion;
          var activePromotions = state.activePromotions;
          if (topPromotion == null && (activePromotions ?? []).isEmpty) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(child: NoDataFound(fontSize: 16)),
            );
          }
          return ListView(
            children: [
              promotionTitle('Top Promotion'),
              if (topPromotion != null) TopPromotion(topPromotion),
              promotionTitle('Active Promotions'),
              // ActivePromotionsScreen(promotions: activePromotions ?? []),
              ...activePromotions
                      ?.asMap()
                      .entries
                      .map<Widget>((entry) => ActivePromotion(
                          promotion: entry.value, index: entry.key))
                      .toList() ??
                  []
              // promotionTitle('Expired/other Promotion'),
              // ...expiredPromotions
              //     .map((ep) => ExpiredPromotion(promotion: ep))
              //     .toList(),
            ],
          );
        }
        if (state is PromotionScreenFailure) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(child: NoDataFound(fontSize: 16)),
          );
        }
        return SizedBox(
            height: double.infinity,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ));
      }),
    );
  }

  Widget promotionTitle(String title) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Text(
          title,
          style: TextStyle(
              color: ColorSystem.romanSilver, fontWeight: FontWeight.w500),
        ),
      );

  // PreferredSize _appbar() {
  //   double widthOfScreen = MediaQuery.of(context).size.width;

  //   return PreferredSize(
  //     preferredSize: Size.fromHeight(65),
  //     child: AppBarWidget(
  //       paddingFromleftLeading: widthOfScreen * 0.034,
  //       paddingFromRightActions: widthOfScreen * 0.034,
  //       textThem: Theme.of(context).textTheme,
  //       leadingWidget: kIsWeb
  //           ? SizedBox.shrink()
  //           : Container(
  //               height: 48,
  //               width: 48,
  //               child: Icon(
  //                 Icons.chevron_left_rounded,
  //                 size: 42,
  //                 color: ColorSystem.black.withOpacity(0.7),
  //               ),
  //             ),
  //       onPressedLeading: () => Navigator.of(context).pop(),
  //       titletxt: 'PROMOTIONS',
  //       actionsWidget: kIsWeb
  //           ? SizedBox.shrink()
  //           : SvgPicture.asset(IconSystem.addIcon),
  //       actionOnPress: () => () {},
  //     ),
  //   );
  // }
}
