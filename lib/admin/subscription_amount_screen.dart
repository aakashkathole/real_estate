import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubscriptionAmountScreen extends StatefulWidget {
  const SubscriptionAmountScreen({super.key});

  @override
  State<SubscriptionAmountScreen> createState() => _SubscriptionAmountScreenState();
}

class _SubscriptionAmountScreenState extends State<SubscriptionAmountScreen> {
  final TextEditingController _semiAnnualController = TextEditingController();
  final TextEditingController _annualController = TextEditingController();

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

  // update prices logic
  Future<void> _updateSubscriptionPrices() async {
    try {
      final double? semiAnnualPrice = double.tryParse(_semiAnnualController.text);
      final double? annualPrice = double.tryParse(_annualController.text);

      if (semiAnnualPrice == null || annualPrice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter both subscription prices")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('AdminSettings').doc('SubscriptionPrices').set({
        'semiAnnualPrice': semiAnnualPrice,
        'annualPrice': annualPrice,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subscription prices updated successfully")),
      );

     // Clear input fields after submission
      _semiAnnualController.clear();
      _annualController.clear();

      _fetchSubscriptionPrices(); // Refresh the page after update

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating prices: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Manage Subscription Prices",),
        backgroundColor: Colors.white,
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: Colors.blue,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current Subscription Prices :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    Divider(color: Colors.green),
                    _isLoading
                    ? const Center(child: CircularProgressIndicator()) // show loader
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Semi-Annual Subscription : ₹ ${semiAnnualPrice ?? 'N/a'}"),
                        const SizedBox(height: 8,),
                        Text("Annual Subscription : ₹ ${annualPrice ?? 'N/a'}"),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height:16,),
            TextField(
              controller: _semiAnnualController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Semi-Annual Subscription Price"),
            ),
            SizedBox(height: 16,),
            TextField(
              controller: _annualController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Annual Subscription Price"),
            ),
            SizedBox(height: 30,),
            Center( child:
            SizedBox(
              width: 200.0,
              height: 50.0,
              child: ElevatedButton(
                  onPressed: _updateSubscriptionPrices,
                  child: const Text("Update Prices",
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),

                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.blue, width: 1),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
              ),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
