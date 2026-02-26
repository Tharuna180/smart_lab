import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_home_page.dart';

class StudentDetailsPage extends StatefulWidget {
  const StudentDetailsPage({super.key});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final deptController = TextEditingController();
  final classController = TextEditingController();
  final sectionController = TextEditingController();

  bool isLoading = false;

  Future<void> saveDetails() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;

    await FirebaseFirestore.instance.collection("students").doc(uid).set({
      "name": nameController.text.trim(),
      "rollNo": rollController.text.trim(),
      "department": deptController.text.trim(),
      "class": classController.text.trim(),
      "section": sectionController.text.trim(),
      "email": user.email,
      "createdAt": Timestamp.now(),
    });

    // 🔁 After first-time save → HOME
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const StudentHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Student Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Complete Your Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This information helps us personalize your experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                _inputField(
                  label: "Full Name",
                  controller: nameController,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                _inputField(
                  label: "Roll Number",
                  controller: rollController,
                  icon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: 16),

                _inputField(
                  label: "Department",
                  controller: deptController,
                  icon: Icons.apartment_outlined,
                ),
                const SizedBox(height: 16),

                _inputField(
                  label: "Class",
                  controller: classController,
                  icon: Icons.class_outlined,
                ),
                const SizedBox(height: 16),

                _inputField(
                  label: "Section",
                  controller: sectionController,
                  icon: Icons.group_outlined,
                ),

                const SizedBox(height: 30),

                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: saveDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}