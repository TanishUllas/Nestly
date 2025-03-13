import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final int userId; // ✅ Requires userId

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

  // ✅ Load User Data
  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.fetchUser(widget.userId);
      if (userData.containsKey("error")) {
        setState(() {
          errorMessage = userData["error"];
          isLoading = false;
        });
      } else if (userData.isNotEmpty) {
        setState(() {
          firstNameController.text = userData['firstname'] ?? '';
          lastNameController.text = userData['lastname'] ?? '';
          emailController.text = userData['email'] ?? '';
          dobController.text = ApiService.formatDate(userData['dob']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "❌ Failed to load user data.";
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

  // ✅ Update User Profile
  Future<void> _updateUser() async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty || dobController.text.isEmpty) {
      _showMessage("❌ Fields cannot be empty");
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final response = await ApiService.updateUser(
        widget.userId,
        firstNameController.text,
        lastNameController.text,
        emailController.text,
        dobController.text,
      );

      setState(() {
        isUpdating = false;
      });

      if (response.containsKey("error")) {
        _showMessage(response["error"]);
      } else {
        _showMessage("✅ Profile updated successfully", success: true);
      }
    } catch (error) {
      setState(() {
        isUpdating = false;
      });
      _showMessage("❌ Failed to update profile. Please try again.");
    }
  }

  // ✅ Show Snackbar Message
  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 80, color: Colors.blueGrey)),
                      const SizedBox(height: 20),
                      ProfileField(label: "First Name", controller: firstNameController),
                      ProfileField(label: "Last Name", controller: lastNameController),
                      ProfileField(label: "Email", controller: emailController, isReadOnly: true),
                      ProfileField(label: "DOB", controller: dobController),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isUpdating ? null : _updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        ),
                        child: isUpdating
                            ? const SizedBox(
                                height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                            : const Text("Save Changes", style: TextStyle(color: Colors.white)),
                      ),
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
          suffixIcon: isReadOnly ? null : const Icon(Icons.edit, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
