import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../primitives/color_system.dart';
import 'circular_add_button.dart';
import 'green_check_box_widget.dart';

class RecommendedAndOfferWidget extends StatelessWidget {
  RecommendedAndOfferWidget({
    Key? key,
    required this.heightOfScreen,
    required this.widthOfScreen,
    required this.textThem,
    required this.imageUrl,
  }) : super(key: key);

  final double heightOfScreen;
  final double widthOfScreen;
  final TextTheme textThem;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heightOfScreen * 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: heightOfScreen * 0.14,
                width: widthOfScreen * 0.3,
                decoration: BoxDecoration(
                  color: Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      width: widthOfScreen * 0.3,
                      height: heightOfScreen * 0.15,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(0),
                        color: Colors.transparent,
                      ),
                      child: Image(
                        image: imageProvider,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 3,
                left: 2,
                child: CircularAddButton(
                  buttonColor: Theme.of(context).primaryColor.withOpacity(0.65),
                  onPressed: () {},
                ),
              ),
              Positioned(
                bottom: -10,
                right: -17,
                child: GreenCheckBoxWidget(
                    paddingOfButton: 2,
                    iconOfButton: Icons.check,
                    onPressed: () {}),
              )
            ],
          ),
          SizedBox(
            height: heightOfScreen * 0.01,
          ),
          SizedBox(
            width: widthOfScreen * 0.3,
            child: Text(
              'Gibson Les Paul Standard \'60s and is professional',
              style: textThem.headline3,
              maxLines: 2,
            ),
          ),
          SizedBox(
            height: heightOfScreen * 0.002,
          ),
          Text(
            '\$${129.99}',
            style: textThem.headline4,
          )
        ],
      ),
    );
  }
}
