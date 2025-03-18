import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';
import 'package:intl/intl.dart'; // ✅ Import for date formatting

class AcceptVisitorPage extends StatefulWidget {
  final int userId; // ✅ User ID to fetch visitors

  const AcceptVisitorPage({super.key, required this.userId});

  @override
  _AcceptVisitorPageState createState() => _AcceptVisitorPageState();
}

class _AcceptVisitorPageState extends State<AcceptVisitorPage> {
  List<Map<String, dynamic>> visitors = [];
  bool isLoading = true;
  Set<int> processingVisitors = {}; // ✅ To track visitors being processed

  @override
  void initState() {
    super.initState();
    _fetchRecentVisitors();
  }

  // ✅ Fetch visitors who arrived in the last 10 minutes
  Future<void> _fetchRecentVisitors() async {
    setState(() => isLoading = true);
    try {
      List<Map<String, dynamic>> fetchedVisitors = await ApiService.fetchRecentVisitors(widget.userId);
      setState(() {
        visitors = fetchedVisitors;
        isLoading = false;
      });
    } catch (e) {
      _showError("Failed to fetch visitors");
      setState(() => isLoading = false);
    }
  }

  // ✅ Accept a visitor
  Future<void> _acceptVisitor(int visitorId, String name, String relation) async {
    if (processingVisitors.contains(visitorId)) return;

    setState(() => processingVisitors.add(visitorId));
    try {
      await ApiService.updateVisitorStatus(visitorId, "Accepted");
      await ApiService.addToMyVisitors(widget.userId, name, relation);
      _fetchRecentVisitors();
    } catch (e) {
      _showError("Failed to accept visitor");
    }
    setState(() => processingVisitors.remove(visitorId));
  }

  // ✅ Reject a visitor
  Future<void> _rejectVisitor(int visitorId) async {
    if (processingVisitors.contains(visitorId)) return;

    setState(() => processingVisitors.add(visitorId));
    try {
      await ApiService.updateVisitorStatus(visitorId, "Rejected");
      _fetchRecentVisitors();
    } catch (e) {
      _showError("Failed to reject visitor");
    }
    setState(() => processingVisitors.remove(visitorId));
  }

  // ✅ Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ✅ Format arrival time
  String _formatArrivalTime(String arrivalTime) {
    try {
      final DateTime parsedTime = DateTime.parse(arrivalTime);
      return DateFormat("yyyy-MM-dd hh:mm a").format(parsedTime);
    } catch (e) {
      return arrivalTime; // Fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text('Visitor Approvals', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : visitors.isEmpty
                ? const Center(
                    child: Text("No recent visitors", style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                  )
                : ListView.builder(
                    itemCount: visitors.length,
                    itemBuilder: (context, index) {
                      final visitor = visitors[index];
                      final int visitorId = visitor['id'];
                      final bool isProcessing = processingVisitors.contains(visitorId);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: ListTile(
                          leading: Icon(Icons.account_circle, color: Colors.blueGrey[700]),
                          title: Text(visitor['name'], style: const TextStyle(fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Relation: ${visitor['relation']}"),
                              Text("Reason: ${visitor['reason']}"),
                              Text("Arrived: ${_formatArrivalTime(visitor['arrival_time'])}"),
                              Text("Status: ${visitor['status']}", style: TextStyle(color: Colors.blueGrey[600])),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: isProcessing
                                    ? const CircularProgressIndicator()
                                    : const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: isProcessing ? null : () => _acceptVisitor(visitorId, visitor['name'], visitor['relation']),
                              ),
                              IconButton(
                                icon: isProcessing
                                    ? const CircularProgressIndicator()
                                    : const Icon(Icons.cancel, color: Colors.red),
                                onPressed: isProcessing ? null : () => _rejectVisitor(visitorId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
