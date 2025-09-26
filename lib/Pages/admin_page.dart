import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mess_management_app/providers/dinner_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'role_selection_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  final Map<String, List<String>> _menuData = {
    "Breakfast": ["Pancakes", "Scrambled Eggs", "Tea/Coffee"],
    "Lunch": ["Rice", "Dal", "Vegetable Curry", "Chapati", "Salad"],
    "Dinner": ["Soup", "Fried Rice", "Paneer Butter Masala", "Naan"],
  };

  final Map<String, TextEditingController> _controllers = {};
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _menuData.forEach((key, items) {
      _controllers[key] = TextEditingController(text: items.join(", "));
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _saveMenu() {
    setState(() {
      _menuData.forEach((key, value) {
        final text = _controllers[key]?.text ?? "";
        _menuData[key] = text.split(",").map((e) => e.trim()).toList();
      });
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Menu updated!")));
  }

  void _issueToken() {
    context.read<DinnerProvider>().resetDinner();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Special dinner token issued!")));
  }

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File selected: ${_selectedFile!.path}")),
      );
    }
  }

  void _uploadData() {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an Excel file first.")),
      );
      return;
    }
    // TODO: Upload data to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel data uploaded successfully!")),
    );
  }

  void _resetData() {
    // TODO: Clear all student data in backend
    setState(() {
      _selectedFile = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All student data reset for new semester.")),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("role");

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Edit Mess Menu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._menuData.entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _controllers[entry.key],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter items separated by comma",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveMenu,
              child: const Text("Save Menu"),
            ),
          ],
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Special Dinner Token",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _issueToken,
              child: const Text("Issue Token to All Students"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Note: Students will be able to redeem token once.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Manage Student Data",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickExcelFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Select Excel File"),
            ),
            const SizedBox(height: 10),
            if (_selectedFile != null)
              Text("Selected File: ${_selectedFile!.path.split('/').last}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Upload Data"),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Reset All Data for New Semester"),
            ),
          ],
        ),
      ),

      Center(
        child: ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(200, 50),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Menu",),
          BottomNavigationBarItem(icon: Icon(Icons.token), label: "Token"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
