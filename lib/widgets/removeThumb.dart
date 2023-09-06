import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class NoThumbSliderThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.zero;
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {}
}

SliderThemeData getNoThumbSliderTheme(BuildContext context) {
  return SliderThemeData(
    thumbShape: NoThumbSliderThumbShape(),
    trackHeight: 2.0,
    disabledThumbColor: Colors.transparent,
    overlayColor: Colors.transparent,
  );
}