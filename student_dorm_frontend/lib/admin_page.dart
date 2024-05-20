import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:student_dorm_frontend/utils.dart';

class User {
  final String id;
  final String userId;
  final String name;
  final String room;
  final String phone;
  final String email;

  User(
      {required this.id,
      required this.userId,
      required this.name,
      required this.room,
      required this.phone,
      required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      userId: json['userId'],
      name: json['name'],
      room: json['room'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class Complaint {
  final String id;
  final String userId;
  final String subject;
  final String description;

  Complaint(
      {required this.id,
      required this.userId,
      required this.subject,
      required this.description});

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'].toString(),
      userId: json['userId'],
      subject: json['subject'],
      description: json['description'],
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<List<User>> fetchUsers() async {
    final response =
        await http.get(Uri.http(getBackendUrl(), '/api/students'));

    if (response.statusCode == 200) {
      List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Nu am reușit să aduc utilizatorii din server.');
    }
  }

  Future<List<Complaint>> fetchComplaints() async {
    final response = await http.get(Uri.http(getBackendUrl(), '/api/complaints'));

    if (response.statusCode == 200) {
      List<dynamic> complaintsJson = json.decode(response.body);
      return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
    } else {
      throw Exception('Nu am reușit să aduc plângerile din server.');
    }
  }

  Future<void> _navigateTo(String routeName) async {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina de administrator'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              _navigateTo('/home');
            },
            tooltip: 'Home Page',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _selectedIndex == 0 ? _buildUsersList() : _buildComplaintsList(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Meniu Admin',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: const Text('Studenți'),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Plângeri'),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return FutureBuilder<List<User>>(
      future: fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              User user = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildComplaintsList() {
    return FutureBuilder<List<Complaint>>(
      future: fetchComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Complaint complaint = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.report_problem),
                  title: Text(complaint.subject),
                  subtitle: Text(complaint.description),
                ),
              );
            },
          );
        }
      },
    );
  }
}
