import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:student_dorm_frontend/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<bool> checkIfUserIsAdmin(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();
    final userId = uid;
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

  void _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isAdmin = await checkIfUserIsAdmin(user.uid);
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    _navigateTo('/login');
  }

  void _navigateTo(String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
        backgroundColor: const Color(0xFF0077B6),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Bun venit pe StudentDormSystem!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    if (_isAdmin)
                      buildCard(
                        icon: Icons.admin_panel_settings,
                        text: 'Pagina de administrare',
                        onTap: () => _navigateTo('/admin'),
                      ),
                    if (_isAdmin) const SizedBox(height: 20),
                    if (_isAdmin)
                      buildCard(
                        icon: Icons.announcement,
                        text: 'Feed anunțuri',
                        onTap: () => _navigateTo('/feed'),
                      ),
                    const SizedBox(height: 20),
                    buildCard(
                      icon: Icons.person,
                      text: 'Modifică profilul',
                      onTap: () => _navigateTo('/profile'),
                    ),
                    if (_isAdmin) const SizedBox(height: 20),
                    if (_isAdmin)
                      buildCard(
                        icon: Icons.local_laundry_service,
                        text: 'Rezervă o mașină de spălat',
                        onTap: () => _navigateTo('/booking'),
                      ),
                    if (_isAdmin) const SizedBox(height: 20),
                    if (_isAdmin)
                      buildCard(
                        icon: Icons.list,
                        text: 'Rezervările mele',
                        onTap: () => _navigateTo('/mybookings'),
                      ),
                    if (_isAdmin) const SizedBox(height: 20),
                    if (_isAdmin)
                      buildCard(
                        icon: Icons.report_problem,
                        text: 'Realizează o plângere',
                        onTap: () => _navigateTo('/complaint'),
                      ),
                    const SizedBox(height: 20),
                    buildCard(
                      icon: Icons.logout,
                      text: 'Logout',
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF0077B6)),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
