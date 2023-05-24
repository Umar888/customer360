part of 'search_places_bloc.dart';

abstract class SearchPlacesEvent extends Equatable{
 SearchPlacesEvent();
}

class SearchSetInitial extends SearchPlacesEvent{
  final SearchPlacesListModel search;
  SearchSetInitial({required this.search});

  @override
  List<Object> get props => [search];

}
class EmptyMessage extends SearchPlacesEvent{
  final SearchPlacesListModel search;
  final bool init;
  EmptyMessage({required this.search,required this.init});

  @override
  List<Object> get props => [search,init];

}


class SearchRequested extends SearchPlacesEvent {
  final String query;

  SearchRequested({required this.query});

  @override
  List<Object> get props => [query];
}