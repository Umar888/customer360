part of 'search_places_bloc.dart';

enum LoadingState { loading,notLoading }
class SearchPlacesLoadSuccess extends Equatable{
  final SearchPlacesListModel search;
  final String message;
  final LoadingState loadingState;
  final bool isInit;

  SearchPlacesLoadSuccess({required this.search,this.message = "",this.loadingState = LoadingState.notLoading,this.isInit = true});

  @override
  List<Object> get props => [search,message,loadingState,isInit];
}
