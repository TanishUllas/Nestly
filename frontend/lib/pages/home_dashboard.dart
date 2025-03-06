import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  final int userId; // ✅ Added userId parameter

  const HomeDashboard({super.key, required this.userId}); // ✅ Require userId

  @override
  Widget build(BuildContext context) {
    print("🟢 User ID received in HomeDashboard: $userId");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blueGrey[800]),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_sharp, size: 52),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: userId, // ✅ Ensure userId is passed correctly
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlue[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome to\nAnanda Seva Sadana Trust',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DashboardButton(label: 'Accept Visitor', route: '/acceptVisitor', userId: userId),
                    const SizedBox(width: 10),
                    DashboardButton(label: 'Call Guard', route: '/callGuard', userId: userId),
                    const SizedBox(width: 10),
                    DashboardButton(label: 'Pre-Approval', route: '/preApproval', userId: userId),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DashboardButton(label: 'My Visitors', route: '/myVisitors', userId: userId),
                    const SizedBox(width: 10),
                    DashboardButton(label: 'SOS', route: '/sos', userId: userId),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Footer(),
          ],
        ),
      ),
    );
  }
}

// ✅ **Dashboard Button Widget**
class DashboardButton extends StatelessWidget {
  final String label;
  final String route;
  final int userId;

  const DashboardButton({super.key, required this.label, required this.route, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          route,
          arguments: userId, // ✅ Ensure userId is passed correctly
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        minimumSize: const Size(140, 70),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}

// ✅ **Footer Widget**
class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[700],
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FooterSectionTitle(title: 'GET IN TOUCH'),
          const FooterRow(icon: Icons.email, text: 'anandasevasadana@gmail.com'),
          const FooterRow(icon: Icons.phone, text: '+080-4215786\n+767829032\n+6362543616'),
          const SizedBox(height: 10),
          const FooterSectionTitle(title: 'OUR UNITS'),
          const FooterText(
            text: 'UNIT 1:\n3rd Block, 40, 4th Main Rd, BEML Layout, RR Nagar, Bengaluru, Karnataka 560098',
          ),
          const SizedBox(height: 6),
          const FooterText(
            text: 'UNIT 2:\n4-15, Vishrutha, Survey No 56, Muryappa Layout, Jawaregowda Nagar, RR Nagar, Bengaluru, Karnataka 560098',
          ),
        ],
      ),
    );
  }
}

// ✅ **Footer Section Title**
class FooterSectionTitle extends StatelessWidget {
  final String title;
  const FooterSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}

// ✅ **Footer Row (Icon + Text)**
class FooterRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const FooterRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ✅ **Footer Text**
class FooterText extends StatelessWidget {
  final String text;
  const FooterText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }
}
