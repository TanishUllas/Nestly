import 'package:flutter/material.dart';

class PreApprovalPage extends StatelessWidget {
  final int userId; // ✅ Require userId

  const PreApprovalPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text(
          'Pre Approval',
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
        child: ListView(
          children: [
            PreApprovalTile(
              icon: Icons.local_taxi,
              label: 'Cab',
              userId: userId, // ✅ Pass userId when navigating
              route: '/scheduleCD',
            ),
            PreApprovalTile(
              icon: Icons.delivery_dining,
              label: 'Delivery',
              userId: userId, // ✅ Pass userId when navigating
              route: '/scheduleCD',
            ),
            PreApprovalTile(
              icon: Icons.person,
              label: 'Visitor',
              userId: userId, // ✅ Pass userId when navigating
              route: '/scheduleVisitor',
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ **PreApprovalTile (Fixed Colors Issue)**
class PreApprovalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final int userId; // ✅ Require userId

  const PreApprovalTile({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.userId, // ✅ Accept userId
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[800]), // ✅ No `const` here
      title: Text(
        label,
        style: TextStyle( // ✅ Removed `const`
          fontSize: 18,
          color: Colors.blueGrey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(Icons.arrow_forward, color: Colors.blueGrey[800]), // ✅ No `const` here
      onTap: () {
        Navigator.pushNamed(
          context,
          route,
          arguments: userId, // ✅ Pass userId to the next page
        );
      },
    );
  }
}
