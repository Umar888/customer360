import 'package:equatable/equatable.dart';

class PromotionModel extends Equatable {
  PromotionModel({
    this.id,
    this.messageDate,
    this.textBody,
    this.htmlBody,
    this.fromName,
    this.fromAddress,
    this.toAddress,
    this.bccAddress,
    this.incoming,
    this.status,
    this.isDeleted,
    this.subject,
    this.serviceCommunicationId,
  });

  String? id;
  String? messageDate;
  String? subject;
  String? textBody;
  String? htmlBody;
  String? fromName;
  String? fromAddress;
  String? toAddress;
  String? bccAddress;
  bool? incoming;
  String? status;
  bool? isDeleted;
  String? serviceCommunicationId;

  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
        id: json["id"],
        messageDate: json["emailDate"],
        textBody: json["TextBody"],
        htmlBody: json["HtmlBody"],
        fromName: json["FromName"],
        fromAddress: json["FromAddress"],
        toAddress: json["ToAddress"],
        bccAddress: json["BccAddress"],
        incoming: json["Incoming"],
        status: json["Status"],
        isDeleted: json["IsDeleted"],
        subject: json["subject"],
        serviceCommunicationId: json["serviceCommunicationId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "emailDate": messageDate,
        "TextBody": textBody,
        "HtmlBody": htmlBody,
        "FromName": fromName,
        "FromAddress": fromAddress,
        "ToAddress": toAddress,
        "BccAddress": bccAddress,
        "Incoming": incoming,
        "Status": status,
        "IsDeleted": isDeleted,
        "subject": subject,
        "serviceCommunicationId": serviceCommunicationId,
      };

  @override
  List<Object?> get props => [
        id,
        messageDate,
        subject,
        textBody,
        htmlBody,
        fromName,
        fromAddress,
        toAddress,
        bccAddress,
        incoming,
        status,
        isDeleted,
        serviceCommunicationId,
      ];
}
