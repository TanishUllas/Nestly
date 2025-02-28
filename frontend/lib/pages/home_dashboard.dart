import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
              backgroundColor: Colors.lightBlue[100],
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.blueGrey[800]),
              actions: [
                IconButton(
                  icon: Icon(Icons.account_circle_sharp, size: 52), // Increased size to 32
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
            ),
      body: Container(
        color: Colors.lightBlue[100], // Set background color same as header
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome to\nAnanda Seva Sadana Trust',
                style: TextStyle(
                  fontSize: 36, // Increased font size for welcome text
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10), // Reduced space to bring buttons higher
            // Column for buttons (split into two rows)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Align buttons to the center
                  children: [
                    DashboardButton(
                      label: 'Accept Visitor',
                      onTap: () {
                        Navigator.pushNamed(context, '/acceptVisitor');
                      },
                    ),
                    SizedBox(width: 10),
                    DashboardButton(
                      label: 'Call Guard',
                      onTap: () {
                        Navigator.pushNamed(context, '/callGuard');
                      },
                    ),
                    SizedBox(width: 10),
                    DashboardButton(
                      label: 'Pre - Approval',
                      onTap: () {
                        Navigator.pushNamed(context, '/preApproval');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10), // Reduced space between rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Align buttons to the center
                  children: [
                    DashboardButton(
                      label: 'My Visitors',
                      onTap: () {
                        Navigator.pushNamed(context, '/myVisitors');
                      },
                    ),
                    SizedBox(width: 10),
                    DashboardButton(
                      label: 'SOS',
                      onTap: () {
                        Navigator.pushNamed(context, '/sos');
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Expanded to push footer to the bottom
            Expanded(child: Container()),
            // Footer container
            Container(
              color: Colors.blueGrey[700],
              padding: EdgeInsets.all(12.0), // Reduced padding for smaller footer
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GET IN TOUCH',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Smaller font size
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'anandasevasadana@gmail.com',
                        style: TextStyle(color: Colors.white, fontSize: 12), // Smaller font size
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('+080-4215786', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text('+767829032', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text('+6362543616', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'OUR UNITS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Smaller font size
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'UNIT 1:\n3rd Block, 40, 4th Main Rd, BEML Layout, RR Nagar, Bengaluru, Karnataka 560098',
                    style: TextStyle(color: Colors.white, fontSize: 12), // Smaller font size
                  ),
                  SizedBox(height: 6),
                  Text(
                    'UNIT 2:\n4-15, Vishrutha, Survey No 56, Muryappa Layout, Jawaregowda Nagar, RR Nagar, Bengaluru, Karnataka 560098',
                    style: TextStyle(color: Colors.white, fontSize: 12), // Smaller font size
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DashboardButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32), // Increased padding for bigger buttons
        minimumSize: Size(140, 70), // Set a larger minimum size for the buttons
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18, // Larger font size for better visibility
        ),
      ),
    );
  }
}
