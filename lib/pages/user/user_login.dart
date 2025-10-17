import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_login.dart';
import 'user_homepage.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          height: 130,
          color: const Color(0xFF125E77),
          child: Padding(
            padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Welcome to TravelEase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
                Container(
                  width: 67,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF348AA7),
                  ),
                  child: const Icon(
                    Icons.airplanemode_active,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),
          
          // Transparent overlay
          Positioned(
            top: 0, // Start from top since AppBar handles the banner
            left: 6,
            right: 6,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 217, 217, 217).withOpacity(0.75),
              ),
            ),
          ),

            // Back Button
            Positioned(
            top: 50, // Reduced gap - was 180 - 48, now properly positioned
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
              ),
            ),
            ),
          
          // Main Login Card
          Positioned(
            top: 125, // Reduced gap - was 255 - 48, now properly positioned
            left: 30,
            right: 30,
            child: Container(
              height: 514,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Title
                    const Text(
                      'User Login',
                      style: TextStyle(
                        color: Color(0xFF125E77),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Email Address Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            color: Color(0xFF125E77),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Kumbh Sans',
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Password Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Color(0xFF125E77),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '',
                              hintStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Kumbh Sans',
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Login Button
                    SizedBox(
                      width: 235,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleLogin(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF348AA7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Admin Login Link
                    TextButton(
                      onPressed: () {
                        // Handle admin login
                        _handleAdminLogin();
                      },
                      child: const Text(
                        'Login as Admin/Master',
                        style: TextStyle(
                          color: Color(0xFF348AA7),
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Kumbh Sans',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  void _handleLogin() {
    // Validate input
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter your password');
      return;
    }
    
    // Basic email validation
    if (!_emailController.text.contains('@')) {
      _showSnackBar('Please enter a valid email address');
      return;
    }

    final invalidChars = ['>', '<', '(', ')', '{', '}', '[', ']', ';'];
    if (invalidChars.any((char) => _emailController.text.contains(char))) {
      _showSnackBar('Email contains invalid characters');
      return;
    }

    _performFirebaseLogin();
  }

  Future<void> _performFirebaseLogin() async {
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      
      // Sign in user
      final userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if user profile exists in Firestore, create if not
      if (userCredential.user != null) {
        final userDoc = await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create profile for existing auth users who don't have a Firestore profile yet
          await firestore.collection('users').doc(userCredential.user!.uid).set({
            'fullName': userCredential.user!.displayName ?? '',
            'email': userCredential.user!.email ?? _emailController.text.trim(),
            'phoneNumber': '',
            'address': '',
            'passportNumber': '',
            'passportExpiration': '',
            'visaNumber': '',
            'insuranceProvider': '',
            'emergencyContact': '',
            'preferredAirport': '',
            'preferredLanguages': '',
            'twoFactorEnabled': false,
            'dataProcessingConsent': false,
            'profileImageUrl': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      _showSnackBar('Login successful!');
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserHomePage()));
      }
    } on FirebaseAuthException catch (e) {
      var message = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginPage()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}