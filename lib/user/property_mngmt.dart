import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PropertyMngmt extends StatefulWidget {
  const PropertyMngmt({super.key});

  @override
  State<PropertyMngmt> createState() => _PropertyMngmtState();
}

class _PropertyMngmtState extends State<PropertyMngmt> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> _fetchUserProperties() async {
    String userEmail = _auth.currentUser?.email ?? "";
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Property_posts')
          .where('email', isEqualTo: userEmail)
          .get();
      return snapshot.docs;
    } catch (e) {
      print("Error fetching properties: $e");
      return [];
    }
  }

  Future<void> _deleteProperty(String docId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Property"),
        content: const Text("Are you sure you want to delete this property?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _firestore.collection('Property_posts').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Property deleted successfully")),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Properties"),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchUserProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.real_estate_agent, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No properties posted",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          var properties = snapshot.data!;

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              var property = properties[index];
              String title = property['propertyType'] ?? 'Unknown Type';
              String location = property['location'] ?? 'No Location';
              String propertyKind = property['propertyKind'] ?? 'N/A';
              String lookingFor = property['lookingFor'] ?? 'N/A';
              String docId = property.id;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.red),
                        const SizedBox(width: 5),
                        Text(location, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 5),
                        Text("Type: $propertyKind", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 5),
                        Text("Looking For: $lookingFor", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline,color: Colors.white,),
                        label: const Text("Delete"),
                        onPressed: () => _deleteProperty(docId),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
