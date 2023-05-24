import 'package:flutter/material.dart';
import 'package:gc_customer_app/app.dart';


import '../../primitives/color_system.dart';
import '../../primitives/size_system.dart';

class DropdownWithSearch<T> extends StatelessWidget {
  final String title;
  final String placeHolder;
  final T selected;
  final String? Function(String?)? validator;

  final List items;
  final EdgeInsets? selectedItemPadding;
  final TextEditingController? textEditingController;
  final TextStyle? selectedItemStyle;
  final TextStyle? dropdownHeadingStyle;
  final TextStyle? labelStyle;
  final TextStyle? itemStyle;
  final BoxDecoration? decoration, disabledDecoration;
  final double? searchBarRadius;
  final double? dialogRadius;
  final bool disabled;
  final EdgeInsets? contentPadding;
  final bool readAble;
  final String label;

  final Function onChanged;

  DropdownWithSearch(
      {Key? key,
      required this.title,
      required this.placeHolder,
      required this.items,
      required this.validator,
      required this.selected,
      required this.onChanged,
      required this.textEditingController,
      this.selectedItemPadding,
      this.readAble = true,
      this.selectedItemStyle,
      this.dropdownHeadingStyle,
      this.labelStyle,
      this.itemStyle,
      this.decoration,
      this.disabledDecoration,
      this.searchBarRadius,
      this.contentPadding,
      this.dialogRadius,
      required this.label,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: readAble && disabled,
      child: TextFormField(
         readOnly: readAble,

         onTap: readAble?(){
           if(disabled){
             showMessage(context: context,message:"Please select state");
           }
           else{
             showDialog(
                 context: context,
                 builder: (context) => SearchDialog(
                     placeHolder: placeHolder,
                     title: title,
                     searchInputRadius: searchBarRadius,
                     dialogRadius: dialogRadius,
                     titleStyle: dropdownHeadingStyle,
                     itemStyle: itemStyle,
                     items: items)).then((value) {
               onChanged(value);
             });
           }
         }:null,
        validator: validator,
        cursorColor: Theme.of(context).primaryColor,
        controller: textEditingController,
        style: itemStyle,
        onChanged: (value){
          onChanged(value);
          textEditingController!.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController!.text.length));
        },
         decoration: InputDecoration(
            labelText: title.toString(),
            alignLabelWithHint: false,

            hintText:
            selected.toString().toLowerCase()=="state"?"Select State":selected.toString(),
            hintStyle: TextStyle(
              color: readAble?ColorSystem.black:Colors.grey,
              fontSize: SizeSystem.size16,
            ),
            floatingLabelBehavior: selected != null && selected!.toString().isEmpty?FloatingLabelBehavior.auto:FloatingLabelBehavior.always,

            constraints: BoxConstraints(),
            contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 0),
            labelStyle: labelStyle??TextStyle(
              color: ColorSystem.greyDark,
            ),
            errorStyle: TextStyle(
                color: ColorSystem.lavender3,
                fontWeight: FontWeight.w400
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:
              ColorSystem.greyDark,
                width: 1,
              ),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color:
              ColorSystem.greyDark,
                width: 1,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:
              ColorSystem.greyDark,
                width: 1,
              ),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color:
              ColorSystem.lavender3,
                width: 1,
              ),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color:
              ColorSystem.lavender3,
                width: 1,
              ),
            ),
             suffixIcon: readAble?Icon(Icons.keyboard_arrow_down_rounded):null
          ),
       /* padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: !disabled
            ? decoration != null
                ? decoration
                : BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1))
            : disabledDecoration != null
                ? disabledDecoration
                : BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.grey.shade300,
                    border:
                        Border.all(color: Colors.grey.shade300, width: 1)),
        child: Row(
          children: [
            Expanded(
                child: Text(selected.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: selectedItemStyle != null
                        ? selectedItemStyle
                        : TextStyle(fontSize: SizeSystem.size18,))),
            Icon(Icons.keyboard_arrow_down_rounded)
          ],
        ),*/
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final String title;
  final String placeHolder;
  final List items;
  final TextStyle? titleStyle;
  final TextStyle? itemStyle;
  final double? searchInputRadius;

  final double? dialogRadius;

  SearchDialog(
      {Key? key,
      required this.title,
      required this.placeHolder,
      required this.items,
      this.titleStyle,
      this.searchInputRadius,
      this.dialogRadius,
      this.itemStyle})
      : super(key: key);

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState<T> extends State<SearchDialog> {
  TextEditingController textController = TextEditingController();
  late List filteredList;

  @override
  void initState() {
    filteredList = widget.items;
    textController.addListener(() {
      setState(() {
        if (textController.text.isEmpty) {
          filteredList = widget.items;
        } else {
          filteredList = widget.items
              .where((element) => element
                  .toString()
                  .toLowerCase()
                  .contains(textController.text.toLowerCase()))
              .toList();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      shape: RoundedRectangleBorder(
          borderRadius: widget.dialogRadius != null
              ? BorderRadius.circular(widget.dialogRadius!)
              : BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.title,
                    style: widget.titleStyle != null
                        ? widget.titleStyle
                        : TextStyle(
                        fontSize: SizeSystem.size18, fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    })
                /*Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Close',
                      style: widget.titleStyle != null
                          ? widget.titleStyle
                          : TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    )),
              )*/
              ],
            ),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                  hintText: widget.placeHolder,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        widget.searchInputRadius != null
                            ? Radius.circular(widget.searchInputRadius!)
                            : Radius.circular(5)),
                    borderSide: BorderSide(
                      color: Colors.black26,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        widget.searchInputRadius != null
                            ? Radius.circular(widget.searchInputRadius!)
                            : Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                ),
                style: widget.itemStyle != null
                    ? widget.itemStyle
                    : TextStyle(
                  fontSize: SizeSystem.size18,),
                controller: textController,
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.all(widget.dialogRadius != null
                    ? Radius.circular(widget.dialogRadius!)
                    : Radius.circular(5)),
                //borderRadius: widget.dialogRadius!=null?BorderRadius.circular(widget.dropDownRadius!):BorderRadius.circular(14),
                child: ListView.separated(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context, filteredList[index]);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 18),
                            child: Text(
                              filteredList[index].toString(),
                              style: widget.itemStyle != null
                                  ? widget.itemStyle
                                  : TextStyle(
                                fontSize: SizeSystem.size18,),
                            ),
                          ));
                    }, separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 5,);
                },),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  /// Creates a dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  CustomDialog({
    Key? key,
    this.child,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.shape,
    this.constraints =const  BoxConstraints(
        minWidth: 280.0, minHeight: 280.0, maxHeight: 400.0, maxWidth: 400.0),
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  /// The duration of the animation to show when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to 100 milliseconds.
  final Duration insetAnimationDuration;

  /// The curve to use for the animation shown when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to [Curves.fastOutSlowIn].
  final Curve insetAnimationCurve;

  /// {@template flutter.material.dialog.shape}
  /// The shape of this dialog's border.
  ///
  /// Defines the dialog's [Material.shape].
  ///
  /// The default shape is a [RoundedRectangleBorder] with a radius of 2.0.
  /// {@endtemplate}
  final ShapeBorder? shape;
  final BoxConstraints constraints;

  Color _getColor(BuildContext context) {
    return Theme.of(context).dialogBackgroundColor;
  }

  // TODO(johnsonmh): Update default dialog border radius to 4.0 to match material spec.
  static RoundedRectangleBorder _defaultDialogShape =
      RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)));

  @override
  Widget build(BuildContext context) {
    final DialogTheme dialogTheme = DialogTheme.of(context);
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: ConstrainedBox(
            constraints: constraints,
            child: Material(
              elevation: 15.0,
              color: _getColor(context),
              type: MaterialType.card,
              child: child,
              shape: shape ?? dialogTheme.shape ?? _defaultDialogShape,
            ),
          ),
        ),
      ),
    );
  }
}
