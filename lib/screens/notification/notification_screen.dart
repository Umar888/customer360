import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/approval_process_bloc/approval_process_bloc.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/models/promotion_model.dart';
import 'package:gc_customer_app/models/approval_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/notification/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  late ApprovalProcessBloC approvalProcessBloC;
  StreamSubscription? streamSubscription;
  final StreamController<bool> isLoadingController =
      StreamController<bool>.broadcast()..add(false);
  List<ApprovalModel> approvalModels = [];

  List<PromotionModel> expiredPromotions = [];
  @override
  void initState() {
    super.initState();
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'ApprovalNotificationsScreen');
    WidgetsBinding.instance.addObserver(this);
    approvalProcessBloC = context.read<ApprovalProcessBloC>();
    streamSubscription = approvalProcessBloC.stream.listen((event) {
      isLoadingController.add(false);
      if (event is ApprovalProcessSuccess) {
        if (event.itemIndex == null) {
          setState(() {
            approvalModels.clear();
            approvalModels.addAll(event.approvalModels ?? []);
          });
        }
      } else if (event is ApprovalProcessProgress) {
        isLoadingController.add(true);
      }
    });
    approvalProcessBloC.add(LoadApprovalProcess());
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('NOTIFICATIONS',
            style: TextStyle(
                fontFamily: kRubik,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 15)),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: approvalModels.length,
            itemBuilder: (context, index) {
              return NotificationItem(
                approvalModel: approvalModels[index],
                index: index,
              );
            },
          ),
          StreamBuilder<bool>(
              stream: isLoadingController.stream,
              builder: (context, snapshot) {
                if (snapshot.data == true)
                  return Center(child: CircularProgressIndicator());
                return SizedBox.shrink();
              }),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed)
    //   context.read<ApprovalProcessBloC>().add(LoadApprovalProcesss());
  }
}
