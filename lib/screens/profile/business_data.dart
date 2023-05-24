import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/purchase_metrics_bloc/purchase_metrics_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/order_history/order_history_model.dart';
import 'package:gc_customer_app/models/purchase_metrics_model.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/screens/profile/business_data_chart_widget.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:provider/provider.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class BusinessData extends StatefulWidget {
  final BoxConstraints constraints;
  final UserProfile? userProfile;
  BusinessData(this.constraints, this.userProfile, {super.key});

  @override
  State<BusinessData> createState() => _BusinessDataState();
}

class _BusinessDataState extends State<BusinessData> {
  late OrderHistoryBloc orderHistoryBloc;

  @override
  void initState() {
    super.initState();
    // orderHistoryBloc = context.read<OrderHistoryBloc>();
    // orderHistoryBloc.add(FetchOrderHistory());
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(top: 14, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
          //   builder: (context, state) {
          //     if (state.fetchOrderHistory ?? false) {
          //       return Center(child: CircularProgressIndicator());
          //     }
          //     if ((state.orderHistory ?? <OrderHistoryModel>[]).isNotEmpty) {
          //       var histories = state.orderHistory!;
          //       histories.sort((a, b) => (a.orderDate != null &&
          //               DateTime.parse(a.orderDate ?? DateTime(1900).toString())
          //                   .isBefore(DateTime.parse(
          //                       b.orderDate ?? DateTime(1900).toString()))
          //           ? 1
          //           : 0));
          //       if (histories.first.orderDate == null) {
          //         return SizedBox.shrink();
          //       }
          //       int newestYear =
          //           DateTime.parse(histories.first.orderDate!).year;
          //       List<OrderHistory> dataInNewestYear = histories
          //           .where((h) =>
          //               DateTime.parse(h.orderDate ?? DateTime(1900).toString())
          //                   .year ==
          //               newestYear)
          //           .toList();
          //       String? previousYearString = histories
          //           .firstWhere(
          //               (h) =>
          //                   (DateTime.parse(
          //                           h.orderDate ?? DateTime(1900).toString())
          //                       .year) <
          //                   newestYear,
          //               orElse: () => OrderHistory())
          //           .orderDate;
          //       int? previousYear;
          //       List<OrderHistory>? dataInPreviousYear;
          //       if (previousYearString != null) {
          //         previousYear = DateTime.parse(previousYearString).year;
          //         dataInPreviousYear = histories
          //             .where((h) =>
          //                 DateTime.parse(
          //                         h.orderDate ?? DateTime(1900).toString())
          //                     .year ==
          //                 previousYear)
          //             .toList();
          //       }

          //       return Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           rate(textTheme, newestYear, dataInNewestYear, previousYear,
          //               dataInPreviousYear),
          //           //Chart
          //           Container(
          //               width:
          //                   kIsWeb ? 188 : widget.constraints.maxWidth / 1.82,
          //               height: kIsWeb
          //                   ? 85
          //                   : (widget.constraints.maxWidth / 1.81) / 2.4,
          //               color: Colors.white,
          //               padding: EdgeInsets.only(left: 14),
          //               child: BusinessDataChart(
          //                   dataInNewestYear: dataInNewestYear,
          //                   dataInPreviousYear: dataInPreviousYear))
          //         ],
          //       );
          //     }
          //     return SizedBox.shrink();
          //   },
          // ),
          SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                businessValue(
                    title: ltvtxt,
                    value: widget.userProfile?.lifetimeNetSalesAmountC ?? 0,
                    textTheme),
                divider(),
                businessValue(
                    title: transactiontxt,
                    value:
                        widget.userProfile?.lifetimeNetSalesTransactionsC ?? 0,
                    textTheme),
                divider(),
                businessValue(
                    title: aovtxt,
                    value: (widget.userProfile?.lifetimeNetSalesAmountC ?? 0) /
                        (widget.userProfile?.lifetimeNetSalesTransactionsC ??
                            1),
                    textTheme),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget divider() => VerticalDivider(
        width: 5,
        thickness: 1,
        color: ColorSystem.greyLight,
      );

  Widget businessValue(
    TextTheme textTheme, {
    required String title,
    required double value,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.headline5?.copyWith(fontSize: 10)),
          SizedBox(height: 4),
          Text(
            '\$${value.toHumanRead()}',
            style: textTheme.headline3
                ?.copyWith(fontSize: 24, fontWeight: FontWeight.w500),
          )
        ],
      );

  Widget rate(
      TextTheme textTheme,
      int newestYear,
      List<OrderHistory> dataInNewestYear,
      int? previousYear,
      List<OrderHistory>? dataInPreviousYear) {
    double dataNewestYear = 0;
    dataInNewestYear.forEach((d) => dataNewestYear +=
        double.parse(d.lineItems?.first.purchasedPrice ?? '0.0'));
    double dataPreviousYear = 0;
    dataInPreviousYear?.forEach((d) => dataPreviousYear +=
        double.parse(d.lineItems?.first.purchasedPrice ?? '0.0'));
    bool isDataIncrease = dataNewestYear >= dataPreviousYear;
    return Column(
      children: [
        Row(
          children: [
            Text(
              newestYear.toString(),
              style: textTheme.bodyText1,
            ),
            SizedBox(width: 8),
            if (previousYear != null)
              SvgPicture.asset(
                isDataIncrease
                    ? IconSystem.upwardTrendIcon
                    : IconSystem.downwardTrendIcon,
                package: 'gc_customer_app',
                width: 22,
              )
          ],
        ),
        Text(
          '\$${dataNewestYear.toStringAsFixed(2)}',
          style: textTheme.headline3
              ?.copyWith(fontSize: 30, fontWeight: FontWeight.w500),
        ),
        if (previousYear != null)
          Text(
            '\$$previousYear : \$${dataPreviousYear.toHumanRead()}',
            style: textTheme.bodyText1,
          )
      ],
    );
  }
}
