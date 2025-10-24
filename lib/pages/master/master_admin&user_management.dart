import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../utils/master_app_drawer.dart';

class MasterAdminUserManagement extends StatefulWidget {
  const MasterAdminUserManagement({super.key});

  @override
  State<MasterAdminUserManagement> createState() => _MasterAdminUserManagementState();
}

class _MasterAdminUserManagementState extends State<MasterAdminUserManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'users'; // 'users' or 'admins'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MasterAppDrawer(),
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
                // Menu Button (opens drawer)
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
                const Text(
                  'User Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
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
                // Tab Selector
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
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = 'users'),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'users'
                                  ? const Color(0xFF348AA7)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  color: _selectedTab == 'users'
                                      ? Colors.white
                                      : const Color(0xFF348AA7),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Users',
                                  style: TextStyle(
                                    color: _selectedTab == 'users'
                                        ? Colors.white
                                        : const Color(0xFF348AA7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Kumbh Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = 'admins'),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'admins'
                                  ? const Color(0xFF348AA7)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  color: _selectedTab == 'admins'
                                      ? Colors.white
                                      : const Color(0xFF348AA7),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Admins',
                                  style: TextStyle(
                                    color: _selectedTab == 'admins'
                                        ? Colors.white
                                        : const Color(0xFF348AA7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Kumbh Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                      hintText: _selectedTab == 'users'
                          ? 'Search users by name or email...'
                          : 'Search admins by name or email...',
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

                // Display selected tab content
                if (_selectedTab == 'users') _buildUsersList() else _buildAdminsList(),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .orderBy('fullName')
          .snapshots(),
      builder: (context, snapshot) {
        return _buildList(
          snapshot: snapshot,
          title: 'User List',
          icon: Icons.people,
          emptyMessage: 'No users found',
          emptySubMessage: 'Users will appear here once registered',
          role: 'user',
        );
      },
    );
  }

  Widget _buildAdminsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .orderBy('fullName')
          .snapshots(),
      builder: (context, snapshot) {
        return _buildList(
          snapshot: snapshot,
          title: 'Admin List',
          icon: Icons.admin_panel_settings,
          emptyMessage: 'No admins found',
          emptySubMessage: 'Admins will appear here once created',
          role: 'admin',
        );
      },
    );
  }

  Widget _buildList({
    required AsyncSnapshot<QuerySnapshot> snapshot,
    required String title,
    required IconData icon,
    required String emptyMessage,
    required String emptySubMessage,
    required String role,
  }) {
    return Container(
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
                child: Icon(
                  icon,
                  color: const Color(0xFF125E77),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF125E77),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kumbh Sans',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF348AA7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${snapshot.hasData ? snapshot.data!.docs.length : 0} ${role == 'user' ? (snapshot.hasData && snapshot.data!.docs.length == 1 ? 'user' : 'users') : (snapshot.hasData && snapshot.data!.docs.length == 1 ? 'admin' : 'admins')}',
                  style: const TextStyle(
                    color: Color(0xFF348AA7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Add Button
              IconButton(
                onPressed: () => _showAddDialog(role),
                icon: const Icon(Icons.add_circle, color: Color(0xFF348AA7)),
                tooltip: 'Add ${role == 'user' ? 'User' : 'Admin'}',
                iconSize: 28,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // List content
          Builder(
            builder: (context) {
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
                        'Error loading $role${role == 'user' ? 's' : 's'}',
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
                        role == 'user' ? Icons.person_outline : Icons.admin_panel_settings_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontFamily: 'Kumbh Sans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emptySubMessage,
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

              // Filter based on search query
              final filteredDocs = snapshot.data!.docs.where((doc) {
                if (_searchQuery.isEmpty) return true;
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['fullName'] ?? '').toString().toLowerCase();
                final email = (data['email'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery) || email.contains(_searchQuery);
              }).toList();

              if (filteredDocs.isEmpty) {
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
                        'No ${role}s match your search',
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
                children: filteredDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final userId = doc.id;
                  final name = data['fullName'] ?? 'Unknown ${role.capitalize()}';
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
                                    name.isNotEmpty ? name[0].toUpperCase() : role[0].toUpperCase(),
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
                        // User/Admin Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Kumbh Sans',
                                        color: Color(0xFF125E77),
                                      ),
                                    ),
                                  ),
                                  if (role == 'admin')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFA500).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ADMIN',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFA500),
                                          fontFamily: 'Kumbh Sans',
                                        ),
                                      ),
                                    ),
                                ],
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
                          onPressed: () => _showEditDialog(userId, name, role, data),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF348AA7),
                            size: 24,
                          ),
                          tooltip: 'Edit ${role}',
                        ),
                        // Delete Button
                        IconButton(
                          onPressed: () => _showDeleteDialog(userId, name, role),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFA54547),
                            size: 24,
                          ),
                          tooltip: 'Delete ${role}',
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
    );
  }

  void _showAddDialog(String role) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add New ${role.capitalize()}',
            style: const TextStyle(
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
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF348AA7)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF348AA7),
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Kumbh Sans'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Color(0xFF34C759), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Account will be created with Firebase Auth & Firestore',
                            style: const TextStyle(
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
                  await _addAccount(
                    nameController.text.trim(),
                    emailController.text.trim(),
                    passwordController.text.trim(),
                    phoneController.text.trim(),
                    addressController.text.trim(),
                    role,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF348AA7),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Add ${role.capitalize()}',
                style: const TextStyle(
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

  Future<void> _addAccount(String name, String email, String password, String phone, String address, String role) async {
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
        'role': role,
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        final data = result.data;
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? '${role.capitalize()} "$name" created successfully',
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
        
        String errorMessage = 'Error creating ${role}: ${e.toString()}';
        
        // Extract user-friendly error message
        if (e.toString().contains('Email already registered')) {
          errorMessage = 'This email is already registered';
        } else if (e.toString().contains('Invalid email')) {
          errorMessage = 'Invalid email format';
        } else if (e.toString().contains('Password must be at least 6 characters')) {
          errorMessage = 'Password must be at least 6 characters';
        } else if (e.toString().contains('Permission denied')) {
          errorMessage = 'Permission denied: Master role required';
        } else if (e.toString().contains('Authentication required')) {
          errorMessage = 'Please log in again';
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

  void _showEditDialog(String userId, String userName, String role, Map<String, dynamic> userData) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: userData['fullName'] ?? '');
    final emailController = TextEditingController(text: userData['email'] ?? '');
    final phoneController = TextEditingController(text: userData['phoneNumber'] ?? '');
    final addressController = TextEditingController(text: userData['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit ${role.capitalize()}',
          style: const TextStyle(
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
                await _updateAccount(
                  userId,
                  nameController.text.trim(),
                  emailController.text.trim(),
                  phoneController.text.trim(),
                  addressController.text.trim(),
                  role,
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

  Future<void> _updateAccount(String userId, String name, String email, String phone, String address, String role) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF348AA7)),
        ),
      );

      // Update user/admin document in Firestore
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
              '${role.capitalize()} "$name" updated successfully',
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
              'Error updating ${role}: $e',
              style: const TextStyle(fontFamily: 'Kumbh Sans'),
            ),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(String userId, String userName, String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete ${role.capitalize()}',
          style: const TextStyle(
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
              await _deleteAccount(userId, userName, role);
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

  Future<void> _deleteAccount(String userId, String userName, String role) async {
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
                data['message'] ?? '${role.capitalize()} "$userName" deleted successfully',
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
        
        String errorMessage = 'Error deleting ${role}: ${e.toString()}';
        
        // Extract user-friendly error message
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'You do not have permission to delete this ${role}';
        } else if (e.toString().contains('User not found')) {
          errorMessage = '${role.capitalize()} not found';
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
