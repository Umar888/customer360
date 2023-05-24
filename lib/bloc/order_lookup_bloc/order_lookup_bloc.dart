import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/data/reporsitories/order_lookup_repository/order_lookup_repository.dart';
import 'package:gc_customer_app/models/order_lookup_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:flutter/foundation.dart';

part 'order_lookup_event.dart';
part 'order_lookup_state.dart';

class OrderLookUpBloC extends Bloc<OrderLookUpEvent, OrderLookUpState> {
  final OrderLookUpRepository orderLookUpRepo;

  OrderLookUpBloC({required this.orderLookUpRepo})
      : super(OrderLookUpInitial()) {
    on<SearchOrders>(
      (event, emit) async {
        emit(OrderLookUpProgress());
        List<OrderLookupModel> orders = [];

        orders = await orderLookUpRepo
            .getOrderLookUp(event.searchText)
            .timeout(Duration(seconds: 60))
            .catchError((er) {
          print(er.toString());
          return Future.value([]);
        });
        if (!isNumeric(event.searchText) && !event.searchText.contains('@')) {
          if (event.searchText.contains('GCQ')) {
            await orderLookUpRepo
                .getOrderLookUpOpenOrderByQouteNumber(event.searchText)
                .catchError((error) {
                  emit(OrderLookUpFailure(message: error.toString()));
                  return <OrderLookupModel>[];
                })
                .timeout(Duration(seconds: 60))
                .catchError((er) {
                  print(er.toString());
                  return <OrderLookupModel>[];
                })
                .then((value) {
                  orders.insertAll(0, value);
                });
          } else {
            await orderLookUpRepo
                .getOrderLookUpOpenOrderByOrderNumber(event.searchText)
                .catchError((error) {
                  emit(OrderLookUpFailure(message: error.toString()));
                  return <OrderLookupModel>[];
                })
                .timeout(Duration(seconds: 60))
                .catchError((er) {
                  print(er.toString());
                  return <OrderLookupModel>[];
                })
                .then((value) {
                  orders.insertAll(0, value);
                });
          }
        }

        emit(OrderLookUpSuccess(orders: orders));

        return;
      },
    );

    on<ClearOrderLookUp>(
      (event, emit) async {
        emit(OrderLookUpInitial());

        return;
      },
    );
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }
}
