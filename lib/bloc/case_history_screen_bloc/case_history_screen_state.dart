// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'case_history_screen_bloc.dart';

abstract class CaseHistoryScreenState extends Equatable {
  CaseHistoryScreenState();

  @override
  List<Object> get props => [];
}

class CaseHistoryScreenProgress extends CaseHistoryScreenState {}

class CaseHistoryScreenFailure extends CaseHistoryScreenState {}

class CaseHistoryScreenSuccess extends CaseHistoryScreenState {
  final CaseHistoryChartDetails? caseHistoryChartDetails;
  final OpenCasesListModel? openCasesListModel;
  final CaseHistoryListModelClass? caseHistoryListModelClass;
  CaseHistoryScreenSuccess({
    required this.caseHistoryChartDetails,
    required this.openCasesListModel,
    required this.caseHistoryListModelClass,
  });
  @override
  List<Object> get props => [openCasesListModel!];
}
