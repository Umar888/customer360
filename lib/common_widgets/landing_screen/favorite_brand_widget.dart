import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/favorite_brand_landing_widget.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

import '../../screens/favourite_brand_screen/favorite_brand_screen.dart';

class FavoriteBrand extends StatefulWidget {
  FavoriteBrand({super.key, required this.landingScreenState});
  final LandingScreenState landingScreenState;
  @override
  State<FavoriteBrand> createState() => _FavoriteBrandState();
}

class _FavoriteBrandState extends State<FavoriteBrand> {
  late LandingScreenBloc landingScreenBloc;

  @override
  void initState() {
    landingScreenBloc = context.read<LandingScreenBloc>();
    landingScreenBloc.add(LoadFavoriteBrands());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    var textThem = Theme.of(context).textTheme;

    Size size = MediaQuery.of(context).size;
    return BlocBuilder<LandingScreenBloc, LandingScreenState>(
        builder: (context, state) {
      if (state.landingScreenStatus == LandingScreenStatus.success) {
        if (!state.gettingFavorites!) {
          if (state.favoriteBrandsLandingScreen != null &&
              state.favoriteBrandsLandingScreen != null &&
              state.favoriteBrandsLandingScreen!.isNotEmpty) {
            return Column(
              children: [
                // SizedBox(
                //   height: 25,
                // ),
                Padding(
                  padding: EdgeInsets.only(right: widthOfScreen * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        favoriteBrandtxt,
                        style: TextStyle(
                            color: ColorSystem.blueGrey,
                            fontFamily: kRubik,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      Text(
                        '${widget.landingScreenState.favoriteBrandsLandingScreen != null ? widget.landingScreenState.favoriteBrandsLandingScreen!.length : 0} items',
                        style: textThem.headline5,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: size.height * 0.17,
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
                            return SizedBox(width: 5);
                          },
                          itemCount: state.favoriteBrandsLandingScreen!.length,
                          itemBuilder: (context, index) {
                            //if(index < state.favoriteBrandsLandingScreen!.brands!.length) {
                            return AspectRatio(
                              aspectRatio:
                                  MediaQuery.of(context).size.aspectRatio *
                                      1.75,
                              child: FavoriteBrandLandingWidget(
                                widthOfScreen: size.width,
                                heightOfScreen: size.height,
                                onTap: () {
                                  print("widget.brandItems ${state.favoriteBrandsLandingScreen![index].items!.length}");
                                  for(int i=0; i < state.favoriteBrandsLandingScreen![index].items!.length ;i ++){
                                    print("widget.brandItems[i].description ${state.favoriteBrandsLandingScreen![index].items![i].description}");
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FavoriteBrandScreen(
                                        instrumentName: state
                                            .customerInfoModel!
                                            .records!
                                            .first
                                            .primaryInstrumentCategoryC??"",
                                        brandName: state
                                            .favoriteBrandsLandingScreen![index]
                                            .brand??"",
                                        listOfBrand: state
                                            .favoriteBrandsLandingScreen![index]
                                            .items!,
                                        customerInfoModel:
                                            state.customerInfoModel!,
                                      ),
                                    ),
                                  ).then((value) => searchNameInFavouriteBrandScreen='');
                                },
                                brandName: state
                                    .favoriteBrandsLandingScreen![index].brand??"",
                                updates: state
                                    .favoriteBrandsLandingScreen![index]
                                    .items!
                                    .length
                                    .toString(),
                                imageUrl: "",
                              ),
                            );
                            // }
                            // else if(index == 1){
                            //   return AspectRatio(
                            //     aspectRatio:
                            //     MediaQuery.of(context).size.aspectRatio * 1.75,
                            //     child: FavoriteBrandLandingWidget(
                            //       widthOfScreen: size.width,
                            //       heightOfScreen: size.height,
                            //       onTap: () {
                            //         Navigator.of(context).push(
                            //           MaterialPageRoute(
                            //             builder: (context) =>
                            //             FavouriteScreenMain(),
                            //           ),
                            //         );
                            //       },
                            //       brandName:"MARSHALL",
                            //       updates: "2",
                            //       imageUrl: "",
                            //     ),
                            //   );
                            // }
                            // else if(index == 2){
                            //   return AspectRatio(
                            //     aspectRatio:
                            //     MediaQuery.of(context).size.aspectRatio * 1.75,
                            //     child: FavoriteBrandLandingWidget(
                            //       widthOfScreen: size.width,
                            //       heightOfScreen: size.height,
                            //       onTap: () {
                            //         Navigator.of(context).push(
                            //           MaterialPageRoute(
                            //             builder: (context) =>
                            //             FavouriteScreenMain(),
                            //           ),
                            //         );
                            //       },
                            //       brandName:"GIBSON",
                            //       updates: "2",
                            //       imageUrl: "",
                            //     ),
                            //   );
                            // }
                            // else if(index == 3){
                            //   return AspectRatio(
                            //     aspectRatio:
                            //     MediaQuery.of(context).size.aspectRatio * 1.75,
                            //     child: FavoriteBrandLandingWidget(
                            //       widthOfScreen: size.width,
                            //       heightOfScreen: size.height,
                            //       onTap: () {
                            //         Navigator.of(context).push(
                            //           MaterialPageRoute(
                            //             builder: (context) =>
                            //             FavouriteScreenMain(),
                            //           ),
                            //         );
                            //       },
                            //       brandName:"ABLETON",
                            //       updates: "5",
                            //       imageUrl: "",
                            //     ),
                            //   );
                            // }
                            // else{
                            //   return AspectRatio(
                            //     aspectRatio:
                            //     MediaQuery.of(context).size.aspectRatio * 1.75,
                            //     child: FavoriteBrandLandingWidget(
                            //       widthOfScreen: size.width,
                            //       heightOfScreen: size.height,
                            //       onTap: () {
                            //         Navigator.of(context).push(
                            //           MaterialPageRoute(
                            //             builder: (context) =>
                            //             FavouriteScreenMain(),
                            //           ),
                            //         );
                            //       },
                            //       brandName:"FENDERS",
                            //       updates: "8",
                            //       imageUrl: "",
                            //     ),
                            //   );
                            // }
                          }),
                    ],
                  ),
                ),
              SizedBox(
                  height: 25,
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        } else {
          return SizedBox(
            height: size.height * 0.15,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      } else {
        return SizedBox(
          height: size.height * 0.15,
          child: Center(child: CircularProgressIndicator()),
        );
      }
    });
  }
}
