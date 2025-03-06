import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  bool isLoading = true;
  bool isUpdating = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.fetchUser(widget.userId);
      if (userData.containsKey("error")) {
        setState(() {
          errorMessage = userData["error"];
          isLoading = false;
        });
      } else {
        setState(() {
          firstNameController.text = userData['firstName'] ?? '';
          lastNameController.text = userData['lastName'] ?? '';
          emailController.text = userData['email'] ?? '';
          dobController.text = userData['dob'] ?? '';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "❌ Error fetching user details.";
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userId");
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ProfileField(label: "First Name", controller: firstNameController),
                      ProfileField(label: "Last Name", controller: lastNameController),
                      ProfileField(label: "Email", controller: emailController, isReadOnly: true),
                      ProfileField(label: "DOB", controller: dobController),
                      ElevatedButton(onPressed: _logout, child: const Text("Logout")),
                    ],
                  ),
                ),
    );
  }
}

// ✅ ProfileField Widget
class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;

  const ProfileField({super.key, required this.label, required this.controller, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
