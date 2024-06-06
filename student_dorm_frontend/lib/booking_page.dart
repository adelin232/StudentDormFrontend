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
    if (selectedHour.isEmpty) {
      showErrorSnackBar('Vă rugăm să selectați o oră pentru rezervare.');
      return;
    }

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
      showErrorSnackBar('Eroare: Aveți deja o rezervare la această mașină.');
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

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHour = '';
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FFFF),
        appBar: AppBar(
          title: const Text('Rezervări de mașini de spălat'),
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
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
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
                    ],
                  ),
                ),
              ),
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

  void _showReservationInfo(String name, String phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rezervare făcută de:'),
          content: Text('Nume: $name\nTelefon: $phone'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildAvailableHours() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (availableHours.isNotEmpty) ...[
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
            ],
            if (availableHours.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Nu se mai pot rezerva mașini de spălat la această oră.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: availableHours.map<Widget>((hour) {
                String time = hour['time'];
                bool reserved = hour['reserved'];
                hour['userName'] = hour['userName'] ?? '';
                hour['userPhone'] = hour['userPhone'] ?? '';
                return GestureDetector(
                  onTap: reserved
                      ? () => _showReservationInfo(
                          hour['userName'], hour['userPhone'])
                      : () {
                          setState(() {
                            selectedHour = time;
                          });
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: reserved
                          ? Colors.red
                          : (selectedHour == time ? Colors.blue : Colors.green),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        time,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
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
