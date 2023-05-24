import 'dart:math';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/intermediate_widgets/currency_text_input_formatter.dart';
import 'package:gc_customer_app/models/cart_model/financial_type_model.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:intl/intl.dart';

import '../../../primitives/constants.dart';
import '../animation/credit_card_animation.dart';
import '../utils/credit_card_brand.dart';
import '../views/flutter_credit_card.dart';

Map<CardType, String> CardTypeIconAsset = <CardType, String>{
  CardType.visa: 'assets/icons/visa.png',
  CardType.americanExpress: 'assets/icons/amex.png',
  CardType.mastercard: 'assets/icons/mastercard.png',
  CardType.discover: 'assets/icons/discover.png',
};

class CreditCardWidget extends StatefulWidget {
  CreditCardWidget({
    Key? key,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardHolderName,
    required this.showAmount,
    required this.showChip,
    required this.amount,
    required this.cvvCode,
    required this.showBackView,
    this.animationDuration = const Duration(milliseconds: 500),
    this.height,
    this.width,
    this.textStyle,
    this.cardBgColor = const Color(0xff1b447b),
    this.obscureCardNumber = true,
    this.obscureCardCvv = true,
    this.labelCardHolder = 'CARD HOLDER',
    this.labelExpiredDate = 'MM/YY',
    this.cardType,
    this.isHolderNameVisible = false,
    this.isCardMonthYearVisible = false,
    this.backgroundImage,
    this.glassmorphismConfig,
    this.isChipVisible = true,
    this.isSwipeGestureEnabled = true,
    this.customCardTypeIcons = const <CustomCardTypeIcon>[],
    required this.onCreditCardWidgetChange,
    this.isAmountEditable = false,
    this.onSubmitNewAmount,
    this.isCOACard = false,
    this.coaCreditBalance,
    this.paymentMethodType,
    this.financialTypeModel,
  }) : super(key: key);

  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String amount;
  final String cardHolderName;
  final bool showAmount;
  final bool showChip;
  final String cvvCode;
  final TextStyle? textStyle;
  final Color cardBgColor;
  final bool showBackView;
  final Duration animationDuration;
  final double? height;
  final double? width;
  final bool obscureCardNumber;
  final bool obscureCardCvv;
  final void Function(CreditCardBrand) onCreditCardWidgetChange;
  final bool isHolderNameVisible;
  final bool isCardMonthYearVisible;
  final String? backgroundImage;
  final bool isChipVisible;
  final Glassmorphism? glassmorphismConfig;
  final bool isSwipeGestureEnabled;
  final bool isAmountEditable;

  final String labelCardHolder;
  final String labelExpiredDate;

  final CardType? cardType;
  final PaymentMethodType? paymentMethodType;
  final List<CustomCardTypeIcon> customCardTypeIcons;
  final Function(String)? onSubmitNewAmount;
  final bool isCOACard;
  final CreditBalance? coaCreditBalance;
  final FinancialTypeModel? financialTypeModel;

  @override
  _CreditCardWidgetState createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;
  late Gradient backgroundGradientColor;
  late bool isFrontVisible = true;
  late bool isGestureUpdate = false;
  TextEditingController _amountController = TextEditingController();

  bool isAmex = false;

  @override
  void initState() {
    super.initState();

    ///initialize the animation controller
    controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _gradientSetup();
    _updateRotations(false);
  }

