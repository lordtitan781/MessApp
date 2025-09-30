import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mess_management_app/Pages/student_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentUploadPhotoPage extends StatefulWidget {
  const StudentUploadPhotoPage({super.key});

  @override
  State<StudentUploadPhotoPage> createState() => _StudentUploadPhotoPageState();
}

class _StudentUploadPhotoPageState extends State<StudentUploadPhotoPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPhoto() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload or capture a photo first.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      String backendUrl;
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        backendUrl = 'http://10.0.2.2:5002/api/student/upload-photo';
      } else if (Platform.isIOS) {
        // iOS simulator uses localhost directly
        backendUrl = 'http://localhost:5002/api/student/upload-photo';
      } else {
        // For web or other platforms
        backendUrl = 'http://localhost:5002/api/student/upload-photo';
      }
      final uri = Uri.parse(backendUrl);
      final prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('google_id_token');
      final email = prefs.getString('user_email');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'photoBase64': base64Image,
          'email': email,
        }),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo submitted successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${body['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Student Photo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(_imageFile!),
            )
                : const CircleAvatar(
              radius: 80,
              child: Icon(Icons.person, size: 80),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Upload"),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitPhoto,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
