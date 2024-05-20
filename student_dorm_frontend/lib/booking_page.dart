import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:student_dorm_frontend/utils.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _wmNoController = TextEditingController();
  String selectedMachine = '1';
  List<String> machines = ['1', '2', '3'];
  List<Map<String, dynamic>> availableHours = [];
  String selectedHour = '';

  @override
  void initState() {
    super.initState();
    fetchAvailableHours();
  }

  Future<void> fetchAvailableHours() async {
    try {
      var url = Uri.http(getBackendUrl(), '/api/bookings/available-hours',
          {'wmNo': selectedMachine});
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          availableHours =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showErrorSnackBar('Eroare la preluarea orelor: ${response.body}');
      }
    } catch (e) {
      showErrorSnackBar('Eroare la preluarea orelor: $e');
    }
  }

  Future<void> _book() async {
    final numarMasina =
        (_wmNoController.text.trim() == '') ? '1' : _wmNoController.text.trim();
    final oraIncepere = selectedHour;
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showErrorSnackBar('Utilizatorul nu este logat.');
      return;
    }

    var url = Uri.http(getBackendUrl(), '/api/bookings/create');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'userId': userId,
        'wmNo': numarMasina,
        'startHour': oraIncepere,
      }),
    );

    if (response.statusCode == 200) {
      _navigateTo('/home');
    } else {
      // showErrorSnackBar('Eroare la rezervare: ${response.body}');
      showErrorSnackBar('Eroare la rezervare: Aveți deja o rezervare.');
    }
  }

  Future<void> _navigateTo(String routeName) async {
    Navigator.pushReplacementNamed(context, routeName);
  }

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double widthFactor =
        screenSize.width > 800 ? 0.5 : (screenSize.width > 600 ? 0.75 : 0.95);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      appBar: AppBar(
        title: const Text('Rezervări pentru mașinile de spălat'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Rezervă o mașină de spălat',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: buildDropdownButton(),
                ),
                const SizedBox(height: 20.0),
                buildAvailableHours(),
                const SizedBox(height: 20.0),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: ElevatedButton(
                    onPressed: _book,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFB6D0E2),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: const Text(
                      'Rezervă mașina',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: ElevatedButton(
                    onPressed: () => _navigateTo('/home'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFB6D0E2),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: const Text(
                      'Înapoi la Home Page',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: selectedMachine,
      decoration: const InputDecoration(
        labelText: 'Număr mașină',
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
      ),
      onChanged: (String? newValue) {
        setState(() {
          selectedMachine = newValue!;
          _wmNoController.text = newValue;
          fetchAvailableHours();
        });
      },
      items: machines.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget buildAvailableHours() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Ora începere rezervare',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: availableHours.map<Widget>((hour) {
                String time = hour['time'];
                bool reserved = hour['reserved'];
                String tooltipMessage = '';
                if (reserved) {
                  tooltipMessage =
                      'Rezervat de: ${hour['userName']}, Telefon: ${hour['userPhone']}';
                }
                return Tooltip(
                  message: tooltipMessage,
                  child: ElevatedButton(
                    onPressed: reserved
                        ? null
                        : () {
                            setState(() {
                              selectedHour = time;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: reserved
                          ? Colors.red
                          : (selectedHour == time ? Colors.blue : Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
