import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  int home_color_1 = 0xFF000000;

  void update_home_color_1(int value) {
    home_color_1 = value;
    notifyListeners();
  }
}
