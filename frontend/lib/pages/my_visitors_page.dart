import 'package:flutter/material.dart';

class MyVisitorsPage extends StatelessWidget {
  const MyVisitorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text(
          'My Visitors',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Family'),
              VisitorList(members: ['Member 1', 'Member 2', 'Member 3']),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Friends/Others'),
              VisitorList(members: ['Member 1', 'Member 2', 'Member 3']),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[800],
        ),
      ),
    );
  }
}

class VisitorList extends StatelessWidget {
  final List<String> members;

  const VisitorList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: members
          .map((member) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.blueGrey[700]),
                  title: Text(
                    member,
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                ),
              ))
          .toList(),
    );
  }
}
