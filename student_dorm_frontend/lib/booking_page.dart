import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _wmNoController = TextEditingController();
  final _startHourController = TextEditingController();
  String selectedMachine = '1';
  List<String> machines = ['1', '2', '3'];
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _book() async {
    final numarMasina =
        (_wmNoController.text.trim() == '') ? '1' : _wmNoController.text.trim();
    final oraIncepere = (_startHourController.text.trim() == '')
        ? _formatTimeOfDay(TimeOfDay.now())
        : _startHourController.text.trim();
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showErrorSnackBar('Utilizatorul nu este logat.');
      return;
    }

    var url = Uri.parse('http://localhost:8080/api/bookings/create');
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
      showErrorSnackBar('Eroare la rezervare: ${response.body}');
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _startHourController.text = _formatTimeOfDay(picked);
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat("HH:mm");
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      appBar: AppBar(
        title: const Text('Rezervări pentru mașinile de spălat'),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(250.0),
                padding: const EdgeInsets.all(50.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF6495ED),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    SizedBox(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Număr mașină',
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMachine,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMachine = newValue!;
                                _wmNoController.text = newValue;
                              });
                            },
                            items: machines
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      child: GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(
                                text: selectedTime.format(context)),
                            decoration: const InputDecoration(
                              labelText: 'Oră începere rezervare',
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        _book();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color(0xFFB6D0E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Text(
                        'Rezervă mașina',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        _navigateTo('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color(0xFFB6D0E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Text(
                        'Înapoi la Home Page',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
