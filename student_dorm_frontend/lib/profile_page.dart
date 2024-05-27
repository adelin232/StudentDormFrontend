import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:student_dorm_frontend/utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final response = await http.get(
        Uri.http(
            getBackendUrl(), '/api/students/profile', {'userId': user.uid}),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await user.getIdToken()}",
        },
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        setState(() {
          _nameController.text = profileData['name'] ?? '';
          _roomController.text = profileData['room'] ?? '';
          _phoneController.text = profileData['phone'] ?? '';
        });
      } else {
        showErrorSnackBar('Eroare la încărcarea profilului: ${response.body}');
      }
    }
  }

  Future<void> _navigateTo(String routeName) async {
    Navigator.pushReplacementNamed(context, routeName);
  }

  Future<void> _createStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      var email = user.email;
      final response = await http.put(
        Uri.http(getBackendUrl(), '/api/students/create'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await user.getIdToken()}",
        },
        body: jsonEncode({
          'userId': user.uid,
          'name': _nameController.text,
          'room': _roomController.text,
          'phone': _phoneController.text,
          'email': email,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _navigateTo('/home');
      } else {
        showErrorSnackBar('Eroare la salvarea profilului: ${response.body}');
      }
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double widthFactor =
        screenSize.width > 800 ? 0.5 : (screenSize.width > 600 ? 0.75 : 0.95);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      appBar: AppBar(
        title: const Text('Profil student'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            'Modificare profil',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),
                          buildTextField(_nameController, 'Nume'),
                          const SizedBox(height: 20.0),
                          buildTextField(_roomController, 'Cameră'),
                          const SizedBox(height: 20.0),
                          buildTextField(_phoneController, 'Telefon'),
                          const SizedBox(height: 20.0),
                          FractionallySizedBox(
                            widthFactor: widthFactor,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _createStudentProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: const Color(0xFFB6D0E2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                              ),
                              child: const Text(
                                'Salvează profil',
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
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vă rugăm să introduceți $label';
          }
          return null;
        },
      ),
    );
  }
}
