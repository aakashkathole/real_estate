import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalPendingPage extends StatefulWidget {
  const ApprovalPendingPage({super.key});

  @override
  State<ApprovalPendingPage> createState() => _ApprovalPendingPageState();
}

class _ApprovalPendingPageState extends State<ApprovalPendingPage> {
  List<Map<String, dynamic>> approvalpending = [];

  @override
  void initState() {
    super.initState();
    fetchRecentListings();
  }

  Future<void> fetchRecentListings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Posts_for_approval')
          .orderBy('timestamp', descending: true) // Sorting by timestamp (latest first)
          .get();

      setState(() {
        approvalpending = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'] ?? 'Unknown Owner',
            'district': doc['district'] ?? 'Unknown City',
            'location': doc['location'] ?? 'Unknown Location',
            'contact': doc['contact'] ?? 'No Contact',
            'email': doc['email'] ?? 'No Email',
            'lookingFor': doc['lookingFor'] ?? 'N/A',
            'propertyKind': doc['propertyKind'] ?? 'N/A',
            'propertyType': doc['propertyType'] ?? 'N/A',
            'timestamp': (doc['timestamp'] as Timestamp).toDate(),
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching recent listings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Pending Property Approval"),backgroundColor: Colors.white,),
      body: approvalpending.isEmpty
          ? const Center(child: Text("No property available"))
          : ListView.builder(
        itemCount: approvalpending.length,
        itemBuilder: (context, index) {
          var property = approvalpending[index];
          return Card(
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blue, width: 1.0),
          ),
            shadowColor: Colors.blue,
            color: Colors.white,
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text("${property['propertyType']} in ${property['district']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location: ${property['location']}"),
                  Text("Owner: ${property['name']}"),
                  Text("Contact: ${property['contact']}"),
                  Text("Looking to: ${property['lookingFor']}"),
                  Text("Kind: ${property['propertyKind']}"),
                  Text("Email: ${property['email']}"),
                  Text("Posted: ${property['timestamp']}"),
                ],
              ),
              trailing: const Icon(Icons.info_outline,color: Colors.blue,),
              onTap: () {
                // Navigate to a detailed page if needed
              },
            ),
          );
        },
      ),
    );
  }
}
