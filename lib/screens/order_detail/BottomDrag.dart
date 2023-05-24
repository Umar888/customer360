import 'package:flutter/material.dart';



class BottomDrag extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BottomDragState();
}

class _BottomDragState extends State<BottomDrag> {
  static List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  static double minExtent = 0.2;
  static double maxExtent = 0.6;

  bool isExpanded = false;
  double initialExtent = minExtent;
  late BuildContext draggableSheetContext;

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return InkWell(
      onTap: _toggleDraggableScrollableSheet,
      child: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          key: Key(initialExtent.toString()),
          minChildSize: minExtent,
          maxChildSize: maxExtent,
          initialChildSize: initialExtent,
          builder: _draggableScrollableSheetBuilder,
        ),
      ),
    );
  }

  void _toggleDraggableScrollableSheet() {
    setState(() {
      initialExtent = isExpanded ? minExtent : maxExtent;
      isExpanded = !isExpanded;
    });
    DraggableScrollableActuator.reset(draggableSheetContext);
  }

  Widget _draggableScrollableSheetBuilder(
      BuildContext context,
      ScrollController scrollController,
      ) {
    draggableSheetContext = context;
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: colors
            .map((color) => Container(
          height: 200,
          width: double.infinity,
          color: color,
        ))
            .toList(),
      ),
    );
  }
}