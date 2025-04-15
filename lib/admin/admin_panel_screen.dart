import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:real_estate/admin/property_management.dart';
import 'package:real_estate/admin/user_agent_management.dart';
import 'admin_user_list_screen.dart';
import 'Subscription_Mngmt.dart';
import 'subscription_amount_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('ADMIN PANEL',
      style: TextStyle(color: Colors.green),),backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPanelButton(
              title: 'Dashboard',
              icon: Icons.dashboard_outlined,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => Dashboard(),)
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
                    MaterialPageRoute(builder: (context) => PropertyManagement()),
                );
              },
            ),
            const SizedBox(height: 12),
            AdminPanelButton(
              title: 'User & Agent Management',
              icon: Icons.supervised_user_circle_outlined,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserAgentManagement()),
                );
              },
            ),
            const SizedBox(height: 12),
            AdminPanelButton(
              title: 'Subscription Management',
              icon: Icons.subscriptions_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionMngmt()),
                );
              },
            ),
            const SizedBox(height: 12),
            AdminPanelButton(
              title: 'Subscription Amount',
              icon: Icons.monetization_on_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionAmountScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            AdminPanelButton(
              title: 'Messages to the users',
              icon: Icons.message_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUserListScreen()),
                );
              },
            ),
          ],
        ),
      ),
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
