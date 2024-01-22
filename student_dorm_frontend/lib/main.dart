import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
          '/home': (_) => const HomePage(),
          // '/dashboard': (_) => const Dashboard(),
          '/booking': (_) => const BookingPage(),
          '/mybookings': (_) => const MyBookingsPage(),
        },
        initialRoute: '/login',
        home: const LoginPage());
  }
}
