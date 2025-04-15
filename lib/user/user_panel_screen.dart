import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'property_mngmt.dart';
import 'property_status.dart';
import 'user_chat_screen.dart';
import 'subscription_page.dart';

class UserPanelScreen extends StatefulWidget {
  const UserPanelScreen({super.key});

  @override
  State<UserPanelScreen> createState() => _UserPanelScreenState();
}

class _UserPanelScreenState extends State<UserPanelScreen> {

  // fetch
  double? semiAnnualPrice;
  double? annualPrice;
  bool _isLoading = true;// loding indicator

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionPrices();
  }

  // logic to fetch prices from table
  Future<void> _fetchSubscriptionPrices() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('AdminSettings')
          .doc('SubscriptionPrices')
          .get();

      if (doc.exists) {
        setState(() {
          semiAnnualPrice = doc['semiAnnualPrice'];
          annualPrice = doc['annualPrice'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching prices :$e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('USER PANEL',
        style: TextStyle(color: Colors.green),),backgroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 5),
            Divider(color: Colors.green),
            AdminPanelButton(
              title: 'Property Approval Status',
              icon: Icons.check_circle_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PropertyStatus()),
                );
              },
            ),
            const SizedBox(height: 12),
            AdminPanelButton(
              title: 'Property Management',
              icon: Icons.business_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PropertyMngmt()),
                );
              },
            ),
            const SizedBox(height: 12),
            AdminPanelButton(
              title: 'Messages to the admin',
              icon: Icons.message_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserChatScreen()),
                );
              },
            ),
            const SizedBox(height: 5),
            Divider(color: Colors.green),
            const SizedBox(height: 5),
            Text(
              "Subscription :",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.blue),
            ),
            Text("Semi-Annual Subscription", style: TextStyle(color: Colors.grey),),
            const SizedBox(height: 10),
            // Placeholder for Graphs/Analytics
            Container(
              padding: EdgeInsets.all(12),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.green.shade100, blurRadius: 5, spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Price (Top Section)
                  Text(
                    "₹ ${semiAnnualPrice ?? 'N/a'}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 5),

                  // Data & Validity (Middle Section)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Validity | 180 Days",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text("Unlock Access to: Posting | Renting | Buying",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                  Divider(color: Colors.blueGrey,),
                  Spacer(),

                  // Bottom Section (Horizontal Icons/Benefits)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.edit_note_outlined, color: Colors.blue.shade700, size: 22),
                      Icon(Icons.home_work_outlined, color: Colors.amber.shade700, size: 22),
                      Icon(Icons.real_estate_agent, color: Colors.teal.shade700, size: 22),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SubscriptionPage()),
                          );
                        },
                        child: Text("Activate Subscription >", style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text("Annual Subscription", style: TextStyle(color: Colors.grey),),
            const SizedBox(height: 10),
            // Placeholder for Graphs/Analytics
            Container(
              padding: EdgeInsets.all(12),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.green.shade100, blurRadius: 5, spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Price (Top Section)
                  Text(
                    "₹ ${annualPrice ?? 'N/a'}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 5),

                  // Data & Validity (Middle Section)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Validity | 365 Days",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text("Unlock Access to: Posting | Renting | Buying",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                  Divider(color: Colors.blueGrey,),
                  Spacer(),

                  // Bottom Section (Horizontal Icons/Benefits)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.edit_note_outlined, color: Colors.blue.shade700, size: 22),
                      Icon(Icons.home_work_outlined, color: Colors.amber.shade700, size: 22),
                      Icon(Icons.real_estate_agent, color: Colors.teal.shade700, size: 22),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SubscriptionPage()),
                          );
                        },
                        child: Text("Activate Subscription >", style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ),

                    ],
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
      )
    );
  }
}

class AdminPanelButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const AdminPanelButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          textStyle: const TextStyle(fontSize: 18),
          foregroundColor: Colors.green,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.green,width: 2)
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Aligns icon to the left
        children: [
          Icon(icon, size: 28, color: Colors.green,),
          const SizedBox(width: 15), // Space between icon and text
          Text(title, style: const TextStyle(color: Colors.green),),
        ],
      ),
    );
  }
}
