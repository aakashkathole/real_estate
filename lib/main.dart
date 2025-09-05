import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:real_estate/wrapper.dart';
import 'grid view/buy_screen.dart';
import 'grid view/rent_screen.dart';
import 'grid view/commercial_screen.dart';
import 'grid view/land_screen.dart';
import 'grid view/offices_screen.dart';
import 'grid view/farm_land_screen.dart';
import 'grid view/paying_guest_screen.dart';
import 'grid view/property_post_screen.dart';
import 'user_screen.dart';
import 'property_details_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'user/user_panel_screen.dart';

Future<bool> checkSubscriptionStatus(String userEmail) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .get();

    if (!userDoc.exists) {
      return false; // User document does not exist
    }

    // Allow admin to post properties without a subscription
    if (userEmail == "admin@gmail.com") {
      return true;
    }

    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null || !userData.containsKey('expiryDate')) {
      return false; // No subscription data found
    }

    Timestamp expireDate = userData['expiryDate'];
    return expireDate.toDate().isAfter(DateTime.now()); // True if subscription is active

  } catch (e) {
    print("Error checking subscription status: $e");
    return false; // Default to false in case of an error
  }
}


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wrapper(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;


  // Define different views/screens for each tab
  final List<Widget> _pages = [
    HomeView(),
    GridViewScreen(),
    SearchView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Real Estate'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.dashboard_customize_outlined),
            onPressed: () async {
              // Get current user
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                if (user.email == 'admin@gmail.com') {
                  // Navigate to Admin Dashboard
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminPanelScreen(),
                    ),
                  );
                } else {
                  // Navigate to User Dashboard
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPanelScreen(),
                    ),
                  );
                }
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate back to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),


      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.green,
        color: Colors.green,
        animationDuration: const Duration(milliseconds: 100),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;  // Update selected index
          });
        },
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),  // Home icon
          Icon(Icons.grid_view, size: 30, color: Colors.white),  // Grid View icon
          Icon(Icons.search, size: 30, color: Colors.white),  // Search icon
          Icon(Icons.person, size: 30, color: Colors.white),  // Person icon (Profile)
        ],
      ),
    );
  }
}

