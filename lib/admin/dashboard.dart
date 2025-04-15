import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recent_listings_page.dart';
import 'approval_pending_page.dart';
import 'admin_user_list_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int totalproperties = 0;
  int totalUsers = 0;
  int totalAgents  =0;
  int totalTransactions =0;

  @override
  void initState(){
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async{
    try {
      // Fetch number of property
      QuerySnapshot propertySnapshot = await FirebaseFirestore.instance.collection('Property_posts').get();
      int propertyCount = propertySnapshot.size;

      // Fetch number of Users
      QuerySnapshot userSnapshot =  await FirebaseFirestore.instance.collection('Users').get();
      int userCount = userSnapshot.size;

      // Fetch number of Agents
      QuerySnapshot agentsSnapshot =  await FirebaseFirestore.instance.collection('Users').where('role', isEqualTo: 'agent').get();
      int agentsCount = agentsSnapshot.size;

      // Fetch number of Transactions
      QuerySnapshot transactionsSnapshot =  await FirebaseFirestore.instance.collection('Posts_for_approval').get();
      int transactionsCount = transactionsSnapshot.size;

      setState(() {
        totalproperties = propertyCount;
        totalUsers = userCount;
        totalAgents = agentsCount;
        totalTransactions = transactionsCount;
      });
    } catch (e) {
      print("Error fetching counts: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Admin Dashboard'),backgroundColor: Colors.white,scrolledUnderElevation: 0,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Overview Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OverviewCard(title: "Total Properties", value: "$totalproperties", icon: Icons.home_outlined),
                  OverviewCard(title: "Total Users", value: "$totalUsers", icon: Icons.people_outline),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OverviewCard(title: "Total Agents", value: "$totalAgents", icon: Icons.person_outline),
                  OverviewCard(title: "Transactions", value: "$totalTransactions", icon: Icons.attach_money_outlined),
                ],
              ),

              const SizedBox(height: 20),

              // Placeholder for Graphs/Analytics
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("Graphs & Analytics (Coming Soon)", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),

              // Recent Activity Section
              const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecentListingsPage()),
                  );
                },
              child: RecentActivityItem(
                title: "New Listing Added:",
                subtitle: "Tap to view details",
                icon: Icons.add_business,
              ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ApprovalPendingPage()),
                  );
                },
              child: RecentActivityItem(
                title: "Property Approval Pending",
                subtitle: "Tap to view details",
                icon: Icons.pending_actions,
              ),
              ),
          InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminUserListScreen()),
              );
            },
            child: RecentActivityItem(
                title: "Message from Client",
                subtitle: "Tap to view details",
                icon: Icons.message,
              ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

// Overview Card Widget
class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const OverviewCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
        shadowColor: Colors.blue,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// Recent Activity Item Widget
class RecentActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const RecentActivityItem({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
