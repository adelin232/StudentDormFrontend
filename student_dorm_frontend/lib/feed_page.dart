import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:student_dorm_frontend/utils.dart';
import 'package:student_dorm_frontend/models.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
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
        title: const Text('Feed anunțuri'),
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
      body: _buildAnnouncementsList(),
    );
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
                ),
              );
            },
          );
        }
      },
    );
  }
}
