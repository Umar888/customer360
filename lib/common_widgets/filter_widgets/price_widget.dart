import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/models/common_models/refinement_model.dart';
import 'package:gc_customer_app/models/inventory_search/add_search_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:intl/intl.dart';


class PriceTileWidget extends StatefulWidget {
  PriceTileWidget(
      {super.key,
      required this.nameOfTile,
      required this.index,
      required this.minAmountController,
      required this.maxAmountController});
  final String nameOfTile;
  final int index;
  final TextEditingController minAmountController;
  final TextEditingController maxAmountController;

  @override
  State<PriceTileWidget> createState() => _PriceTileWidgetState();
}

class _PriceTileWidgetState extends State<PriceTileWidget> {
  List<Text> trailingItems = [];
  late InventorySearchBloc inventorySearchBloc;
  bool? isExpanded = false;

  @override
  void initState() {
    inventorySearchBloc = context.read<InventorySearchBloc>();
    super.initState();
  }

  List<Widget> mainTileTrailingWidget(InventorySearchState state) {
    for (var i = 0;
        i <
            state.searchDetailModel.first.wrapperinstance!.facet![widget.index]
                .refinement!.length;
        i++) {
      if (state.searchDetailModel.first.wrapperinstance!.facet![widget.index]
              .refinement![i].onPressed ==
          true) {
        trailingItems.add(Text(
          dollarSignAddString(state.searchDetailModel.first.wrapperinstance!
              .facet![widget.index].refinement![i].name!),
          style: TextStyle(color: Colors.red, fontFamily: kRubik),
        ));
      } else {}
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
    // double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return BlocConsumer<InventorySearchBloc, InventorySearchState>(
        listener: (context, state) {
      if (state.message.isNotEmpty && state.message != "done" && state.message != "zebon") {
        Future.delayed(Duration.zero, () {
          setState(() {});
          showMessage(context: context,message:state.message);
        });
      }
      inventorySearchBloc.add(EmptyMessage());
    }, builder: (context, state) {
      if (state.inventorySearchStatus == InventorySearchStatus.successState) {
        return Column(
          children: [
            InkWell(
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
                    style: TextStyle(
                        fontSize: SizeSystem.size17,
                        color: state
                                .searchDetailModel
                                .first
                                .wrapperinstance!
                                .facet![widget.index]
                                .selectedRefinement!
                                .isNotEmpty
                            ? Colors.red
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: kRubik),
                  ),
                  trailing: state.searchDetailModel.first.wrapperinstance!
                          .facet![widget.index].selectedRefinement!.isNotEmpty
                      ? SizedBox(
                          width: widthOfScreen * 0.4,
                          child: TrailingWidgets(
                              listOfRefinementItems: state
                                  .searchDetailModel
                                  .first
                                  .wrapperinstance!
                                  .facet![widget.index]
                                  .selectedRefinement!),
                        )
                      : Container(
                          height: 10,
                          width: 10,
                        )),
            ),
            // Expanded(flex: 1, child: SizedBox()),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Divider(
                color: ColorSystem.greyDark,
              ),
            ),
            state.searchDetailModel.first.wrapperinstance!.facet![widget.index]
                    .isExpand!
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: state.searchDetailModel.first.wrapperinstance!
                        .facet![widget.index].refinement!.length,
                    itemBuilder: (context, index) {
                      // if (index == 0) {
                      //   return Column(
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Expanded(flex: 1, child: SizedBox()),
                      //           Expanded(
                      //             flex: 5,
                      //             child: Column(
                      //               children: [
                      //                 Row(
                      //                   children: [
                      //                     SizedBox(
                      //                       width: 12,
                      //                     ),
                      //                     Expanded(
                      //                       flex: 2,
                      //                       child: Container(
                      //                         padding: EdgeInsets.only(left: 10),
                      //                         decoration: BoxDecoration(
                      //                             border: Border.all(
                      //                               color: ColorSystem.greyDark,
                      //                             ),
                      //                             borderRadius:
                      //                                 BorderRadius.circular(10)),
                      //                         child: TextField(
                      //                           controller: widget.minAmountController,
                      //                           keyboardType: TextInputType.number,
                      //                           decoration: InputDecoration(
                      //                             border: InputBorder.none,
                      //                             hintText: '\$ Min',
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     SizedBox(width: 10),
                      //                     Text(
                      //                       'to',
                      //                       style: TextStyle(
                      //                           fontSize: SizeSystem.size16,
                      //                           fontFamily: kRubik),
                      //                     ),
                      //                     SizedBox(width: 10),
                      //                     Expanded(
                      //                       flex: 2,
                      //                       child: Container(
                      //                         padding: EdgeInsets.only(left: 10),
                      //                         decoration: BoxDecoration(
                      //                             border: Border.all(
                      //                               color: ColorSystem.greyDark,
                      //                             ),
                      //                             borderRadius:
                      //                                 BorderRadius.circular(10)),
                      //                         child: TextField(
                      //                           controller: widget.maxAmountController,
                      //                           keyboardType: TextInputType.number,
                      //                           decoration: InputDecoration(
                      //                             border: InputBorder.none,
                      //                             hintText: '\$ Max',
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     Expanded(flex: 1, child: SizedBox())
                      //                   ],
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.only(left: 12.0),
                      //                   child: Divider(
                      //                     color: ColorSystem.greyDark,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       Row(
                      //   children: [
                      //     Expanded(flex: 1, child: SizedBox()),
                      //     Expanded(
                      //       flex: 5,
                      //       child: InkWell(
                      //         onTap: () {
                      //           inventorySearchBloc.add(AddFilters(
                      //               parentIndex: widget.index,
                      //               childIndex: index));
                      //           mainTileTrailingWidget(state);
                      //         },
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             ListTile(
                      //               title: Text(
                      //                 dollarSignAddString(state
                      //                         .searchDetailModel
                      //                         .first
                      //                         .wrapperinstance!
                      //                         .facet![widget.index]
                      //                         .refinement![index]
                      //                         .name!) +
                      //                     ' (${state.searchDetailModel.first.wrapperinstance!.facet![widget.index].refinement![index].eRecCount!})',
                      //                 style: TextStyle(
                      //                     fontSize: 18.0,
                      //                     color: state
                      //                             .searchDetailModel
                      //                             .first
                      //                             .wrapperinstance!
                      //                             .facet![widget.index]
                      //                             .refinement![index]
                      //                             .onPressed!
                      //                         ? Colors.red
                      //                         : Colors.black,
                      //                     fontFamily: kRubik),
                      //               ),
                      //               trailing: state
                      //                       .searchDetailModel
                      //                       .first
                      //                       .wrapperinstance!
                      //                       .facet![widget.index]
                      //                       .refinement![index]
                      //                       .onPressed!
                      //                   ? Icon(
                      //                       Icons.check,
                      //                       color: Colors.red,
                      //                       size: 35,
                      //                     )
                      //                   : SizedBox(
                      //                       height: 10,
                      //                       width: 10,
                      //                     ),
                      //             ),
                      //             Padding(
                      //               padding: EdgeInsets.only(left: 12.0),
                      //               child: Divider(
                      //                 color: ColorSystem.greyDark,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      //     ],
                      //   );
                      // }
                      return Row(
                        children: [
                          Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              onTap: () {
                                inventorySearchBloc.add(AddFilters(
                                    parentIndex: widget.index,
                                    childIndex: index));
                                mainTileTrailingWidget(state);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      dollarSignAddString(state
                                              .searchDetailModel
                                              .first
                                              .wrapperinstance!
                                              .facet![widget.index]
                                              .refinement![index]
                                              .name!) +
                                          ' (${state.searchDetailModel.first.wrapperinstance!.facet![widget.index].refinement![index].eRecCount!})',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: state
                                                  .searchDetailModel
                                                  .first
                                                  .wrapperinstance!
                                                  .facet![widget.index]
                                                  .refinement![index]
                                                  .onPressed!
                                              ? Colors.red
                                              : Colors.black,
                                          fontFamily: kRubik),
                                    ),
                                    trailing: state
                                            .searchDetailModel
                                            .first
                                            .wrapperinstance!
                                            .facet![widget.index]
                                            .refinement![index]
                                            .onPressed!
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
                                  Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Divider(
                                      color: ColorSystem.greyDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Container(),
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
  String dollarSignAddString(String amountRange) {
    String firstPart;
    String secondPart;
    String overTxtValues;
    int firstPartOfNumber = 0;
    int secondtPartOfNumber = 0;

    if (amountRange.contains('-')) {
      if (!amountRange.contains('Over')) {
        firstPart = amountRange.split('-')[0].trim();
        secondPart = amountRange.split('-')[1].trim();

        firstPartOfNumber = int.parse(firstPart);
        secondtPartOfNumber = int.parse(secondPart);
        if (firstPartOfNumber >= 1000) {
          firstPart =
              NumberFormat.compact().format(firstPartOfNumber).toString();
        }
        if (secondtPartOfNumber >= 1000) {
          secondPart =
              NumberFormat.compact().format(secondtPartOfNumber).toString();
        }

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
    if (listOfRefinementItems.isEmpty) {
      return SizedBox();
    }
    if (listOfRefinementItems.length == 1) {
      if (listOfRefinementItems[0].name != null) {
        return Text(
          dollarSignAddString(listOfRefinementItems[0].name!),
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontFamily: kRubik),
          textAlign: TextAlign.end,
        );
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
                dollarSignAddString(listOfRefinementItems[0].name!) + ', ',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: kRubik),
                textAlign: TextAlign.end,
              ),
            SizedBox(
              width: SizeSystem.size4,
            ),
            if (listOfRefinementItems[1].name != null)
              Text(dollarSignAddString(listOfRefinementItems[1].name!),
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: kRubik)),
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
                    dollarSignAddString(listOfRefinementItems[0].name!) + ', ',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: kRubik),
                  ),
                SizedBox(
                  width: SizeSystem.size4,
                ),
                if (listOfRefinementItems[1].name != null)
                  Text(
                    dollarSignAddString(listOfRefinementItems[1].name!) + ', ',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: kRubik),
                  ),
                SizedBox(
                  height: SizeSystem.size4,
                ),
                if (listOfRefinementItems[2].name != null)
                  Text(
                    dollarSignAddString(listOfRefinementItems[2].name!),
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: kRubik),
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
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.end,
                children: [
                  if (listOfRefinementItems[0].name != null)
                    Text(
                      dollarSignAddString(listOfRefinementItems[0].name!) +
                          ', ',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: kRubik),
                    ),
                  SizedBox(
                    width: SizeSystem.size4,
                  ),
                  if (listOfRefinementItems[1].name != null)
                    Text(
                      dollarSignAddString(listOfRefinementItems[1].name!) +
                          ', ',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: kRubik),
                    ),
                  SizedBox(
                    width: SizeSystem.size4,
                  ),
                  if (listOfRefinementItems[2].name != null)
                    Text(
                      dollarSignAddString(listOfRefinementItems[2].name!) +
                          ', ',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: kRubik),
                    ),
                  Text(
                    '+${listOfRefinementItems.length - 3}',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: kRubik),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox();
  }
}
