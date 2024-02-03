// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// class ChatPage extends StatefulWidget {
//   const ChatPage({Key? key}) : super(key: key);

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final _messageController = TextEditingController();
//   final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('chats');

//   void _sendMessage() {
//     _messagesRef.push().set({
//       'sender': FirebaseAuth.instance.currentUser?.uid,
//       'text': _messageController.text,
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//     });
//     _messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: _messagesRef.onValue,
//               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 List<Message> messages = [];
//                 Map<dynamic, dynamic> values =
//                     snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
//                 values.forEach((key, value) {
//                   messages.add(Message(
//                     sender: value['sender'],
//                     text: value['text'],
//                     timestamp: value['timestamp'],
//                   ));
//                 });
//                 return ListView.builder(
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) => ListTile(
//                     title: Text(messages[index].text),
//                     subtitle: Text(messages[index].sender),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       labelText: 'Type your message',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Message {
//   final String sender;
//   final String text;
//   final int timestamp;

//   Message({required this.sender, required this.text, required this.timestamp});
// }
