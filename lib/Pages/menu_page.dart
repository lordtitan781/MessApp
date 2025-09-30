import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Meals.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool loading = true;
  List<Meal> meals = [];

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    String backendUrl;
    if (Platform.isAndroid) {
      backendUrl = 'http://10.0.2.2:5002/api/student/menu';
    } else if (Platform.isIOS) {
      backendUrl = 'http://localhost:5002/api/student/menu';
    } else {
      backendUrl = 'http://localhost:5002/api/student/menu';
    }
    final prefs = await SharedPreferences.getInstance();
    final tokenId = prefs.getString("google_id_token");
    final response = await http.get(Uri.parse(backendUrl),
        headers: {"Authorization": "Bearer $tokenId"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        meals = [
          Meal(name: "Breakfast", items: List<String>.from(data["breakfast"] ?? [])),
          Meal(name: "Lunch", items: List<String>.from(data["lunch"] ?? [])),
          Meal(name: "Dinner", items: List<String>.from(data["dinner"] ?? [])),
        ];
        loading = false;
      });
    } else {
      setState(() => loading = false);
      throw Exception("Failed to load menu");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mess Menu")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...meal.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8),
                        const SizedBox(width: 8),
                        Text(item, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
