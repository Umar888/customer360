import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

import '../models/order_history/order_history_model.dart';

class InstrumentsTile extends StatelessWidget {
  final List<LineItems>? items;
  final List<Items>? orderDetailItems;

  InstrumentsTile({
    Key? key,
    this.items,
    this.orderDetailItems,
  }) : super(key: key);

  Widget _imageContainer(String imageUrl, double width) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      errorWidget: (context, url, s) => FadeShimmer(
        height: width,
        width: width,
        radius: 5,
        highlightColor: Colors.grey.shade300,
        baseColor: Colors.grey.shade100,
      ),
      placeholder: (context, url) => FadeShimmer(
        height: width,
        width: width,
        radius: 5,
        highlightColor: Colors.grey.shade300,
        baseColor: Colors.grey.shade100,
      ),
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(SizeSystem.size12),
            color: ColorSystem.culturedGrey,
          ),
          child: Image(
            image: imageProvider,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if ((items ?? []).isEmpty && (orderDetailItems ?? []).isEmpty) {
      return SizedBox();
    }

    var length = orderDetailItems?.length ?? items?.length ?? 0;
    String? image0;
    String? image1;
    String? image2;
    String? image3;
    if (length == 1) {
      image0 = orderDetailItems?[0].imageUrl ?? items?[0].imageUrl;
      if (image0 != null) {
        return _imageContainer(image0, 64);
      } else {
        return SizedBox();
      }
    }
    if (length == 2) {
      image0 = orderDetailItems?[0].imageUrl ?? items?[0].imageUrl;
      image1 = orderDetailItems?[1].imageUrl ?? items?[1].imageUrl;
      return SizedBox(
        width: SizeSystem.size64,
        height: SizeSystem.size64,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image0 != null) _imageContainer(image0, SizeSystem.size30),
            SizedBox(width: SizeSystem.size4),
            if (image1 != null) _imageContainer(image1, SizeSystem.size30),
          ],
        ),
      );
    }
    if (length == 3) {
      image0 = orderDetailItems?[0].imageUrl ?? items?[0].imageUrl;
      image1 = orderDetailItems?[1].imageUrl ?? items?[1].imageUrl;
      image2 = orderDetailItems?[2].imageUrl ?? items?[2].imageUrl;
      return SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image0 != null)
                  _imageContainer(
                    image0,
                    SizeSystem.size30,
                  ),
                SizedBox(
                  width: SizeSystem.size4,
                ),
                if (image1 != null)
                  _imageContainer(
                    image1,
                    SizeSystem.size30,
                  ),
              ],
            ),
            SizedBox(
              height: SizeSystem.size4,
            ),
            if (image2 != null)
              _imageContainer(
                image2,
                SizeSystem.size30,
              ),
          ],
        ),
      );
    }
    if (length >= 4) {
      image0 = orderDetailItems?[0].imageUrl ?? items?[0].imageUrl;
      image1 = orderDetailItems?[1].imageUrl ?? items?[1].imageUrl;
      image2 = orderDetailItems?[2].imageUrl ?? items?[2].imageUrl;
      image3 = orderDetailItems?[3].imageUrl ?? items?[3].imageUrl;
      return SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image0 != null)
                  _imageContainer(
                    image0,
                    SizeSystem.size30,
                  ),
                SizedBox(
                  width: SizeSystem.size4,
                ),
                if (image1 != null)
                  _imageContainer(
                    image1,
                    SizeSystem.size30,
                  ),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image2 != null)
                  _imageContainer(
                    image2,
                    SizeSystem.size30,
                  ),
                SizedBox(
                  width: SizeSystem.size4,
                ),
                Stack(
                  children: [
                    if (image3 != null)
                      _imageContainer(
                        image3,
                        SizeSystem.size30,
                      ),
                    Container(
                      width: SizeSystem.size30,
                      height: SizeSystem.size30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(SizeSystem.size12),
                        color: ColorSystem.culturedGrey.withOpacity(0.8),
                      ),
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(
                          '+${length - 3}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik,
                            fontSize: SizeSystem.size12,
                          ),
                        ),
                      ),
                    ),
                  ],
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
