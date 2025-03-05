import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  Future<void> _registerUser() async {
    String apiUrl = "https://nestly.onrender.com/register"; // ✅ Backend URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "dob": dobController.text,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${data['message']}"), backgroundColor: Colors.green),
      );
      Navigator.pushNamed(context, '/home_dashboard'); // ✅ Redirect after success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${data['message']}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blueGrey[800]),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.lightBlue[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('REGISTER', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
                SizedBox(height: 40),
                TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder())),
                SizedBox(height: 16),
                TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder())),
                SizedBox(height: 16),
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                SizedBox(height: 16),
                TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
                SizedBox(height: 16),
                TextField(controller: dobController, decoration: InputDecoration(labelText: 'DOB (YYYY-MM-DD)', border: OutlineInputBorder())),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _registerUser, // ✅ Calls API
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700], padding: EdgeInsets.symmetric(vertical: 15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Register', style: TextStyle(color: Colors.lightBlue[100], fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.lightBlue[100]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
