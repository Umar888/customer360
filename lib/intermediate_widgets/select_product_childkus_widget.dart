import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

class SelectProductChildkusWidget extends StatefulWidget {
  final Records product;
  final double width;
  final Function(String) onTap;
  SelectProductChildkusWidget(
      {Key? key,
      required this.product,
      required this.width,
      required this.onTap})
      : super(key: key);

  @override
  State<SelectProductChildkusWidget> createState() =>
      _SelectProductChildkusWidgetState();
}

class _SelectProductChildkusWidgetState
    extends State<SelectProductChildkusWidget> {
  final StreamController<int> showingItemController =
      StreamController<int>.broadcast()..add(1);
  ScrollController scrollController = ScrollController();
  bool isManyChildskus = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: showingItemController.stream,
        initialData: 1,
        builder: (context, snapshot) {
          if (!isManyChildskus) {
            return Wrap(
              spacing: 8,
              children: widget.product.childskus
                      ?.map<Widget>((child) => InkWell(
                            onTap: () => widget.onTap(child.skuId ?? ''),
                            child: CachedNetworkImage(
                              imageUrl: (child.skuImageUrl ?? '')
                                  .replaceAll('120x120', '500x500'),
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  alignment: Alignment.center,
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.contain)),
                                );
                              },
                            ),
                          ))
                      .toList() ??
                  [],
            );
          }
          var midIndex = snapshot.data!;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  midIndex > 1
                      ? IconButton(
                          onPressed: () {
                            scrollController.animateTo((midIndex - 1) * 58,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease);
                            showingItemController.add(midIndex - 1);
                          },
                          icon: Icon(Icons.chevron_left))
                      : SizedBox(width: 40),
                  SizedBox(
                    height: 50,
                    width: 166,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: widget.product.childskus!.length,
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => widget.onTap(
                              widget.product.childskus![index].skuId ?? ''),
                          child: CachedNetworkImage(
                            imageUrl:
                                (widget.product.childskus![index].skuImageUrl ??
                                        '')
                                    .replaceAll('120x120', '500x500'),
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                alignment: Alignment.center,
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain)),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  (midIndex < widget.product.childskus!.length - 2)
                      ? IconButton(
                          onPressed: () {
                            scrollController.animateTo((midIndex) * 58,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease);
                            showingItemController.add(midIndex + 1);
                          },
                          icon: Icon(Icons.chevron_right))
                      : SizedBox(width: 40),
                ],
              ),
              Row(
                children: List.generate(
                    widget.product.childskus!.length - 2,
                    (index) => Container(
                          height: midIndex == index + 1 ? 6 : 4,
                          width: midIndex == index + 1 ? 6 : 4,
                          margin: EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor
                                .withOpacity(midIndex == index + 1 ? 1 : 0.6),
                            shape: BoxShape.circle,
                          ),
                        )),
              )
            ],
          );
        });
  }
}
