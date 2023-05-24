part of 'approval_process_bloc.dart';

abstract class ApprovalProcessEvent extends Equatable {
  ApprovalProcessEvent();
}

class LoadApprovalProcess extends ApprovalProcessEvent {
  LoadApprovalProcess();

  @override
  List<Object?> get props => [];
}

class ApproveApprovalProcess extends ApprovalProcessEvent {
  final String recordId;
  final String? orderId;
  final String? unitPrice;
  ApproveApprovalProcess(this.recordId, {this.orderId, this.unitPrice});

  @override
  List<Object?> get props => [recordId, orderId, unitPrice];
}

class RejectApprovalProcesss extends ApprovalProcessEvent {
  final String recordId;
  final String? orderId;
  final String? unitPrice;
  RejectApprovalProcesss(this.recordId, {this.orderId, this.unitPrice});

  @override
  List<Object?> get props => [recordId, orderId, unitPrice];
}
