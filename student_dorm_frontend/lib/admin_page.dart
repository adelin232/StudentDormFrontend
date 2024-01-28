// import 'package:flutter/material.dart';

// class AdminPage extends StatefulWidget {
//   const AdminPage({Key? key}) : super(key: key);

//   @override
//   State<AdminPage> createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   late Future<List<User>> futureUsers;
//   late Future<List<Complaint>> futureComplaints;

//   @override
//   void initState() {
//     super.initState();
//     futureUsers = fetchUsers();
//     futureComplaints = fetchComplaints();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             FutureBuilder<List<User>>(
//               future: futureUsers,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(snapshot.data![index].name),
//                         subtitle: Text(snapshot.data![index].email),
//                       );
//                     },
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text("${snapshot.error}");
//                 }
//                 return CircularProgressIndicator();
//               },
//             ),
//             FutureBuilder<List<Complaint>>(
//               future: futureComplaints,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(
//                             'Plângere de la user ID: ${snapshot.data![index].userId}'),
//                         subtitle: Text(snapshot.data![index].description),
//                       );
//                     },
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text("${snapshot.error}");
//                 }
//                 return const CircularProgressIndicator();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
