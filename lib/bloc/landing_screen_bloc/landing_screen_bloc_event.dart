part of 'landing_screen_bloc_bloc.dart';

@immutable
abstract class LandingScreenBlocEvent extends Equatable {
  LandingScreenBlocEvent();
  @override
  List<Object> get props => [];
}

class LoadData extends LandingScreenBlocEvent {
  String appName;
  LoadData({this.appName = "Customer 360"});

  @override
  List<Object> get props => [appName];
}

class RemoveCustomer extends LandingScreenBlocEvent {
  RemoveCustomer();

  @override
  List<Object> get props => [];
}

class ReloadTasks extends LandingScreenBlocEvent {
  ReloadTasks();

  @override
  List<Object> get props => [];
}

class LoadActivity extends LandingScreenBlocEvent {
  LoadActivity();
  @override
  List<Object> get props => [];
}

class LoadOffers extends LandingScreenBlocEvent {
  LoadOffers();
  @override
  List<Object> get props => [];
}

class ReloadReminders extends LandingScreenBlocEvent {
  ReloadReminders();
  @override
  List<Object> get props => [];
}

class CheckAgent extends LandingScreenBlocEvent {
  CheckAgent();
  @override
  List<Object> get props => [];
}

class GetAgentList extends LandingScreenBlocEvent {
  GetAgentList();
  @override
  List<Object> get props => [];
}

class AssignAgent extends LandingScreenBlocEvent {
  String agentId;
  bool isStore;
  int index;
  AssignAgent({required this.agentId, required this.index, required this.isStore});
  @override
  List<Object> get props => [agentId, index,isStore];
}

class SearchAgentList extends LandingScreenBlocEvent {
  final String searchString;
  SearchAgentList({required this.searchString});
  @override
  List<Object> get props => [searchString];
}

class ClearSearchList extends LandingScreenBlocEvent {
  ClearSearchList();
  @override
  List<Object> get props => [];
}

class ClearMessage extends LandingScreenBlocEvent {
  ClearMessage();
  @override
  List<Object> get props => [];
}

class LoadFavoriteBrands extends LandingScreenBlocEvent {
  LoadFavoriteBrands();
  @override
  List<Object> get props => [];
}

class GetRecommendedItemStock extends LandingScreenBlocEvent {
  final String itemSkuId;
  final bool gettingFavorites;
  final bool gettingActivity;
  final LandingScreenRecommendationModel? recommendationModel;
  final LandingScreenRecommendationModelBuyAgain? recommendationModelBuyAgain;
  GetRecommendedItemStock(
      {required this.itemSkuId,
      required this.gettingFavorites,
      required this.gettingActivity,
      this.recommendationModel,
      this.recommendationModelBuyAgain});
  @override
  List<Object> get props => [itemSkuId, gettingActivity, gettingFavorites];
}

class PinnedNotesChange extends LandingScreenBlocEvent {
  int index;
  PinnedNotesChange({required this.index});

  @override
  List<Object> get props => [index];
}
