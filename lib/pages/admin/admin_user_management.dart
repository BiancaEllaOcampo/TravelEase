import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../utils/admin_app_drawer.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminAppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          height: 130,
          color: const Color(0xFF125E77),
          child: Padding(
            padding: const EdgeInsets.only(top: 48, left: 22, right: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu Button
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: Color(0xFFF3F3F3),
                        size: 50,
                      ),
                    );
                  },
                ),
                // Title
                const Flexible(
                  child: Text(
                    'User Management',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
                // Logo
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFD9D9D9),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: 'Kumbh Sans',
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF348AA7),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF348AA7)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),

                // User List Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF125E77).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.people,
                              color: Color(0xFF125E77),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'User List',
                            style: TextStyle(
                              color: Color(0xFF125E77),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kumbh Sans',
                            ),
                          ),
                          const Spacer(),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('role', isEqualTo: 'user')
                                .snapshots(),
                            builder: (context, snapshot) {
                              final userCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF348AA7).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$userCount ${userCount == 1 ? 'user' : 'users'}',
                                  style: const TextStyle(
                                    color: Color(0xFF348AA7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Kumbh Sans',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          // Add User Button
                          IconButton(
                            onPressed: () => _showAddUserDialog(),
                            icon: const Icon(Icons.add_circle, color: Color(0xFF348AA7)),
                            tooltip: 'Add User',
                            iconSize: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // User list with real-time data
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'user')
                            .orderBy('fullName')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF348AA7),
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading users',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF348AA7).withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No users found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Users will appear here once registered',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Filter users based on search query
                          final users = snapshot.data!.docs.where((doc) {
                            if (_searchQuery.isEmpty) return true;
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['fullName'] ?? '').toString().toLowerCase();
                            final email = (data['email'] ?? '').toString().toLowerCase();
                            return name.contains(_searchQuery) || email.contains(_searchQuery);
                          }).toList();

                          if (users.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF348AA7).withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No users match your search',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search term',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: users.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final userId = doc.id;
                              final name = data['fullName'] ?? 'Unknown User';
                              final email = data['email'] ?? 'No email';
                              final profileImageUrl = data['profileImageUrl'];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF348AA7).withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Profile Image
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: profileImageUrl == null
                                            ? const LinearGradient(
                                                colors: [Color(0xFF348AA7), Color(0xFF125E77)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        image: profileImageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(profileImageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: profileImageUrl == null
                                          ? Center(
                                              child: Text(
                                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Kumbh Sans',
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    // User Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Kumbh Sans',
                                              color: Color(0xFF125E77),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.email_outlined,
                                                size: 14,
                                                color: Color(0xFF348AA7),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  email,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontFamily: 'Kumbh Sans',
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Edit Button
                                    IconButton(
                                      onPressed: () => _showEditUserDialog(userId, data),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF348AA7),
                                        size: 24,
                                      ),
                                      tooltip: 'Edit user',
                                    ),
                                    // Delete Button
                                    IconButton(
                                      onPressed: () => _showDeleteUserDialog(userId, name),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Color(0xFFA54547),
                                        size: 24,
                                      ),
                                      tooltip: 'Delete user',
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons - Removed (admins can only delete individual users)
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteUserDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete User',
          style: TextStyle(
            fontFamily: 'Kumbh Sans',
            fontWeight: FontWeight.bold,
            color: Color(0xFF125E77),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$userName"? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Kumbh Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                color: Color(0xFF348AA7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(userId, userName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA54547),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String userId, String userName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF348AA7)),
        ),
      );

      // Call Cloud Function to delete Firebase Auth + Firestore account
      // Must specify region where function is deployed (us-central1)
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('deleteAccount');
      
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        final data = result.data;
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'User "$userName" deleted successfully',
                style: const TextStyle(fontFamily: 'Kumbh Sans'),
              ),
              backgroundColor: const Color(0xFF34C759),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        String errorMessage = 'Error deleting user: ${e.toString()}';
        
        // Extract user-friendly error message
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'You do not have permission to delete this user';
        } else if (e.toString().contains('User not found')) {
          errorMessage = 'User not found';
        } else if (e.toString().contains('Cannot delete your own account')) {
          errorMessage = 'You cannot delete your own account';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(fontFamily: 'Kumbh Sans'),
            ),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Add New User',
            style: TextStyle(
              fontFamily: 'Kumbh Sans',
              fontWeight: FontWeight.bold,
              color: Color(0xFF125E77),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Color(0xFF348AA7)),
                    ),
                    style: const TextStyle(fontFamily: 'Kumbh Sans'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Color(0xFF348AA7)),
                    ),
                    style: const TextStyle(fontFamily: 'Kumbh Sans'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF348AA7)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF348AA7),
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Kumbh Sans'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone, color: Color(0xFF348AA7)),
                    ),
                    style: const TextStyle(fontFamily: 'Kumbh Sans'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on, color: Color(0xFF348AA7)),
                    ),
                    style: const TextStyle(fontFamily: 'Kumbh Sans'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF34C759)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Color(0xFF34C759), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Account will be created with Firebase Auth & Firestore',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Kumbh Sans',
                              color: Color(0xFF34C759),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                emailController.dispose();
                passwordController.dispose();
                phoneController.dispose();
                addressController.dispose();
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Kumbh Sans',
                  color: Color(0xFF348AA7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await _addUser(
                    nameController.text.trim(),
                    emailController.text.trim(),
                    passwordController.text,
                    phoneController.text.trim(),
                    addressController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF348AA7),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Add User',
                style: TextStyle(
                  fontFamily: 'Kumbh Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addUser(String name, String email, String password, String phone, String address) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF348AA7)),
        ),
      );

      // Call Cloud Function to create Firebase Auth + Firestore account
      // Must specify region where function is deployed (us-central1)
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('createAccount');
      
      final result = await callable.call<Map<String, dynamic>>({
        'email': email,
        'password': password,
        'fullName': name,
        'phoneNumber': phone.isNotEmpty ? phone : null,
        'address': address.isNotEmpty ? address : null,
        'role': 'user',
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        final data = result.data;
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'User "$name" created successfully',
                style: const TextStyle(fontFamily: 'Kumbh Sans'),
              ),
              backgroundColor: const Color(0xFF34C759),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        String errorMessage = 'Error creating user: ${e.toString()}';
        
        // Extract user-friendly error message
        if (e.toString().contains('auth/email-already-exists')) {
          errorMessage = 'Email already in use';
        } else if (e.toString().contains('auth/invalid-email')) {
          errorMessage = 'Invalid email format';
        } else if (e.toString().contains('auth/weak-password')) {
          errorMessage = 'Password is too weak';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = 'You do not have permission to create users';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(fontFamily: 'Kumbh Sans'),
            ),
            backgroundColor: const Color(0xFFA54547),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showEditUserDialog(String userId, Map<String, dynamic> userData) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: userData['fullName'] ?? '');
    final emailController = TextEditingController(text: userData['email'] ?? '');
    final phoneController = TextEditingController(text: userData['phoneNumber'] ?? '');
    final addressController = TextEditingController(text: userData['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit User',
          style: TextStyle(
            fontFamily: 'Kumbh Sans',
            fontWeight: FontWeight.bold,
            color: Color(0xFF125E77),
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF348AA7)),
                  ),
                  style: const TextStyle(fontFamily: 'Kumbh Sans'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF348AA7)),
                  ),
                  style: const TextStyle(fontFamily: 'Kumbh Sans'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF348AA7)),
                  ),
                  style: const TextStyle(fontFamily: 'Kumbh Sans'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on, color: Color(0xFF348AA7)),
                  ),
                  style: const TextStyle(fontFamily: 'Kumbh Sans'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.dispose();
              emailController.dispose();
              phoneController.dispose();
              addressController.dispose();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                color: Color(0xFF348AA7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _updateUser(
                  userId,
                  nameController.text.trim(),
                  emailController.text.trim(),
                  phoneController.text.trim(),
                  addressController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF348AA7),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser(String userId, String name, String email, String phone, String address) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF348AA7)),
        ),
      );

      // Update user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fullName': name,
        'email': email,
        'phoneNumber': phone.isNotEmpty ? phone : null,
        'address': address.isNotEmpty ? address : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User "$name" updated successfully',
              style: const TextStyle(fontFamily: 'Kumbh Sans'),
            ),
            backgroundColor: const Color(0xFF34C759),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating user: $e',
              style: const TextStyle(fontFamily: 'Kumbh Sans'),
            ),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }
}