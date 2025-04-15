import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate/property_details_screen.dart';

class PayingGuestScreen extends StatelessWidget {
  final String category; // Declare the category parameter.

  // Constructor to accept category.
  PayingGuestScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paying Guest Properties"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.green),
            SizedBox(height: 10),
            Text(
              "Here you can find all the details about available paying guest accommodations.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.green),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Property_posts')
                    .where('lookingFor', isEqualTo: "Paying Guest") // Filter by category
                // .orderBy('timestamp', descending: true) // Uncomment if Firestore index is created
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  print("Snapshot Connection State: ${snapshot.connectionState}");
                  print("Has Data: ${snapshot.hasData}");
                  print("Docs Count: ${snapshot.data?.docs.length}");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No properties available"));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var property = snapshot.data!.docs[index];
                      return _buildPropertyCard(context, property);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, QueryDocumentSnapshot property) {
    // Handle missing fields safely to prevent crashes
    String propertyType = property['propertyType'] ?? "Unknown Type";
    String lookingFor = property['lookingFor'] ?? "Unknown";
    String propertyKind = property['propertyKind'] ?? "Unknown";
    String location = property['location'] ?? "Unknown Location";

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.green, width: 2),
      ),
      child: ListTile(
        title: Text(propertyType, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$lookingFor - $propertyKind \nLocation: $location"),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(property: property),
            ),
          );
        },
      ),
    );
  }
}