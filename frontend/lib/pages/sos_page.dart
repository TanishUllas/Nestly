import 'package:flutter/material.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text('SOS', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 40, // Increased size
              backgroundColor: Colors.red[700],
              child: Text(
                'SOS',
                style: TextStyle(
                  fontSize: 28, // Larger font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20), // More space between the header and buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SOSButton(
                      label: 'Medical Emergency',
                      icon: Icons.local_hospital,
                      color: Colors.blueGrey[700],
                    ),
                    SOSButton(
                      label: 'Fire/Gas Leak Emergency',
                      icon: Icons.fire_extinguisher,
                      color: Colors.blue[400],
                    ),
                  ],
                ),
                SizedBox(height: 20), // Space between rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SOSButton(
                      label: 'Lift Emergency',
                      icon: Icons.elevator,
                      color: Colors.blueGrey[600],
                    ),
                    SOSButton(
                      label: 'Theft/Others',
                      icon: Icons.help_outline,
                      color: Colors.blueGrey[400],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SOSButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const SOSButton({
    super.key,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320, // Increased button width
      height: 185, // Increased button height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero, // Remove additional padding
        ),
        onPressed: () {
          // SOS button logic
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white), // Larger icon size
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14), // Larger text size
            ),
          ],
        ),
      ),
    );
  }
}