  void _gradientSetup() {
    backgroundGradientColor = LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      // Add one stop for each color. Stops should increase from 0 to 1
      stops: <double>[0.1, 0.4, 0.7, 0.9],
      colors: <Color>[
        widget.cardBgColor.withOpacity(1),
        widget.cardBgColor.withOpacity(0.97),
        widget.cardBgColor.withOpacity(0.90),
        widget.cardBgColor.withOpacity(0.86),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _amountController.text =
        '\$${NumberFormat.currency(name: '').format(double.parse((widget.amount.isEmpty ? '0.0' : widget.amount.replaceAll(',', ''))
          ..replaceAll('\$', '')
          ..replaceAll(',', '')))}';
    _amountController.selection = TextSelection(
        baseOffset: _amountController.text.length,
        extentOffset: _amountController.text.length);

    ///
    /// If uer adds CVV then toggle the card from front to back..
    /// controller forward starts animation and shows back layout.
    /// controller reverse starts animation and shows front layout.
    ///
    if (!isGestureUpdate) {
      _updateRotations(false);
      if (widget.showBackView) {
        controller.forward();
      } else {
        controller.reverse();
      }
    } else {
      isGestureUpdate = false;
    }

    final CardType cardType =
        widget.cardType ?? detectCCType(widget.cardNumber);
    widget.onCreditCardWidgetChange(CreditCardBrand(cardType));

    return Stack(
      children: <Widget>[
        _cardGesture(
          child: AnimationCard(
            animation: _frontRotation,
            child: _buildFrontContainer(),
          ),
        ),
        // if (!widget.isCOACard)
        //   _cardGesture(
        //     child: AnimationCard(
        //       animation: _backRotation,
        //       child: _buildBackContainer(),
        //     ),
        //   ),
      ],
    );
  }

  void _leftRotation() {
    _toggleSide(false);
  }

  void _rightRotation() {
    _toggleSide(true);
  }

  void _toggleSide(bool isRightTap) {
    _updateRotations(!isRightTap);
    if (isFrontVisible) {
      controller.forward();
      isFrontVisible = false;
    } else {
      controller.reverse();
      isFrontVisible = true;
    }
  }

  void _updateRotations(bool isRightSwipe) {
    setState(() {
      final bool rotateToLeft =
          (isFrontVisible && !isRightSwipe) || !isFrontVisible && isRightSwipe;

      ///Initialize the Front to back rotation tween sequence.
      _frontRotation = TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(
                    begin: 0.0, end: rotateToLeft ? (pi / 2) : (-pi / 2))
                .chain(CurveTween(curve: Curves.linear)),
            weight: 50.0,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(rotateToLeft ? (-pi / 2) : (pi / 2)),
            weight: 50.0,
          ),
        ],
      ).animate(controller);

      ///Initialize the Back to Front rotation tween sequence.
      _backRotation = TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(rotateToLeft ? (pi / 2) : (-pi / 2)),
            weight: 50.0,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(
                    begin: rotateToLeft ? (-pi / 2) : (pi / 2), end: 0.0)
                .chain(
              CurveTween(curve: Curves.linear),
            ),
            weight: 50.0,
          ),
        ],
      ).animate(controller);
    });
  }

  ///
  /// Builds a front container containing
  /// Card number, Exp. year and Card holder name
  ///
  Widget _buildFrontContainer() {
    final TextStyle defaultTextStyle =
        Theme.of(context).textTheme.headline6!.merge(
              TextStyle(
                color: Colors.white,
                fontFamily: kRubik,
                fontSize: 20,
              ),
            );

    String number = widget.cardNumber;
    if (widget.obscureCardNumber) {
      final String stripped = number.replaceAll(RegExp(r'[^\d]'), '');
      if (stripped.length > 8) {
        final String middle = number
            .substring(0, number.length - 5)
            .trim()
            .replaceAll(RegExp(r'\d'), '*');
        number = '$middle ${stripped.substring(stripped.length - 4)}';
      }
    }

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(
                widget.backgroundImage!,
                package: 'gc_customer_app',
              ),
              fit: BoxFit.fill,
            ),
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(38, 112, 136, 210),
                  blurRadius: 30,
                  offset: Offset(0, 10))
            ]),
        height: widget.height,
        width: widget.width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            (!(widget.financialTypeModel?.promoTitle
                        ?.toLowerCase()
                        .contains('without any promotional financing') ??
                    true))
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Text(
                      widget.financialTypeModel?.promoTitle ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: kRubik,
                          fontSize: 14),
                    ),
                  )
                : SizedBox(height: 24),
            // Padding(
            //             padding: EdgeInsets.only(right: 50),
            //             child: Image.asset(
            //               'assets/icons/chip.png',
            //               scale: 0.8,
            //             ),
            //           ),
            widget.showChip
                ? Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Enter Amount",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: kRubik,
                                  fontSize: 12),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            !widget.isAmountEditable
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        color: Colors.grey[400],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.0,
                                          top: 5,
                                          bottom: 5,
                                          right: 20),
                                      child: Text(
                                        r"$" + widget.amount,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: kRubik,
                                            fontSize: 18),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: 112,
                                    height: 32,
                                    child: TextFormField(
                                      controller: _amountController,
                                      inputFormatters: [
                                        CurrencyTextInputFormatter(
                                            name: '', symbol: '\$'),
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[0-9.,\$]")),
                                      ],
                                      keyboardType: TextInputType.number,
                                      cursorColor: ColorSystem.black,
                                      textInputAction: TextInputAction.done,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      decoration: InputDecoration(
                                          fillColor: ColorSystem.white,
                                          filled: true,
                                          // prefix: Text(
                                          //   '\$',
                                          //   style: TextStyle(color: ColorSystem.black),
                                          // ),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: ColorSystem.black),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: ColorSystem.black),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: ColorSystem.black),
                                          )),
                                      onChanged: (value) {
                                        EasyDebounce.cancelAll();
                                        if (value.isNotEmpty) {
                                          EasyDebounce.debounce(
                                              'update_card_amount_debounce',
                                              Duration(seconds: 2), () {
                                            if (widget.onSubmitNewAmount !=
                                                null) {
                                              widget.onSubmitNewAmount!(value);
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  )
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(),
            if (!widget.cardNumber.isEmpty)
              Padding(
                padding: EdgeInsets.only(left: 40, top: 15, bottom: 8),
                child: Text(
                  number,
                  style: widget.textStyle ??
                      defaultTextStyle.copyWith(letterSpacing: 2.3),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: 40.0, right: 0, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: widget.isCardMonthYearVisible,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'EXP',
                                style: widget.textStyle ??
                                    defaultTextStyle.copyWith(
                                        fontSize: 11,
                                        letterSpacing: 1.92,
                                        fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.expiryMonth.isEmpty
                                    ? widget.labelExpiredDate
                                    : "${widget.expiryMonth}.${widget.expiryYear}",
                                style: widget.textStyle ??
                                    defaultTextStyle.copyWith(
                                        fontSize: 11,
                                        letterSpacing: 1.13,
                                        fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: widget.isHolderNameVisible,
                              child: Expanded(
                                child: Text(
                                  (widget.cardHolderName.isEmpty
                                          ? widget.labelCardHolder
                                          : '${widget.cardHolderName}')
                                      .toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: kRubik,
                                      fontSize: 17,
                                      letterSpacing: 1.2),
                                ),
                              ),
                            ),
                            if (widget.cardType != PaymentMethodType.credit)
                              Text(
                                _getCardTitle(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: kRubik,
                                    fontSize: 17,
                                    letterSpacing: 1.2),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: getCardTypeIcon(widget.cardNumber),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  String _getCardTitle() {
    var title = '';
    switch (widget.paymentMethodType ?? PaymentMethodType.credit) {
      case PaymentMethodType.cOA:
        title = 'COA';
        break;
      case PaymentMethodType.gcGear:
        title = 'Gear Card';
        break;
      case PaymentMethodType.gcEssentials:
        title = 'Essential Card';
        break;
      case PaymentMethodType.gcGift:
        title = 'Gift Card';
        break;
      default:
    }
    return title;
  }

  ///
  /// Builds a back container containing cvv
  ///
  Widget _buildBackContainer() {
    final TextStyle defaultTextStyle =
        Theme.of(context).textTheme.headline6!.merge(
              TextStyle(
                color: Colors.black,
                fontFamily: kRubik,
                fontSize: 16,
              ),
            );

    final String cvv = widget.obscureCardCvv
        ? widget.cvvCode.replaceAll(RegExp(r'\d'), '*')
        : widget.cvvCode;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(
              widget.backgroundImage!,
              package: 'gc_customer_app',
            ),
            fit: BoxFit.fill,
          )),
      height: widget.height,
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              margin: EdgeInsets.only(top: 30, left: 20, right: 24),
              height: 48,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(top: 16, left: 20, right: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Container(
                      height: 48,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          widget.cvvCode.isEmpty
                              ? isAmex
                                  ? 'XXXX'
                                  : 'XXX'
                              : cvv,
                          maxLines: 1,
                          style: widget.textStyle ?? defaultTextStyle,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding:
                    EdgeInsets.only(left: 0.0, right: 40, bottom: 40, top: 0),
                child: widget.cardType != null
                    ? getCardTypeImage(widget.cardType)
                    : getCardTypeIcon(widget.cardNumber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardGesture({required Widget child}) {
    bool isRightSwipe = true;
    return widget.isSwipeGestureEnabled
        ? GestureDetector(
            onPanEnd: (_) {
              isGestureUpdate = true;
              if (isRightSwipe) {
                _leftRotation();
              } else {
                _rightRotation();
              }
            },
            onPanUpdate: (DragUpdateDetails details) {
              // Swiping in right direction.
              if (details.delta.dx > 0) {
                isRightSwipe = true;
              }

              // Swiping in left direction.
              if (details.delta.dx < 0) {
                isRightSwipe = false;
              }
            },
            child: child,
          )
        : child;
  }

  /// Credit Card prefix patterns as of March 2019
  /// A [List<String>] represents a range.
  /// i.e. ['51', '55'] represents the range of cards starting with '51' to those starting with '55'
  Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
  };

  /// This function determines the Credit Card type based on the cardPatterns
  /// and returns it.
  CardType detectCCType(String cardNumber) {
    //Default card type is other
    CardType cardType = CardType.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    cardNumPatterns.forEach(
      (CardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          String ccPatternStr =
              cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }

  Widget getCardTypeImage(CardType? cardType) {
    final List<CustomCardTypeIcon> customCardTypeIcon =
        getCustomCardTypeIcon(cardType!);
    if (customCardTypeIcon.isNotEmpty) {
      return customCardTypeIcon.first.cardImage;
    } else {
      return Image.asset(
        CardTypeIconAsset[cardType]!,
        height: 48,
        width: 48,
        package: 'gc_customer_app',
      );
    }
  }

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  Widget getCardTypeIcon(String cardNumber) {
    Widget icon;
    final CardType ccType = detectCCType(cardNumber);
    final List<CustomCardTypeIcon> customCardTypeIcon =
        getCustomCardTypeIcon(ccType);
    if (customCardTypeIcon.isNotEmpty) {
      icon = customCardTypeIcon.first.cardImage;
      isAmex = ccType == CardType.americanExpress;
    } else {
      switch (ccType) {
        case CardType.visa:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            height: 48,
            width: 48,
            package: 'gc_customer_app',
          );
          isAmex = false;
          break;

        case CardType.americanExpress:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            height: 48,
            width: 48,
            package: 'gc_customer_app',
          );
          isAmex = true;
          break;

        case CardType.mastercard:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            height: 48,
            width: 48,
            package: 'gc_customer_app',
          );
          isAmex = false;
          break;

        case CardType.discover:
          icon = Image.asset(
            CardTypeIconAsset[ccType]!,
            height: 48,
            width: 48,
            package: 'gc_customer_app',
          );
          isAmex = false;
          break;

        default:
          icon = Container(
            height: 48,
          );
          isAmex = false;
          break;
      }
    }

    return icon;
  }

  List<CustomCardTypeIcon> getCustomCardTypeIcon(CardType currentCardType) =>
      widget.customCardTypeIcons
          .where((CustomCardTypeIcon element) =>
              element.cardType == currentCardType)
          .toList();
}

class MaskedTextController extends TextEditingController {
  MaskedTextController(
      {String? text, required this.mask, Map<String, RegExp>? translator})
      : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      final String previous = _lastUpdatedText;
      if (beforeChange(previous, this.text)) {
        updateText(this.text);
        afterChange(previous, this.text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(this.text);
  }

  String mask;

  late Map<String, RegExp> translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String text) {
    if (text.isNotEmpty) {
      this.text = _applyMask(mask, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    updateText(text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    final String text = _lastUpdatedText;
    selection = TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return <String, RegExp>{
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String? mask, String value) {
    String result = '';

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask!.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      final String maskChar = mask[maskCharIndex];
      final String valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar]!.hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}

enum CardType {
  otherBrand,
  mastercard,
  visa,
  americanExpress,
  discover,
}
