import 'package:equatable/equatable.dart';
import 'package:pdf/widgets.dart';

class QuotesHistoryListModel extends Equatable {
  QuotesHistoryListModel({
    required this.quoteHistoryList,
    this.QuoteAccount,
    this.notesList,
    required this.message,
  });
  late final List<QuoteHistoryList> quoteHistoryList;
  late final Null QuoteAccount;
  late final Null notesList;
  late final String message;

  QuotesHistoryListModel.fromJson(Map<String, dynamic> json) {
    quoteHistoryList = List.from(json['quoteHistoryList'])
        .map((e) => QuoteHistoryList.fromJson(e))
        .toList();
    QuoteAccount = null;
    notesList = null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['quoteHistoryList'] =
        quoteHistoryList.map((e) => e.toJson()).toList();
    _data['QuoteAccount'] = QuoteAccount;
    _data['notesList'] = notesList;
    _data['message'] = message;
    return _data;
  }

  @override
  List<Object?> get props => [
        quoteHistoryList,
        QuoteAccount,
        notesList,
        message,
      ];
}

class QuoteHistoryList extends Equatable {
  QuoteHistoryList({
    required this.subtotal,
    required this.quoteNumber,
    required this.lastName,
    required this.itemCount,
    required this.firstName,
    required this.expiryDate,
    required this.email,
    required this.createDate,
  });
  late final String subtotal;
  late final String quoteNumber;
  late final String lastName;
  late final int itemCount;
  late final String firstName;
  late final String expiryDate;
  late final String email;
  late final String createDate;
  late final String createTime;
  late final String contentUrl;
  bool? isPressed;

  QuoteHistoryList.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal'];
    quoteNumber = json['quoteNumber'];
    lastName = json['lastName'];
    itemCount = json['itemCount'];
    firstName = json['firstName'];
    expiryDate = json['expiryDate'];
    email = json['email'];
    createDate = json['createDate'];
    createTime = json['createTime'];
    contentUrl = json['ContentUrl'];
    isPressed = false;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['subtotal'] = subtotal;
    _data['quoteNumber'] = quoteNumber;
    _data['lastName'] = lastName;
    _data['itemCount'] = itemCount;
    _data['firstName'] = firstName;
    _data['expiryDate'] = expiryDate;
    _data['email'] = email;
    _data['createDate'] = createDate;
    _data['createTime'] = createTime;
    _data['ContentUrl'] = contentUrl;
    return _data;
  }

  @override
  List<Object?> get props => [
        subtotal,
        quoteNumber,
        lastName,
        itemCount,
        firstName,
        expiryDate,
        email,
        createDate,
        isPressed,
        contentUrl
      ];
}
