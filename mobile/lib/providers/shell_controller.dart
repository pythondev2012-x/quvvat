import 'package:flutter/foundation.dart';

class ShellController extends ChangeNotifier {
  ShellController({int initialIndex = 0}) : _index = initialIndex;

  int _index;

  int get index => _index;

  void select(int index) {
    if (index == _index) {
      return;
    }
    _index = index;
    notifyListeners();
  }
}
