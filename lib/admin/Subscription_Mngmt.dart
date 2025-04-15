import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubscriptionMngmt extends StatefulWidget {
  const SubscriptionMngmt({super.key});

  @override
  State<SubscriptionMngmt> createState() => _SubscriptionManagementState();
}

class _SubscriptionManagementState extends State<SubscriptionMngmt> {
  final CollectionReference subscriptionsCollection =
  FirebaseFirestore.instance.collection('Subscriptions');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

  Stream<QuerySnapshot>? _subscriptionStream;

  @override
  void initState() {
    super.initState();
    _subscriptionStream = subscriptionsCollection.snapshots();
  }

  // Refresh data
  void refreshData() {
    setState(() {
      _subscriptionStream = subscriptionsCollection.snapshots();
    });
  }

  // Function to update subscription details
  void _editStatus(String userId, String? currentStatus) {
    TextEditingController statusController =
    TextEditingController(text: currentStatus ?? "");

    showDialog(
      context: context,
      builder: (context) {
        String? selectedSubscriptionType;

        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Update Subscription"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: statusController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Subscription Price'),
                  ),
                  Text("(Enter subscription amount)"),
                  DropdownButtonFormField<String>(
                    value: selectedSubscriptionType,
                    dropdownColor: Colors.white,
                    items: [
                      DropdownMenuItem(
                          value: "semi-annual",
                          child: Text("Semi-Annual (6 months)")),
                      DropdownMenuItem(
                          value: "annual", child: Text("Annual (12 months)")),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedSubscriptionType = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: "Subscription Type"),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (statusController.text.isEmpty ||
                    selectedSubscriptionType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Please enter a price and select a subscription type")),
                  );
                  return;
                }

                try {
                  // Convert entered price to number
                  int subscriptionPrice = int.parse(statusController.text);

                  // Get current date
                  DateTime now = DateTime.now();

                  // Calculate expiry date based on type
                  int durationDays = (selectedSubscriptionType == "semi-annual")
                      ? 180
                      : 365;
                  DateTime expiryDate = now.add(Duration(days: durationDays));

                  // Update Firestore with subscription details
                  await usersCollection.doc(userId).set({
                    'subscriptionType': selectedSubscriptionType,
                    'subscriptionPrice': subscriptionPrice,
                    'purchaseDate': Timestamp.fromDate(now),
                    'expiryDate': Timestamp.fromDate(expiryDate),
                  }, SetOptions(merge: true));

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Subscription Updated Successfully!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
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

  // Function to delete user
  void _deleteUser(String userId) async {
    try {
      await subscriptionsCollection.doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subscription Deleted Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Subscription Status"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: refreshData,
              icon: Icon(Icons.refresh_outlined, color: Colors.blue))
        ],
      ),
      body: StreamBuilder(
        stream: _subscriptionStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Subscription Listing"));
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
                        data['name'] ?? 'Unknown',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Text("User ID : ${data['userID'] ?? '....'}"),
                      Text("Phone : ${data['contact'] ?? '....'},"),
                      Text("Amount: ${data['SubscriptionAmt'] ?? '....'}"),
                      Text("Transaction Id : ${data['transectionId'] ?? '....'}"),
                      Divider(color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () =>
                                _editStatus(doc.id, data['subscriptionType']),
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