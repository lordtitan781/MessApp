import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mess_management_app/services/admin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AdminService _adminService = AdminService();
  int _currentIndex = 0;

  // Separate files for students and weekly menu
  File? _studentFile;
  File? _menuFile;

  // For special token button
  late String msg = "Start Session";

  // Meal items
  List<String> breakfastItems = [];
  List<String> lunchItems = [];
  List<String> dinnerItems = [];

  @override
  void initState() {
    super.initState();
    _initTokenSession();
    _loadTodayMenu();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initTokenSession() async {
    final sessionActive = await _adminService.tokenSession();
    setState(() {
      msg = sessionActive ? "End Session" : "Start Session";
    });
  }

  // ---- FILE PICKERS ----
  Future<void> _pickStudentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _studentFile = File(result.files.single.path!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student file selected: ${_studentFile!.path.split('/').last}")),
      );
    }
  }

  Future<void> _pickMenuFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _menuFile = File(result.files.single.path!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Menu file selected: ${_menuFile!.path.split('/').last}")),
      );
    }
  }

  // ---- API CALLS ----
  Future<void> _uploadStudents() async {
    if (_studentFile == null) return;
    final success = await _adminService.uploadStudents(_studentFile!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Students uploaded successfully" : "Upload failed")),
    );
  }

  Future<void> _uploadMenu() async {
    if (_menuFile == null) return;
    final success = await _adminService.uploadMenu(_menuFile!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Menu uploaded successfully" : "Menu upload failed")),
    );
  }

  Future<void> _resetStudents() async {
    final success = await _adminService.resetStudents();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "All students cleared" : "Failed to reset")),
    );
  }

  Future<void> _loadTodayMenu() async {
    try {
      final menu = await _adminService.fetchMenu(); // fetch today's menu
      if (menu != null) {
        setState(() {
          breakfastItems = List<String>.from(menu['breakfast'] ?? []);
          lunchItems = List<String>.from(menu['lunch'] ?? []);
          dinnerItems = List<String>.from(menu['dinner'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load menu: $e")),
      );
    }
  }

  Future<void> _updateDayMenu() async {
    final now = DateTime.now();
    final currentDay = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ][now.weekday - 1];

    final success = await _adminService.updateDayMenu(
      currentDay,
      breakfastItems,
      lunchItems,
      dinnerItems,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Menu for $currentDay updated" : "Update failed")),
    );
  }

  Future<void> _startToken() async {
    final success = await _adminService.startToken();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Special token issued" : "Failed to start token")),
    );

    if (success) setState(() => msg = "End Session");
  }

  Future<void> _endToken() async {
    final success = await _adminService.endToken();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Special token ended" : "Failed to end token")),
    );

    if (success) setState(() => msg = "Start Session");
  }

  Future<void> _tokenSystem() async {
    final session = await _adminService.tokenSession();
    if (session) {
      await _endToken();
    } else {
      await _startToken();
    }
  }

  Future<void> _logout() async {
    await _adminService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
          (route) => false,
    );
  }

  // Helper widget for meals
  // Helper widget for meals
  Widget _mealSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.asMap().entries.map((entry) {
              int index = entry.key;
              String item = entry.value;
              return ListTile(
                title: Text(item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        String? edited = await _showEditDialog(item,"Edit Item");
                        if (edited != null && edited.isNotEmpty) {
                          setState(() => items[index] = edited);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => items.removeAt(index)),
                    ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: () async {
                String? newItem = await _showEditDialog("","Add Item"); // empty string for new item
                if (newItem != null && newItem.isNotEmpty) {
                  setState(() => items.add(newItem));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
            ),
          ],
        ),
      ),
    );
  }


  // Dialog to edit item
  Future<String?> _showEditDialog(String current,String msg) {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(msg),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // ---- Menu Editing Page ----
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Edit Mess Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _mealSection("Breakfast", breakfastItems),
          _mealSection("Lunch", lunchItems),
          _mealSection("Dinner", dinnerItems),
          ElevatedButton(
            onPressed: _updateDayMenu,
            child: const Text("Save Today's Menu"),
          ),
          const Divider(),
          ElevatedButton.icon(
            onPressed: _pickMenuFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Select Menu CSV File"),
          ),
          if (_menuFile != null)
            Text("Selected: ${_menuFile!.path.split('/').last}"),
          ElevatedButton(
            onPressed: _uploadMenu,
            child: const Text("Upload Weekly Menu (CSV)"),
          ),
        ],
      ),

      // ---- Special Token Page ----
      Center(
        child: ElevatedButton(
          onPressed: _tokenSystem,
          child: Text(msg),
        ),
      ),

      // ---- Manage Students Page ----
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: _pickStudentFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Select Student CSV File"),
          ),
          if (_studentFile != null)
            Text("Selected: ${_studentFile!.path.split('/').last}"),
          ElevatedButton(
            onPressed: _uploadStudents,
            child: const Text("Upload Students"),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: _resetStudents,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reset Students"),
          ),
        ],
      ),

      // ---- Settings Page ----
      Center(
        child: ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Logout"),
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
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.token), label: "Token"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
