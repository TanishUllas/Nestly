import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';

class MyVisitorsPage extends StatefulWidget {
  const MyVisitorsPage({super.key});

  @override
  _MyVisitorsPageState createState() => _MyVisitorsPageState();
}

class _MyVisitorsPageState extends State<MyVisitorsPage> {
  List<Map<String, dynamic>> visitors = [];

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    List<Map<String, dynamic>> fetchedVisitors = await ApiService.fetchMyVisitors();
    setState(() {
      visitors = fetchedVisitors;
    });
  }

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        padding: const EdgeInsets.all(16.0),
        child: visitors.isEmpty
            ? Center(child: CircularProgressIndicator()) // ✅ Show loader
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: "Family"),
                  VisitorList(visitors: visitors.where((v) => v['category'] == 'Family').toList()),
                  SizedBox(height: 20),
                  SectionTitle(title: "Friends/Others"),
                  VisitorList(visitors: visitors.where((v) => v['category'] == 'Friends/Others').toList()),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
      ),
    );
  }
}

class VisitorList extends StatelessWidget {
  final List<Map<String, dynamic>> visitors;
  const VisitorList({super.key, required this.visitors});

  @override
  Widget build(BuildContext context) {
    return visitors.isEmpty
        ? Text("No visitors available", style: TextStyle(color: Colors.blueGrey[600]))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: visitors.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.blueGrey[700]),
                  title: Text(visitors[index]['name'], style: TextStyle(fontSize: 16, color: Colors.blueGrey[800])),
                ),
              );
            },
          );
  }
}
