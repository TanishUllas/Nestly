import 'package:flutter/material.dart';

class CallGuardPage extends StatelessWidget {
  const CallGuardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text('Call Guard', style: TextStyle(color: Colors.white)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: "Exit Gate"),
            GuardList(guards: ["Guard 1"]),
            SizedBox(height: 20),
            SectionTitle(title: "Main Gate"),
            GuardList(guards: ["Guard 1", "Guard 2", "Guard 3"]),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[700],
        ),
      ),
    );
  }
}

class GuardList extends StatelessWidget {
  final List<String> guards;

  const GuardList({super.key, required this.guards});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: guards.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey[400],
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              guards[index],
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
