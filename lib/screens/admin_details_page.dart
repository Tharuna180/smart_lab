import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_home_page.dart';

class AdminDetailsPage extends StatefulWidget {
  const AdminDetailsPage({super.key});

  @override
  State<AdminDetailsPage> createState() => _AdminDetailsPageState();
}

class _AdminDetailsPageState extends State<AdminDetailsPage> {
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final designationController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;

  Future<void> saveAdminDetails() async {
    // 🛑 BASIC VALIDATION
    if (nameController.text.isEmpty ||
        deptController.text.isEmpty ||
        designationController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      await FirebaseFirestore.instance.collection("admins").doc(uid).set({
        "name": nameController.text.trim(),
        "department": deptController.text.trim(),
        "designation": designationController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": user.email,
        "role": "admin",
        "createdAt": Timestamp.now(),
      });

      // ✅ SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Admin profile created")),
      );

      // 🚀 GO TO ADMIN HOME & REMOVE BACK STACK
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Admin Details"),
        centerTitle: true,
        automaticallyImplyLeading: false, // ❌ NO BACK BUTTON
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Complete Admin Profile",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter basic information to manage labs",
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              _inputField(
                label: "Full Name",
                icon: Icons.person_outline,
                controller: nameController,
              ),

              _inputField(
                label: "Department",
                icon: Icons.apartment_outlined,
                controller: deptController,
              ),

              _inputField(
                label: "Designation",
                icon: Icons.work_outline,
                controller: designationController,
              ),

              _inputField(
                label: "Phone Number",
                icon: Icons.phone_outlined,
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 30),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: saveAdminDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Save & Continue",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
