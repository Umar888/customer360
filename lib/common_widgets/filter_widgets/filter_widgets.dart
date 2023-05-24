import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/models/common_models/refinement_model.dart';
import 'package:gc_customer_app/models/inventory_search/add_search_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


class FilterWidgetTile extends StatefulWidget {
  FilterWidgetTile(
      {super.key, required this.nameOfTile, required this.index});
  final String nameOfTile;
  final int index;

  @override
  State<FilterWidgetTile> createState() => _FilterWidgetTileState();
}

class _FilterWidgetTileState extends State<FilterWidgetTile> {
  List<Text> trailingItems = [];
  late InventorySearchBloc inventorySearchBloc;
  bool? isExpanded = false;
  int _currentItem = 0;
  List<Refinement> finalRefinement = [];
  final PagingController<int, Refinement> _pagingController =
  PagingController(firstPageKey: 0);
  static const _pageSize = 50;
  bool loading = true;
  final ScrollController itemScrollController = ScrollController();
  Timer? timer;
  paginateList({required List<Refinement> refinement}){
    if((_currentItem + 50) > refinement.length && _currentItem  < refinement.length){
      List<Refinement> newItems = refinement.getRange(_currentItem, refinement.length).toList();
      setState(() {
        finalRefinement.addAll(newItems);
        loading = false;
        _currentItem = refinement.length;
      });
    }
    else if((_currentItem + 50) < refinement.length){
      List<Refinement> newItems = refinement.getRange(_currentItem, _currentItem + 50).toList();
      setState(() {
        finalRefinement.addAll(newItems);
        _currentItem = _currentItem + 50;
        loading = false;
      });
    }

  }

  @override
  void initState() {
    inventorySearchBloc = context.read<InventorySearchBloc>();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => paginateList(refinement: inventorySearchBloc.state.searchDetailModel.first.wrapperinstance!.facet![widget.index].refinement!));
    super.initState();
  }
  @override
  void dispose() {
    timer?.cancel();
    _pagingController.dispose();
    super.dispose();
  }

  List<Widget> mainTileTrailingWidget(InventorySearchState state) {
    for (var i = 0;i <state.searchDetailModel.first.wrapperinstance!.facet![widget.index].refinement!.length;i++) {
      if (state.searchDetailModel.first.wrapperinstance!.facet![widget.index].refinement![i].onPressed == true) {
        trailingItems.add(Text(
          state.searchDetailModel.first.wrapperinstance!.facet![widget.index].refinement![i]
              .name
              .toString(),
          style: TextStyle(color: Colors.red),
        ));
      } else {
      }
    }
    return LinkedHashSet<Text>.from(trailingItems).toList();
  }

  String dollarSignAddString(String amountRange) {
    String firstPart;
    String secondPart;
    String overTxtValues;

    if (amountRange.contains('-')) {
      if (!amountRange.contains('Over')) {
        firstPart = amountRange.split('-')[0];
        secondPart = amountRange.split('-')[1];
        amountRange = '\$$firstPart - \$${secondPart.trim()}';
      } else {
        amountRange.replaceAll(RegExp(r'Over'), 'Over \$');
      }
    } else if (amountRange.contains('Over')) {
      overTxtValues = amountRange.split(' ')[1];
      amountRange = 'Over \$$overTxtValues';
    }
    return amountRange;
  }

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return BlocConsumer<InventorySearchBloc, InventorySearchState>(
        listener: (context, state) {
          if (state.message.isNotEmpty && state.message != "done" && state.message != "zebon") {
            Future.delayed(Duration.zero, () {
              setState(() {});
//              showMessage(context: context,message:state.message);
            });
          }
          inventorySearchBloc.add(EmptyMessage());
        }, builder: (context, state) {
      if (state.inventorySearchStatus == InventorySearchStatus.successState) {
        return CustomScrollView(
          shrinkWrap: true,
          // primary: false,
          physics: NeverScrollableScrollPhysics(),
          // semanticChildCount: 3,
          slivers: [
            SliverToBoxAdapter(
              child: InkWell(
                onTap: () {
                  inventorySearchBloc.add(OnExpandMainTile(
                      searchDetailModel: state.searchDetailModel,
                      index: widget.index));
                },
                child: ListTile(
                    leading: RotationTransition(
                      turns: !state.searchDetailModel.first.wrapperinstance!
                          .facet![widget.index].isExpand!
                          ? AlwaysStoppedAnimation(0 / 360)
                          : AlwaysStoppedAnimation(90 / 360),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          inventorySearchBloc.add(OnExpandMainTile(
                              searchDetailModel: state.searchDetailModel,
                              index: widget.index));
                        },
                      ),
                    ),
                    title: Text(
                      widget.nameOfTile,
                      style: TextStyle(fontSize: SizeSystem.size17,color: state.searchDetailModel.first.wrapperinstance!.facet![widget.index]
                          .selectedRefinement!.isNotEmpty?Colors.red:Colors.black,fontWeight: FontWeight.bold,fontFamily: kRubik),
                    ),
                    trailing: loading?CupertinoActivityIndicator():state.searchDetailModel.first.wrapperinstance!.facet![widget.index]
                        .selectedRefinement!.isNotEmpty?SizedBox(
                      width: widthOfScreen *0.4,
                      child: TrailingWidgets(listOfRefinementItems:  state.searchDetailModel.first.wrapperinstance!.facet![widget.index]
                          .selectedRefinement!),
                    ):Container(height: 10,width: 10,)
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(
                color: ColorSystem.greyDark,
              ),
            ),
            state.searchDetailModel.first.wrapperinstance!.facet![widget.index].isExpand!?
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ListView.separated(
                    controller: itemScrollController,
                    shrinkWrap: true,
                    // itemScrollController: itemScrollController,
                    // itemPositionsListener: itemPositionsListener,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: finalRefinement.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(flex: 1,child: SizedBox()),
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              
                              onTap: () {
                                inventorySearchBloc.add(AddFilters(
                                    parentIndex: widget.index, childIndex: index));
                                mainTileTrailingWidget(state);
                              },
                              child: ListTile(
                                title: Text(
                                  '${finalRefinement[index].name!} (${finalRefinement[index].eRecCount!})',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color:
                                      finalRefinement[index]
                                          .onPressed!
                                          ? Colors.red
                                          : Colors.black,
                                      fontFamily: kRubik),
                                ),
                                trailing: finalRefinement[index].onPressed!
                                    ? Icon(
                                  Icons.check,
                                  color: Colors.red,
                                  size: 35,
                                )
                                    : SizedBox(
                                  height: 10,
                                  width: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }, separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: EdgeInsets.only(left:widthOfScreen*0.2),
                          child: Divider(
                            color: finalRefinement[index].onPressed!?ColorSystem.greyDark:ColorSystem.greyDark,
                          ),
                        );
                  },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:widthOfScreen*0.2),
                    child: Divider(
                      color: ColorSystem.greyDark,
                    ),
                  )
                ],
              ),
            ):
            SliverToBoxAdapter(child: SizedBox.shrink()
            ),
          ],
        );
      } else {
        return Center(
          child: Text(
            'Ooops!\nSomething Wrong happened Please Try again Later',
            style: textThem.headline2,
            textAlign: TextAlign.center,
          ),
        );
      }
    });
  }
}
class TrailingWidgets extends StatelessWidget {
  final List<Refinement> listOfRefinementItems;

