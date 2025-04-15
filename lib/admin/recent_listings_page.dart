import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecentListingsPage extends StatefulWidget {
  const RecentListingsPage({super.key});

  @override
  State<RecentListingsPage> createState() => _RecentListingsPageState();
}

class _RecentListingsPageState extends State<RecentListingsPage> {
  List<Map<String, dynamic>> recentListings = [];

  @override
  void initState() {
    super.initState();
    fetchRecentListings();
  }

  Future<void> fetchRecentListings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Property_posts')
          .orderBy('timestamp', descending: true) // Sorting by timestamp (latest first)
          .limit(5) // Fetch latest 5 listings
          .get();

      setState(() {
        recentListings = snapshot.docs.map((doc) {
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
      appBar: AppBar(title: const Text("Recent Listings"),backgroundColor: Colors.white,),
      body: recentListings.isEmpty
          ? const Center(child: Text("No recent listings available"))
          : ListView.builder(
        itemCount: recentListings.length,
        itemBuilder: (context, index) {
          var property = recentListings[index];
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
