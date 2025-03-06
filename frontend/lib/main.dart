import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Required for async operations

  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt("userId"); // ✅ Get userId from storage
  print("🟢 Retrieved userId: $userId");

  runApp(MyApp(userId: userId));
}

class MyApp extends StatelessWidget {
  final int? userId;

  const MyApp({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ananda Seva Sadana Trust',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: userId != null ? '/first_page' : '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => FirstPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());
          case '/home_dashboard':
            final int? passedUserId = settings.arguments as int?;
            final int finalUserId = passedUserId ?? userId ?? 0;
            return MaterialPageRoute(builder: (_) => HomeDashboard(userId: finalUserId));
          case '/profile':
            final int? passedUserId = settings.arguments as int?;
            return MaterialPageRoute(builder: (_) => ProfilePage(userId: passedUserId ?? 0));
          case '/sos':
            return MaterialPageRoute(builder: (_) => SOSPage());
          case '/callGuard':
            return MaterialPageRoute(builder: (_) => CallGuardPage());
          case '/scheduleVisitor':
            return MaterialPageRoute(builder: (_) => ScheduleVisitorPage());
          case '/acceptVisitor':
            return MaterialPageRoute(builder: (_) => AcceptVisitorPage());
          case '/preApproval':
            return MaterialPageRoute(builder: (_) => PreApprovalPage());
          case '/myVisitors':
            return MaterialPageRoute(builder: (_) => MyVisitorsPage());
          case '/scheduleCD':
            return MaterialPageRoute(builder: (_) => ScheduleCDPage());
          default:
            return MaterialPageRoute(builder: (_) => FirstPage());
        }
      },
    );
  }
}
