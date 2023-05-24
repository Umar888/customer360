import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/data/reporsitories/promotions_screen_repository/promotions_screen_repository.dart';
import 'package:gc_customer_app/models/promotion_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx_plus/webviewx_plus.dart' as wbxp;

class PromotionDetailScreen extends StatefulWidget {
  final PromotionModel promotion;
  PromotionDetailScreen({super.key, required this.promotion});

  @override
  State<PromotionDetailScreen> createState() => _PromotionDetailScreenState();
}

class _PromotionDetailScreenState extends State<PromotionDetailScreen> {
  final format = DateFormat('MMM dd, yyyy');
  late WebViewController _controller;
  late wbxp.WebViewXController webviewController;
  StreamSubscription? navigatorListener;
  var counter = 0;

  @override
  void initState() {
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'PromotionDetailScreen');
    if (kIsWeb) {
      context.read<NavigatorWebBloC>().selectedTabIndex = 6;
      navigatorListener =
          context.read<NavigatorWebBloC>().selectedTab.listen((event) {
        if (event != 6 && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    navigatorListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: FutureBuilder(
          future: (widget.promotion.id ?? '').isNotEmpty
              ? PromotionBloC(PromotionsScreenRepository())
                  .getPromotionDetail(widget.promotion.id ?? '')
              : PromotionBloC(PromotionsScreenRepository())
                  .getPromotionDetailService(
                      widget.promotion.serviceCommunicationId ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              var promotion = snapshot.data!;
              if (promotion is! PromotionModel) {
                if (kIsWeb) {
                  return Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: wbxp.WebViewX(
                      initialContent: promotion as String,
                      initialSourceType: wbxp.SourceType.html,
                      width: 1000,
                      height: MediaQuery.of(context).size.height,
                    ),
                  );
                }
                return WebView(
                  initialUrl: 'about:blank',
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    _loadHtmlFromAssets(promotion as String);
                  },
                  navigationDelegate: (request) {
                    counter++;

                    if (counter <= 2) {
                      return NavigationDecision.navigate;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Limited to Restricted Viewing"),
                    ));
                    return NavigationDecision.prevent;
                  },
                );
              }
              return ListView(
                padding: EdgeInsets.only(left: 31),
                children: [
                  Text(
                    widget.promotion.subject ?? '',
                    maxLines: 100,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.fromAddress ?? '',
                          maxLines: 100,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          format.format(DateTime.parse(promotion.messageDate ??
                              DateTime.now().toString())),
                          style: TextStyle(
                              color: ColorSystem.secondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: HtmlWidget(
                      promotion.htmlBody ?? '',
                      onErrorBuilder: (context, element, error) {
                        return SizedBox.shrink();
                      },
                      onLoadingBuilder: (context, element, loadingProgress) =>
                          CircularProgressIndicator(),
                      textStyle: TextStyle(fontSize: 14),
                      onTapUrl: (url) => Future.value(false),
                    ),
                  ),
                ],
              );
            }
            return Padding(
              padding: EdgeInsets.only(left: kIsWeb ? 30 : 8),
              child: Text(
                widget.promotion.subject ?? '',
                maxLines: 100,
                style: Theme.of(context).textTheme.caption,
              ),
            );
          }),
    );
  }

  _loadHtmlFromAssets(String promotion) async {
    String fileText = await rootBundle.loadString(promotion);
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
    return fileText;
  }

  PreferredSize _appbar() {
    double widthOfScreen = MediaQuery.of(context).size.width;

    return PreferredSize(
      preferredSize: Size.fromHeight(65),
      child: AppBarWidget(
        paddingFromleftLeading: kIsWeb ? 0 : widthOfScreen * 0.034,
        paddingFromRightActions: widthOfScreen * 0.034,
        textThem: Theme.of(context).textTheme,
        leadingWidget: Container(
          height: 45,
          width: 45,
          child: Icon(
            Icons.chevron_left_rounded,
            size: 42,
            color: ColorSystem.black.withOpacity(0.7),
          ),
        ),
        onPressedLeading: () => Navigator.of(context).pop(),
        titletxt: 'Email Promo',
        actionOnPress: () {},
        actionsWidget: SizedBox.shrink(),
      ),
    );
  }
}
