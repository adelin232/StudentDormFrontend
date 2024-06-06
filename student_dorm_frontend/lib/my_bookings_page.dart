import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:student_dorm_frontend/utils.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<dynamic> myBookings = [];

  @override
  void initState() {
    super.initState();
    if (user != null) {
      fetchMyBookings();
    }
  }

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> fetchMyBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showErrorSnackBar('Utilizatorul nu este logat.');
      return;
    }

    final url = Uri.http(getBackendUrl(), '/api/bookings/${user.uid}');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await user.getIdToken()}",
        },
      );

      if (response.statusCode == 200) {
        final bookingData = json.decode(response.body);
        setState(() {
          myBookings = bookingData;
        });
      } else {
        showErrorSnackBar('Eroare la preluarea rezervărilor: ${response.body}');
      }
    } catch (e) {
      showErrorSnackBar('Eroare la preluarea rezervărilor: $e');
    }
  }

  Future<void> _navigateTo(String routeName) async {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      appBar: AppBar(
        title: const Text('Rezervările mele'),
        backgroundColor: const Color(0xFF0077B6),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              _navigateTo('/home');
            },
            tooltip: 'Homepage',
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Trebuie să fii logat pentru a vedea rezervările.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : myBookings.isEmpty
              ? const Center(
                  child: Text(
                    'Nu există rezervări.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: myBookings.length,
                  itemBuilder: (context, index) {
                    var booking = myBookings[index];
                    String wmNo = booking['wmNo'] ?? 'N/A';
                    String startHour = booking['startHour'] ?? 'N/A';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: const Icon(Icons.local_laundry_service,
                            size: 40, color: Color(0xFF0077B6)),
                        title: Text(
                          'Mașină: $wmNo',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Ora începerii: $startHour',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
