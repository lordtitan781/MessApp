import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mess_management_app/Pages/student_home_page.dart';
import 'package:mess_management_app/Pages/student_photo_upload_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'digital_mess_card.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSignIn.signOut();
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Access Token - use this for Google API calls
      final String? accessToken = googleAuth.accessToken;

      // ID Token - use this to verify user on your backend
      final String? idToken = googleAuth.idToken;

      print('=== Google Sign-In Successful ===');
      print('User Email: ${googleUser.email}');
      print('User Name: ${googleUser.displayName}');
      print('User ID: ${googleUser.id}');
      print('Access Token: $accessToken');
      print('ID Token: $idToken');

      // Create a credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Get Firebase ID Token (recommended for backend authentication)
        final String? firebaseIdToken = await user.getIdToken();

        print('=== Firebase Sign-In Successful ===');
        print('Firebase UID: ${user.uid}');
        print('Firebase Email: ${user.email}');
        print('Firebase ID Token: $firebaseIdToken');

        // Save user info and tokens in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_email", user.email ?? '');
        await prefs.setString("google_id_token", idToken ?? '');

        // Send Google ID token to your backend (your backend expects Google token, not Firebase token)
        http.Response? response = await _sendTokenToBackend(idToken, user);
        int? statusCode = response?.statusCode;
        final data = jsonDecode(response!.body);
        final student = data['student'];
        String? message = data['message'];
        final bool hasPhoto = student['hasUploadedPhoto'] != null && student['hasUploadedPhoto'];

        // Navigate to Student Home Page
        if (mounted&&statusCode==200) {
          if(hasPhoto) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentHomePage()),
            );
          }else{
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentUploadPhotoPage()),
            );
          }
        }else if(mounted&&statusCode!=200){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      if (mounted) {
        _showErrorDialog('Authentication failed: ${e.message}');
      }
    } catch (error) {
      debugPrint("Google Sign-In failed: $error");
      if (mounted) {
        _showErrorDialog('Sign-in failed: ${error.toString()}');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Send token to your backend for verification
  Future<http.Response?> _sendTokenToBackend(String? token, User user) async {
    if (token == null) return null;

    try {
      // Determine the correct localhost URL based on platform
      String backendUrl;
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        backendUrl = 'http://10.0.2.2:5002/api/student/login';
      } else if (Platform.isIOS) {
        // iOS simulator uses localhost directly
        backendUrl = 'http://localhost:5002/api/student/login';
      } else {
        // For web or other platforms
        backendUrl = 'http://localhost:5002/api/student/login';
      }

      print('Sending request to: $backendUrl');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'role': 'student',
          'photoUrl': user.photoURL,
          'tokenId':token,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - Make sure your backend is running on port 5000');
        },
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Token verified by backend successfully');
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        if (data['user_id'] != null) {
          await prefs.setString('backend_user_id', data['user_id']);
        }

        return response; // ✅ success
      } else {
        print('❌ Backend returned error: ${response.statusCode}');
        return response; // ❌ fail, don’t navigate
      }
    } catch (e) {
      print('❌ Error sending token to backend: $e');
      return null; // ❌ fail, don’t navigate
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Login"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Student Portal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign in with your Google account',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : () => _handleGoogleSignIn(context),
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.login),
                  label: Text(_isLoading ? "Signing in..." : "Login with Google"),
                ),
              ),
              const SizedBox(height: 24),
              // Display current auth state

            ],
          ),
        ),
      ),
    );
  }
}

// Helper class to store and retrieve tokens
class TokenManager {
  static Future<String?> getFirebaseToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebase_token');
  }

  static Future<String?> getGoogleAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('google_access_token');
  }

  static Future<String?> getGoogleIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('google_id_token');
  }

  static Future<Map<String, String?>> getAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firebase_token': prefs.getString('firebase_token'),
      'google_access_token': prefs.getString('google_access_token'),
      'google_id_token': prefs.getString('google_id_token'),
      'user_id': prefs.getString('user_id'),
      'user_email': prefs.getString('user_email'),
    };
  }

  static Future<void> clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_token');
    await prefs.remove('google_access_token');
    await prefs.remove('google_id_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }
}