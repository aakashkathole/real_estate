import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserAgentManagement extends StatefulWidget {
  const UserAgentManagement({super.key});

  @override
  State<UserAgentManagement> createState() => _UserAgentManagementState();
}

class _UserAgentManagementState extends State<UserAgentManagement> {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');

  void _editUser(String userId, String name, String email, String role, String phone) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController roleController = TextEditingController(text: role);
    TextEditingController phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Update User Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: roleController, decoration: InputDecoration(labelText: 'Role')),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                usersCollection.doc(userId).update({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': roleController.text,
                  'phone': phoneController.text,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) {
    usersCollection.doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("User Management"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: usersCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No users found"));
          }

          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                shadowColor: Colors.blue,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue, width: 1.0),
                ),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Text("Email: ${data['email']}"),
                      Text("Phone: ${data['phone']} \t                    \t Role: ${data['role']}"),
                      Divider(color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _editUser(doc.id, data['name'], data['email'], data['role'], data['phone']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(doc.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
