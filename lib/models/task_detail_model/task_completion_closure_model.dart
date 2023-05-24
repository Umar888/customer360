class TaskCompletionClosureModel {
  String taskType;
  String closureType;

  TaskCompletionClosureModel({
    required this.taskType,
    required this.closureType,
  });

  Map toJson(){
    return {
      'TaskType': taskType,
      'ClosureType': closureType
    };
  }

}
