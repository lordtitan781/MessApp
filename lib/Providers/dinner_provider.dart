import 'package:flutter/material.dart';
import '../Core/storage_service.dart';
import '../models/token.dart';
import '../core/storage_service.dart' hide StorageService;

class DinnerProvider extends ChangeNotifier {
  SpecialDinnerToken _token =
      SpecialDinnerToken(hasEaten: false, redeemedAt: null);

  SpecialDinnerToken get token => _token;

  // Load from local storage
  Future<void> loadToken() async {
    final data = await StorageService.loadToken();
    if (data != null) {
      _token = SpecialDinnerToken.fromMap(data);
      notifyListeners();
    }
  }

  // Redeem dinner
  Future<void> redeemDinner() async {
    _token = SpecialDinnerToken(
      hasEaten: true,
      redeemedAt: DateTime.now(),
    );
    await StorageService.saveToken(_token.toMap());
    notifyListeners();
  }

  // Reset (for testing/admin)
  Future<void> resetDinner() async {
    _token = SpecialDinnerToken(hasEaten: false, redeemedAt: null);
    await StorageService.saveToken(_token.toMap());
    notifyListeners();
  }
}
