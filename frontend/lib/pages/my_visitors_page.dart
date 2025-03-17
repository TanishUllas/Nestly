import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyVisitorsPage extends StatefulWidget {
  final int userId;

  const MyVisitorsPage({super.key, required this.userId}); // ✅ Make userId required

  @override
  _MyVisitorsPageState createState() => _MyVisitorsPageState();
}

class _MyVisitorsPageState extends State<MyVisitorsPage> {
  List<Map<String, dynamic>> visitors = [];
  bool isLoading = true;
  int? userId; // ✅ Store userId

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // ✅ **Load User ID from Shared Preferences**
  Future<void> _loadUserId() async {
    int storedUserId = await ApiService.getUserId(); // ✅ Get userId from SharedPreferences
    setState(() {
      userId = storedUserId;
    });

    _loadVisitors(storedUserId);
  }

  // ✅ **Load Visitors for User**
  Future<void> _loadVisitors(int userId) async {
    print("🟡 Loading visitors for userId: $userId");

    List<Map<String, dynamic>> fetchedVisitors = await ApiService.fetchMyVisitors(userId);

    setState(() {
      visitors = fetchedVisitors;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text('My Visitors', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // ✅ Show loader
            : visitors.isEmpty
                ? const Center(
                    child: Text("No visitors found", style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                  )
                : ListView(
                    children: [
                      SectionTitle(title: "Family"),
                      VisitorList(visitors: visitors.where((v) => v['category'] == 'Family').toList()),
                      const SizedBox(height: 20),
                      SectionTitle(title: "Friends/Others"),
                      VisitorList(visitors: visitors.where((v) => v['category'] != 'Family').toList()),
                    ],
                  ),
      ),
    );
  }
}

// ✅ **Reusable Section Title Widget**
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

// ✅ **Visitor List Widget**
class VisitorList extends StatelessWidget {
  final List<Map<String, dynamic>> visitors;
  const VisitorList({super.key, required this.visitors});

  @override
  Widget build(BuildContext context) {
    return visitors.isEmpty
        ? const Text("No visitors available", style: TextStyle(color: Colors.blueGrey))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visitors.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.blueGrey[700]),
                  title: Text(visitors[index]['name'], style: const TextStyle(fontSize: 16)),
                  subtitle: Text(
                    visitors[index]['category'] ?? "Unknown",
                    style: TextStyle(color: Colors.blueGrey[600]),
                  ),
                ),
              );
            },
          );
  }
}
