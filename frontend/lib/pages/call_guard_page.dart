import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';

class CallGuardPage extends StatefulWidget {
  const CallGuardPage({super.key});

  @override
  _CallGuardPageState createState() => _CallGuardPageState();
}

class _CallGuardPageState extends State<CallGuardPage> {
  List<Map<String, dynamic>> guards = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadGuards();
  }

  Future<void> _loadGuards() async {
    try {
      List<Map<String, dynamic>> fetchedGuards = await ApiService.fetchGuards();
      setState(() {
        guards = fetchedGuards;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = "❌ Failed to load guards. Please try again.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text('Call Guard', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // ✅ Show loading indicator
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red))) // ✅ Show error message
                : ListView(
                    children: [
                      SectionTitle(title: "Exit Gate"),
                      GuardList(guards: guards.where((g) => g['gate'] == 'Exit Gate').toList()),
                      const SizedBox(height: 20),
                      SectionTitle(title: "Main Gate"),
                      GuardList(guards: guards.where((g) => g['gate'] == 'Main Gate').toList()),
                      const SizedBox(height: 20),
                      SectionTitle(title: "Other"),
                      GuardList(guards: guards.where((g) => g['gate'] == 'Other').toList()),
                    ],
                  ),
      ),
    );
  }
}

// ✅ Section Title Widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }
}

// ✅ Guard List Widget
class GuardList extends StatelessWidget {
  final List<Map<String, dynamic>> guards;
  const GuardList({super.key, required this.guards});

  @override
  Widget build(BuildContext context) {
    return guards.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No guards available", style: TextStyle(color: Colors.blueGrey)),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guards.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey[400],
                    child: const Icon(Icons.security, color: Colors.white),
                  ),
                  title: Text(guards[index]['name'], style: const TextStyle(fontSize: 16)),
                ),
              );
            },
          );
  }
}
