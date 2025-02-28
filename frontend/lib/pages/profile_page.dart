import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.lightBlue[100],
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 80, color: Colors.blueGrey[700]),
              ),
              SizedBox(height: 20),
              ProfileField(label: 'First Name'),
              ProfileField(label: 'Last Name'),
              ProfileField(label: 'Password...', isPassword: true),
              ProfileField(label: 'Email...'),
              ProfileField(label: 'DOB'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Save changes logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[100],
                      foregroundColor: Colors.blueGrey[700], // Text and icon color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blueGrey[700]!),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    child: Text('Save Changes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Discard changes logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[100],
                      foregroundColor: Colors.blueGrey[700], // Text and icon color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blueGrey[700]!),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    child: Text('Discard Changes'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                child: Text('LOGOUT', style: TextStyle(color: Colors.blueGrey[700])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final bool isPassword;

  const ProfileField({super.key, required this.label, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: Icon(Icons.edit, color: Colors.blueGrey[700]),
        ),
      ),
    );
  }
}
