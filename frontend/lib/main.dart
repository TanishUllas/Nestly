import 'package:flutter/material.dart';
import 'pages/first_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_dashboard.dart';
import 'pages/sos_page.dart';  
import 'pages/call_guard_page.dart';  
import 'pages/schedule_visitor_page.dart';
import 'pages/accept_visitor_page.dart';
import 'pages/profile_page.dart';
import 'pages/pre_approval_page.dart';
import 'pages/my_visitors_page.dart';
import 'pages/schedule_cd_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ananda Seva Sadana Trust',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FirstPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home_dashboard': (context) => HomeDashboard(),
        '/sos': (context) => SOSPage(),
        '/callGuard': (context) => CallGuardPage(),
        '/scheduleVisitor': (context) => ScheduleVisitorPage(),
        '/profile': (context) => ProfilePage(),
        '/acceptVisitor': (context) => AcceptVisitorPage(),
        '/preApproval': (context) => PreApprovalPage(),
        '/myVisitors': (context) => MyVisitorsPage(),
        '/scheduleCD': (context) => ScheduleCDPage(),
      },
    );
  }
}
