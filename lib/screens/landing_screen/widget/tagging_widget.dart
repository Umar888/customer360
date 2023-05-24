import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/tagging_bloc/tagging_bloc.dart';
import 'package:gc_customer_app/common_widgets/tagging_elements.dart';
import 'package:gc_customer_app/constants/constant_lists.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class TaggingWidget extends StatefulWidget {
  TaggingWidget({Key? key}) : super(key: key);

  @override
  State<TaggingWidget> createState() => _TaggingWidgetState();
}

class _TaggingWidgetState extends State<TaggingWidget> {
  @override
  void initState() {
    context.read<TaggingBloc>().add(LoadTagData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    return BlocBuilder<TaggingBloc, TaggingState>(builder: (context, state) {
      if (state is TaggingProgress)
        return Center(child: CircularProgressIndicator());
      if (state is TaggingSuccess) {
        Map<String, dynamic> newVal = {};

        if (state.tags.data!.containsKey("attributes")) {
          state.tags.data!.remove("attributes");
        }
        if (state.tags.data!.containsKey("Id")) {
          state.tags.data!.remove("Id");
        }
        if (state.tags.data!.containsKey("Name")) {
          state.tags.data!.remove("Name");
        }
        var values = [...state.tags.data!.values]
          ..sort((b, a) => a.toString().compareTo(b.toString()));
        var tem = {};
        tem.addAll(state.tags.data!);
        for (bool values in values) {
          newVal[tem.keys.firstWhere((element) => tem[element] == values)] =
              tem[tem.keys.firstWhere((element) => tem[element] == values)];
          tem.remove(tem.keys.firstWhere((element) => tem[element] == values));
        }
        bool displayTaggingList = newVal.values
            .firstWhere((element) => element == true, orElse: () => false);
        // print(displayTaggingList);
        return displayTaggingList
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    taggingtxt,
                    style: kIsWeb
                        ? Theme.of(context)
                            .textTheme
                            .headline2
                            ?.copyWith(fontWeight: FontWeight.w500)
                        : TextStyle(
                            color: ColorSystem.blueGrey,
                            fontFamily: kRubik,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: widthOfScreen,
                    height: kIsWeb ? 60 : widthOfScreen * 0.1,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: newVal.entries.map((e) {
                          if (!e.value) {
                            return Container();
                          }
                          return TaggingElements(
                            widthOfScreen: widthOfScreen,
                            taggingText: taggingList.firstWhere((element) =>
                                element['text'].toString().toLowerCase() ==
                                e.key
                                    .toString()
                                    .replaceAll("_Customer__c", "")
                                    .replaceAll("_Purchaser__c", "")
                                    .replaceAll("_", " ")
                                    .toLowerCase())['text'],
                            imagePath: taggingList.firstWhere((element) =>
                                element['text'].toString().toLowerCase() ==
                                e.key
                                    .toString()
                                    .replaceAll("_Customer__c", "")
                                    .replaceAll("_Purchaser__c", "")
                                    .replaceAll("_", " ")
                                    .toLowerCase())['icon'],
                            chipColor: e.value,
                          );
                        }).toList()),
                  ),
                  SizedBox(
                    height: 25,
                  )
                ],
              )
            : SizedBox.shrink();
      }
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Center(child: Text(" No Tags Available")),
      );
    });
  }
}
