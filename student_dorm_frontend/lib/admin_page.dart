import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    final response = await http.get(Uri.http(getBackendUrl(), '/api/students'));

    if (response.statusCode == 200) {
      List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Nu am reușit să aduc utilizatorii din server.');
    }
  }

  Future<List<Complaint>> fetchComplaints() async {
    final response =
        await http.get(Uri.http(getBackendUrl(), '/api/complaints'));

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
      List<Booking> bookings =
          bookingsJson.map((json) => Booking.fromJson(json)).toList();

      // Sort bookings by wmNo and startHour
      bookings.sort((a, b) {
        int wmNoComparison = a.wmNo.compareTo(b.wmNo);
        if (wmNoComparison != 0) return wmNoComparison;
        return a.startHour.compareTo(b.startHour);
      });

      return bookings;
    } else {
      throw Exception('Nu am reușit să aduc rezervările din server.');
    }
  }

  Future<List<Announcement>> fetchAnnouncements() async {
    final response =
        await http.get(Uri.http(getBackendUrl(), '/api/announcements'));

    if (response.statusCode == 200) {
      List<dynamic> announcementsJson = json.decode(response.body);
      return announcementsJson
          .map((json) => Announcement.fromJson(json))
          .toList();
    } else {
      throw Exception('Nu am reușit să aduc anunțurile din server.');
    }
  }

  Future<void> _navigateTo(String routeName) async {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator'),
        backgroundColor: const Color(0xFF0077B6),
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
      drawer: _buildDrawer(),
      body: _buildSelectedPage(),
      floatingActionButton: _selectedIndex == 3
          ? FloatingActionButton(
              onPressed: () => _showAnnouncementDialog(),
              tooltip: 'Adaugă anunț',
              backgroundColor: const Color(0xFF0077B6),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF0077B6),
            ),
            child: Text(
              'Meniu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Studenți'),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Plângeri'),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_online),
            title: const Text('Rezervări'),
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Anunțuri'),
            onTap: () {
              setState(() => _selectedIndex = 3);
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
      case 3:
        return _buildAnnouncementsList();
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.report_problem),
                  title: Text(complaint.subject),
                  subtitle: Text(complaint.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await deleteComplaint(complaint.id);
                      setState(() {});
                    },
                  ),
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
          if (snapshot.hasData) {
            var bookings = snapshot.data!;
            var bookingsByMachine = <String, List<Booking>>{};

            for (var booking in bookings) {
              if (!bookingsByMachine.containsKey(booking.wmNo)) {
                bookingsByMachine[booking.wmNo] = [];
              }
              bookingsByMachine[booking.wmNo]!.add(booking);
            }

            return ListView(
              children: bookingsByMachine.entries.map((entry) {
                var machineNumber = entry.key;
                var machineBookings = entry.value;

                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ExpansionTile(
                    leading: const Icon(Icons.book_online),
                    title: Text('Mașina: $machineNumber'),
                    children: machineBookings.map((booking) {
                      return ListTile(
                        title: Text('Ora: ${booking.startHour}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await deleteBooking(booking.id);
                            setState(() {});
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('Nu există rezervări.'));
          }
        }
      },
    );
  }

  void _showAnnouncementDialog([Announcement? announcement]) {
    final titleController = TextEditingController(
      text: announcement?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: announcement?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(announcement == null ? 'Adaugă anunț' : 'Editează anunț'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titlu'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descriere'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final formattedDate =
                    DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);

                final newAnnouncement = Announcement(
                  id: announcement?.id ?? '',
                  title: titleController.text,
                  description: descriptionController.text,
                  date: announcement?.date ?? formattedDate,
                );

                if (announcement == null) {
                  await createAnnouncement(newAnnouncement);
                } else {
                  await updateAnnouncement(newAnnouncement);
                }

                setState(() {});
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Salvează'),
            ),
          ],
        );
      },
    );
  }

  Future<void> createAnnouncement(Announcement announcement) async {
    final response = await http.post(
      Uri.http(getBackendUrl(), '/api/announcements'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'title': announcement.title,
        'description': announcement.description,
        'date': announcement.date,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Nu am reușit să creez anunțul.');
    }
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    final response = await http.put(
      Uri.http(getBackendUrl(), '/api/announcements/${announcement.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'title': announcement.title,
        'description': announcement.description,
        'date': announcement.date,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Nu am reușit să actualizez anunțul.');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    final response = await http.delete(
      Uri.http(getBackendUrl(), '/api/announcements/$id'),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception(
          'Nu am reușit să șterg anunțul. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteBooking(String id) async {
    final response = await http.delete(
      Uri.http(getBackendUrl(), '/api/bookings/$id'),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception(
          'Nu am reușit să șterg rezervarea. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteComplaint(String id) async {
    final response = await http.delete(
      Uri.http(getBackendUrl(), '/api/complaints/$id'),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception(
          'Nu am reușit să șterg plângerea. Status code: ${response.statusCode}');
    }
  }

  Widget _buildAnnouncementsList() {
    return FutureBuilder<List<Announcement>>(
      future: fetchAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Announcement announcement = snapshot.data![index];
              DateTime date = DateTime.parse(announcement.date);
              String formattedDate =
                  DateFormat('dd/MM/yyyy, HH:mm').format(date);

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.announcement),
                  title: Text(announcement.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.description),
                      const SizedBox(height: 4),
                      Text(formattedDate),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAnnouncementDialog(announcement),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await deleteAnnouncement(announcement.id);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
