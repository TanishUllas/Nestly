import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';
import 'package:intl/intl.dart';

class AcceptVisitorPage extends StatefulWidget {
  final int userId;

  const AcceptVisitorPage({super.key, required this.userId});

  @override
  _AcceptVisitorPageState createState() => _AcceptVisitorPageState();
}

class _AcceptVisitorPageState extends State<AcceptVisitorPage> {
  List<Map<String, dynamic>> visitors = [];
  bool isLoading = true;
  Set<int> processingVisitors = {};

  @override
  void initState() {
    super.initState();
    _fetchRecentVisitors();
  }

  Future<void> _fetchRecentVisitors() async {
    setState(() => isLoading = true);
    try {
      List<Map<String, dynamic>> fetchedVisitors =
          await ApiService.fetchRecentVisitors(widget.userId);
      setState(() {
        visitors = fetchedVisitors;
      });
    } catch (e) {
      _showError("Failed to fetch visitors: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _acceptVisitor(int visitorId) async {
    if (processingVisitors.contains(visitorId)) return;
    setState(() => processingVisitors.add(visitorId));

    try {
      await ApiService.updateVisitorStatus(visitorId, "Accepted");
      setState(() {
        visitors.removeWhere((v) => v['id'] == visitorId);
      });
    } catch (e) {
      _showError("Failed to accept visitor: $e");
    } finally {
      setState(() => processingVisitors.remove(visitorId));
    }
  }

  Future<void> _acceptAndAddVisitor(int visitorId, String name, String category) async {
    if (processingVisitors.contains(visitorId)) return;
    setState(() => processingVisitors.add(visitorId));

    try {
      await ApiService.updateVisitorStatus(visitorId, "Accepted");
      await ApiService.addToMyVisitors(widget.userId, name, category); // ✅ Updated relation -> category

      setState(() {
        visitors.removeWhere((v) => v['id'] == visitorId);
      });
    } catch (e) {
      _showError("Failed to accept and add visitor: $e");
    } finally {
      setState(() => processingVisitors.remove(visitorId));
    }
  }

  Future<void> _rejectVisitor(int visitorId) async {
    if (processingVisitors.contains(visitorId)) return;
    setState(() => processingVisitors.add(visitorId));

    try {
      await ApiService.updateVisitorStatus(visitorId, "Rejected");
      setState(() {
        visitors.removeWhere((v) => v['id'] == visitorId);
      });
    } catch (e) {
      _showError("Failed to reject visitor: $e");
    } finally {
      setState(() => processingVisitors.remove(visitorId));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatArrivalTime(String arrivalTime) {
    try {
      final DateTime parsedTime = DateTime.parse(arrivalTime);
      return DateFormat("yyyy-MM-dd hh:mm a").format(parsedTime);
    } catch (e) {
      return arrivalTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text('Approval', style: TextStyle(color: Colors.white)),
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
                    child: Text(
                      "No recent visitors",
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 50, color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _buildVisitorInfo(visitors.first),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildVisitorInfo(Map<String, dynamic> visitor) {
    int visitorId = visitor['id'];
    bool isProcessing = processingVisitors.contains(visitorId);

    return Column(
      children: [
        _buildTextField("Name", visitor['name']),
        _buildTextField("Category", visitor['relation']), // ✅ Updated label from Relation → Category
        _buildTextField("Reason of visit", visitor['reason']),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLargeButton("Accept", Colors.green, isProcessing, () {
              _acceptVisitor(visitorId); // ✅ Only updates visitors table
            }),
            const SizedBox(width: 170), // Increased gap between buttons
            _buildLargeButton("Reject", Colors.red, isProcessing, () {
              _rejectVisitor(visitorId);
            }),
          ],
        ),
        const SizedBox(height: 15),
        _buildMediumButton("Accept and Add to My Visitors", Colors.blueGrey, isProcessing, () {
          _acceptAndAddVisitor(visitorId, visitor['name'], visitor['category']); // ✅ Uses new function
        }),
      ],
    );
  }

  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }

  Widget _buildLargeButton(String text, Color color, bool isProcessing, VoidCallback onPressed) {
    return SizedBox(
      width: 130, // Increased button size
      height: 50,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildMediumButton(String text, Color color, bool isProcessing, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 50,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: isProcessing
            ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
            : Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
