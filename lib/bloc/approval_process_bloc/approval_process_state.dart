part of 'approval_process_bloc.dart';

@immutable
abstract class ApprovalProcessState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ApprovalProcessInitial extends ApprovalProcessState {}

class ApprovalProcessProgress extends ApprovalProcessState {}

class ApprovalProcessFailure extends ApprovalProcessState {}

class ApprovalProcessSuccess extends ApprovalProcessState {
  final List<ApprovalModel>? approvalModels;
  final String? message;
  final int? itemIndex;
  ApprovalProcessSuccess({this.approvalModels, this.message, this.itemIndex});

  @override
  List<Object?> get props => [approvalModels, message, itemIndex];
}
