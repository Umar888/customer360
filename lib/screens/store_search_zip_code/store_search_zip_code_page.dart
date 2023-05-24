import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/screens/store_search_zip_code/store_search_zip_code_list.dart';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../bloc/store_search_zip_code_bloc/store_search_zip_code_bloc.dart';
import '../../data/data_sources/store_search_zip_code_data_source/store_search_zip_code_data_source.dart';
import '../../data/reporsitories/store_search_zip_code_reporsitory/store_search_zip_code_repository.dart';


class StoreSearchZipCodePage extends StatelessWidget {
  final String? orderID;

  StoreSearchZipCodePage({Key? key, required this.orderID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: ()  {
        return Future.value(false);
      },
      child: Scaffold(
        body: BlocProvider(
          create: (context) {
            return StoreSearchZipCodeBloc(
              storeSearchZipCodeRepository: StoreSearchZipCodeRepository(storeSearchZipCodeDataSource: StoreSearchZipCodeDataSource()),
            );
          },
          child: StoreSearchZipCodeList(orderID: orderID),
        ),
      ),
    );
  }
}