  TrailingWidgets({
    Key? key,
    required this.listOfRefinementItems,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    if (listOfRefinementItems.isEmpty) {
      return SizedBox();
    }
    if (listOfRefinementItems.length == 1) {
      if (listOfRefinementItems[0].name != null) {
        return Text(listOfRefinementItems[0].name!,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),textAlign: TextAlign.end,);
      } else {
        return SizedBox();
      }
    }
    if (listOfRefinementItems.length == 2) {
      return Container(
        alignment: Alignment.centerRight,

        child: Wrap(
          alignment: WrapAlignment.end,

          children: [
            if (listOfRefinementItems[0].name != null)
              Text(
                listOfRefinementItems[0].name!+', ',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),textAlign: TextAlign.end,
              ),
            SizedBox(
              width: SizeSystem.size4,
            ),
            if (listOfRefinementItems[1].name != null)
              Text(
                  listOfRefinementItems[1].name!,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik)
              ),
          ],
        ),
      );
    }
    if (listOfRefinementItems.length == 3) {
      return Container(
        alignment: Alignment.centerRight,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.end,

              children: [
                if (listOfRefinementItems[0].name != null)
                  Text(
                    listOfRefinementItems[0].name!+', ',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,),
                  ),
                SizedBox(
                  width: SizeSystem.size4,
                ),
                if (listOfRefinementItems[1].name != null)
                  Text(
                    listOfRefinementItems[1].name!+', ',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),
                  ),
                SizedBox(
                  height: SizeSystem.size4,
                ),
                if (listOfRefinementItems[2].name != null)
                  Text(
                    listOfRefinementItems[2].name!,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    if (listOfRefinementItems.length >= 4) {
      return Container(
        alignment: Alignment.centerRight,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.end,

              children: [
                if (listOfRefinementItems[0].name != null)
                  Text(
                    listOfRefinementItems[0].name!+', ',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),
                  ),
                SizedBox(
                  width: SizeSystem.size4,
                ),
                if (listOfRefinementItems[1].name != null)
                  Text(
                    listOfRefinementItems[1].name!+', ',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),
                  ),
                SizedBox(
                  width: SizeSystem.size4,
                ),
                if (listOfRefinementItems[2].name != null)
                  Text(
                    listOfRefinementItems[2].name!+', ',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),
                  ),
                Text(
                  '+${listOfRefinementItems.length - 3}',
                  style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontFamily: kRubik),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }
}