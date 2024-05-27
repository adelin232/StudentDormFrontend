import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:student_dorm_frontend/feed_page.dart';
import 'package:student_dorm_frontend/utils.dart';
// import 'chat_page.dart';
// import 'dart:convert';
import 'admin_page.dart';
import 'profile_page.dart';
import 'complaint_page.dart';
import 'my_bookings_page.dart';
import 'booking_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAD0ivs9-iSH13NyT4c7P-gaXBRjo24rMs',
      appId: '1:20795749884:ios:a8c2eb3829463acd4bae79',
      messagingSenderId: '20795749884',
      projectId: 'studentdormplatform',
      databaseURL: '',
    ),
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

class AdminPageProtection extends StatelessWidget {
  final Widget child;

  const AdminPageProtection({Key? key, required this.child}) : super(key: key);

  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();
    final userId = user.uid;
    // final uri = Uri.parse('${getBackendUrl()}/admin/check-admin')
    //     .replace(queryParameters: {'userId': userId});
    final uri =
        Uri.http(getBackendUrl(), '/admin/check-admin', {'userId': userId});
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!) {
            return child;
          } else {
            Future.microtask(
                () => Navigator.of(context).pushReplacementNamed('/home'));
            return const Scaffold(
              body: Center(
                child: Text(
                    'Acces interzis. Redirecționare către pagina principală...'),
              ),
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
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
          '/admin': (_) => const AuthGuard(
                  protectedPage: AdminPageProtection(
                child: AdminPage(),
              )),
          // '/chat': (_) => const ChatPage(),
          '/feed': (context) => const AuthGuard(protectedPage: FeedPage()),
        },
        initialRoute: '/login',
        home: const LoginPage());
  }
}
