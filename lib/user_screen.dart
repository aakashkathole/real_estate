import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'register_now.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<bool> _onWillPop() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()), // Ensure MyApp is correctly implemented.
          (route) => false, // Clears all previous routes from the stack.
    );
    return false; // Prevents default back navigation.
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Sign In Page"),
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
                // Navigate back to login screen
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                const CircleAvatar(
                  radius: 70,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, size: 100),
                ),
                const SizedBox(height: 40),
                UiHelper.customTextField(emailController, "Email", false, const Icon(Icons.mail)),
                const SizedBox(height: 20),
                UiHelper.customTextField(passwordController, "Password", true, const Icon(Icons.lock)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: (()=>signIn()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green,width: 2),
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                  ),
                  child: const Text("Sign In", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 10,),

                const SizedBox(height: 20),
                Text("Not a member? Register now."),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterNowScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green,width: 2),
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  ),
                  child: const Text("Register now", style: TextStyle(fontSize: 20)),
                ),

                // exit button
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop(); // Closes the app
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green,width: 2),
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  ),
                  child: Text("Exit App", style: TextStyle(fontSize: 20),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Ensure UiHelper is properly defined
class UiHelper {
  static Widget customTextField(TextEditingController controller, String hint, bool isObscure, Icon prefixIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}