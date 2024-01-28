import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'profile_page.dart';
import 'complaint_page.dart';
import 'my_bookings_page.dart';
import 'booking_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class AuthGuard extends StatelessWidget {
  final Widget protectedPage;
  const AuthGuard({Key? key, required this.protectedPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return protectedPage;
    } else {
      return const LoginPage();
    }
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'StudentDormSystem',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/login': (_) => const LoginPage(),
          '/signup': (_) => const SignUpPage(),
          '/home': (_) => const AuthGuard(protectedPage: HomePage()),
          // '/dashboard': (_) => const Dashboard(),
          '/booking': (_) => const AuthGuard(protectedPage: BookingPage()),
          '/mybookings': (_) =>
              const AuthGuard(protectedPage: MyBookingsPage()),
          '/complaint': (_) => const AuthGuard(protectedPage: ComplaintPage()),
          '/profile': (_) => const AuthGuard(protectedPage: ProfilePage()),
        },
        initialRoute: '/login',
        home: const LoginPage());
  }
}
