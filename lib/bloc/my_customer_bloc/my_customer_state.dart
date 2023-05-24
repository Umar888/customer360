part of 'my_customer_bloc.dart';

@immutable
class MyCustomerState extends Equatable {
  final String? loggedInUserName;
  final String? loggedInUserId;
  final String? allCount;
  final String? newCount;
  final List<MyCustomerModel>? clients;
  final List<MyCustomerModel>? contacteds;
  final List<MyCustomerModel>? purchaseds;
  final bool? isLoading;
  final int? high;
  final int? medium;
  final int? low;
  final int? contactedCount;
  final int? notContactedCount;
  final int? purchasedCount;
  final int? notPurchasedCount;
  final bool? isManager;
  final bool? isShowAllUsers;
  final List<EmployeeMyCustomerModel>? employees;

  MyCustomerState({
    this.loggedInUserName,
    this.loggedInUserId,
    this.clients,
    this.contacteds,
    this.purchaseds,
    this.allCount,
    this.newCount,
    this.isLoading,
    this.high,
    this.medium,
    this.low,
    this.contactedCount,
    this.notContactedCount,
    this.purchasedCount,
    this.notPurchasedCount,
    this.isManager,
    this.isShowAllUsers,
    this.employees,
  });

  MyCustomerState copyWith({
    String? loggedInUserName,
    String? loggedInUserId,
    String? allCount,
    String? newCount,
    List<MyCustomerModel>? clients,
    List<MyCustomerModel>? contacteds,
    List<MyCustomerModel>? purchaseds,
    int? high,
    int? medium,
    int? low,
    int? contactedCount,
    int? notContactedCount,
    int? purchasedCount,
    int? notPurchasedCount,
    bool? isLoading,
    bool? isManager,
    bool? isShowAllUsers,
    List<EmployeeMyCustomerModel>? employees,
  }) {
    return MyCustomerState(
      loggedInUserName: loggedInUserName ?? this.loggedInUserName,
      loggedInUserId: loggedInUserId ?? this.loggedInUserId,
      clients: clients ?? this.clients,
      contacteds: contacteds ?? this.contacteds,
      purchaseds: purchaseds ?? this.purchaseds,
      allCount: allCount ?? this.allCount,
      newCount: newCount ?? this.newCount,
      isLoading: isLoading ?? this.isLoading,
      high: high ?? this.high,
      medium: medium ?? this.medium,
      low: low ?? this.low,
      contactedCount: contactedCount ?? this.contactedCount,
      notContactedCount: notContactedCount ?? this.notContactedCount,
      purchasedCount: purchasedCount ?? this.purchasedCount,
      notPurchasedCount: notPurchasedCount ?? this.notPurchasedCount,
      isManager: isManager ?? this.isManager,
      isShowAllUsers: isShowAllUsers ?? this.isShowAllUsers,
      employees: employees ?? this.employees,
    );
  }

  @override
  List<Object?> get props => [
        loggedInUserName,
        allCount,
        newCount,
        clients,
        contacteds,
        purchaseds,
        isLoading,
        high,
        medium,
        low,
        contactedCount,
        notContactedCount,
        purchasedCount,
        notPurchasedCount,
        isManager,
        isShowAllUsers,
        employees,
      ];
}

// class MyCustomerInitial extends MyCustomerState {}

// class MyCustomerProgress extends MyCustomerState {}

// class MyCustomerFailure extends MyCustomerState {}

// class MyCustomerSuccess extends MyCustomerState {
//   final PromotionModel? topPromotion;
//   final List<PromotionModel>? activePromotions;
//   MyCustomerSuccess({this.topPromotion, this.activePromotions});

//   @override
//   List<Object?> get props => [topPromotion, activePromotions];
// }
