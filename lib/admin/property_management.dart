import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate/property_details_screen.dart';

class PropertyManagement extends StatefulWidget {
  const PropertyManagement({super.key});

  @override
  State<PropertyManagement> createState() => _PropertyManagementState();
}

class _PropertyManagementState extends State<PropertyManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void approveProperty(String propertyId, Map<String, dynamic> propertyData) async {
    await _firestore.collection('Property_posts').doc(propertyId).set(propertyData);
    await _firestore.collection('Posts_for_approval').doc(propertyId).delete();
  }

  void rejectProperty(String propertyId) async {
    await _firestore.collection('Posts_for_approval').doc(propertyId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Management')),
      body: StreamBuilder(
        stream: _firestore.collection('Posts_for_approval').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No properties pending approval.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final propertyData = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    "${propertyData['propertyType'] ?? 'Unknown'} in ${propertyData['taluka'] ?? 'Unknown'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Status: Pending Approval'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => approveProperty(doc.id, propertyData),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => rejectProperty(doc.id),
                      ),
                    ],
                  ),
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PropertyDetailsScreen(property: doc))
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
