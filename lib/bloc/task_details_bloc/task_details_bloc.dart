import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gc_customer_app/models/task_detail_model/order.dart';
import 'package:gc_customer_app/models/task_detail_model/order_item.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import 'package:gc_customer_app/models/task_detail_model/test_model.dart';
import '../../services/networking/endpoints.dart';
import '../../services/networking/networking_service.dart';

part 'task_details_event.dart';

part 'task_details_state.dart';

part 'task_details_bloc.freezed.dart';

class TaskDetailsBloc extends Bloc<TaskDetailsEvent, TaskDetailsState> {
  final HttpService httpService = HttpService();
  TaskDetailsBloc() : super(TaskDetailsInitialState()) {
    on<TaskDetailsLoadingEvent>((event, emit) async {
      emit(TaskDetailsLoadingState());
      taskId = event.taskId;
      await getTaskDetails(event.taskId);
      emit(TaskDetailsLoadedState(orders, task));
    });
    on<TaskDetailsRefreshEvent>((event, emit) async {
      emit(TaskDetailsState.loading());
      taskId = event.tempTaskId;
      await getTaskDetails(event.tempTaskId);
      emit(TaskDetailsLoadedState(orders, task));
    });
    on<TaskDetailsOnlyLoadingEvent>(
        (event, emit) => emit(TaskDetailsLoadingState()));
  }

  List<Order> orders = [];
  String taskId = '';
  late TaskModel task;

  Future<void> getTaskDetails(String taskId) async {
    orders.clear();

    var response = await httpService.doGet(path: Endpoints.getTaskDetails(taskId));
    log(Endpoints.getTaskDetails(taskId));

    try {
      if (response.data != null) {
        // log(jsonEncode(response.data));
        task = TaskModel.fromJson(response.data['CurrentTask']);
        TestModel testModel = TestModel.fromJson(response.data);
        log(testModel.currentTask!.phoneC??"");

        for (var orderJson in response.data['Orders']) {
          var orderLines = <OrderItem>[];
          try {
            for (var orderLine in orderJson['OrderLines']) {
              var orderLineItem = OrderItem.fromTaskOrderLineJson(orderLine);
              orderLines.add(orderLineItem);
            }
          } on Exception catch (e) {}
          try {
            var order = Order.fromOrderInfoJson(orderJson);
            order.orderLines = List.from(orderLines);
            orders.add(order);
          } catch (e) {}
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
