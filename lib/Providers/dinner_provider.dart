import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage_service.dart';
import '../models/token.dart';

class DinnerProvider extends ChangeNotifier {
  SpecialDinnerToken _token =
  SpecialDinnerToken(hasEaten: false, redeemedAt: null);

  SpecialDinnerToken get token => _token;

  // --- New student details fields ---
  String name = "";
  String email = "";
  String photoUrl = "";
  bool hasUploadedPhoto = false;
  bool hasEaten = false;
  String mess = "";
  String rollNo = "";

  // Load token from local storage
  Future<void> loadToken() async {
    final data = await StorageService.loadToken();
    if (data != null) {
      _token = SpecialDinnerToken.fromMap(data);
      hasEaten = _token.hasEaten;
      notifyListeners();
    }
  }

  // Redeem dinner locally + sync to backend
  Future<void> redeemDinner() async {
    _token = SpecialDinnerToken(
      hasEaten: true,
      redeemedAt: DateTime.now(),
    );
    hasEaten = true;

    await StorageService.saveToken(_token.toMap());
    await syncTokenToBackend(true);

    notifyListeners();
  }

  // Reset token locally + sync to backend
  Future<void> resetDinner() async {
    _token = SpecialDinnerToken(hasEaten: false, redeemedAt: null);
    hasEaten = false;

    await StorageService.saveToken(_token.toMap());
    await syncTokenToBackend(false);

    notifyListeners();
  }

  // --- Fetch details from backend ---
  Future<void> fetchStudentDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenId = prefs.getString("google_id_token");

    if (tokenId == null) {
      throw Exception("No tokenId found in SharedPreferences");
    }
    String backendUrl;
    if (Platform.isAndroid) {
      backendUrl = 'http://10.0.2.2:5002/api/student/details';
    } else if (Platform.isIOS) {
      backendUrl = 'http://localhost:5002/api/student/details';
    } else {
      backendUrl = 'http://localhost:5002/api/student/details';
    }

    final response = await http.get(
      Uri.parse(backendUrl),
      headers: {"Authorization": "Bearer $tokenId"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["student"];
      name = data["name"];
      email = data["email"];
      photoUrl = data["photoUrl"];
      hasUploadedPhoto = data["hasUploadedPhoto"];
      hasEaten = data["redeemedToken"] == true;
      mess = data["mess"];
      rollNo = data["rollNo"];

      // Keep local token in sync
      _token = SpecialDinnerToken(
        hasEaten: hasEaten,
        redeemedAt: hasEaten ? DateTime.now() : null,
      );

      notifyListeners();
    } else {
      throw Exception("Failed to fetch student details: ${response.body}");
    }
  }

  // --- Sync token state back to backend ---
  Future<void> syncTokenToBackend(bool redeemed) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString("email");
    final tokenId = prefs.getString("google_id_token");
    if (savedEmail == null) return;
    String backendUrl;
    if (Platform.isAndroid) {
      backendUrl = 'http://10.0.2.2:5002/api/student/sync-token';
    } else if (Platform.isIOS) {
      backendUrl = 'http://localhost:5002/api/student/sync-token';
    } else {
      backendUrl = 'http://localhost:5002/api/student/sync-token';
    }

    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {"Content-Type": "application/json","Authorization": "Bearer $tokenId"},
      body: jsonEncode({"email": savedEmail, "redeemedToken": redeemed}),
    );

    if (response.statusCode != 200) {
      debugPrint("Failed to sync token to backend: ${response.body}");
    }
  }
}
