import 'package:flutter/material.dart';

class ScheduleVisitorPage extends StatefulWidget {
  const ScheduleVisitorPage({super.key});

  @override
  _ScheduleVisitorPageState createState() => _ScheduleVisitorPageState();
}

class _ScheduleVisitorPageState extends State<ScheduleVisitorPage> {
  String? selectedDate = "Today";
  String? selectedTime = "04:00 PM - 05:00 PM";
  final List<String> dates = ["Today", "Tomorrow", "Pick Date"];
  final List<String> quickTimes = ["In next 30 mins", "In next 1 hour"];
  final List<String> timeSlots = [
    "04:00 PM - 05:00 PM",
    "05:00 PM - 06:00 PM",
    "06:00 PM - 07:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text('Schedule', style: TextStyle(color: Colors.white)),
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
            Wrap(
              spacing: 8.0,
              children: dates
                  .map((date) => ChoiceChip(
                        label: Text(date),
                        selected: selectedDate == date,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedDate = selected ? date : null;
                          });
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              children: quickTimes
                  .map((time) => ChoiceChip(
                        label: Text(time),
                        selected: selectedTime == time,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedTime = selected ? time : null;
                          });
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedTime,
              onChanged: (newValue) {
                setState(() {
                  selectedTime = newValue;
                });
              },
              items: timeSlots.map((time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Time",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            SizedBox(height: 20),
            VisitorField(label: 'Name'),
            VisitorField(label: 'Relation'),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Notify guard logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[100],
                foregroundColor: Colors.blueGrey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blueGrey[700]!),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
              ),
              child: Text(
                'Notify Guard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Notify guard and add to My Visitors logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[100],
                foregroundColor: Colors.blueGrey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blueGrey[700]!),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              child: Text(
                'Notify Guard and Add to My Visitors',
                style: TextStyle(fontWeight: FontWeight.bold),
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

  const VisitorField({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
