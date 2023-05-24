import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gc_customer_app/models/task_detail_model/task.dart';
import '../../services/networking/endpoints.dart';
import '../../services/networking/networking_service.dart';

part 'task_details_loading_event.dart';

part 'task_details_loading_state.dart';

part 'task_details_loading_bloc.freezed.dart';



class TaskDetailsLoadingBloc extends Bloc<TaskDetailsLoadingEvent, TaskDetailsLoadingState> {
  final HttpService httpService = HttpService();
  TaskDetailsLoadingBloc() : super(TaskDetailsFetchingState(TaskDetailLoadingStatus.initial,[])) {
    on<TaskDetailsLoadingFetchEvent>((event, emit) async {
      emit(TaskDetailsFetchingState(TaskDetailLoadingStatus.loading,[]));
      taskId = event.taskId;
      print("taskId $taskId");
      await getTaskDetails(event.taskId);
      if(taskModel.isNotEmpty){
        log("fetched taskId "+taskModel[0].id!);
        emit(TaskDetailsFetchingState(TaskDetailLoadingStatus.success, taskModel));
      }
      else{
        print("task is empty");
        emit(TaskDetailsFetchingState(TaskDetailLoadingStatus.failed, []));
      }
    });
  }


  late TaskModel task;
  List<TaskModel> taskModel = [];
  String taskId = '';

  Future<void> getTaskDetails(String taskId) async {

    var response = await httpService.doGet(path: Endpoints.getTaskDetails(taskId));

    try {
      if (response.data != null) {
        if(response.data['CurrentTask'] != null){
          task = TaskModel.fromJson(response.data['CurrentTask']);
          taskModel.add(task);
        }
        else{
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
