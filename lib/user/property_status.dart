import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PropertyStatus extends StatefulWidget {
  const PropertyStatus({super.key});

  @override
  State<PropertyStatus> createState() => _PropertyStatusState();
}

class _PropertyStatusState extends State<PropertyStatus> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  void _getUserEmail() {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown Date";
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    if (userEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Property Approval Pending",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Posts_for_approval')
            .where('email', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No pending properties found.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            );
          }

          var properties = snapshot.data!.docs;

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              var property = properties[index];
              var data = property.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.blue, width: 1.0),
                ),
                shadowColor: Colors.blue,
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['propertyType'] ?? 'No Type',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "📍 ${data['location'] ?? 'No Location'}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "🏡 ${data['propertyKind'] ?? 'Unknown'} | ${data['lookingFor'] ?? 'Unknown'}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "🕒 Posted on: ${formatTimestamp(data['timestamp'])}",
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.green,),
                      Text(
                        "🗺️ ${data['taluka']}, ${data['district']}, ${data['state']}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
