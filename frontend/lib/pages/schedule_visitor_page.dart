import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // ✅ Import for Date Formatting

class ScheduleVisitorPage extends StatefulWidget {
  final int userId;

  const ScheduleVisitorPage({super.key, required this.userId});

  @override
  _ScheduleVisitorPageState createState() => _ScheduleVisitorPageState();
}

class _ScheduleVisitorPageState extends State<ScheduleVisitorPage> {
  String? selectedDate = "Today";
  String selectedTime = "10:00 AM - 11:00 AM"; // ✅ Default Time
  bool isProcessing = false;

  final List<String> dates = ["Today", "Tomorrow", "Pick Date"];
  final List<String> timeSlots = [
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "01:00 PM - 02:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController relationController = TextEditingController();

  // ✅ **Show Date Picker**
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Allow 1 month selection
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // ✅ Save proper date format
      });
    }
  }

  // ✅ **Pre-Approve Visitor**
  Future<void> preApproveVisitor(bool addToMyVisitors) async {
    if (nameController.text.isEmpty || relationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Name and Relation are required"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isProcessing = true);

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ User not authenticated"), backgroundColor: Colors.red),
      );
      setState(() => isProcessing = false);
      return;
    }

    final url = Uri.parse("http://localhost:5001/pre-approve");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "userId": widget.userId,
        "type": "Visitor",
        "name": nameController.text,
        "relation": relationController.text,
        "date": selectedDate,
        "time": selectedTime,
      }),
    );

    print("Pre-Approval Response: ${response.body}");

    if (response.statusCode == 200) {
      if (addToMyVisitors) {
        await addToMyVisitorsTable(token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Visitor Pre-Approved"), backgroundColor: Colors.green),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to Pre-Approve Visitor"), backgroundColor: Colors.red),
      );
    }

    setState(() => isProcessing = false);
  }

  // ✅ **Add to My Visitors Table**
  Future<void> addToMyVisitorsTable(String token) async {
    final url = Uri.parse("http://localhost:5001/myvisitors/add");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "userId": widget.userId,
        "name": nameController.text,
        "relation": relationController.text,
        "date": selectedDate,
        "time": selectedTime,
      }),
    );

    print("MyVisitors Response: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Visitor Added to My Visitors"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to Add to My Visitors"), backgroundColor: Colors.red),
      );
    }
  }

  List<String> _getValidTimeSlots() {
  if (selectedDate != "Today") return timeSlots; // ✅ Show all slots for future dates

  final now = DateTime.now();
  final currentHour = now.hour;
  final currentMinute = now.minute;

  return timeSlots.where((slot) {
    final parts = slot.split(" - ")[0].split(" ");
    final timePart = parts[0];
    final period = parts[1];

    int hour = int.parse(timePart.split(":")[0]);
    int minute = int.parse(timePart.split(":")[1]);

    // Convert 12-hour format to 24-hour format
    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    // ✅ Allow only future time slots
    return (hour > currentHour) || (hour == currentHour && minute > currentMinute);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text('Schedule Visitor', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ **Date Selection**
            Wrap(
              spacing: 8.0,
              children: dates.map((date) {
                return ChoiceChip(
                  label: Text(date),
                  selected: selectedDate == date,
                  onSelected: (bool selected) {
                    if (selected) {
                      if (date == "Pick Date") {
                        _pickDate(); // ✅ Show Date Picker
                      } else {
                        setState(() => selectedDate = date);
                      }
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ✅ **Dropdown for Time Slots**
            DropdownButtonFormField<String>(
                  value: selectedTime,
                  onChanged: (newValue) {
                    setState(() => selectedTime = newValue!);
                  },
                  items: _getValidTimeSlots().map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Select Time",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                ),
            const SizedBox(height: 20),

            // ✅ **Visitor Details**
            VisitorField(label: 'Name', controller: nameController),
            VisitorField(label: 'Relation', controller: relationController),

            const Spacer(),

            // ✅ **Pre-Approval Button**
            ElevatedButton(
              onPressed: isProcessing ? null : () => preApproveVisitor(false), // ✅ Pre-Approve Only
              style: _buttonStyle(),
              child: isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Notify Guard', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // ✅ **Pre-Approve & Add to My Visitors Button**
            ElevatedButton(
              onPressed: isProcessing ? null : () => preApproveVisitor(true), // ✅ Pre-Approve & Add
              style: _buttonStyle(),
              child: isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Notify Guard and Add to My Visitors', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ **Reused Button Style**
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.lightBlue[100],
      foregroundColor: Colors.blueGrey[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blueGrey[700]!),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
    );
  }
}

// ✅ **Reusable Visitor Input Field**
class VisitorField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const VisitorField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
