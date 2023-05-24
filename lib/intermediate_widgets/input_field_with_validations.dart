import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

class GuitarCentreInputField extends StatelessWidget {
  final String? leadingIcon;
  final Color? leadingIconColor;

  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextStyle? floatingLabelTextStyle;
  final String label;
  final String? hintText;
  final TextInputType? textInputType;
  final TextStyle? errorStyle;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? focusedBorder;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? initialText;
  final FocusNode? focusNode;
  final TextEditingController? textEditingController;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? errorText;
  final Function()? onTap;

  /// This widget has been made for guitar centre.
  /// Widget comprises of label, masked formatter, validation and state management.
  /// Further enhancements can be made with respect to different masks, different validations, etc.

  const GuitarCentreInputField({
    required this.label,
    this.leadingIcon,
    this.leadingIconColor,
    this.onChanged,
    this.focusedErrorBorder,
    this.focusedBorder,
    this.border,
    this.errorBorder,
    this.enabledBorder,
    this.errorStyle,
    this.hintText,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.textInputType,
    this.floatingLabelTextStyle,
    this.inputFormatters,
    this.initialText,
    this.onFieldSubmitted,
    this.focusNode,
    this.textEditingController,
    this.suffixIcon,
    this.validator,
    this.errorText,
    this.textInputAction,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null)
          Padding(
            padding: const EdgeInsets.only(
              left: PaddingSystem.padding16,
              right: PaddingSystem.padding28,
              top: PaddingSystem.padding20,
              bottom: PaddingSystem.padding20,
            ),
            child: SvgPicture.asset(
              leadingIcon!,
              color: leadingIconColor ?? Theme.of(context).accentColor,
              package: 'gc_customer_app',
              width: SizeSystem.size24,
              height: SizeSystem.size24,
            ),
          ),
        Expanded(
          child: TextFormField(
            validator: validator,
            controller: textEditingController,
            focusNode: focusNode,
            initialValue: initialText,
            cursorHeight: SizeSystem.size16,
            cursorWidth: SizeSystem.size1,
            style: const TextStyle(
              fontSize: SizeSystem.size16,
            ),
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            keyboardType: textInputType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            onTap: onTap,
            decoration: InputDecoration(
              errorBorder: errorBorder,
              enabledBorder: enabledBorder,
              focusedBorder: focusedBorder,
              border: border,
              focusedErrorBorder: focusedErrorBorder,
              errorStyle: errorStyle,
              hintText: hintText,
              label: Text(label,
                  style: TextStyle(
                    color: leadingIconColor ?? Theme.of(context).accentColor,
                  )),
              labelStyle: const TextStyle(
                fontSize: SizeSystem.size14,
                fontFamily: kRubik,
              ),
              floatingLabelBehavior: floatingLabelBehavior,
              floatingLabelStyle: floatingLabelTextStyle,
              suffixIconConstraints: const BoxConstraints(
                maxWidth: SizeSystem.size24,
                maxHeight: SizeSystem.size36,
              ),
              suffixIcon: Center(child: suffixIcon),
              errorText: errorText,
            ),
          ),
        ),
      ],
    );
  }
}
