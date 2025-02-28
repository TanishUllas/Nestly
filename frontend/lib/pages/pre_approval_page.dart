import 'package:flutter/material.dart';

class PreApprovalPage extends StatelessWidget {
  const PreApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text(
          'Pre Approval',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        child: ListView(
          children: [
            PreApprovalTile(
              icon: Icons.local_taxi,
              label: 'Cab',
              onTap: () {
                Navigator.pushNamed(context, '/scheduleCD');
              },
            ),
            PreApprovalTile(
              icon: Icons.delivery_dining,
              label: 'Delivery',
              onTap: () {
                Navigator.pushNamed(context, '/scheduleCD');
              },
            ),
            PreApprovalTile(
              icon: Icons.person,
              label: 'Visitor',
              onTap: () {
                Navigator.pushNamed(context, '/scheduleVisitor');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PreApprovalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PreApprovalTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[800]),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: Colors.blueGrey[800],
        ),
      ),
      trailing: Icon(Icons.arrow_forward, color: Colors.blueGrey[800]),
      onTap: onTap,
    );
  }
}
