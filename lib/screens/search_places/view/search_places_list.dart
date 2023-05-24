import 'dart:async';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/search_places/search_places_bloc.dart';
import 'package:gc_customer_app/models/search_places/search_places_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import '../widget/search_places_item.dart';

class SearchPlacesList extends StatefulWidget {
  SearchPlacesList({super.key});

  @override
  _SearchPlacesListState createState() => _SearchPlacesListState();
}

class _SearchPlacesListState extends State<SearchPlacesList> {
  final TextEditingController _controller = TextEditingController();
  StreamController<String> streamController = StreamController();
  late FocusNode focusNode;
  late SearchPlacesBloc searchBloc;
  bool hasFocus=true;
  void _onFocusChange() {
    if(focusNode.hasFocus){
      setState(() {
        hasFocus = true;
      });
    }
    else{
      setState(() {
        hasFocus = false;
      });

    }
  }

  @override
  void dispose() {
    streamController.close();
    focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: BlocConsumer<SearchPlacesBloc, SearchPlacesLoadSuccess>(
        listener: (context, state) {
            if(state.message.isNotEmpty){
              searchBloc.add(EmptyMessage(search: state.search,init: state.isInit));
            }

        },
        builder: (context, state) {
            return Column(
              children: <Widget>[
                _searchWidget(context, state.search, state),
                SizedBox(height: 10),
                Expanded(
                  child: Center(
                      child:
                      !state.isInit &&
                          _controller.text.isNotEmpty &&
                          state.search.autoCompleteAddressList!.isEmpty?
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)):
                      state.isInit?
                      Text("Search Places",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                              fontSize: 16
                          )
                      )
                    :_getSearchList(state.search.autoCompleteAddressList!)
                  ),
                ),
              ],
            );
        },
      ),
    );
  }

  @override
  void initState() {
    focusNode = FocusNode();

    searchBloc = context.read<SearchPlacesBloc>();
    focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) =>FocusScope.of(context).requestFocus(focusNode));

    super.initState();
  }

  Widget _searchWidget(BuildContext context,SearchPlacesListModel searchModel,SearchPlacesLoadSuccess state) {
    return  SafeArea(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            right: 30,
            left: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                transitionBuilder: (Widget child,Animation<double> animation){
                  return SlideTransition(position: Tween<Offset>(
                    begin: Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),child: child);
                },
                child: hasFocus?
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 28,
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.only(top: 15),
                  color: ColorSystem.greyDark,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ):
                SizedBox.shrink(),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: focusNode,
                  onTap: () {
                    FocusScope.of(context).requestFocus(focusNode);
                  },
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  cursorColor: Theme.of(context).primaryColor,
                  style: TextStyle(
                      fontSize: 24,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                      fontFamily: kRubik),
                  onChanged: (val) {
                    EasyDebounce.cancelAll();
                    if(val.isNotEmpty){
                      EasyDebounce.debounce('search_name_debounce', Duration(milliseconds: 300), () {
                        callApiToSearch(context);
                      });
                    }
                    else{
                      EasyDebounce.debounce('search_name_debounce', Duration(milliseconds: 300), () {
                        searchBloc.add(SearchSetInitial(search: searchModel));
                      });
                    }
                  },
                  decoration:  InputDecoration(
                    hintText: 'Search Address',
                    hintStyle: TextStyle(
                      color: ColorSystem.secondary,
                      fontSize: 20,
                    ),
                    suffixIcon: _controller.text.isNotEmpty?
                    IconButton(
                      onPressed: () {
                        _controller.clear();
                        searchBloc.add(SearchSetInitial(search: searchModel));
                        // WidgetsBinding.instance.addPostFrameCallback((_) =>FocusScope.of(context).requestFocus(focusNode));
                      },
                      icon: Icon(Icons.close,
                        color: Colors.black,
                        size: 24,),
                    ):
                    SizedBox(width: 0,height: 0,),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  Widget _getSearchList(List<AutoCompleteAddressList> searchList) {
    return Column(
      children: [
        Flexible(
          child: ListView.separated(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: true,
              itemCount: searchList.length,
              itemBuilder: (ctx, i) {
                return InkWell(
                  onTap: () {},
                  child: SearchPlacesItem(
                    searchPlacesData: searchList[i],
                  ),
                );
              },
              separatorBuilder: (ctx, i) {
                return Divider(color: Colors.black38, height: 1);
              }),
        ),
        Divider(color: Colors.black38, height: 1)
      ],
    );
  }

  void callApiToSearch(BuildContext context) {
    BlocProvider.of<SearchPlacesBloc>(context).add(SearchRequested(query: _controller.text.toString()));
  }
}
