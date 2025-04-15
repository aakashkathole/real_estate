import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserChatScreen extends StatefulWidget {
  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    String userEmail = _auth.currentUser!.email!;
    String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      DocumentReference chatRef = _firestore.collection('Messages').doc(userEmail);

      // Ensure the document exists before adding messages
      await chatRef.set({
        'userEmail': userEmail,
      }, SetOptions(merge: true));

      await chatRef.update({
        'messages': FieldValue.arrayUnion([
          {
            'sender': 'user',
            'message': message,
            'timestamp': Timestamp.now(),
          }
        ])
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    String userEmail = _auth.currentUser!.email!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Chat with Admin'),backgroundColor: Colors.white,),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('Messages').doc(userEmail).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text("No messages yet."));
                }

                List messages = snapshot.data!['messages'];

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index];
                    bool isUser = msg['sender'] == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg['message'], style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
