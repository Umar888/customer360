enum TaskActionEnum {
  call,
  chat,
  sms,
  mail,
  unknown,
}

abstract class TaskAction {
  TaskActionEnum getActionFromString(String action){
    switch(action){
      case 'Call':
        return TaskActionEnum.call;
      case 'Chat':
        return TaskActionEnum.chat;
      case 'SMS':
        return TaskActionEnum.sms;
      case 'Mail':
        return TaskActionEnum.mail;
      default:
        return TaskActionEnum.unknown;
    }
  }
}