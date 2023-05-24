import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/case_history_screen_bloc/case_history_screen_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:intl/intl.dart';

import '../../common_widgets/case_history_widgets/case_history_cart_widget.dart';
import '../../common_widgets/case_history_widgets/case_history_pie_chart_data_widget.dart';
import '../../common_widgets/case_history_widgets/open_cases_widget.dart';
import '../../common_widgets/dash_generator.dart';
import '../../common_widgets/search_bar_widget.dart';
import '../../primitives/color_system.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/padding_system.dart';

class CaseHistoryScreen extends StatefulWidget {
  CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  late CaseHistoryScreenBloc caseHistoryScreenBloc;

  @override
  initState() {
    super.initState();
    caseHistoryScreenBloc = context.read<CaseHistoryScreenBloc>();
    caseHistoryScreenBloc.add(LoadData());
  }

  @override
  Widget build(BuildContext context) {
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    var textThem = Theme.of(context).textTheme;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBarWidget(
            paddingFromleftLeading: widthOfScreen * 0.034,
            paddingFromRightActions: widthOfScreen * 0.034,
            textThem: Theme.of(context).textTheme,
            leadingWidget: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey[600],
              size: 30,
            ),
            onPressedLeading: () => Navigator.of(context).pop(),
            titletxt: 'CASE HISTORY',
            actionsWidget: SizedBox.shrink(),
            actionOnPress: () => () {},
          ),
        ),
        body: BlocBuilder<CaseHistoryScreenBloc, CaseHistoryScreenState>(
          builder: (context, state) {
            if (state is CaseHistoryScreenSuccess) {
              formatDate(String date) {
                return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
              }

              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: heightOfScreen * 0.05),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: widthOfScreen * 0.12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 110,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              pieTouchData: PieTouchData(
                                  enabled: true,
                                  touchCallback: (event, response) {
                                    // if (response != null) {
                                    //   if (response.touchedSection != null) {
                                    //     if (response.touchedSection?.touchedSectionIndex !=
                                    //         null) {
                                    //       switch (
                                    //           response.touchedSection!.touchedSectionIndex) {
                                    //         case 0:
                                    //           var blocInstance = context.read<TaskListBloc>();
                                    //           blocInstance.add(
                                    //               TaskListEvent.viewFilteredTasks(
                                    //                   'ACTIVE TASKS',
                                    //                   TaskFilterTypeEnum.active));
                                    //           break;
                                    //         case 1:
                                    //           var blocInstance = context.read<TaskListBloc>();
                                    //           blocInstance.add(
                                    //               TaskListEvent.viewFilteredTasks(
                                    //                   'OVERDUE TASKS',
                                    //                   TaskFilterTypeEnum.overdue));
                                    //           break;
                                    //         case 2:
                                    //           var blocInstance = context.read<TaskListBloc>();
                                    //           blocInstance.add(
                                    //               TaskListEvent.viewFilteredTasks(
                                    //                   'UNASSIGNED TASKS',
                                    //                   TaskFilterTypeEnum.unAssigned));
                                    //           break;
                                    //       }
                                    //     }
                                    //   }
                                    // }
                                  }),
                              sections: showingSections(
                                deliveredTasks: 65,
                                purchasedTasks: 14,
                              ),
                              centerSpaceColor:
                                  ColorSystem.purple.withOpacity(0.1),
                              centerSpaceRadius: 24,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: widthOfScreen * 0.1,
                        ),
                        Expanded(
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              CaseHistoryPieChartDataWidget(
                                heightOfScreen: heightOfScreen,
                                widthOfScreen: widthOfScreen,
                                numberOfOrders: '65',
                                textOfItems: 'Delivery',
                                colorOfVerticalBar:
                                    AppColors.deliveredTaskColor,
                              ),
                              CaseHistoryPieChartDataWidget(
                                heightOfScreen: heightOfScreen,
                                widthOfScreen: widthOfScreen,
                                numberOfOrders: '14',
                                textOfItems: 'Purchase',
                                colorOfVerticalBar:
                                    AppColors.purchasedTaskColor,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: heightOfScreen * 0.02),
                  Padding(
                    padding: EdgeInsets.only(left: widthOfScreen * 0.11),
                    child: Row(
                      children: [
                        Text(
                          'LAST CASE',
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.grey),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          formatDate(state.caseHistoryChartDetails!.records[0]
                                  .lastModifiedDate)
                              .toUpperCase(),
                          style: TextStyle(
                              fontSize: SizeSystem.size15,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: heightOfScreen * 0.02,
                  ),
                  SearchBaarWidget(
                    widthOfScreen: widthOfScreen,
                    heightOfScreen: heightOfScreen,
                    textOfSearchBar: 'Sort By',
                    onTapSearchText: () {},
                    onTapSearchButton: () {},
                    showNotification: false,
                    numberOfNotifications: '',
                    searchBarTextColor: Colors.black,
                  ),
                  SizedBox(
                    height: heightOfScreen * 0.02,
                  ),
                  // state is CaseHistoryOpenCasesFailure
                  //     ? Center(
                  //         child: Text(
                  //           'An Error Occurred While Loading Open Cases',
                  //           style: textThem.headline5,
                  //         ),
                  //       )
                  //     :
                  Padding(
                    padding: EdgeInsets.only(
                      left: widthOfScreen * 0.05,
                      right: widthOfScreen * 0.05,
                      top: heightOfScreen * 0.03,
                      bottom: heightOfScreen * 0.03,
                    ),
                    child: Container(
                      width: widthOfScreen * 1,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.greyContainer),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: widthOfScreen * 0.06,
                          right: widthOfScreen * 0.06,
                          top: heightOfScreen * 0.03,
                          bottom: heightOfScreen * 0.03,
                        ),
                        child: ListView.separated(
                          itemCount: state.openCasesListModel!.records.length,
                          primary: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              OpenCasesDeliveryWidge(
                                widthOfScreen: widthOfScreen,
                                textOfItems: state
                                    .openCasesListModel!.records[0].owner.name,
                                dateOfItem: formatDate(state.openCasesListModel!
                                    .records[0].lastModifiedDate),
                                dateColor: AppColors.redTextColor,
                                remainingText: 'Laximinaras ass asf',
                                twoIcons: true,
                                rightIconPath: IconSystem.cartIcon,
                                leftIconPath: IconSystem.shippingDetails,
                              ),
                            ],
                          ),
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              color: Colors.grey.withOpacity(0.2),
                              thickness: 1,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: heightOfScreen * 0.03,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: widthOfScreen * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Case History',
                          style: textThem.headline2,
                        ),
                        SizedBox(height: heightOfScreen * 0.04),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                              right: PaddingSystem.padding20),
                          itemCount:
                              state.caseHistoryListModelClass!.records.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    index == 0
                                        ? Column(
                                            children: [
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.black)),
                                              ),
                                              DashGenerator(
                                                  numberOfDashes: 3),
                                              Container(
                                                height: 17,
                                                width: 17,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        AppColors.blueContainer,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        spreadRadius: 1,
                                                        blurRadius: 10,
                                                        offset: Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 3)),
                                              ),
                                              DashGenerator(
                                                  numberOfDashes: 3),
                                            ],
                                          )
                                        : index > 0 &&
                                                index <
                                                    state.caseHistoryListModelClass!
                                                            .records.length -
                                                        1
                                            ? Column(
                                                children: [
                                                  DashGenerator(
                                                    numberOfDashes: 4,
                                                  ),
                                                  Container(
                                                    height: 17,
                                                    width: 17,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors
                                                            .blueContainer,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                            spreadRadius: 1,
                                                            blurRadius: 10,
                                                            offset: Offset(
                                                                0,
                                                                3), // changes position of shadow
                                                          ),
                                                        ],
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 3)),
                                                  ),
                                                  DashGenerator(
                                                      numberOfDashes: 4),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  DashGenerator(
                                                    numberOfDashes: 4,
                                                  ),
                                                  Container(
                                                    height: 17,
                                                    width: 17,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors
                                                            .blueContainer,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                            spreadRadius: 1,
                                                            blurRadius: 10,
                                                            offset: Offset(
                                                                0,
                                                                3), // changes position of shadow
                                                          ),
                                                        ],
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 3)),
                                                  ),
                                                  DashGenerator(
                                                    numberOfDashes: 3,
                                                    color: ColorSystem
                                                        .scaffoldBackgroundColor,
                                                  ),
                                                ],
                                              ),
                                    SizedBox(
                                      width: SizeSystem.size20,
                                    ),
                                    // state is CaseHistoryCasesFailure
                                    //     ? Center(
                                    //         child: Text(
                                    //           'An Error Occurred While Loading Case History',
                                    //           style: textThem.headline5,
                                    //         ),
                                    //       )
                                    //     :

                                    Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(right: 20.0),
                                        child: CaseHistoryCartDeliveryWidget(
                                          widthOfScreen: widthOfScreen,
                                          textOfItems: state
                                              .caseHistoryListModelClass!
                                              .records[0]
                                              .owner
                                              .name,
                                          dateOfItem: formatDate(state
                                              .caseHistoryListModelClass!
                                              .records[0]
                                              .lastModifiedDate),
                                          remainingText: 'Laximinaras ass asf',
                                          twoIcons: true,
                                          rightIconPath: IconSystem.cartIcon,
                                          leftIconPath:
                                              IconSystem.shippingDetails,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              );
            } else if (state is CaseHistoryScreenFailure) {
              return Center(
                child: Text(
                  'Ooops!\nSomething Wrong happened Please Try again Later',
                  style: textThem.headline2,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Container(
                  height: heightOfScreen / 2,
                  color: Colors.white,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ));
            }
          },
        ));
  }

  List<PieChartSectionData> showingSections({
    required double deliveredTasks,
    required double purchasedTasks,
  }) {
    return List.generate(2, (i) {
      const fontSize = 0.0;
      const  radius = 26.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.deliveredTaskColor,
            value: deliveredTasks,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.purchasedTaskColor,
            value: purchasedTasks,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
            ),
          );

        default:
          throw Error();
      }
    });
  }
}
