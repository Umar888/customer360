import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/search_places/search_places_bloc.dart';
import 'package:gc_customer_app/screens/search_places/view/search_places_list.dart';


class SearchPlacesPage extends StatefulWidget {
  SearchPlacesPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SearchPlacesPage());
  }

  @override
  _SearchPlacesPageState createState() => _SearchPlacesPageState();
}

class _SearchPlacesPageState extends State<SearchPlacesPage> with AutomaticKeepAliveClientMixin{

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
        body: Padding(
            padding: EdgeInsets.all(5),
            child: BlocProvider(
              create: (context) => SearchPlacesBloc(),
              child: SearchPlacesList(),
            ),
          ),
        ),
      ),
    );
  }
  @override
  bool get wantKeepAlive => false;
}


