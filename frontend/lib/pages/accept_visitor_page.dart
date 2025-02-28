import 'package:flutter/material.dart';

class AcceptVisitorPage extends StatelessWidget {
  const AcceptVisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text('Approval', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
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
            VisitorField(label: 'Name'),
            VisitorField(label: 'Relation'),
            VisitorField(label: 'Reason of visit', isMultiline: true),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Accept visitor logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600], // Button background color
                    foregroundColor: Colors.blue[100], // Text color
                  ),
                  child: Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Reject visitor logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600], // Button background color
                    foregroundColor: Colors.blue[100], // Text color
                  ),
                  child: Text('Reject'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add visitor to My Visitors logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700], // Button background color
                foregroundColor: Colors.blue[100], // Text color
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Adjust padding
              ),
              child: Text(
                'Accept and Add to My Visitors',
                style: TextStyle(fontSize: 16), // Optional: Adjust text size
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisitorField extends StatelessWidget {
  final String label;
  final bool isMultiline;

  const VisitorField({super.key, required this.label, this.isMultiline = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: isMultiline ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
