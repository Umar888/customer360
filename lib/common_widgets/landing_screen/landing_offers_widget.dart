import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/common_widgets/offers_widget.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/offers_screen/offers_screen_main.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';

class LandingOffersWidget extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  LandingOffersWidget({super.key, required this.customerInfoModel});

  @override
  State<LandingOffersWidget> createState() => _LandingOffersWidgetState();
}

class _LandingOffersWidgetState extends State<LandingOffersWidget> {
  late LandingScreenBloc landingScreenBloc;

  @override
  void initState() {
    landingScreenBloc = context.read<LandingScreenBloc>();
    landingScreenBloc.add(LoadOffers());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<LandingScreenBloc, LandingScreenState>(
        builder: (context, state) {
      if (state.landingScreenStatus == LandingScreenStatus.success) {
        if (!state.gettingOffers!) {
          // print("state.gettingFavorites ${state.gettingFavorites}");
          if (state.landingScreenOffersModel != null &&
              state.landingScreenOffersModel!.offers != null &&
              state.landingScreenOffersModel!.offers!.isNotEmpty) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: widthOfScreen * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        offerstxt,
                        style: TextStyle(
                            color: ColorSystem.blueGrey,
                            fontFamily: kRubik,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: size.height * 0.2,
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
                        itemCount:
                            state.landingScreenOffersModel!.offers!.length,
                        separatorBuilder: (context, i) => SizedBox(
                          width: size.width * 0.04,
                        ),
                        itemBuilder: (context, index) => InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => OffersScreenMain(
                                      customerInfoModel:
                                          widget.customerInfoModel,
                                      offers: state
                                          .landingScreenOffersModel!.offers!)))
                              .then((value) => searchNameInOffersScreen = ''),
                          child: OffersWidget(
                            widthOfScreen: size.width,
                            pathOfImage: state.landingScreenOffersModel
                                    ?.offers?[index].flashDeal?.assetPath
                                    ?.toString() ??
                                '',
                            percentageOff: state
                                    .landingScreenOffersModel!
                                    .offers![index]
                                    .flashDeal!
                                    .savingsPercentRounded
                                    ?.toStringAsFixed(2) ??
                                '',
                            backOf: amountFormatting(state.landingScreenOffersModel!
                                    .offers![index].flashDeal!.todaysPrice!),
                            totalPrice:  amountFormatting(state.landingScreenOffersModel!
                                    .offers![index].flashDeal!.msrpPrice!),
                            numberOfProducts: state
                                    .landingScreenOffersModel!
                                    .offers![index]
                                    .flashDeal!
                                    .productDisplayName ??
                                '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        } else {
          return SizedBox(
            height: size.height * 0.1,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      } else {
        return SizedBox(
          height: size.height * 0.1,
          child: Center(child: CircularProgressIndicator()),
        );
      }
    });
  }
}
