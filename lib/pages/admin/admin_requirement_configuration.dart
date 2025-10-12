import 'package:flutter/material.dart';

class AdminReqConfigPage extends StatefulWidget {
  const AdminReqConfigPage({Key? key}) : super(key: key);

  @override
  State<AdminReqConfigPage> createState() => _AdminReqConfigPageState();
}

class _AdminReqConfigPageState extends State<AdminReqConfigPage> {
  String selectedCountry = 'Japan';
  final List<Map<String, dynamic>> requirements = [
    {'title': 'Passport', 'status': true},
    {'title': 'Visa', 'status': false},
    {'title': 'Travel Insurance', 'status': true},
    {'title': 'Return Ticket', 'status': false},
    {'title': 'Hotel Booking', 'status': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFD9D9D9)),
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 110,
            child: Container(
              color: const Color(0xFF125E77),
              child: Padding(
                padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                    ),
                    const Text(
                      'Travel Requirements\nConfiguration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF348AA7),
                      ),
                      child: const Icon(
                        Icons.airplanemode_active,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            bottom: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedCountry,
                        items: const [
                          DropdownMenuItem(value: 'Japan', child: Text('Japan')),
                          DropdownMenuItem(value: 'USA', child: Text('USA')),
                          DropdownMenuItem(value: 'France', child: Text('France')),
                          DropdownMenuItem(value: 'Poland', child: Text('Poland')),
                          DropdownMenuItem(value: 'Germany', child: Text('Germany')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...requirements.map((req) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: IntrinsicHeight(
                        child: Container(
                          // Remove fixed height, let content dictate height
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        req['title'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Kumbh Sans',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 70,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF348AA7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Sample',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Kumbh Sans',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: req['status']
                                        ? const Color(0xFF43B049)
                                        : const Color(0xFFA54547),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      req['status'] ? 'Ready' : 'Not Ready',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Kumbh Sans',
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF125E77),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add Requirement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF125E77),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Remove Requirement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF125E77),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Configuration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
