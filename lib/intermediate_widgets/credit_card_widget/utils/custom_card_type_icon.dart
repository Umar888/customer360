import 'package:flutter/material.dart';

import '../views/flutter_credit_card.dart';

class CustomCardTypeIcon {
  CustomCardTypeIcon({
    required this.cardType,
    required this.cardImage,
  });

  CardType cardType;
  Widget cardImage;
}