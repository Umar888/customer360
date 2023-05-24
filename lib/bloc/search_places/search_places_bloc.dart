import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:gc_customer_app/data/reporsitories/search_places/search_places_repository.dart';
import 'package:gc_customer_app/models/search_places/search_places_model.dart';

import 'package:rxdart/rxdart.dart';

part 'search_places_event.dart';
part 'search_places_state.dart';

class SearchPlacesBloc extends Bloc <SearchPlacesEvent, SearchPlacesLoadSuccess>{
  SearchPlacesRepository searchPlacesRepository = SearchPlacesRepository();

  SearchPlacesBloc() : super(SearchPlacesLoadSuccess(search:  SearchPlacesListModel(autoCompleteAddressList: []))){
    on<SearchRequested>((event, emit) async {

      try{
        emit(SearchPlacesLoadSuccess(
            search:  SearchPlacesListModel(autoCompleteAddressList: []),
            message: "done",
            isInit: false,
            loadingState: LoadingState.loading));
        SearchPlacesListModel searchPlacesListModel = await searchPlacesRepository.fetchEventList(event.query);
        if(searchPlacesListModel.autoCompleteAddressList != null) {
          if (searchPlacesListModel.autoCompleteAddressList!.isNotEmpty) {
            emit(SearchPlacesLoadSuccess(search: searchPlacesListModel,
                message: "done",
                loadingState: LoadingState.notLoading,isInit: false));
          } else {
            emit(SearchPlacesLoadSuccess(search:  SearchPlacesListModel(autoCompleteAddressList: []),message: "done",loadingState: LoadingState.notLoading,isInit: false));
          }
        } else {
          emit(SearchPlacesLoadSuccess(search:  SearchPlacesListModel(autoCompleteAddressList: []),message: "done",loadingState: LoadingState.notLoading,isInit: false));
        }
      } on Exception{
        emit(SearchPlacesLoadSuccess(search:  SearchPlacesListModel(autoCompleteAddressList: []),message: "done",loadingState: LoadingState.notLoading,isInit: false));
      }
    },
      transformer: (events, mapper) {
        return events.debounceTime(Duration(milliseconds: 1000)).asyncExpand(mapper);
      },
    );
    on<SearchSetInitial>((event, emit) async {
      SearchPlacesListModel searchEventListModel = event.search;
      searchEventListModel.autoCompleteAddressList!.clear();
      emit(SearchPlacesLoadSuccess(search:  searchEventListModel,message: "done",loadingState: LoadingState.notLoading,isInit: true));
    });
    on<EmptyMessage>((event, emit) async {
      SearchPlacesListModel searchEventListModel = event.search;
      bool isInit = event.init;
      emit(SearchPlacesLoadSuccess(search: searchEventListModel,message: "",loadingState: LoadingState.notLoading,isInit: isInit));
    });
  }
}