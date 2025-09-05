import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class PropertyDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot property;

  PropertyDetailsScreen({required this.property});

  String getDisplayValue(dynamic value) {
    if (value == null) return '....';
    final str = value.toString().trim();
    return str.isEmpty ? '....' : str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(property['propertyType'] ?? 'Property'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Overview Header
            Text(
              property['propertyType'] ?? 'N/A',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 8),
            Text(
              property['lookingFor'] ?? 'N/A',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              "Property Kind: ${property['propertyKind'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),

            // Property Details Card
            _buildCard(
              title: "Location Details",
              children: [
                _detailRow(Icons.map, "State", property['state']),
                _detailRow(Icons.location_city, "District", property['district']),
                _detailRow(Icons.business, "Taluka", property['taluka']),
                _detailRow(Icons.location_on, "Specific Location", property['location']),
              ],
            ),

            SizedBox(height: 20),

            // Property info Card
            _buildCard(
              title: "Property Details",
              children: [
                _detailRow(Icons.currency_rupee_rounded, "Price", getDisplayValue(property['propertyPrice'])),
                _detailRow(Icons.location_city, "Area (in sq.ft.)", getDisplayValue(property['propertyArea'])),
                _detailRow(Icons.business, "Floor Number", getDisplayValue(property['propertyFlorN'])),
                _detailRow(Icons.location_on, "Furnishing Status", getDisplayValue(property['FurnishingStatus'])),
                _detailRow(Icons.location_on, "Parking Availability", getDisplayValue(property['parkingAvailability'])),
                _detailRow(Icons.location_on, "Water Supply", getDisplayValue(property['waterSupply'])),
                _detailRow(Icons.location_on, "Available From", getDisplayValue(property['availableFrom'])),
              ],
            ),

            SizedBox(height: 20),

            // Contact Details Card
            _buildCard(
              title: "Contact Details",
              children: [
                _contactRow(Icons.person, "Posted By", property['name']),
                _contactRow(Icons.email, "Email", property['email']),
                _contactRow(Icons.phone, "Contact", property['contact']),
              ],
            ),

            SizedBox(height: 20),

            // Posted Date Card
            _buildCard(
              title: "Posted On",
              children: [
                _detailRow(Icons.access_time, "Date", _formatTimestamp(property['timestamp'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget for building section cards
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.blue,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            Divider(color: Colors.green),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Property Details
  Widget _detailRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 10),
          Text(
            "$title: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Contact Details (Selectable Text)
  Widget _contactRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 10),
          Text(
            "$title: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SelectableText(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // Function to format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime);
  }
}
