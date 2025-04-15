import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterNowScreen extends StatefulWidget {
  @override
  _RegisterNowScreenState createState() => _RegisterNowScreenState();
}

class _RegisterNowScreenState extends State<RegisterNowScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Register user with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Determine user role: Admin or User
        String role = 'user';

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('Users').doc(emailController.text.trim()).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'role': role, // Store user role
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Successful!")),
        );

        // Clear form after successful registration
        _formKey.currentState!.reset();
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Now'), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _buildTextField('Full Name', nameController),
                SizedBox(height: 10),
                _buildTextField('Email', emailController, isEmail: true),
                SizedBox(height: 10),
                _buildTextField('Phone Number', phoneController, isPhone: true),
                SizedBox(height: 10),
                _buildTextField('Password', passwordController, isPassword: true),
                _buildTextField('Confirm Password', confirmPasswordController, isPassword: true),
                SizedBox(height: 35),
                Divider(color: Colors.green),
                SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Register'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Divider(color: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isEmail = false, bool isPhone = false, bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : isPhone ? TextInputType.phone : TextInputType.text,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) return 'Enter a valid email';
          if (isPhone && !RegExp(r"^[0-9]{10}$").hasMatch(value)) return 'Enter a valid phone number';
          if (isPassword && value.length < 6) return 'Password must be at least 6 characters';
          if (label == 'Confirm Password' && value != passwordController.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }
}