// Home View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Property_posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),
            );

          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No properties available"));
          }

          // Display properties in a ListView
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var property = snapshot.data!.docs[index];
              return _buildPropertyCard(context, property);
            },
          );
        },
      ),
      // post property floating button........................
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyPostScreen(category: 'Default'),
            ),
          );
        },
        label: Text("", style: TextStyle(color: Colors.black, fontSize: 16),),
        icon: Icon(Icons.add , color: Colors.white,),
        backgroundColor: Colors.green, // use transparent if you want
        elevation: 0,
      ),
    );
  }

  // Property Card UI
  Widget _buildPropertyCard(BuildContext context,QueryDocumentSnapshot property) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.green,width: 2)
      ),
      child: ListTile(
        title: Text(property['propertyType'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${property['lookingFor']} - ${property['propertyKind']} \nLocation: ${property['location']}"),
        trailing: Icon(Icons.arrow_forward),
        // Navigate to details screen
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

// Grid View Screen
class GridViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data for grid items (could be property categories or anything else)
    List<String> categories = ['Buy', 'Rent', 'Commercial', 'Land', 'Offices', 'Farm Land', 'PG']; // 'Post a Property'

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of items per row
            crossAxisSpacing: 10, // Horizontal spacing between items
            mainAxisSpacing: 10, // Vertical spacing between items
          ),
          itemCount: categories.length, // Number of items in the grid
          itemBuilder: (context, index) {
            // Navigate to the click screen
            return GestureDetector(
              onTap: () {
                // push buy screen on click
                if (categories[index] == 'Buy'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyScreen(category: categories[index]),
                    ),
                  );
                }
                // push Rent screen on click
                else if (categories[index] == 'Rent'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RentScreen(category: categories[index]),
                    ),
                  );
                }
                // push commercial screen on click
                else if (categories[index] == 'Commercial'){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommercialScreen(category: categories[index]),
                      ),
                  );
                }
                // push land screen on click
                else if (categories[index] == 'Land'){
                  Navigator.push(
                     context,
                      MaterialPageRoute(
                          builder: (context) => LandScreen(category: categories[index]),
                      ),
                  );
                }
                // push offices screen on click
                else if (categories[index] == 'Offices'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfficesScreen(category: categories[index]),
                    ),
                  );
                }
                // push farm land screen on click
                else if (categories[index] == 'Farm Land'){
                  Navigator.push(
                    context,
                      MaterialPageRoute(
                        builder: (context) => FarmLandScreen(category: categories[index]),
                      ),
                  );
                }
                // push pg screen on click
                else if (categories[index] == 'PG') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayingGuestScreen(category: categories[index]),
                    ),
                  );
                }
                // push post a property screen on click
                // else if (categories[index] == 'Post a Property') {
                //   String userEmail = FirebaseAuth.instance.currentUser!.email!;
                //
                //   checkSubscriptionStatus(userEmail).then((hasActiveSubscription){
                //     if (hasActiveSubscription) {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => PropertyPostScreen(category: categories[index]),
                //           ),
                //       );
                //     } else {
                //       showDialog(
                //         context: context,
                //         builder: (context) => AlertDialog(
                //           backgroundColor: Colors.white,
                //           title: Text("Subscription Required"),
                //           content: Text("Please purchase a subscription to post a property."),
                //           actions: [
                //             TextButton(
                //               onPressed: () => Navigator.push(
                //                   context,
                //               MaterialPageRoute(builder: (context) => UserPanelScreen())),
                //               style: ElevatedButton.styleFrom(
                //                 side: BorderSide(color: Colors.blue, width: 2),
                //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                //                 backgroundColor: Colors.white,
                //                 foregroundColor: Colors.black,
                //               ),
                //               child: Text("Activate Subscription"),
                //             ),
                //             TextButton(
                //               onPressed: () => Navigator.pop(context),
                //                 style: ElevatedButton.styleFrom(
                //                 side: BorderSide(color: Colors.blue, width: 2),
                //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                //                 backgroundColor: Colors.white,
                //                 foregroundColor: Colors.black,
                //                 ),
                //               child: Text("OK"),
                //             ),
                //           ],
                //         ),
                //       );
                //     }
                //   });
                // }
                },
              child: CategoryCard(label: categories[index], color: Colors.white), // Only one return for CategoryCard
            );
          },
        ),
      ),
      // post property floating button........................
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyPostScreen(category: 'Default'),
            ),
          );
        },
        label: Text("Post Property", style: TextStyle(color: Colors.white, fontSize: 16),),
        icon: Icon(Icons.add , color: Colors.white,),
        backgroundColor: Colors.green, // use transparent if you want
        elevation: 0,
      ),
    );
  }
}

// Custom widget to display each grid item
class CategoryCard extends StatelessWidget {
  final String label;
  final Color color;

  CategoryCard({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white60,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}


// Search View
class SearchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SearchSection(), // Use a StatefulWidget for search functionality
    );
  }
}
class SearchSection extends StatefulWidget {
  @override
  _SearchSectionState createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Search Bar
            TextField(
              controller: searchController,
              textCapitalization: TextCapitalization.characters, // auto upper case on mob keyboard
              decoration: InputDecoration(
                hintText: "Enter district name...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      searchQuery = "";
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toUpperCase().trim(); // convert to upper
                  searchController.value = TextEditingValue(text: searchQuery,
                  selection: TextSelection.collapsed(offset: searchQuery.length),
                  );
                });
              },
            ),

            SizedBox(height: 20),

            // 🔹 Property List based on search query
            Expanded(child: PropertyList(searchQuery: searchQuery)),
          ],
        ),
      ),
    );
  }
}

// 🔹 Widget to Fetch and Display Properties Based on Search Query
class PropertyList extends StatelessWidget {
  final String searchQuery;

  PropertyList({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: searchQuery.isEmpty
          ? null // wait for search
          : FirebaseFirestore.instance
          .collection("Property_posts")
          .where("district", isGreaterThanOrEqualTo: searchQuery)
          .where("district", isLessThan: searchQuery + 'z') // Firestore text filtering
          .snapshots(),
      builder: (context, snapshot) {
        if (searchQuery.isEmpty) {
          return Center(child: Text("Search for properties by district"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No properties found in '$searchQuery'"));
        }

        var properties = snapshot.data!.docs;

        return ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            var data = properties[index].data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green,width: 2),
              ),
              child: ListTile(
                title: Text(data["propertyType"] ?? "Unknown Property"),
                subtitle: Text("Located in: ${data["location"]}"),
                trailing: Text(data["lookingFor"] ?? ""),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PropertyDetailsScreen(property: properties[index]),
                      ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// Profile View
class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserScreen()),
      );
    });

    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Temporary UI before navigation
    );
  }
}

