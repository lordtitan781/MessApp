import 'package:flutter/material.dart';
import '../Models/Meals.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  // Static data using class structure
  final List<Meal> meals = const [
    Meal(name: "Breakfast", items: const ["Pancakes", "Scrambled Eggs", "Tea/Coffee"]),
    Meal(name: "Lunch", items: const ["Rice", "Dal", "Vegetable Curry", "Chapati", "Salad"]),
    Meal(name: "Dinner", items: const ["Soup", "Fried Rice", "Paneer Butter Masala", "Naan"]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mess Menu")),
      body: ListView.builder(
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
                        Text(
                          item,
                          style: const TextStyle(fontSize: 16),
                        ),
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
