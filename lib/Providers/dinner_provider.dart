import 'package:flutter/material.dart';
import '../Core/storage_service.dart';
import '../models/token.dart';
import '../core/storage_service.dart' hide StorageService;

class DinnerProvider extends ChangeNotifier {
  SpecialDinnerToken _token =
      SpecialDinnerToken(hasEaten: false, redeemedAt: null);

  SpecialDinnerToken get token => _token;

  Future<void> loadToken() async {
    final data = await StorageService.loadToken();
    if (data != null) {
      _token = SpecialDinnerToken.fromMap(data);
      notifyListeners();
    }
  }

  Future<void> redeemDinner() async {
    _token = SpecialDinnerToken(
      hasEaten: true,
      redeemedAt: DateTime.now(),
    );
    await StorageService.saveToken(_token.toMap());
    notifyListeners();
  }

  Future<void> resetDinner() async {
    _token = SpecialDinnerToken(hasEaten: false, redeemedAt: null);
    await StorageService.saveToken(_token.toMap());
    notifyListeners();
  }
}
