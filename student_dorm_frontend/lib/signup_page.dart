import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:student_dorm_frontend/utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roomController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  void _checkLoginState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Future.microtask(() => _navigateTo('/home'));
    }
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _createStudentProfile(userCredential.user);
      _navigateTo('/login');
    } catch (e) {
      showErrorSnackBar('Eroare la înregistrare: $e');
    }
  }

  Future<void> _createStudentProfile(User? user) async {
    if (user != null) {
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

      if (response.statusCode != 201) {
        showErrorSnackBar('Eroare la crearea profilului: ${response.body}');
      }
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
    double widthFactor = screenSize.width > 600 ? 1.2 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0077B6),
        title: const Text('Înregistrare'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFFF),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Înregistrare',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),
                          buildTextField(_emailController, _emailFocusNode,
                              'E-mail', AutofillHints.email),
                          const SizedBox(height: 20.0),
                          buildTextField(
                              _passwordController,
                              _passwordFocusNode,
                              'Parola',
                              AutofillHints.newPassword,
                              obscureText: true),
                          const SizedBox(height: 20.0),
                          buildTextField(_nameController, FocusNode(), 'Nume',
                              AutofillHints.name),
                          const SizedBox(height: 20.0),
                          buildTextField(_phoneController, FocusNode(),
                              'Telefon', AutofillHints.telephoneNumber),
                          const SizedBox(height: 20.0),
                          buildTextField(_roomController, FocusNode(), 'Cameră',
                              AutofillHints.addressCity),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF0077B6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            child: const Text(
                              'Înregistrare',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () => _navigateTo('/login'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF0077B6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            child: const Text(
                              'Aveți deja un cont? Conectați-vă',
                              style: TextStyle(
                                fontSize: 16.0,
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
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, FocusNode focusNode,
      String label, String autofillHint,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction:
          (label == 'E-mail') ? TextInputAction.next : TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      onFieldSubmitted: (_) {
        (label == 'E-mail')
            ? FocusScope.of(context).requestFocus(_passwordFocusNode)
            : _signUp();
      },
      obscureText: obscureText,
      autocorrect: false,
      autofillHints: [autofillHint],
    );
  }
}
