import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/recommended_landing_bloc/recommended_landing_bloc.dart';
import 'package:gc_customer_app/common_widgets/order_history/order_product.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model_buy_again.dart';
import 'package:gc_customer_app/models/order_history/order_history.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/recommendation_screen/recommendation_screen_main.dart';

class RecommendedWidget extends StatefulWidget {
  final LandingScreenState landingScreenState;
  final LandingScreenRecommendationModel landingScreenRecommendationModel;
  RecommendedWidget({super.key, required this.landingScreenState, required this.landingScreenRecommendationModel});

  @override
  State<RecommendedWidget> createState() => _RecommendedWidgetState();
}

class _RecommendedWidgetState extends State<RecommendedWidget> {
  @override
  void initState() {
    super.initState();
    context.read<RecommendedLandingBloc>().add(LoadRecommendedData());
  }

  @override
  Widget build(BuildContext context) {
    var heightOfScreen = MediaQuery.of(context).size.height;
    return BlocBuilder<RecommendedLandingBloc, RecommendedLandingState>(
        builder: (context, state) {
      LandingScreenRecommendationModel? recommended;
      LandingScreenRecommendationModelBuyAgain? recommendedBuyAgain;
      if (state is RecommendedLandingSuccess) {
        recommended = widget.landingScreenRecommendationModel;

        recommendedBuyAgain = state.recommendedBuyAgain;
      }
      if (state is RecommendedLandingProgress) {
        return Center(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: CircularProgressIndicator(),
        ));
      }
      if (state is RecommendedLandingFailure ||
          (recommended?.status ?? 0) != 200) return SizedBox.shrink();
      return !widget.landingScreenState.gettingFavorites! &&
                  recommended!.productBrowsing!.isNotEmpty
          /*||
              (recommended!.productBrowsing!.isEmpty &&
                  recommendedBuyAgain!.productBuyAgain!.isNotEmpty
              )*/
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recommendedtxt,
                        style: TextStyle(
                            color: ColorSystem.blueGrey,
                            fontFamily: kRubik,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      Text(
                        '${recommended.productBrowsing!.isNotEmpty && recommended.productBrowsing!.first.recommendedProductSet!.length > 3?3:
                        recommended.productBrowsing!.first.recommendedProductSet!.length} items',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                !widget.landingScreenState.gettingFavorites!
                    ? recommended.productBrowsing!.isNotEmpty
                        ? SizedBox(
                            height: heightOfScreen * 0.17,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        width: 10,
                                      );
                                    },
                                    itemCount: recommended.productBrowsing!
                                        .first.recommendedProductSet!.length>3?3:recommended.productBrowsing!
                                    .first.recommendedProductSet!.length,
                                    itemBuilder: (context, index) {
                                      return BlocProvider.value(
                                        value:
                                            context.read<LandingScreenBloc>(),
                                        child: AspectRatio(
                                          aspectRatio: MediaQuery.of(context).size.aspectRatio * 1.75,
                                          child: OrderHistoryProductItem(
                                            isLanding: true,
                                            recommendationModel: recommended,
                                            recommendationModelBuyAgain:
                                                recommendedBuyAgain,
                                            gettingFavorites: widget
                                                .landingScreenState
                                                .gettingFavorites!,
                                            gettingActivity: widget
                                                .landingScreenState
                                                .gettingActivity!,
                                            orderItems: OrderItems(
                                                itemSku: recommended!
                                                    .productBrowsing!
                                                    .first
                                                    .recommendedProductSet![
                                                        index]
                                                    .itemSKU,
                                                itemPrice: recommended
                                                    .productBrowsing!
                                                    .first
                                                    .recommendedProductSet![
                                                        index]
                                                    .salePrice!
                                                    .toStringAsFixed(2),
                                                itemPic: recommended
                                                    .productBrowsing!
                                                    .first
                                                    .recommendedProductSet![
                                                        index]
                                                    .imageURL!,
                                                itemName: recommended
                                                    .productBrowsing!
                                                    .first
                                                    .recommendedProductSet![
                                                        index]
                                                    .name!,
                                                isItemOutOfStock: recommended
                                                    .productBrowsing!
                                                    .first
                                                    .recommendedProductSet![
                                                        index]
                                                    .outOfStock!,
                                                isNetwork: true,
                                                isItemOnline: recommended
                                                    .productBrowsing!
                                                    .first
                                                    .recommendedProductSet![
                                                        index]
                                                    .inStore!),
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RecommendationScreenMain(
                                                    customerInfoModel: widget
                                                        .landingScreenState
                                                        .customerInfoModel!,
                                                    selectedItemId: recommended!
                                                        .productBrowsing!
                                                        .first
                                                        .recommendedProductSet![
                                                            index]
                                                        .itemSKU,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    })
                              ],
                            ))
                        /*: (recommended.productBrowsing!.isEmpty &&
                                recommendedBuyAgain!
                                    .productBuyAgain!.isNotEmpty)
                            ? SizedBox(
                                height: heightOfScreen * 0.17,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        separatorBuilder: (context, index) {
                                          return SizedBox(
                                            width: 10,
                                          );
                                        },
                                        itemCount: recommendedBuyAgain
                                            .productBuyAgain!.length,
                                        itemBuilder: (context, index) {
                                          return BlocProvider.value(
                                            value: context
                                                .read<LandingScreenBloc>(),
                                            child: AspectRatio(
                                              aspectRatio:
                                                  MediaQuery.of(context)
                                                          .size
                                                          .aspectRatio *
                                                      1.75,
                                              child: OrderHistoryProductItem(
                                                isLanding: true,
                                                recommendationModel:
                                                    recommended,
                                                recommendationModelBuyAgain:
                                                    recommendedBuyAgain,
                                                gettingFavorites: widget
                                                    .landingScreenState
                                                    .gettingFavorites!,
                                                gettingActivity: widget
                                                    .landingScreenState
                                                    .gettingActivity!,
                                                orderItems: OrderItems(
                                                    itemSku:
                                                        recommendedBuyAgain!
                                                            .productBuyAgain![
                                                                index]
                                                            .itemSKUC,
                                                    itemPrice:
                                                        recommendedBuyAgain
                                                            .productBuyAgain![
                                                                index]
                                                            .itemPriceC!
                                                            .toStringAsFixed(2),
                                                    itemPic: recommendedBuyAgain
                                                        .productBuyAgain![index]
                                                        .imageURLC!,
                                                    itemName:
                                                        recommendedBuyAgain
                                                            .productBuyAgain![
                                                                index]
                                                            .descriptionC!,
                                                    isItemOutOfStock:
                                                        recommendedBuyAgain
                                                            .productBuyAgain![
                                                                index]
                                                            .outOfStock!,
                                                    isNetwork: true,
                                                    isItemOnline:
                                                        recommendedBuyAgain
                                                            .productBuyAgain![
                                                                index]
                                                            .inStore!),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          RecommendationScreenMain(
                                                              customerInfoModel: widget
                                                                  .landingScreenState
                                                                  .customerInfoModel!),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        })
                                  ],
                                ))*/
                            : SizedBox.shrink()
                    : SizedBox(
                        height: heightOfScreen * 0.15,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                SizedBox(height: 25),
              ],
            )
          : SizedBox.shrink();
    });
  }
}
