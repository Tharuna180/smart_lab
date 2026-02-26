import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_home_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final deptController = TextEditingController();
  final roleController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminDetails();
  }

  Future<void> fetchAdminDetails() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection("admins").doc(uid).get();

    if (doc.exists) {
      nameController.text = doc["name"];
      emailController.text = doc["email"];
      deptController.text = doc["department"];
      roleController.text = doc["role"];
      phoneController.text = doc["phone"];
    }

    setState(() => loading = false);
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: false, // 🔒 Admin profile is READ-ONLY
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomePage()),
            );
          },
        ),
        title: const Text(
          "Admin Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                nameController.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              _field(
                label: "Name",
                controller: nameController,
                icon: Icons.person_outline,
              ),
              _field(
                label: "Email",
                controller: emailController,
                icon: Icons.email_outlined,
              ),
              _field(
                label: "Department",
                controller: deptController,
                icon: Icons.apartment_outlined,
              ),
              _field(
                label: "Role",
                controller: roleController,
                icon: Icons.badge_outlined,
              ),
              _field(
                label: "Phone",
                controller: phoneController,
                icon: Icons.phone_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
