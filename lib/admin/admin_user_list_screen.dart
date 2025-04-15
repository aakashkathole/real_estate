import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_chat_screen.dart';

class AdminUserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Users List"),backgroundColor: Colors.white,),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(), // Fetch all users
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String userEmail = user['email']; // Assuming 'Users' collection stores emails

              return ListTile(
                title: Text(userEmail),
                trailing: Icon(Icons.chat),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminChatScreen(userEmail: userEmail)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
