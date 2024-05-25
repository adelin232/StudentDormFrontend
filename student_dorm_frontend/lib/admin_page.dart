import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:student_dorm_frontend/utils.dart';
import 'package:student_dorm_frontend/models.dart';

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

  Future<List<Booking>> fetchBookings() async {
    final response = await http.get(Uri.http(getBackendUrl(), '/api/bookings'));

    if (response.statusCode == 200) {
      List<dynamic> bookingsJson = json.decode(response.body);
      return bookingsJson.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Nu am reușit să aduc rezervările din server.');
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
      body: _buildSelectedPage(),
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
          ListTile(
            title: const Text('Rezervări'),
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildUsersList();
      case 1:
        return _buildComplaintsList();
      case 2:
        return _buildBookingsList();
      default:
        return _buildUsersList();
    }
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

  Widget _buildBookingsList() {
    return FutureBuilder<List<Booking>>(
      future: fetchBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Booking booking = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.book_online),
                  title: Text('Mașina: ${booking.wmNo}'),
                  subtitle: Text('Ora: ${booking.startHour}'),
                ),
              );
            },
          );
        }
      },
    );
  }
}

