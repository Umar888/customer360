part of 'landing_screen_bloc_bloc.dart';

enum LandingScreenStatus { initial, success, failure}

@immutable
class LandingScreenState extends Equatable {
  final CustomerInfoModel? customerInfoModel;
  final Map<dynamic, dynamic>? tags;
  final LandingScreenOffersModel? landingScreenOffersModel;
  final AssignedAgent? assignedAgent;
  final LandingScreenStatus? landingScreenStatus;
  final List<AggregatedTaskList>? taskModel;
  final LandingScreenRecommendationModel? landingScreenRecommendationModel;
  final LandingScreenRecommendationModelBuyAgain?
      landingScreenRecommendationModelBuyAgain;
  final lrp.LandingScreenReminders? landingScreenReminders;
  final List<FavoriteBrandsLandingScreen>? favoriteBrandsLandingScreen;
  final List<OrderHistoryLandingScreen>? orderHistoryLandingScreen;
  final String? message;
  final bool? gettingFavorites;
  final bool? isAgentAssigned;
  final bool? isAssigningStoreAgent;
  final bool? isAssigningCCAgent;
  final bool? isSearchAgent;
  final bool? gettingOffers;
  final bool? gettingAgentAssigned;
  final bool? gettingAgentsList;
  final bool? gettingActivity;
  final List<AgentList>? agentList;
  final List<AgentList>? searchedAgentList;
  final List<PinnedNotes>? pinnedNotesList;
  final ActivityClass? openOrder;
  final ActivityClass? openCases;
  final ActivityClass? browsingHistory;
  final CreditBalance? creditBalance;

  LandingScreenState({
    this.gettingAgentsList,
    this.tags,
    this.landingScreenOffersModel,
    this.landingScreenRecommendationModelBuyAgain,
    this.searchedAgentList,
    this.landingScreenStatus,
    this.message,
    this.agentList,
    this.favoriteBrandsLandingScreen,
    this.orderHistoryLandingScreen,
    this.isSearchAgent,
    this.isAgentAssigned,
    this.assignedAgent,
    this.gettingActivity,
    this.gettingAgentAssigned,
    this.gettingFavorites,
    this.gettingOffers,
    this.landingScreenReminders,
    this.taskModel,
    this.customerInfoModel,
    this.landingScreenRecommendationModel,
    this.pinnedNotesList,
    this.openOrder,
    this.openCases,
    this.browsingHistory,
    this.isAssigningStoreAgent = false,
    this.isAssigningCCAgent = false,
    this.creditBalance,
  });

  LandingScreenState copyWith(
      {LandingScreenStatus? landingScreenStatus,
      LandingScreenOffersModel? landingScreenOffersModel,
      Map<dynamic, dynamic>? tags,
      CustomerInfoModel? customerInfoModel,
      AssignedAgent? assignedAgent,
      List<AggregatedTaskList>? taskModel,
      LandingScreenRecommendationModel? landingScreenRecommendationModel,
      LandingScreenRecommendationModelBuyAgain? landingScreenRecommendationModelBuyAgain,
      lrp.LandingScreenReminders? landingScreenReminders,
      List<FavoriteBrandsLandingScreen>? favoriteBrandsLandingScreen,
      List<OrderHistoryLandingScreen>? orderHistoryLandingScreen,
      bool? gettingFavorites,
      String? message,
      bool? isAgentAssigned,
      bool? isSearchAgent,
      bool? gettingAgentAssigned,
      bool? gettingAgentsList,
      bool? isAssigningStoreAgent,
      bool? isAssigningCCAgent,
      bool? gettingOffers,
      bool? gettingActivity,
      List<OffersList>? offerList,
      List<AgentList>? agentList,
      List<AgentList>? searchedAgentList,
      List<PinnedNotes>? pinnedNotesList,
      ActivityClass? openOrder,
      ActivityClass? openCases,
      ActivityClass? browsingHistory,
      CreditBalance? creditBalance}) {
    return LandingScreenState(
      customerInfoModel: customerInfoModel ?? this.customerInfoModel,
      orderHistoryLandingScreen: orderHistoryLandingScreen ?? this.orderHistoryLandingScreen,
      tags: tags ?? this.tags,
      isAssigningStoreAgent: isAssigningStoreAgent ?? this.isAssigningStoreAgent,
      isAssigningCCAgent: isAssigningCCAgent ?? this.isAssigningCCAgent,
      assignedAgent: assignedAgent ?? this.assignedAgent,
      taskModel: taskModel ?? this.taskModel,
      landingScreenOffersModel:
          landingScreenOffersModel ?? this.landingScreenOffersModel,
      message: message ?? this.message,
      landingScreenRecommendationModel: landingScreenRecommendationModel ??
          this.landingScreenRecommendationModel,
      landingScreenRecommendationModelBuyAgain:
          landingScreenRecommendationModelBuyAgain ??
              this.landingScreenRecommendationModelBuyAgain,
      landingScreenReminders:
          landingScreenReminders ?? this.landingScreenReminders,
      favoriteBrandsLandingScreen:
          favoriteBrandsLandingScreen ?? this.favoriteBrandsLandingScreen,
      gettingFavorites: gettingFavorites ?? this.gettingFavorites,
      isAgentAssigned: isAgentAssigned ?? this.isAgentAssigned,
      isSearchAgent: isSearchAgent ?? this.isSearchAgent,
      gettingAgentAssigned: gettingAgentAssigned ?? this.gettingAgentAssigned,
      gettingAgentsList: gettingAgentsList ?? this.gettingAgentsList,
      gettingActivity: gettingActivity ?? this.gettingActivity,
      landingScreenStatus: landingScreenStatus ?? this.landingScreenStatus,
      agentList: agentList ?? this.agentList,
      searchedAgentList: searchedAgentList ?? this.searchedAgentList,
      pinnedNotesList: pinnedNotesList ?? this.pinnedNotesList,
      gettingOffers: gettingOffers ?? this.gettingOffers,
      openOrder: openOrder ?? this.openOrder,
      openCases: openCases ?? this.openCases,
      browsingHistory: browsingHistory ?? this.browsingHistory,
      creditBalance: creditBalance ?? this.creditBalance,
    );
  }

  @override
  List<Object?> get props => [
        agentList,
        isAssigningStoreAgent,
        isAssigningCCAgent,
        tags,
        landingScreenStatus,
        gettingAgentsList,
        landingScreenOffersModel,
        message,
        searchedAgentList,
        isSearchAgent,
        gettingOffers,
        gettingActivity,
        gettingFavorites,
        gettingAgentAssigned,
        orderHistoryLandingScreen,
        isAgentAssigned,
        landingScreenReminders,
        assignedAgent,
        landingScreenRecommendationModel,
        landingScreenRecommendationModelBuyAgain,
        customerInfoModel,
        favoriteBrandsLandingScreen,
        taskModel,
        openOrder,
        openCases,
        browsingHistory,
        pinnedNotesList,
      ];
}
