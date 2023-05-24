part of 'case_history_screen_bloc.dart';

abstract class CaseHistoryScreenEvent extends Equatable {
  CaseHistoryScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadData extends CaseHistoryScreenEvent {
  LoadData();
  @override
  List<Object> get props => [];
}
