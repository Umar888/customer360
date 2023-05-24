import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/common_widgets/circular_add_button.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

class OffersWithFilter extends StatelessWidget {
  OffersWithFilter(
      {Key? key, required this.index, required this.listOfOfferForFilters})
      : super(key: key);

  final int index;
  final List<Records>? listOfOfferForFilters;

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widthOfScreen * 0.05,
                vertical: heightOfScreen * 0.00,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: AspectRatio(
                              aspectRatio: 0.99,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFFF4F6FA),
                                    borderRadius: BorderRadius.circular(20)),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: listOfOfferForFilters![index]
                                          .productImageUrl ??
                                      '',
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF4F6FA),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: listOfOfferForFilters![index]
                                                .productImageUrl ??
                                            '',
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            width: widthOfScreen * 0.3,
                                            height: heightOfScreen * 0.15,
                                            decoration: BoxDecoration(
                                              color: ColorSystem
                                                  .addtionalCulturedGrey,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            margin: EdgeInsets.only(
                                                bottom: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                    child: Image.network(
                                                  listOfOfferForFilters![index]
                                                          .productImageUrl ??
                                                      '',
                                                  width: double.infinity,
                                                )),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    listOfOfferForFilters![index].productName ??
                                        '',
                                    maxLines: 2,
                                    style: textThem.headline3),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black26),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: AppColors.selectedChipColor
                                                  .withOpacity(0.2)),
                                          child: Center(
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(listOfOfferForFilters![
                                                                index]
                                                            .childskus!
                                                            .first
                                                            .skuCondition ==
                                                        'New'
                                                    ? '${listOfOfferForFilters![index].childskus!.first.skuCondition} Arrived'
                                                    : listOfOfferForFilters![
                                                                index]
                                                            .childskus!
                                                            .first
                                                            .skuCondition ??
                                                        ''),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: 4.0),
                                          child: Text(
                                            '\$${double.parse(listOfOfferForFilters![index].productPrice ?? '0.00').toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontSize: SizeSystem.size20,
                                                fontWeight: FontWeight.bold,
                                                color: ColorSystem.chartBlack,
                                                fontFamily: kRubik),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularAddButton(
                                          buttonColor:
                                              Theme.of(context).primaryColor,
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
          child: Divider(
            color: Colors.grey.shade400,
            height: 1.5,
          ),
        )
      ],
    );
  }
}
