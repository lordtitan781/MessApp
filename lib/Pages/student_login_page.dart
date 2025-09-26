import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'digital_mess_card.dart';

class StudentLoginPage extends StatelessWidget {
  const StudentLoginPage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // if (googleUser != null) {
      //   // Save role in SharedPreferences
      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.setString("role", "student");
      //
      //   // Navigate to SpecialDinnerPage
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const SpecialDinnerPage()),
      //   );
      // }
    } catch (error) {
      debugPrint("Google Sign-In failed: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Login")),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Google button color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () => _handleGoogleSignIn(context),
          icon: const Icon(Icons.login),
          label: const Text("Login with Google"),
        ),
      ),
    );
  }
}
