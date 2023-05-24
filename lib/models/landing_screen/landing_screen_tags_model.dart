import 'package:equatable/equatable.dart';

class CustomerTagging extends Equatable{
  Map<String, dynamic>? data;

  CustomerTagging({this.data});
  CustomerTagging.fromJson(Map<String, dynamic> json) {
    data= json;
  }
  @override
  List<Object?> get props => [data];
}
