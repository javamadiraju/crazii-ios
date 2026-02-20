import 'package:flutter/material.dart';

class CreditProvider with ChangeNotifier {
  int _remainingCredits = 0;

  int get remainingCredits => _remainingCredits;

  void setCredits(int value) {
    _remainingCredits = value;
    notifyListeners();  // Notify all listeners (widgets) about the update
  }

  void deductCredit(int value) {
    _remainingCredits -= value;
    notifyListeners();
  }
}
