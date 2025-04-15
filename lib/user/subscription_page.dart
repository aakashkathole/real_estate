import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userEmail;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });

      try {
        DocumentSnapshot userDoc =
        await _firestore.collection("Users").doc(user.email).get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void activateSubscription() {
    TextEditingController amountController = TextEditingController();
    TextEditingController transactionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Enter Subscription Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                controller: amountController,
                decoration: const InputDecoration(labelText: "Subscription Amount"),
              ),
              TextField(
                controller: transactionController,
                decoration: const InputDecoration(labelText: "Transaction ID"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Show a message when canceling
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Action canceled!"),
                    backgroundColor: Colors.red, // Red color for cancellation
                    duration: Duration(milliseconds: 30),
                  ),
                );
              },
              style: TextButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String amount = amountController.text.trim();
                String transactionId = transactionController.text.trim();

                // Input Validate
                if (amount.isEmpty || transactionId.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter all details"),
                      backgroundColor: Colors.orangeAccent,
                      duration: Duration(milliseconds: 30),
                    ),
                  );
                  return;
                }
                if (userData == null || userEmail == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User data not loded. Try again."),
                    backgroundColor: Colors.red,
                    duration: Duration(milliseconds: 60),
                    ),
                  );
                  return;
                }

                // Storing data in DB
                await _firestore.collection("Subscriptions").doc(userEmail).set({
                  "userID": userEmail,
                  "name": userData?['name'] ?? 'N/A',
                  "contact": userData?['phone'] ?? 'N/A',
                  "SubscriptionAmt": amount,
                  "transectionId": transactionId,
                  "timestamp": FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
                // Show Success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Subscription activated successfully!"),
                    backgroundColor: Colors.green, // Red color for cancellation
                    duration: Duration(milliseconds: 60),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Activate"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Activate Subscription"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(child: Text("Error loading user details."))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(color: Colors.green),
              const SizedBox(height: 10.0),

              // User Details Section
              const Text(
                "User Details:",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5.0),
              Text("Logged-in User ID: $userEmail",
                  style: const TextStyle(fontSize: 18)),
              Text("Full Name: ${userData!['name'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 18)),
              Text("Phone: ${userData!['phone'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 5.0),
              const Divider(color: Colors.green),
              const SizedBox(height: 10.0),

              // Subscription Activation Steps
              const Text(
                "How to Activate Subscription:",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5.0),
              const Text(
                "1. Choose a subscription plan from the available options.\n"
                    "2. Complete the payment using the provided QR code or UPI ID.\n"
                    "3. Enter the subscription amount & transaction ID.\n"
                    "4. Click on 'Activate Subscription'.\n"
                    "5. Your subscription will be activated within 2 to 3 working hours.",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20.0),

              // QR Code Section
              Column(
                children: [
                  const Text(
                    "Scan QR to Pay",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Image.asset(
                      "assets/gpay_qr.jpeg",
                      width: 400,
                      height: 400,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Subscription Activation Button
              ElevatedButton(
                onPressed: activateSubscription,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Activate Subscription",
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
