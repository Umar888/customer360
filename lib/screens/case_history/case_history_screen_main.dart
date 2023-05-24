import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/case_history_screen_bloc/case_history_screen_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/case_history_screen_repository/case_history_screen_repository.dart';

import 'case_history_screen.dart';

class CaseHistoryScreenMain extends StatelessWidget {
  CaseHistoryScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CaseHistoryScreenBloc>(
        create: (context) => CaseHistoryScreenBloc(
            caseHistoryScreenRepository: CaseHistoryScreenRepository()),
        child: CaseHistoryScreen());
  }
}
