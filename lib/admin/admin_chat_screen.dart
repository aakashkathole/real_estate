import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminChatScreen extends StatelessWidget {
  final String userEmail;

  AdminChatScreen({required this.userEmail});

  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      DocumentReference chatRef = _firestore.collection('Messages').doc(userEmail);

      await chatRef.set({
        'userEmail': userEmail,
      }, SetOptions(merge: true));

      await chatRef.update({
        'messages': FieldValue.arrayUnion([
          {
            'sender': 'admin',
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Chat with $userEmail"),backgroundColor: Colors.white,),
      body: Column(
        children: [
          Divider(color: Colors.blue),
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
                    bool isAdmin = msg['sender'] == 'admin';

                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg['message'], style: TextStyle(color: isAdmin ? Colors.white : Colors.black)),

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
                  icon: Icon(Icons.send, color: Colors.green),
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
